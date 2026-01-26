<template>
  <div v-if="visible" class="modal-overlay">
    <div class="modal-container">
      <div class="modal-header">
        <h2 class="modal-title">거래 내역 입력</h2>
        <button type="button" class="receipt-scan-btn" @click="showReceiptScan = true">
          <span class="scan-icon">📋</span>
          영수증 스캔
        </button>
      </div>
      
      <div v-if="showReceiptScan" class="receipt-scan-popup">
        <div class="scan-header">
          <div class="scan-title">
            <span>📋</span>
            영수증 스캔하기
          </div>
          <button type="button" class="scan-close" @click="showReceiptScan = false">✕</button>
        </div>
        
        <p class="scan-desc">영수증 파일을 업로드하여 지출 내역을 자동으로 입력하세요</p>
        
        <div 
          class="upload-area"
          @dragover.prevent="isDragging = true"
          @dragleave.prevent="isDragging = false"
          @drop.prevent="handleFileDrop"
          :class="{ 'dragging': isDragging }"
        >
          <div class="upload-icon">⬆️</div>
          <p class="upload-text">여기에 영수증 이미지를 업로드해 주세요</p>
          <p class="upload-hint">JPG, PNG, PDF 형식 지원 (최대 10MB)</p>
        </div>
        
        <button type="button" class="file-select-btn" @click="triggerFileInput">
          📁 파일 선택
        </button>
        <input 
          type="file" 
          ref="fileInput" 
          @change="handleFileSelect" 
          accept="image/*,.pdf" 
          style="display: none;"
        />
        
        <div v-if="selectedFile" class="file-preview">
          <div class="preview-header">
            <span class="preview-title">📎 선택된 파일</span>
            <button type="button" class="preview-remove" @click="removeSelectedFile">✕</button>
          </div>
          <div class="preview-content">
            <img 
              v-if="previewUrl && isImageFile" 
              :src="previewUrl" 
              alt="영수증 미리보기" 
              class="preview-image"
            />
            <div v-else class="preview-file-info">
              <span class="file-icon">📄</span>
              <span class="file-name">{{ selectedFile.name }}</span>
            </div>
          </div>
          <div class="preview-meta">
            <span>{{ selectedFile.name }}</span>
            <span>{{ formatFileSize(selectedFile.size) }}</span>
          </div>
        </div>
        
        <div class="recent-scans">
          <div class="recent-header">
            <span>최근 스캔 내역</span>
            <button type="button" class="view-all-btn">모두 보기</button>
          </div>
          <div class="recent-items">
            <div class="recent-item placeholder">
              <span class="plus-icon">+</span>
            </div>
          </div>
        </div>
        
        <button type="button" class="start-scan-btn" @click="startScan" :disabled="!selectedFile || isScanning">
          <template v-if="isScanning">
            스캔 중... {{ scanProgress }}%
          </template>
          <template v-else>
            스캔 시작 →
          </template>
        </button>
      </div>

      <div class="type-toggle">
        <button 
          :class="['type-btn', form.type === 'INCOME' ? 'active' : '']"
          @click="form.type = 'INCOME'"
        >
          수입
        </button>
        <button 
          :class="['type-btn', form.type === 'EXPENSE' ? 'active' : '']"
          @click="form.type = 'EXPENSE'"
        >
          지출
        </button>
      </div>

      <div class="form-row two-columns">
        <div class="form-group">
          <label class="form-label">날짜</label>
          <div class="input-wrapper date-wrapper" @click="showCalendar = true">
            <input 
              type="text" 
              :value="formatDisplayDate(form.date)" 
              class="form-input" 
              readonly
            />
            <button type="button" class="calendar-btn">
              📅
            </button>
          </div>
          <div v-if="showCalendar" class="calendar-popup">
            <div class="calendar-header">
              <button type="button" class="cal-nav" @click="prevMonth">&lt;</button>
              <span class="cal-title">{{ calendarYear }}년 {{ calendarMonth }}월</span>
              <button type="button" class="cal-nav" @click="nextMonth">&gt;</button>
            </div>
            <div class="calendar-weekdays">
              <span v-for="day in ['일', '월', '화', '수', '목', '금', '토']" :key="day">{{ day }}</span>
            </div>
            <div class="calendar-days">
              <span 
                v-for="(day, idx) in calendarDays" 
                :key="idx"
                :class="['cal-day', { 
                  empty: !day, 
                  selected: day && isSelectedDay(day),
                  today: day && isToday(day)
                }]"
                @click="day && selectDate(day)"
              >
                {{ day || '' }}
              </span>
            </div>
            <div class="calendar-footer">
              <button type="button" class="cal-close" @click="showCalendar = false">닫기</button>
            </div>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">카테고리</label>
          <div class="input-wrapper">
            <select v-model="form.categoryId" class="form-input form-select">
              <option :value="null" disabled>카테고리 선택</option>
              <option 
                v-for="cat in filteredCategories" 
                :key="cat.categoryId" 
                :value="cat.categoryId"
              >
                {{ cat.icon }} {{ cat.name }}
              </option>
            </select>
            <span class="select-arrow">▼</span>
          </div>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">금액</label>
        <div class="input-wrapper amount-wrapper">
          <span class="currency-prefix">₩</span>
          <input 
            type="text" 
            v-model="formattedAmount" 
            @input="onAmountInput"
            class="form-input amount-input" 
            placeholder="0"
          />
          <button type="button" class="calculator-btn" @click="openCalculator">
            <span>🔢</span>
          </button>
        </div>
        
        <div v-if="showCalculator" class="calculator-popup">
          <div class="calc-header">
            <div class="calc-title">
              <span>🔢</span>
              금액 계산기
            </div>
            <button type="button" class="calc-close" @click="showCalculator = false">✕</button>
          </div>
          
          <div class="calc-display">
            <div class="calc-expression">{{ calcExpression || '0' }}</div>
            <div class="calc-result">{{ formatCalcResult(calcResult) }}</div>
          </div>
          
          <div class="calc-buttons">
            <button type="button" class="calc-btn func" @click="calcClear">AC</button>
            <button type="button" class="calc-btn func" @click="calcBackspace">⌫</button>
            <button type="button" class="calc-btn func" @click="calcAddOperator('/')">÷</button>
            <button type="button" class="calc-btn func" @click="calcAddOperator('*')">×</button>
            
            <button type="button" class="calc-btn num" @click="calcAddDigit('7')">7</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('8')">8</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('9')">9</button>
            <button type="button" class="calc-btn func" @click="calcAddOperator('-')">−</button>
            
            <button type="button" class="calc-btn num" @click="calcAddDigit('4')">4</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('5')">5</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('6')">6</button>
            <button type="button" class="calc-btn func" @click="calcAddOperator('+')">+</button>
            
            <button type="button" class="calc-btn num" @click="calcAddDigit('1')">1</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('2')">2</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('3')">3</button>
            <button type="button" class="calc-btn equal" @click="calcEquals">=</button>
            
            <button type="button" class="calc-btn num zero" @click="calcAddDigit('0')">0</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('00')">00</button>
            <button type="button" class="calc-btn num" @click="calcAddDigit('.')">.</button>
          </div>
          
          <button type="button" class="calc-apply" @click="applyCalculation">
            적용하기 ✓
          </button>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">결제 수단</label>
        <div class="input-wrapper">
          <select v-model="form.paymentMethod" class="form-input form-select">
            <option value="현금">현금</option>
            <option value="신용카드">신용카드</option>
            <option value="체크카드">체크카드</option>
            <option value="계좌이체">계좌이체</option>
          </select>
          <span class="select-arrow">▼</span>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">내용(상호)</label>
        <input 
          type="text" 
          v-model="form.description" 
          class="form-input" 
          placeholder="간략한 거래 요약을 입력하세요 (예: 점심 식사)"
        />
      </div>

      <div class="form-group">
        <label class="form-label">메모</label>
        <textarea 
          v-model="form.memo" 
          class="form-input form-textarea" 
          placeholder="상세한 메모를 입력하세요..."
          rows="4"
        ></textarea>
      </div>

      <div class="modal-footer">
        <button class="btn-cancel" @click="closeModal">취소</button>
        <button class="btn-save" @click="handleSave">저장</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import categoryService from '../services/categoryService';
