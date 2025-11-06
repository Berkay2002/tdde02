# Product Requirements Document (PRD)
## AI-Powered Recipe Generator - Flutter MVP

---

## 1. Executive Summary

### Product Vision
Build an innovative Flutter mobile application that leverages on-device AI (Gemma 3n multimodal model) to scan fridge contents, detect ingredients, and generate personalized recipes—all without requiring external APIs or internet connectivity after initial setup.

### Target Audience
- Course project demonstration (primary)
- Students learning AI/ML integration in mobile apps
- Users seeking quick recipe ideas from available ingredients
- Privacy-conscious users preferring on-device processing

### Success Criteria
- ✅ Successfully detect 5+ ingredients from a single fridge photo
- ✅ Generate contextually relevant recipes with ingredients, instructions, and cooking time
- ✅ Complete inference cycle (photo → recipe) in under 10 seconds on mid-range devices
- ✅ Fully functional offline after model download
- ✅ Clean, intuitive UI suitable for course presentation

---

## 2. Technical Stack

### Frontend & Mobile
- **Flutter SDK**: 3.24+ (stable channel)
- **Dart**: 3.5+
- **Target Platforms**: Android (primary), iOS (stretch goal)

### AI/ML Layer
- **Model**: Gemma 3n-E4B-it-int4 (4B effective parameters, multimodal)
  - Supports: Text, image, video, and audio input
  - Context length: 32K tokens
  - Image processing: 256×256, 512×512, or 768×768 resolution
  - 4-bit integer quantization for mobile efficiency
- **Inference**: `tflite_flutter` ^0.10.0
- **Image Processing**: `image` package for preprocessing/resizing

### Camera & Media
- `camera` ^0.11.0 (live preview and capture)
- `image_picker` ^1.1.0 (gallery selection fallback)
- `permission_handler` ^11.0.0 (runtime permissions)

### State Management
- **Riverpod** 3.0 (recommended for async operations)
  - Handles camera streams
  - Manages AI inference state
  - Coordinates async recipe generation

### Backend as a Service
- **Supabase** (PostgreSQL + Auth + Storage)
  - `supabase_flutter` ^2.5.0
  - User authentication (email/password)
  - Recipe history storage
  - User preferences/dietary restrictions
  - Row Level Security (RLS) for data privacy

### Local Storage
- **Hive** ^2.2.3 or **sqflite** ^2.3.0
  - Cache recent recipes
  - Store user preferences offline
  - Model metadata tracking

### Additional Packages
- `dio` ^5.4.0 or `http` ^1.2.0 (Supabase communication)
- `cached_network_image` ^3.3.0 (avatar/profile images)
- `flutter_riverpod` ^2.5.0 (state management foundation)
- `riverpod_annotation` ^2.3.0 (code generation)

---

## 3. Core Features

### 3.1 Camera Scanning (Priority: HIGH)
**User Story**: As a user, I want to take a photo of my fridge so the app can identify available ingredients.

**Acceptance Criteria**:
- [ ] Live camera preview with viewfinder overlay
- [ ] Capture button with haptic feedback
- [ ] Gallery selection as fallback option
- [ ] Real-time preview of captured image
- [ ] Image preprocessing (resize to 512×512, normalize)
- [ ] Permission handling for camera/storage (Android/iOS)

**Technical Implementation**:
```dart
// Camera preview with Riverpod state management
@riverpod
class CameraController {
  - Initialize camera on screen load
  - Handle camera lifecycle (pause/resume)
  - Capture image and convert to format for Gemma 3n
  - Preprocess: resize to 512x512, normalize pixel values
}
```

**Gemma 3n Input Requirements**:
- Image resolution: 512×512 (balance between quality and speed)
- Normalization: Scale pixel values appropriately
- Format: Tensor compatible with TFLite model

---

### 3.2 AI Ingredient Detection (Priority: HIGH)
**User Story**: As a user, I want the app to automatically detect ingredients in my fridge photo.

**Acceptance Criteria**:
- [ ] Process image through Gemma 3n multimodal model
- [ ] Extract ingredient list from AI response
- [ ] Display detected ingredients with confidence (optional)
- [ ] Allow manual editing/removal of detected ingredients
- [ ] Handle edge cases (empty fridge, unclear images)
- [ ] Loading state during inference (1-5 seconds)

