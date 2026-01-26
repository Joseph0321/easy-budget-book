import express from 'express';
import cors from 'cors';
import multer from 'multer';
import Anthropic from '@anthropic-ai/sdk';

const app = express();
const upload = multer({ storage: multer.memoryStorage() });

app.use(cors());
app.use(express.json());

const useOwnKey = !!process.env.ANTHROPIC_API_KEY;
const anthropic = new Anthropic({
  apiKey: useOwnKey ? process.env.ANTHROPIC_API_KEY : process.env.AI_INTEGRATIONS_ANTHROPIC_API_KEY,
  baseURL: useOwnKey ? 'https://api.anthropic.com' : process.env.AI_INTEGRATIONS_ANTHROPIC_BASE_URL
});

app.post('/api/scan-receipt', upload.single('receipt'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const categoriesJson = req.body.categories;
    let categories = [];
    if (categoriesJson) {
      try {
        categories = JSON.parse(categoriesJson);
      } catch (e) {
        console.log('Failed to parse categories:', e);
      }
    }

    const expenseCategories = categories.filter(c => c.type === 'EXPENSE' || c.type === 'expense');
    console.log('Received categories:', categories.length, 'Expense categories:', expenseCategories.length);
    const categoryList = expenseCategories.map(c => `- ${c.categoryId || c.id}: ${c.icon || ''} ${c.name}`).join('\n');
    console.log('Category list for Claude:', categoryList);

    const base64Image = req.file.buffer.toString('base64');
    const mediaType = req.file.mimetype || 'image/jpeg';

    let promptText = `이 영수증 이미지를 분석하여 다음 정보를 JSON 형식으로 추출해주세요:
- amount: 총 결제 금액 (숫자만, 콤마 제외)
- date: 거래 날짜 (YYYY-MM-DD 형식)
- merchant: 상호명/가맹점명
- paymentMethod: 결제수단 (현금, 신용카드, 체크카드, 계좌이체 중 하나)`;

    if (categoryList) {
      promptText += `
- categoryId: 아래 카테고리 목록에서 상호명과 가장 관련있는 카테고리의 ID를 선택해주세요. 확실하지 않으면 "기타" 카테고리를 선택하세요.

카테고리 목록:
${categoryList}`;
    }

    promptText += `

JSON 형식으로만 응답해주세요. 예시:
{"amount": 19700, "date": "2026-01-11", "merchant": "개인택시", "paymentMethod": "신용카드", "categoryId": 78}`;

    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-5',
      max_tokens: 1024,
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'image',
              source: {
                type: 'base64',
                media_type: mediaType,
                data: base64Image
              }
            },
            {
              type: 'text',
              text: promptText
            }
          ]
        }
      ]
    });

    const textContent = response.content.find(c => c.type === 'text');
    if (!textContent) {
      return res.status(500).json({ error: 'No text response from Claude' });
    }

    const jsonMatch = textContent.text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return res.status(500).json({ error: 'Could not parse receipt data' });
    }

    const extractedData = JSON.parse(jsonMatch[0]);
    res.json(extractedData);

  } catch (error) {
    console.error('Receipt scan error:', error);
    res.status(500).json({ error: 'Failed to scan receipt' });
  }
});

const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Receipt API server running on port ${PORT}`);
});