import transactionService from '../services/transactionService';
import { scanReceipt } from '../services/receiptScanService';
import { ElMessage } from 'element-plus';
import dayjs from 'dayjs';

const props = defineProps({
  visible: { type: Boolean, default: false },
  transaction: { type: Object, default: null },
  mode: { type: String, default: 'add' }
});

const emit = defineEmits(['update:visible', 'saved']);

const form = ref({
  type: 'EXPENSE',
  date: dayjs().format('YYYY-MM-DD'),
  categoryId: null,
  amount: 0,
  paymentMethod: '신용카드',
  description: '',
  memo: ''
});

const formattedAmount = ref('0');
const showCalendar = ref(false);
const calendarYear = ref(dayjs().year());
const calendarMonth = ref(dayjs().month() + 1);

const showCalculator = ref(false);
const calcExpression = ref('');
const calcResult = ref(0);

const showReceiptScan = ref(false);
const isDragging = ref(false);
const selectedFile = ref(null);
const previewUrl = ref(null);
const fileInput = ref(null);
const isScanning = ref(false);
const scanProgress = ref(0);

const isImageFile = computed(() => {
  if (!selectedFile.value) return false;
  return selectedFile.value.type.startsWith('image/');
});

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const createPreview = (file) => {
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value);
  }
  if (file && file.type.startsWith('image/')) {
    previewUrl.value = URL.createObjectURL(file);
  } else {
    previewUrl.value = null;
  }
};