**Technical Implementation**:
```dart
// Gemma 3n Wrapper Service
class GemmaInferenceService {
  - Load TFLite model from assets (gemma-3n-e4b-it-int4.tflite)
  - Configure interpreter options (threads: 4, NNAPI delegate)
  - Run multimodal inference: image → text output
  - Parse structured output (ingredient list)
  - Handle errors and timeouts
}
```

**Prompt Template** (System Instructions):
```
You are an intelligent kitchen assistant. Analyze the provided image of a refrigerator or food storage area.

Task:
1. Identify all visible food items and ingredients
2. List them in a structured format
3. Be specific (e.g., "red bell pepper" not just "vegetable")

Output Format:
- Ingredient 1
- Ingredient 2
- Ingredient 3
...

Focus on ingredients suitable for cooking. Ignore containers, utensils, or non-food items.
```

---

### 3.3 AI Recipe Generation (Priority: HIGH)
**User Story**: As a user, I want to receive recipe suggestions based on my detected ingredients.

**Acceptance Criteria**:
- [ ] Generate 1-3 recipe options from detected ingredients
- [ ] Include recipe name, description, cooking time, servings
- [ ] Provide step-by-step cooking instructions
- [ ] List required ingredients (mark available vs. needed)
- [ ] Handle dietary restrictions from user profile
- [ ] Regenerate option if user dislikes suggestion

**Technical Implementation**:
```dart
@riverpod
class RecipeGenerationController {
  - Take ingredient list from detection phase
  - Query Gemma 3n with recipe generation prompt
  - Parse structured recipe response
  - Display recipes in card format
  - Allow saving recipes to Supabase
}
```

**Prompt Template** (Recipe Generation):
```
You are a professional chef assistant. Based on these available ingredients, create a delicious recipe.

Available Ingredients:
{ingredient_list}

Dietary Restrictions: {user_preferences}

Generate ONE complete recipe including:
1. Recipe Name (creative and appetizing)
2. Brief Description (2-3 sentences)
3. Prep Time and Cook Time
4. Servings
5. Full Ingredient List (with quantities)
6. Step-by-step Instructions (numbered)
7. Optional: Cooking tips or variations

Make the recipe practical and achievable for home cooks. Use simple language.
```

**Output Format** (Expected from Gemma 3n):
```
Recipe Name: [Name]
Description: [Description]
Prep Time: [X minutes]
Cook Time: [Y minutes]
Servings: [Z]

Ingredients:
- [Quantity] [Ingredient]
...

Instructions:
1. [Step 1]
2. [Step 2]
...

Tips: [Optional cooking tips]
```

---

### 3.4 User Authentication (Priority: MEDIUM)
**User Story**: As a user, I want to create an account to save my recipe history.

**Acceptance Criteria**:
- [ ] Email/password authentication via Supabase Auth
- [ ] Sign up screen with validation
- [ ] Login screen with "Remember me" option
- [ ] Password reset flow
- [ ] Anonymous mode (skip auth, no saving)
- [ ] User profile with dietary preferences

**Supabase Configuration**:
- Enable Email Authentication in Supabase Dashboard
- Configure email templates (welcome, password reset)
- Set up RLS policies for user-specific data

---

### 3.5 Recipe History & Favorites (Priority: MEDIUM)
**User Story**: As a user, I want to access my previously generated recipes.

**Acceptance Criteria**:
- [ ] Save generated recipes to Supabase
- [ ] Display recipe history in chronological order
- [ ] Mark recipes as favorites
- [ ] Search/filter saved recipes
- [ ] Delete recipes from history
- [ ] Offline access to cached recipes (Hive)

**Database Schema** (Supabase PostgreSQL):
```sql
-- Users table (managed by Supabase Auth)

-- Recipes table
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  recipe_name TEXT NOT NULL,
  description TEXT,
  prep_time INTEGER, -- in minutes
  cook_time INTEGER, -- in minutes
  servings INTEGER,
  ingredients JSONB, -- array of ingredient objects
  instructions JSONB, -- array of instruction steps
  detected_ingredients JSONB, -- original detected ingredients
  is_favorite BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security Policies
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
  USING (auth.uid() = user_id);

-- Users can delete their own recipes
CREATE POLICY "Users can delete own recipes"
  ON recipes FOR DELETE
  USING (auth.uid() = user_id);

-- User Preferences table
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  dietary_restrictions TEXT[], -- ["vegetarian", "gluten-free", etc.]
  favorite_cuisines TEXT[],
  skill_level TEXT, -- "beginner", "intermediate", "advanced"
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for user preferences
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own preferences"
  ON user_preferences FOR ALL
  USING (auth.uid() = user_id);
```

