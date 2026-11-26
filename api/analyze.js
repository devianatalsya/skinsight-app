export const config = {
  api: {
    bodyParser: {
      sizeLimit: '1mb',
    },
  },
  maxDuration: 30,
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

  const { skinType, ingredients } = req.body || {};
  if (!skinType || !Array.isArray(ingredients) || ingredients.length === 0) {
    return res.status(400).json({ error: 'skinType and ingredients are required' });
  }

  const endpoint = (model) => `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
  const ingredientList = ingredients.map((i) => `"${String(i)}"`).join(', ');

  const prompt = `
Kamu adalah asisten informasi keamanan bahan skincare dan kosmetik. Analisis daftar bahan berikut untuk pengguna dengan jenis kulit ${skinType}.

ATURAN PENTING:
- JANGAN memberikan diagnosis medis.
- Gunakan bahasa Indonesia yang informatif, tenang, dan singkat seperti "Berpotensi mengiritasi", "Perlu diperhatikan", "Kurang ideal untuk kulit sensitif", atau "Tidak ditemukan indikator risiko utama berdasarkan data yang tersedia".
- Jangan mengklaim produk pasti aman 100% atau pasti menyebabkan penyakit.
- Hanya tandai bahan yang memang relevan untuk jenis kulit ${skinType}.
- Kembalikan HANYA JSON valid sesuai skema di bawah.

Jenis kulit: ${skinType}
Daftar bahan: [${ingredientList}]

Kembalikan JSON persis sesuai skema ini:
{
  "overall_status": "safe|warning|caution",
  "summary": "Satu kalimat ringkasan singkat dalam bahasa Indonesia.",
  "flagged_ingredients": [
    {
      "name": "Nama Bahan",
      "risk": "Label risiko singkat (mis. Berpotensi mengiritasi)",
      "reason": "Penjelasan satu kalimat dalam bahasa Indonesia."
    }
  ],
  "warnings": ["Catatan singkat opsional dalam bahasa Indonesia"],
  "confidence": 0.85
}

Kembalikan hanya objek JSON. Tanpa markdown, tanpa blok kode, tanpa teks tambahan.
`;

  const payload = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: 1024,
      responseMimeType: 'application/json',
    },
    safetySettings: [
      {
        category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
        threshold: 'BLOCK_NONE',
      },
    ],
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
      const rawText = (data?.candidates?.[0]?.content?.parts?.[0]?.text || '')
        .replace(/```json/g, '')
        .replace(/```/g, '')
        .trim();

      const parsed = JSON.parse(rawText);
      if (!parsed.overall_status || !parsed.summary) {
        return res.status(502).json({ error: 'Format respons AI tidak valid' });
      }

      return res.status(200).json(parsed);
    } catch (err) {
      lastError = err.message || 'Gagal menghubungi Gemini';
      if (!isFallback) { await sleep(1500); continue; }
    }
  }

  return res.status(502).json({ error: lastError });
}
