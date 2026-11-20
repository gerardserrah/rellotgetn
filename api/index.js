const fs = require('fs');
const path = require('path');

let cachedHtml = null;

function getBaseHtml() {
  if (!cachedHtml) {
    cachedHtml = fs.readFileSync(path.join(process.cwd(), 'index.html'), 'utf8');
  }
  return cachedHtml;
}

const VALID_YEARS = new Set(['1996', '1999', '2002', '2005', '2014', '2025']);

const MODE_BG_COLORS = {
  '1996': '#3b96dc',
  '1999': '#E5ECE4',
  '2002': '#000000',
  '2005': '#F16806',
  '2014': '#b0c3c3',
  '2025': '#F56115'
};

module.exports = (req, res) => {
  try {
    let html = getBaseHtml();

    const q = req.query || {};
    let raw = q.any || q.mode || q.year || '';
    if (!raw && req.url) {
      const m = req.url.match(/[?&](1996|1999|2001|2002|2005|2014|2025)(?:$|&)/);
      if (m) raw = m[1];
    }
    if (Array.isArray(raw)) raw = raw[0] || '';
    raw = String(raw).trim();
    if (raw === '2001') raw = '1999';

    const rawHost = (req.headers && (req.headers['x-forwarded-host'] || req.headers.host)) || 'rellotgetn.gerard.sh';
    const host = String(rawHost).split(',')[0].trim() || 'rellotgetn.gerard.sh';
    const baseUrl = `https://${host}`;

    if (VALID_YEARS.has(raw)) {
      const y = raw;
      const ogImg = `${baseUrl}/og-image-${y}.jpg`;
      const bgHex = MODE_BG_COLORS[y] || '#b0c3c3';

      html = html
        .replace(/https:\/\/rellotgetn\.gerard\.sh\/og-image\.jpg/g, ogImg)
        .replace(/content="https:\/\/rellotgetn\.gerard\.sh\/"/g, `content="${baseUrl}/?any=${y}"`)
        .replace(/<title>Rellotge TN \| 2014<\/title>/, `<title>Rellotge TN | ${y}</title>`)
        .replace(/<meta property="og:title" content="Rellotge TN">/, `<meta property="og:title" content="Rellotge TN | ${y}">`)
        .replace(/<meta name="twitter:title" content="Rellotge TN">/, `<meta name="twitter:title" content="Rellotge TN | ${y}">`)
        .replace(/apple-touch-icon-2014\.png/g, `apple-touch-icon-${y}.png`)
        .replace(/favicon-2014\.png/g, `favicon-${y}.png`)
        .replace(/id="meta-theme-color" content="#b0c3c3"/g, `id="meta-theme-color" content="${bgHex}"`)
        .replace(/id="meta-theme-color-light" media="\(prefers-color-scheme: light\)" content="#b0c3c3"/g, `id="meta-theme-color-light" media="(prefers-color-scheme: light)" content="${bgHex}"`)
        .replace(/id="meta-theme-color-dark" media="\(prefers-color-scheme: dark\)" content="#b0c3c3"/g, `id="meta-theme-color-dark" media="(prefers-color-scheme: dark)" content="${bgHex}"`);
    } else if (host !== 'rellotgetn.gerard.sh') {
      html = html.replace(/https:\/\/rellotgetn\.gerard\.sh/g, baseUrl);
    }

    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.setHeader('Cache-Control', 'public, max-age=0, must-revalidate');
    res.status(200).send(html);
  } catch (err) {
    res.status(500).send('Error loading Rellotge TN');
  }
};