---

### 3.6 User Preferences (Priority: LOW)
**User Story**: As a user, I want to set dietary restrictions so recipes match my needs.

**Acceptance Criteria**:
- [ ] Settings screen for dietary preferences
- [ ] Options: vegetarian, vegan, gluten-free, dairy-free, nut-free
- [ ] Cuisine preferences (optional)
- [ ] Skill level selection (beginner/intermediate/advanced)
- [ ] Persist preferences to Supabase
- [ ] Apply preferences to recipe generation prompts

---

## 4. User Flow

### Primary Flow: Camera → Ingredients → Recipe
```
1. App Launch
   ↓
2. Home Screen (Quick Action: "Scan Fridge")
   ↓
3. Camera Screen
   - Grant camera permission (first time)
   - Live camera preview
   - Tap capture button OR select from gallery
   ↓
4. Image Preview Screen
   - Show captured image
   - "Analyze Ingredients" button
   - "Retake Photo" option
   ↓
5. Ingredient Detection (Loading: 2-5 seconds)
   - Gemma 3n processes image
   - Display detected ingredients list
   - Allow manual edits (add/remove/edit)
   - "Generate Recipe" button
   ↓
6. Recipe Generation (Loading: 3-7 seconds)
   - Gemma 3n generates recipe based on ingredients
   - Display recipe card with name, time, instructions
   - "Save Recipe" / "Generate Another" / "Share"
   ↓
7. Recipe Detail Screen
   - Full recipe view
   - Option to save to favorites
   - Back to home or scan again
```

### Secondary Flow: View Recipe History
```
1. Home Screen
   ↓
2. Navigate to "My Recipes" tab
   ↓
3. Recipe History List
   - Search/filter recipes
   - Tap recipe card to view details
   ↓
4. Recipe Detail Screen
   - View saved recipe
   - Mark as favorite / Delete
```

---

## 5. Architecture & Folder Structure

### Clean Architecture Pattern
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── prompt_templates.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── image_processor.dart
│   │   └── text_parser.dart
│   └── errors/
│       └── exceptions.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   └── data_sources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   ├── camera/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── ingredient_detection/
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   └── gemma_inference_service.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── ingredient.dart
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   ├── recipe_generation/
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   └── recipe_generator_service.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── recipe.dart
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   └── recipe_history/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── providers/
    └── widgets/

assets/
├── models/
│   └── gemma-3n-e4b-it-int4.tflite (to be downloaded)
└── images/

supabase/
├── migrations/
│   └── 001_initial_schema.sql
└── config.toml
```

---

## 6. Model Integration Details

### 6.1 Gemma 3n Model Acquisition
**Source**: Hugging Face - `google/gemma-3n-e4b-it` or `unsloth/gemma-3n-E4B-it-GGUF`

**Conversion to TFLite**:
1. Download GGUF or original model weights
2. Convert to TFLite format using official Google tools
3. Apply int4 quantization for mobile optimization
4. Expected model size: ~2-3 GB (int4 quantized)

**Alternative**: Use pre-converted TFLite model from `google/gemma-3n-e4b-it-tflite` (if available)

### 6.2 TFLite Configuration
```dart
// lib/features/ingredient_detection/data/services/gemma_inference_service.dart

import 'package:tflite_flutter/tflite_flutter.dart';

class GemmaInferenceService {
  Interpreter? _interpreter;
  
  Future<void> initialize() async {
    final options = InterpreterOptions()
      ..threads = 4  // Optimize for quad-core CPUs
      ..useNnApiForAndroid = true  // Android Neural Networks API
      ..addDelegate(GpuDelegateV2());  // GPU acceleration (if available)
    
    _interpreter = await Interpreter.fromAsset(
      'models/gemma-3n-e4b-it-int4.tflite',
      options: options,
    );
    
    _interpreter?.allocateTensors();
  }
  
  Future<String> detectIngredients(Uint8List imageBytes) async {
    // 1. Preprocess image to 512x512
    final processedImage = _preprocessImage(imageBytes);
    
    // 2. Create input tensor with system prompt + image
    final input = _createMultimodalInput(
      systemPrompt: PromptTemplates.ingredientDetection,
      imageData: processedImage,
    );
    
    // 3. Run inference
    final output = List.filled(32768, 0.0); // 32K context length
    _interpreter?.run(input, output);
    
    // 4. Decode output tokens to text
    final detectedIngredients = _decodeOutput(output);
    
    return detectedIngredients;
  }
  
