export async function scanReceipt(imageFile, categories = []) {
  const formData = new FormData();
  formData.append('receipt', imageFile);
  formData.append('categories', JSON.stringify(categories));

  const response = await fetch('/api/scan-receipt', {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to scan receipt');
  }

  return response.json();
}
