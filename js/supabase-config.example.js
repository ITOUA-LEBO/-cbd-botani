/**
 * supabase-config.example.js — TEMPLATE (commité, sans clés)
 *
 * SETUP :
 * 1. Copiez ce fichier : cp js/supabase-config.example.js js/supabase-config.js
 * 2. Remplissez les valeurs depuis votre projet Supabase (Settings > API)
 *    OU lancez : bash setup.sh  (lit automatiquement le fichier .env)
 * 3. Ne commitez JAMAIS js/supabase-config.js (déjà dans .gitignore)
 */

const SUPABASE_URL      = 'https://VOTRE_PROJET.supabase.co';
const SUPABASE_ANON_KEY = 'VOTRE_CLE_ANON';

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const SUPABASE_CONFIGURED = !SUPABASE_URL.includes('VOTRE_PROJET');
