-- =====================================================================
-- supabase-setup.sql
-- Exécuter UNE SEULE FOIS dans l'éditeur SQL Supabase de votre projet
-- Dashboard → SQL Editor → New Query → coller → Run
-- =====================================================================

-- ─── 1. Table des produits ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.products (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL,
  category    TEXT NOT NULL,
  description TEXT,
  price       NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  price_unit  TEXT DEFAULT '€' CHECK (price_unit IN ('€', '€/g')),
  stock       INTEGER DEFAULT 0 CHECK (stock >= 0),
  image_url   TEXT,
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- ─── 2. Table des abonnés newsletter ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.newsletter_subscribers (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email      TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ─── 3. Table des messages de contact ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.contact_messages (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  prenom     TEXT NOT NULL,
  nom        TEXT NOT NULL,
  email      TEXT NOT NULL,
  sujet      TEXT,
  message    TEXT NOT NULL,
  read       BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ─── 4. Trigger updated_at auto ───────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── 5. Storage bucket pour les images produits ───────────────────────
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- ─── 6. RLS (Row Level Security) ─────────────────────────────────────
-- Lecture publique des produits actifs
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lecture publique produits actifs"
  ON public.products FOR SELECT
  USING (is_active = true);

-- Écriture uniquement pour les admins authentifiés
CREATE POLICY "Admin full access produits"
  ON public.products FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Newsletter : insertion publique, lecture admin uniquement
ALTER TABLE public.newsletter_subscribers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Insert newsletter public"
  ON public.newsletter_subscribers FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admin lecture newsletter"
  ON public.newsletter_subscribers FOR SELECT
  USING (auth.role() = 'authenticated');

-- Messages contact : insertion publique, lecture/mise à jour admin
ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Insert contact public"
  ON public.contact_messages FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admin gestion messages"
  ON public.contact_messages FOR ALL
  USING (auth.role() = 'authenticated');

-- ─── 7. Storage policies ──────────────────────────────────────────────
CREATE POLICY "Lecture publique images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

CREATE POLICY "Upload admin images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');

CREATE POLICY "Delete admin images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'product-images' AND auth.role() = 'authenticated');

-- ─── 8. Données de démonstration ─────────────────────────────────────
INSERT INTO public.products (name, category, description, price, price_unit, stock) VALUES
  ('Amnesia Haze', 'Fleurs', 'Indoor premium, riche en terpènes, arôme citronné intense.', 8.00, '€/g', 50),
  ('OG Kush', 'Fleurs', 'Greenhouse top quality. Notes boisées et épicées caractéristiques.', 6.00, '€/g', 80),
  ('Huile CBD 10%', 'Huiles', 'Spectre complet, base MCT huile de coco. 10ml.', 29.90, '€', 30),
  ('Huile CBD 20%', 'Huiles', 'Broad-spectrum haute concentration. Idéal usage intensif.', 49.90, '€', 20),
  ('Hash Charas', 'Bien-être', 'Résine artisanale traditionnelle. 40% CBD.', 7.00, '€/g', 60),
  ('E-liquide Menthe', 'Vape', '300mg CBD, 50/50 PG/VG. Arôme menthe fraîche.', 12.90, '€', 40),
  ('E-liquide Mangue', 'Vape', '600mg CBD, arôme mangue exotique. Vapeur dense.', 15.90, '€', 35),
  ('Baume CBD 500mg', 'Bien-être', 'Baume topique à base de CBD isolat et beurre de karité.', 24.90, '€', 25)
ON CONFLICT DO NOTHING;
