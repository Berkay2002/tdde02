-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Recipes table
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  recipe_name TEXT NOT NULL,
  description TEXT,
  prep_time INTEGER, -- in minutes
  cook_time INTEGER, -- in minutes
  servings INTEGER,
  ingredients JSONB NOT NULL, -- array of ingredient objects: [{"name": "chicken", "quantity": "500g", "available": true}]
  instructions JSONB NOT NULL, -- array of instruction steps: [{"step": 1, "instruction": "Preheat oven..."}]
  detected_ingredients JSONB, -- original detected ingredients from AI: ["chicken", "tomatoes", "onions"]
  cooking_tips TEXT, -- optional cooking tips from AI
  cuisine_type TEXT, -- e.g., "Italian", "Chinese", "Mexican"
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  is_favorite BOOLEAN DEFAULT false,
  image_url TEXT, -- optional: captured fridge image URL
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add index for faster queries
CREATE INDEX idx_recipes_user_id ON recipes(user_id);
CREATE INDEX idx_recipes_created_at ON recipes(created_at DESC);
CREATE INDEX idx_recipes_is_favorite ON recipes(is_favorite) WHERE is_favorite = true;

-- Row Level Security Policies for recipes
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

-- Users can only read their own recipes
CREATE POLICY "Users can read own recipes"
  ON recipes FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own recipes
CREATE POLICY "Users can insert own recipes"
  ON recipes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own recipes
CREATE POLICY "Users can update own recipes"
  ON recipes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own recipes
CREATE POLICY "Users can delete own recipes"
  ON recipes FOR DELETE
  USING (auth.uid() = user_id);

-- User Preferences table
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  dietary_restrictions TEXT[] DEFAULT '{}', -- ["vegetarian", "gluten-free", "dairy-free", "nut-free", "vegan"]
  favorite_cuisines TEXT[] DEFAULT '{}', -- ["Italian", "Chinese", "Mexican", "Indian"]
  skill_level TEXT CHECK (skill_level IN ('beginner', 'intermediate', 'advanced')) DEFAULT 'beginner',
  default_servings INTEGER DEFAULT 4,
  preferred_units TEXT CHECK (preferred_units IN ('metric', 'imperial')) DEFAULT 'metric',
  language TEXT DEFAULT 'en',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for user preferences
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own preferences"
  ON user_preferences FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Ingredient Library table (optional: pre-populate common ingredients)
CREATE TABLE ingredient_library (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  category TEXT, -- "vegetable", "protein", "dairy", "grain", "spice"
  common_units TEXT[], -- ["g", "kg", "pieces", "cups"]
  aliases TEXT[], -- alternative names
  nutritional_info JSONB, -- optional: calories, protein, etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Public read access for ingredient library (everyone can read, admin can write)
ALTER TABLE ingredient_library ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read ingredient library"
  ON ingredient_library FOR SELECT
  TO public
  USING (true);

-- Recipe Tags table (for better search/filtering)
CREATE TABLE recipe_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(recipe_id, tag)
);

CREATE INDEX idx_recipe_tags_recipe_id ON recipe_tags(recipe_id);
CREATE INDEX idx_recipe_tags_tag ON recipe_tags(tag);

ALTER TABLE recipe_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage tags for own recipes"
  ON recipe_tags FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM recipes
      WHERE recipes.id = recipe_tags.recipe_id
      AND recipes.user_id = auth.uid()
    )
  );

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_recipes_updated_at
  BEFORE UPDATE ON recipes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Storage bucket for recipe images (if capturing fridge photos)
INSERT INTO storage.buckets (id, name, public)
VALUES ('recipe-images', 'recipe-images', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for recipe images
CREATE POLICY "Users can upload own recipe images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'recipe-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view own recipe images"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'recipe-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own recipe images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'recipe-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Insert some common ingredients (optional)
INSERT INTO ingredient_library (name, category, common_units) VALUES
  ('chicken breast', 'protein', ARRAY['g', 'kg', 'pieces']),
  ('tomato', 'vegetable', ARRAY['g', 'pieces']),
  ('onion', 'vegetable', ARRAY['g', 'pieces']),
  ('garlic', 'vegetable', ARRAY['cloves', 'g']),
  ('olive oil', 'condiment', ARRAY['ml', 'tbsp']),
  ('salt', 'spice', ARRAY['g', 'tsp']),
  ('black pepper', 'spice', ARRAY['g', 'tsp']),
  ('rice', 'grain', ARRAY['g', 'cups']),
  ('pasta', 'grain', ARRAY['g', 'cups']),
  ('eggs', 'protein', ARRAY['pieces'])
ON CONFLICT (name) DO NOTHING;

-- Create a view for recipe search with user preferences
CREATE OR REPLACE VIEW recipe_search AS
SELECT 
  r.*,
  up.dietary_restrictions,
  up.skill_level as user_skill_level,
  ARRAY_AGG(DISTINCT rt.tag) as tags
FROM recipes r
LEFT JOIN user_preferences up ON r.user_id = up.user_id
LEFT JOIN recipe_tags rt ON r.id = rt.recipe_id
GROUP BY r.id, up.dietary_restrictions, up.skill_level;

-- Grant access to authenticated users
GRANT SELECT ON recipe_search TO authenticated;

COMMENT ON TABLE recipes IS 'Stores user-generated recipes from AI';
COMMENT ON TABLE user_preferences IS 'User dietary preferences and cooking settings';
COMMENT ON TABLE ingredient_library IS 'Common ingredients database for reference';
COMMENT ON TABLE recipe_tags IS 'Tags for recipe categorization and search';
