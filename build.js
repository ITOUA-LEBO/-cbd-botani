// build.js — Exécuté par Vercel avant le déploiement
// Copie tous les fichiers du site dans dist/ et injecte les clés Supabase

const fs   = require('fs');
const path = require('path');

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_ANON_KEY;

if (!url || !key) {
  console.error('❌  Variables manquantes : SUPABASE_URL et SUPABASE_ANON_KEY requises.');
  process.exit(1);
}

// ── Utilitaires ───────────────────────────────────────────────────────────────

function mkdir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function copy(src, dest) {
  mkdir(path.dirname(dest));
  fs.copyFileSync(src, dest);
  console.log(`  ✓ ${dest}`);
}

function copyDir(src, dest) {
  mkdir(dest);
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(s, d);
    else copy(s, d);
  }
}

// ── Dossier dist/ ─────────────────────────────────────────────────────────────

const dist = path.join(__dirname, 'dist');

// Repart d'un dist/ propre à chaque build
if (fs.existsSync(dist)) fs.rmSync(dist, { recursive: true, force: true });
mkdir(dist);

console.log('\n📦  Build CBD Botani X Brothers\n');

// Copie index.html
copy(path.join(__dirname, 'index.html'), path.join(dist, 'index.html'));

// Copie admin/
copyDir(path.join(__dirname, 'admin'), path.join(dist, 'admin'));

// Copie js/ (sans supabase-config.js qui sera généré)
mkdir(path.join(dist, 'js'));

// Génère js/supabase-config.js avec les vraies clés
const config = `// Généré par build.js — NE PAS COMMITER
const SUPABASE_URL      = '${url}';
const SUPABASE_ANON_KEY = '${key}';

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const SUPABASE_CONFIGURED = true;
`;

fs.writeFileSync(path.join(dist, 'js', 'supabase-config.js'), config, 'utf8');
console.log('  ✓ dist/js/supabase-config.js (clés injectées)');

console.log('\n✅  Build terminé → dist/\n');
