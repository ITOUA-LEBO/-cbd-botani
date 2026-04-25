// build.js — Exécuté par Vercel avant le déploiement
// Génère js/supabase-config.js depuis les variables d'environnement

const fs   = require('fs');
const path = require('path');

const url  = process.env.SUPABASE_URL;
const key  = process.env.SUPABASE_ANON_KEY;

if (!url || !key) {
  console.error('❌  Variables manquantes : SUPABASE_URL et SUPABASE_ANON_KEY requises.');
  console.error('   → Ajoutez-les dans Vercel : Settings > Environment Variables');
  process.exit(1);
}

const content = `// Généré automatiquement par build.js — NE PAS COMMITER
const SUPABASE_URL      = '${url}';
const SUPABASE_ANON_KEY = '${key}';

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const SUPABASE_CONFIGURED = true;
`;

fs.mkdirSync(path.join(__dirname, 'js'), { recursive: true });
fs.writeFileSync(path.join(__dirname, 'js', 'supabase-config.js'), content, 'utf8');

console.log('✅  js/supabase-config.js généré avec succès.');
