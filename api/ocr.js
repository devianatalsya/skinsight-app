const DEFAULT_MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash';

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'Server API key not configured' });
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
      return res.status(429).json({ error: 'Quota exceeded' });
    }
    if (!upstream.ok) {
      return res.status(502).json({ error: 'Upstream AI error' });
    }

    const data = await upstream.json();
    const text = (data?.candidates?.[0]?.content?.parts?.[0]?.text || '').trim();

    if (!text || text.toUpperCase().includes('NO_INGREDIENTS_FOUND')) {
      return res.status(422).json({ error: 'NO_INGREDIENTS_FOUND' });
    }

    return res.status(200).json({ text });
  } catch (_) {
    return res.status(502).json({ error: 'Upstream request failed' });
  }
}
