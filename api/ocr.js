export const config = {
  api: {
    bodyParser: {
      sizeLimit: '4.5mb',
    },
  },
};

const MODEL_PRIMARY = 'gemini-3.5-flash-lite';
const MODEL_FALLBACK = 'gemini-3.8-flash';

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const rawKey = process.env.GEMINI_API_KEY || '';
  const apiKey = rawKey.trim().replace(/^["']|["']$/g, '');
  if (!apiKey) {
    return res.status(500).json({ error: 'GEMINI_API_KEY belum disetting di Vercel' });
  }

  const { imageBase64, mimeType } = req.body || {};
  if (!imageBase64 || typeof imageBase64 !== 'string') {
    return res.status(400).json({ error: 'imageBase64 is required' });
  }

  const endpoint = (model) => `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

  const payload = {
    contents: [
      {
        parts: [
          {
            text:
              'Extract ONLY the cosmetic/skincare ingredients list text from this image. ' +
              'Return only the raw ingredient text separated by commas, with no commentary. ' +
              'If there is NO readable skincare/cosmetic ingredients list in the image, ' +
              'return exactly: NO_INGREDIENTS_FOUND',
          },
          {
            inlineData: {
              mimeType: mimeType || 'image/jpeg',
              data: imageBase64,
            },
          },
        ],
      },
    ],
    generationConfig: {
      temperature: 0.0,
      maxOutputTokens: 512,
    },
  };

  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const models = [MODEL_PRIMARY, MODEL_FALLBACK];

  let lastError = null;
  for (let i = 0; i < models.length; i++) {
    const model = models[i];
    const isFallback = i > 0;
    try {
      const upstream = await fetch(endpoint(model), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (upstream.status === 429) {
        lastError = 'Batas kuota Gemini tercapai (Quota exceeded)';
        if (!isFallback) { await sleep(1500); continue; }
        return res.status(429).json({ error: lastError });
      }

      if (upstream.status === 503) {
        const errJson = await upstream.json().catch(() => ({}));
        lastError = errJson?.error?.message || 'High demand, retrying...';
        if (!isFallback) { await sleep(2000); continue; }
        return res.status(503).json({ error: lastError });
      }

      if (!upstream.ok) {
        const errText = await upstream.text();
        let msg = errText;
        try { const j = JSON.parse(errText); msg = j?.error?.message || errText; } catch (_) {}
        if (!isFallback) { lastError = msg; await sleep(1500); continue; }
        return res.status(502).json({ error: msg });
      }

      const data = await upstream.json();
      const text = (data?.candidates?.[0]?.content?.parts?.[0]?.text || '').trim();

      if (!text || text.toUpperCase().includes('NO_INGREDIENTS_FOUND')) {
        return res.status(422).json({ error: 'NO_INGREDIENTS_FOUND' });
      }

      return res.status(200).json({ text });
    } catch (err) {
      lastError = err.message || 'Gagal menghubungi Gemini';
      if (!isFallback) { await sleep(1500); continue; }
    }
  }

  return res.status(502).json({ error: lastError });
}