const removeSelectedFile = () => {
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value);
  }
  selectedFile.value = null;
  previewUrl.value = null;
  if (fileInput.value) {
    fileInput.value.value = '';
  }
};

const triggerFileInput = () => {
  fileInput.value?.click();
};

const handleFileSelect = (event) => {
  const file = event.target.files[0];
  if (file) {
    selectedFile.value = file;
    createPreview(file);
  }
};

const handleFileDrop = (event) => {
  isDragging.value = false;
  const file = event.dataTransfer.files[0];
  if (file) {
    selectedFile.value = file;
    createPreview(file);
  }
};

const extractReceiptData = (text) => {
  const lines = text.split('\n').map(l => l.trim()).filter(l => l);
  let amount = 0;
  let description = '';
  let date = dayjs().format('YYYY-MM-DD');
  let paymentMethod = '';
  
  const fullText = text.replace(/\n/g, ' ');
  
  const totalPatterns = [
    /결제요금[^:]*[:：]\s*(\d{1,3}(?:,\d{3})*)\s*원/i,
    /Total\s*Fare[^:]*[:：]\s*(\d{1,3}(?:,\d{3})*)\s*원/i,
    /합\s*계[^:]*[:：]?\s*(\d{1,3}(?:,\d{3})*)\s*원/i,
    /총\s*액[^:]*[:：]?\s*(\d{1,3}(?:,\d{3})*)\s*원/i,
    /결제\s*금액[^:]*[:：]?\s*(\d{1,3}(?:,\d{3})*)\s*원/i,
    /총\s*금액[^:]*[:：]?\s*(\d{1,3}(?:,\d{3})*)\s*원/i,
    /(\d{1,3}(?:,\d{3})*)\s*원/
  ];
  
  for (const pattern of totalPatterns) {
    const match = fullText.match(pattern);
    if (match) {
      const parsed = parseInt(match[1].replace(/,/g, ''));
      if (parsed > 100 && parsed > amount) {
        amount = parsed;
        if (pattern.source.includes('결제요금') || pattern.source.includes('합') || pattern.source.includes('총')) {
          break;
        }
      }
    }
  }
  
  const datePatterns = [
    /거래\s*일시[^:]*[:：]\s*(\d{4})[.\-\/](\d{1,2})[.\-\/](\d{1,2})/i,
    /Date[^:]*[:：]\s*(\d{4})[.\-\/](\d{1,2})[.\-\/](\d{1,2})/i,
    /일\s*시[^:]*[:：]\s*(\d{4})[.\-\/](\d{1,2})[.\-\/](\d{1,2})/i,
    /(\d{4})[.\-\/](\d{1,2})[.\-\/](\d{1,2})/,
    /(\d{2})[.\-\/](\d{1,2})[.\-\/](\d{1,2})/
  ];
  
  for (const pattern of datePatterns) {
    const match = fullText.match(pattern);
    if (match) {
      const yearIdx = match[0].includes('거래') || match[0].includes('Date') || match[0].includes('일시') ? 1 : 1;
      let year = match[yearIdx];
      if (year.length === 2) year = '20' + year;
      const month = match[yearIdx + 1].padStart(2, '0');
      const day = match[yearIdx + 2].padStart(2, '0');
      date = `${year}-${month}-${day}`;
      break;
    }
  }
  
  const merchantPatterns = [
    /상\s*호[^:]*[:：]\s*([^\n\r가-힣]*[가-힣]+[^\n\r]*)/i,
    /가맹점[^:]*[:：]\s*([^\n\r]+)/i,
    /매장[^:]*[:：]\s*([^\n\r]+)/i
  ];
  
  for (const pattern of merchantPatterns) {
    const match = fullText.match(pattern);
    if (match) {
      description = match[1].trim().substring(0, 50);
      break;
    }
  }
  
  if (!description) {
    const keywords = ['택시', '편의점', '마트', '카페', '커피', '식당', '음식점', '주유소', '약국'];
    for (const keyword of keywords) {
      if (fullText.includes(keyword)) {
        const keywordIdx = fullText.indexOf(keyword);
        const start = Math.max(0, keywordIdx - 10);
        const end = Math.min(fullText.length, keywordIdx + keyword.length + 10);
        description = fullText.substring(start, end).replace(/[^가-힣a-zA-Z0-9\s]/g, '').trim().substring(0, 50);
        break;
      }
    }
  }
  
  if (!description && lines.length > 0) {
    for (const line of lines) {
      if (line.length > 2 && line.length < 30 && /[가-힣]/.test(line) && !line.includes('영수증') && !line.includes('Receipt')) {
        description = line.substring(0, 50);
        break;
      }
    }
  }
  
  const cardPatterns = [
    /국민카드|KB카드/i,
    /신한카드/i,
    /삼성카드/i,
    /현대카드/i,
    /롯데카드/i,
    /하나카드/i,
    /우리카드/i,
    /NH카드|농협카드/i,
    /BC카드/i,
    /카드\s*번호/i
  ];
  
  for (const pattern of cardPatterns) {
    if (pattern.test(fullText)) {
      paymentMethod = '신용카드';
      break;
    }
  }
  
  if (!paymentMethod) {
    if (/현금|cash/i.test(fullText)) {
      paymentMethod = '현금';
    } else if (/계좌\s*이체|이체/i.test(fullText)) {
      paymentMethod = '계좌이체';
    } else if (/체크카드/i.test(fullText)) {
      paymentMethod = '체크카드';
    }
  }
  
  return { amount, description, date, paymentMethod };
};