  Uint8List _preprocessImage(Uint8List imageBytes) {
    // Resize to 512x512, normalize pixel values
    // Convert to tensor format expected by Gemma 3n
  }
  
  void dispose() {
    _interpreter?.close();
  }
}
```

### 6.3 Inference Performance Targets
- **Ingredient Detection**: 2-5 seconds on mid-range devices
- **Recipe Generation**: 3-7 seconds on mid-range devices
- **Memory Usage**: < 500 MB during inference
- **Model Load Time**: < 3 seconds on first launch

---

## 7. UI/UX Design Guidelines

### Design Principles
1. **Simplicity**: Minimize steps from scan to recipe
2. **Feedback**: Clear loading states and progress indicators
3. **Error Handling**: Graceful failures with retry options
4. **Accessibility**: High contrast, readable fonts, screen reader support

### Key Screens

#### 7.1 Home Screen
- **Quick Action Button**: Large "Scan Fridge" CTA
- **Bottom Navigation**: Home / My Recipes / Profile
- **Recent Recipes**: Horizontal scrolling cards (3 most recent)

#### 7.2 Camera Screen
- **Full-screen Camera Preview**
- **Capture Button**: Bottom center, large, circular
- **Gallery Icon**: Bottom left corner
- **Flash Toggle**: Top right (if supported)
- **Back Button**: Top left

#### 7.3 Ingredient Detection Screen
- **Image Thumbnail**: Top 30% of screen
- **Detected Ingredients**: Chip-style list (editable)
- **Add Ingredient Button**: Floating action button
- **Generate Recipe Button**: Bottom, full-width, primary color

#### 7.4 Recipe Screen
- **Recipe Card**: 
  - Title (bold, large)
  - Cook time + prep time icons
  - Servings indicator
  - Expandable sections: Ingredients, Instructions, Tips
- **Action Buttons**: Save / Share / Regenerate

#### 7.5 Recipe History Screen
- **Search Bar**: Top, with filter icon
- **Recipe List**: Grid or list view toggle
- **Empty State**: Illustration + "Scan your first fridge" CTA

---

## 8. Non-Functional Requirements

### 8.1 Performance
- App launch time: < 3 seconds (cold start)
- Camera initialization: < 1 second
- Screen transitions: 60 FPS animations
- Supabase queries: < 500ms response time

### 8.2 Security
- Supabase Row Level Security (RLS) enabled on all tables
- User passwords hashed by Supabase Auth
- No sensitive data stored locally (except cached recipes)
- Camera permissions requested with clear explanations

### 8.3 Offline Capability
- View cached recipes without internet
- Camera functionality works offline
- AI inference works offline (after model download)
- Sync saved recipes when connection restored

### 8.4 Scalability
- Support 100+ saved recipes per user
- Efficient Hive caching (max 50 recipes locally)
- Lazy loading for recipe history

### 8.5 Compatibility
- **Android**: Minimum SDK 21 (Lollipop 5.0) for NNAPI support
- **iOS**: iOS 12.0+ (if implementing iOS version)
- **Devices**: Mid-range phones with 4GB+ RAM

---

## 9. Development Phases

### Phase 1: Foundation (Week 1)
- [ ] Flutter project setup with folder structure
- [ ] Integrate Riverpod state management
- [ ] Set up Supabase project and database schema
- [ ] Implement authentication (sign up, login, logout)
- [ ] Design and implement basic UI (Home, Auth screens)

### Phase 2: Camera Integration (Week 2)
- [ ] Implement camera preview screen
- [ ] Handle camera permissions (Android/iOS)
- [ ] Add image capture functionality
- [ ] Integrate image_picker for gallery selection
- [ ] Image preprocessing pipeline (resize, normalize)

### Phase 3: AI Model Integration (Week 3)
- [ ] Download and convert Gemma 3n model to TFLite
- [ ] Integrate tflite_flutter package
- [ ] Implement GemmaInferenceService
- [ ] Test ingredient detection with sample images
- [ ] Optimize inference performance (delegates, threading)

### Phase 4: Recipe Generation (Week 4)
- [ ] Implement recipe generation prompts
- [ ] Parse Gemma 3n output into structured Recipe entity
- [ ] Design and implement Recipe Detail screen
- [ ] Add save recipe functionality (Supabase)
- [ ] Implement recipe history screen

### Phase 5: Polish & Testing (Week 5)
- [ ] UI/UX refinements and animations
- [ ] Error handling and edge cases
- [ ] Performance optimization
- [ ] User testing and bug fixes
- [ ] Prepare demo for course presentation

---

## 10. Risk Assessment & Mitigation

### High-Risk Items

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Gemma 3n model too large for mobile | High | Medium | Use int4 quantization; consider Gemma 3n-E2B (2B version) |
| Slow inference on low-end devices | High | High | Set performance expectations; add "processing" animation |
| Inaccurate ingredient detection | Medium | Medium | Allow manual editing; improve prompt engineering |
| Model conversion issues (TFLite) | High | Medium | Use pre-converted models; fallback to GGUF format |
| Supabase free tier limits | Low | Low | Free tier supports 500MB database (sufficient for MVP) |

### Medium-Risk Items

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Camera permissions denied by user | Medium | Low | Provide clear explanation; offer gallery fallback |
| Recipe output format inconsistent | Medium | Medium | Structured output prompting; fallback parsing |
| Offline sync conflicts | Low | Low | Last-write-wins strategy for MVP |

---

## 11. Success Metrics (Course Demo)

### Demonstration Goals
1. ✅ **End-to-End Flow**: Scan → Detect → Generate → Save (< 60 seconds)
2. ✅ **Accuracy**: Detect 70%+ ingredients correctly
3. ✅ **Quality**: Generate coherent, usable recipe
4. ✅ **Performance**: Smooth UI with no freezing
5. ✅ **Showcase Tech**: Highlight on-device AI, multimodal processing

### Demo Script
```
1. Open app → "Welcome to AI Recipe Generator"
2. Tap "Scan Fridge" → Camera opens
3. Point at fridge/ingredients → Capture photo
4. Show loading → "Analyzing ingredients with Gemma 3n AI..."
5. Display detected ingredients (e.g., chicken, tomatoes, onions, garlic)
6. Edit list (optional) → Tap "Generate Recipe"
7. Show loading → "Creating your personalized recipe..."
8. Display recipe (e.g., "Garlic Chicken with Tomato Sauce")
9. Show ingredients, instructions, cook time
10. Save to favorites → "Recipe saved!"
11. Navigate to "My Recipes" → Show saved recipe
```

---

## 12. Future Enhancements (Post-MVP)

### Phase 2 Features
- [ ] Voice input for ingredient addition
- [ ] Nutritional information calculation
- [ ] Step-by-step cooking mode with timers
- [ ] Social sharing (share recipes with friends)
- [ ] Recipe ratings and reviews

### Advanced AI Features
- [ ] Video analysis (time-lapse fridge scanning)
- [ ] Audio input (describe ingredients verbally)
- [ ] Personalized recommendations based on history
- [ ] Allergen detection and warnings

### Integrations
- [ ] Grocery list generation
- [ ] Integration with grocery delivery APIs
- [ ] Smart home integration (Google Assistant, Alexa)

---

## 13. Appendices

### A. Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # AI/ML
  tflite_flutter: ^0.10.0
  tflite_flutter_helper: ^0.3.1
  image: ^4.1.0
  
  # Camera
  camera: ^0.11.0
  image_picker: ^1.1.0
  permission_handler: ^11.0.0
  
  # Backend
  supabase_flutter: ^2.5.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Network
  dio: ^5.4.0
  cached_network_image: ^3.3.0
  
  # UI
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### B. Prompt Templates Reference
See `lib/core/constants/prompt_templates.dart` for full prompt engineering templates.

### C. Supabase Setup Checklist
- [ ] Create Supabase project
- [ ] Enable Email Authentication
- [ ] Run database migrations
- [ ] Configure RLS policies
- [ ] Generate API keys
- [ ] Add credentials to Flutter app

### D. Model Download Links
- **Gemma 3n (Hugging Face)**: https://huggingface.co/google/gemma-3n-e4b-it
- **TFLite Conversion Guide**: https://ai.google.dev/gemma/docs/gemma-3n
- **Unsloth GGUF Version**: https://huggingface.co/unsloth/gemma-3n-E4B-it-GGUF

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-06 | Course Team | Initial PRD for MVP demo |

**Status**: ✅ Approved for Development  
**Next Review**: After Phase 3 (AI Integration Complete)

---

**End of Document**
