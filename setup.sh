#!/usr/bin/env bash
# setup.sh — Génère js/supabase-config.js à partir de .env
# Usage : bash setup.sh

set -e

if [ ! -f ".env" ]; then
  echo "❌  Fichier .env introuvable."
  echo "   Copiez .env.example → .env et remplissez vos clés."
  exit 1
fi

source .env

if [[ "$SUPABASE_URL" == *"VOTRE_PROJET"* ]] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "❌  .env incomplet. Vérifiez SUPABASE_URL et SUPABASE_ANON_KEY."
  exit 1
fi

cat > js/supabase-config.js <<EOF
// Fichier généré automatiquement par setup.sh — NE PAS COMMITER
const SUPABASE_URL      = '${SUPABASE_URL}';
const SUPABASE_ANON_KEY = '${SUPABASE_ANON_KEY}';

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const SUPABASE_CONFIGURED = !SUPABASE_URL.includes('VOTRE_PROJET');
EOF

echo "✅  js/supabase-config.js généré avec succès."