const startScan = async () => {
  if (!selectedFile.value) return;
  
  if (categories.value.length === 0) {
    await loadCategories();
  }
  
  isScanning.value = true;
  scanProgress.value = 50;
  
  try {
    const extractedData = await scanReceipt(selectedFile.value, categories.value);
    console.log('Extracted data:', extractedData);
    
    form.value.type = 'EXPENSE';
    if (extractedData.amount > 0) {
      form.value.amount = extractedData.amount;
      formattedAmount.value = extractedData.amount.toLocaleString('ko-KR');
    }
    if (extractedData.merchant) {
      form.value.description = extractedData.merchant;
    }
    if (extractedData.categoryId && typeof extractedData.categoryId === 'number') {
      form.value.categoryId = extractedData.categoryId;
    } else if (extractedData.categoryId && !isNaN(parseInt(extractedData.categoryId))) {
      form.value.categoryId = parseInt(extractedData.categoryId);
    }
    if (extractedData.date) {
      form.value.date = extractedData.date;
    }
    if (extractedData.paymentMethod) {
      form.value.paymentMethod = extractedData.paymentMethod;
    }
    
    ElMessage.success('영수증 스캔이 완료되었습니다!');
    showReceiptScan.value = false;
    selectedFile.value = null;
    
  } catch (error) {
    console.error('OCR 오류:', error);
    ElMessage.error('영수증 스캔 중 오류가 발생했습니다.');
  } finally {
    isScanning.value = false;
    scanProgress.value = 0;
  }
};

const openCalculator = () => {
  calcExpression.value = form.value.amount > 0 ? form.value.amount.toString() : '';
  calcResult.value = form.value.amount || 0;
  showCalculator.value = true;
};

const formatCalcResult = (num) => {
  return num.toLocaleString('ko-KR');
};

const calcAddDigit = (digit) => {
  calcExpression.value += digit;
  calculateResult();
};

