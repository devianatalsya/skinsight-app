export const config = {
  api: {
    bodyParser: {
      sizeLimit: '4.5mb',
    },
  },
};

const DEFAULT_MODEL = (process.env.GEMINI_MODEL || 'gemini-1.5-flash').trim();

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

  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${DEFAULT_MODEL}:generateContent?key=${apiKey}`;

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

  try {
    const upstream = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (upstream.status === 429) {
      return res.status(429).json({ error: 'Batas kuota Gemini tercapai (Quota exceeded)' });
    }
    if (!upstream.ok) {
      const errText = await upstream.text();
      let msg = errText;
      try {
        const errJson = JSON.parse(errText);
        msg = errJson?.error?.message || errText;
      } catch (_) {}
      return res.status(502).json({ error: msg });
    }

    const data = await upstream.json();
    const text = (data?.candidates?.[0]?.content?.parts?.[0]?.text || '').trim();

    if (!text || text.toUpperCase().includes('NO_INGREDIENTS_FOUND')) {
      return res.status(422).json({ error: 'NO_INGREDIENTS_FOUND' });
    }

    return res.status(200).json({ text });
  } catch (err) {
    return res.status(502).json({ error: err.message || 'Gagal menghubungi Gemini' });
  }
}
