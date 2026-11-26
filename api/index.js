export default function handler(req, res) {
  res.status(200).json({
    status: 'ok',
    service: 'Softly Skincare AI Proxy',
    endpoints: ['/api/analyze', '/api/ocr']
  });
}