const calcAddOperator = (op) => {
  if (calcExpression.value && !/[+\-*/]$/.test(calcExpression.value)) {
    calcExpression.value += ' ' + op + ' ';
    calculateResult();
  }
};

const calcClear = () => {
  calcExpression.value = '';
  calcResult.value = 0;
};

const calcBackspace = () => {
  const expr = calcExpression.value.trimEnd();
  if (expr.endsWith(' ')) {
    calcExpression.value = expr.slice(0, -3);
  } else {
    calcExpression.value = expr.slice(0, -1);
  }
  calculateResult();
};

const calcEquals = () => {
  calculateResult();
};

const calculateResult = () => {
  try {
    const expr = calcExpression.value.replace(/\s/g, '');
    if (expr) {
      const result = Function('"use strict"; return (' + expr + ')')();
      if (!isNaN(result) && isFinite(result)) {
        calcResult.value = Math.floor(result);
      }
    } else {
      calcResult.value = 0;
    }
  } catch (e) {
    // Invalid expression, keep previous result
  }
};

const applyCalculation = () => {
  form.value.amount = calcResult.value;
  formattedAmount.value = calcResult.value.toLocaleString('ko-KR');
  showCalculator.value = false;
};

const formatDisplayDate = (dateStr) => {
  if (!dateStr) return '';
  const d = dayjs(dateStr);
  return `${d.month() + 1}/${d.date()}/${d.year()}`;
};

const calendarDays = computed(() => {
  const firstDay = dayjs(`${calendarYear.value}-${String(calendarMonth.value).padStart(2, '0')}-01`);
  const daysInMonth = firstDay.daysInMonth();
  const startDayOfWeek = firstDay.day();
  
  const days = [];
  for (let i = 0; i < startDayOfWeek; i++) {
    days.push(null);
  }
  for (let i = 1; i <= daysInMonth; i++) {
    days.push(i);
  }
  return days;
});

const prevMonth = () => {
  if (calendarMonth.value === 1) {
    calendarMonth.value = 12;
    calendarYear.value--;
  } else {
    calendarMonth.value--;
  }
};

const nextMonth = () => {
  if (calendarMonth.value === 12) {
    calendarMonth.value = 1;
    calendarYear.value++;
  } else {
    calendarMonth.value++;
  }
};

const isSelectedDay = (day) => {
  const selected = dayjs(form.value.date);
  return selected.year() === calendarYear.value && 
         selected.month() + 1 === calendarMonth.value && 
         selected.date() === day;
};

const isToday = (day) => {
  const today = dayjs();
  return today.year() === calendarYear.value && 
         today.month() + 1 === calendarMonth.value && 
         today.date() === day;
};

const selectDate = (day) => {
  const dateStr = `${calendarYear.value}-${String(calendarMonth.value).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  form.value.date = dateStr;
  showCalendar.value = false;
};

const onAmountInput = (event) => {
  const value = event.target.value.replace(/[^0-9]/g, '');
  form.value.amount = parseInt(value) || 0;
  formattedAmount.value = form.value.amount.toLocaleString('ko-KR');
};

const categories = ref([]);

const filteredCategories = computed(() => {
  const type = form.value.type;
  return categories.value.filter(c => c.type === type || c.type?.toUpperCase() === type);
});

const loadCategories = async () => {
  try {
    const response = await categoryService.getCategories();
    categories.value = response.data || response;
  } catch (error) {
    console.error('카테고리 로딩 실패:', error);
    categories.value = [];
  }
};

const closeModal = () => {
  emit('update:visible', false);
};

watch(() => props.visible, (newVal) => {
  if (newVal) {
    loadCategories();
    showCalendar.value = false;
    if (props.mode === 'edit' && props.transaction) {
      form.value = {
        type: props.transaction.type,
        date: dayjs(props.transaction.transactionDate).format('YYYY-MM-DD'),
        categoryId: props.transaction.categoryId,
        amount: props.transaction.amount,
        paymentMethod: props.transaction.paymentMethod || '신용카드',
        description: props.transaction.description || '',
        memo: props.transaction.memo || ''
      };
      formattedAmount.value = form.value.amount.toLocaleString('ko-KR');
      const d = dayjs(props.transaction.transactionDate);
      calendarYear.value = d.year();
      calendarMonth.value = d.month() + 1;
    } else {
      form.value = {
        type: 'EXPENSE',
        date: dayjs().format('YYYY-MM-DD'),
        categoryId: null,
        amount: 0,
        paymentMethod: '신용카드',
        description: '',
        memo: ''
      };
      formattedAmount.value = '0';
      calendarYear.value = dayjs().year();
      calendarMonth.value = dayjs().month() + 1;
    }
  }
});

const handleSave = async () => {
  if (!form.value.categoryId) {
    ElMessage.warning('카테고리를 선택해주세요.');
    return;
  }
  if (form.value.amount <= 0) {
    ElMessage.warning('금액을 입력해주세요.');
    return;
  }

  try {
    const data = {
      userId: 9,
      categoryId: form.value.categoryId,
      amount: form.value.amount,
      paymentMethod: form.value.paymentMethod,
      memo: form.value.memo,
      description: form.value.description || form.value.memo
    };

    if (form.value.type === 'INCOME') {
      data.incomeDate = form.value.date;
      if (props.mode === 'edit') {
        await transactionService.updateIncome(props.transaction.id, data);
      } else {
        await transactionService.createIncome(data);
      }
    } else {
      data.expenseDate = form.value.date;
      if (props.mode === 'edit') {
        await transactionService.updateExpense(props.transaction.id, data);
      } else {
        await transactionService.createExpense(data);
      }
    }

    ElMessage.success(props.mode === 'add' ? '거래가 추가되었습니다.' : '거래가 수정되었습니다.');
    emit('saved');
    closeModal();
  } catch (error) {
    console.error('저장 실패:', error);
    ElMessage.error('저장에 실패했습니다.');
  }
};
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-container {
  background: #1a2e1a;
  border-radius: 12px;
  width: 420px;
  max-width: 95vw;
  max-height: 90vh;
  overflow-y: auto;
  padding: 16px;
  border: 1px solid rgba(212, 255, 0, 0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.modal-title {
  font-size: 16px;
  font-weight: 600;
  color: #ffffff;
  margin: 0;
}

.receipt-scan-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: #2a3e2a;
  border: 1px solid rgba(212, 255, 0, 0.3);
  border-radius: 8px;
  padding: 8px 12px;
  color: #d4ff00;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}

.receipt-scan-btn:hover {
  background: #3a4e3a;
}

.scan-icon {
  font-size: 14px;
}

.type-toggle {
  display: flex;
  background: #0d1a0d;
  border-radius: 6px;
  padding: 3px;
  margin-bottom: 12px;
}

.type-btn {
  flex: 1;
  padding: 8px 16px;
  border: none;
  border-radius: 5px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  background: transparent;
  color: #888;
}

.type-btn.active {
  background: #d4ff00;
  color: #0d1a0d;
}

.type-btn:not(.active):hover {
  color: #fff;
}

.form-row {
  display: flex;
  gap: 16px;
}

.form-row.two-columns .form-group {
  flex: 1;
}

.form-group {
  margin-bottom: 12px;
}

.form-label {
  display: block;
  font-size: 12px;
  color: #888;
  margin-bottom: 4px;
}

.input-wrapper {
  position: relative;
}

.form-input {
  width: 100%;
  background: #0d1a0d;
  border: 1px solid #2a3e2a;
  border-radius: 6px;
  padding: 10px 12px;
  font-size: 14px;
  color: #ffffff;
  outline: none;
  transition: border-color 0.2s;
  box-sizing: border-box;
}

.form-input:focus {
  border-color: #d4ff00;
}

.form-input::placeholder {
  color: #555;
}

.form-select {
  appearance: none;
  padding-right: 40px;
  cursor: pointer;
}

.select-arrow {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #888;
  font-size: 10px;
  pointer-events: none;
}

.form-group {
  position: relative;
}

.date-wrapper {
  display: flex;
  align-items: center;
  background: #0d1a0d;
  border: 1px solid #2a3e2a;
  border-radius: 8px;
  padding: 0 8px 0 0;
  cursor: pointer;
}

.date-wrapper:hover {
  border-color: #d4ff00;
}

.date-wrapper input[type="text"] {
  flex: 1;
  border: none;
  background: transparent;
  padding: 12px 8px 12px 16px;
  cursor: pointer;
}

.date-wrapper .calendar-btn {
  background: transparent;
  border: none;
  padding: 8px;
  cursor: pointer;
  font-size: 16px;
  border-radius: 4px;
  transition: background 0.2s;
}

.date-wrapper .calendar-btn:hover {
  background: rgba(212, 255, 0, 0.1);
}

.calendar-popup {
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 100;
  background: #1a2e1a;
  border: 1px solid rgba(212, 255, 0, 0.3);
  border-radius: 10px;
  padding: 12px;
  margin-top: 6px;
  width: 220px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.cal-nav {
  background: transparent;
  border: 1px solid #2a3e2a;
  color: #fff;
  width: 26px;
  height: 26px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.2s;
}

.cal-nav:hover {
  background: #2a3e2a;
  border-color: #d4ff00;
}

.cal-title {
  font-size: 13px;
  font-weight: 600;
  color: #fff;
}

.calendar-weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 2px;
  margin-bottom: 6px;
}

.calendar-weekdays span {
  text-align: center;
  font-size: 10px;
  color: #888;
  padding: 3px;
}

.calendar-days {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.cal-day {
  text-align: center;
  padding: 5px 2px;
  font-size: 12px;
  color: #fff;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.cal-day:hover:not(.empty) {
  background: #2a3e2a;
}

.cal-day.empty {
  cursor: default;
}

.cal-day.selected {
  background: #d4ff00;
  color: #0d1a0d;
  font-weight: 600;
}

.cal-day.today:not(.selected) {
  border: 1px solid #d4ff00;
}

.calendar-footer {
  margin-top: 8px;
  text-align: right;
}

.cal-close {
  background: transparent;
  border: 1px solid #555;
  color: #888;
  padding: 5px 12px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 11px;
  transition: all 0.2s;
}

.cal-close:hover {
  color: #fff;
  border-color: #888;
}

.amount-wrapper {
  display: flex;
  align-items: center;
  background: #0d1a0d;
  border: 1px solid #2a3e2a;
  border-radius: 8px;
  padding: 0 8px 0 16px;
}

.amount-wrapper:focus-within {
  border-color: #d4ff00;
}

.currency-prefix {
  color: #ffffff;
  font-size: 16px;
  font-weight: 500;
  margin-right: 8px;
}

.amount-input {
  border: none;
  background: transparent;
  padding: 12px 0;
  flex: 1;
}

.amount-input:focus {
  border: none;
}

.calculator-btn {
  background: #d4ff00;
  border: none;
  border-radius: 6px;
  padding: 8px 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.calculator-btn span {
  font-size: 16px;
}

.calculator-popup {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 100;
  background: #0d1a0d;
  border: 1px solid rgba(212, 255, 0, 0.3);
  border-radius: 12px;
  padding: 12px;
  margin-top: 6px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
  max-width: 280px;
}

.calc-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.calc-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #fff;
}

.calc-close {
  background: transparent;
  border: none;
  color: #888;
  font-size: 14px;
  cursor: pointer;
  padding: 2px 6px;
}

.calc-close:hover {
  color: #fff;
}

.calc-display {
  text-align: right;
  margin-bottom: 12px;
  padding: 0 4px;
}

.calc-expression {
  font-size: 11px;
  color: #888;
  margin-bottom: 4px;
  min-height: 14px;
}

.calc-result {
  font-size: 24px;
  font-weight: 600;
  color: #fff;
}

.calc-buttons {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 6px;
}

.calc-btn {
  padding: 10px;
  border: none;
  border-radius: 50%;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
}

.calc-btn.num {
  background: #2a3e2a;
  color: #fff;
}

.calc-btn.num:hover {
  background: #3a4e3a;
}

.calc-btn.func {
  background: #1a2e1a;
  color: #888;
}

.calc-btn.func:hover {
  background: #2a3e2a;
  color: #fff;
}

.calc-btn.equal {
  background: #00c853;
  color: #fff;
  grid-row: span 2;
  aspect-ratio: auto;
  border-radius: 22px;
  height: auto;
}

.calc-btn.equal:hover {
  background: #00e676;
}

.calc-btn.zero {
  grid-column: span 1;
}

.calc-apply {
  width: 100%;
  margin-top: 12px;
  padding: 10px;
  background: #00c853;
  border: none;
  border-radius: 8px;
  color: #fff;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.calc-apply:hover {
  background: #00e676;
}

.receipt-scan-popup {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 280px;
  background: #0d1a0d;
  border-radius: 10px;
  padding: 12px;
  z-index: 200;
  display: flex;
  flex-direction: column;
  border: 1px solid #2a3e2a;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
}

.scan-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.scan-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
}

.scan-close {
  background: transparent;
  border: none;
  color: #888;
  font-size: 16px;
  cursor: pointer;
  padding: 2px 6px;
}

.scan-close:hover {
  color: #fff;
}

.scan-desc {
  color: #888;
  font-size: 11px;
  text-align: center;
  margin-bottom: 12px;
}

.upload-area {
  border: 2px dashed #3a4e3a;
  border-radius: 10px;
  padding: 20px 16px;
  text-align: center;
  margin-bottom: 10px;
  transition: all 0.2s;
  cursor: pointer;
}

.upload-area.dragging {
  border-color: #d4ff00;
  background: rgba(212, 255, 0, 0.05);
}

.upload-icon {
  font-size: 24px;
  background: #d4ff00;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 8px;
}

.upload-text {
  color: #fff;
  font-size: 12px;
  font-weight: 500;
  margin-bottom: 4px;
}

.upload-hint {
  color: #666;
  font-size: 10px;
}

.file-select-btn {
  width: 100%;
  padding: 10px;
  background: #d4ff00;
  border: none;
  border-radius: 6px;
  color: #0d1a0d;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  margin-bottom: 12px;
  transition: all 0.2s;
}

.file-select-btn:hover {
  background: #c5f000;
}

.file-preview {
  background: #1a2e1a;
  border: 1px solid #3a4e3a;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 12px;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.preview-title {
  color: #d4ff00;
  font-size: 12px;
  font-weight: 600;
}

.preview-remove {
  background: rgba(255, 100, 100, 0.2);
  border: none;
  color: #ff6b6b;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.preview-remove:hover {
  background: rgba(255, 100, 100, 0.4);
}

.preview-content {
  background: #0d1a0d;
  border-radius: 6px;
  overflow: hidden;
  margin-bottom: 8px;
}

.preview-image {
  width: 100%;
  max-height: 200px;
  object-fit: contain;
  display: block;
}

.preview-file-info {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 20px;
  color: #aaa;
}

.file-icon {
  font-size: 32px;
}

.file-name {
  font-size: 13px;
  word-break: break-all;
}

.preview-meta {
  display: flex;
  justify-content: space-between;
  color: #888;
  font-size: 11px;
}

.preview-meta span:first-child {
  max-width: 70%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.recent-scans {
  flex: 1;
  margin-bottom: 10px;
}

.recent-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.recent-header span {
  color: #fff;
  font-size: 11px;
  font-weight: 500;
}

.view-all-btn {
  background: transparent;
  border: none;
  color: #888;
  font-size: 10px;
  cursor: pointer;
}

.view-all-btn:hover {
  color: #fff;
}

.recent-items {
  display: flex;
  gap: 8px;
}

.recent-item {
  width: 55px;
  height: 55px;
  background: #1a2e1a;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.recent-item:hover {
  background: #2a3e2a;
}

.recent-item.placeholder {
  border: 1px dashed #3a4e3a;
  background: transparent;
}

.plus-icon {
  color: #666;
  font-size: 20px;
}

.start-scan-btn {
  width: 100%;
  padding: 10px;
  background: #d4ff00;
  border: none;
  border-radius: 6px;
  color: #0d1a0d;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.start-scan-btn:hover:not(:disabled) {
  background: #c5f000;
}

.start-scan-btn:disabled {
  background: #3a4e3a;
  color: #666;
  cursor: not-allowed;
}

.form-textarea {
  resize: vertical;
  min-height: 60px;
  font-family: inherit;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid #2a3e2a;
}

.btn-cancel {
  background: transparent;
  border: 1px solid #555;
  border-radius: 6px;
  padding: 8px 16px;
  font-size: 13px;
  color: #888;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover {
  color: #fff;
  border-color: #888;
}

.btn-save {
  background: #d4ff00;
  border: none;
  border-radius: 6px;
  padding: 8px 20px;
  font-size: 13px;
  font-weight: 600;
  color: #0d1a0d;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-save:hover {
  background: #c5f000;
}

@media (max-width: 520px) {
  .modal-container {
    padding: 20px;
  }
  
  .form-row.two-columns {
    flex-direction: column;
    gap: 0;
  }
  
  .modal-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
}
</style>
