# Epic PRD: Prototype 1 - Core Recipe Generation MVP

## 1. Epic Name

**Prototype 1: Core Recipe Generation MVP**

---

## 2. Goal

### Problem
Home cooks struggle with recipe inspiration when looking at available ingredients. They often:
- Don't know what to cook with ingredients on hand
- Waste food because they can't think of recipes
- Spend time searching recipes online that don't match their skill level or dietary needs
- Face decision fatigue when meal planning

### Solution
Build a mobile app (iOS & Android) that uses AI to generate personalized recipes from ingredient photos. Users simply:
1. Take a photo of ingredients (or add manually)
2. Set cooking preferences (skill level, dietary restrictions, cuisine)
3. Get AI-generated recipes instantly
4. Save favorites for future reference

The app leverages:
- **Google's Gemini AI** via Firebase AI Logic for intelligent ingredient detection and recipe generation
- **Firebase Backend** for authentication, data storage, and security
- **Flutter** for cross-platform mobile development

### Impact
- **Time saved**: 5-10 minutes per meal planning session
- **Food waste reduction**: Users cook with ingredients they have instead of buying new
- **Personalization**: Recipes match user skill level and dietary needs
- **Engagement**: Recipe success rate >70%, with >60% of users saving at least one recipe
- **Retention**: >40% of users return within 7 days

---

## 2.1 Platform Scope & Assumptions

### Supported Platforms
- ✅ **Android**: Minimum SDK 21 (Android 5.0 Lollipop)
- ✅ **iOS**: iOS 13+ (iPhone 6s and newer)

### Device Requirements
- **Camera**: Required for ingredient scanning (fallback: manual text entry)
- **Internet**: Required for AI features (Gemini runs in cloud)
- **Storage**: ~50MB for app, local cache for offline recipe viewing
- **Network**: Stable 3G/4G/5G or WiFi for AI inference (2-5 second response times)

### Online vs. Offline
- **Online (Required)**:
  - User authentication (Firebase Auth)
  - Ingredient detection from photos (Gemini API)
  - Recipe generation (Gemini API)
  - Syncing saved recipes (Firestore)
  - Profile and preferences (Firestore)

- **Limited Offline**:
  - View previously saved recipes (cached locally with Hive)
  - Browse recipe history (cached locally)
  - Manual ingredient entry to pantry
  - UI navigation (no cloud dependencies)

### Key Assumptions
1. Users have smartphones with functional cameras (>90% of target users)
2. Users have reliable internet for primary workflows (recipe generation)
3. Firebase free tier quotas are sufficient for development and small-scale beta testing
   - Gemini API: 15 RPM, 1,500 RPD (free tier)
   - Firestore: 50k reads/day, 20k writes/day (free tier)
4. Recipe generation takes 2-5 seconds under good network conditions
5. Ingredient detection accuracy >70% with clear, well-lit photos

---

## 3. User Personas

### Primary Persona: **Sarah - The Busy Home Cook**
- **Age**: 28-40
- **Occupation**: Working professional
- **Tech Savviness**: Moderate (uses smartphone apps daily)
- **Pain Points**:
  - Limited time for meal planning
  - Wants to reduce food waste
  - Needs simple, quick recipes (30 minutes or less)
  - Follows dietary restrictions (e.g., vegetarian, gluten-free)
- **Goals**:
  - Find recipes for ingredients on hand
  - Cook healthy meals without extensive planning
  - Improve cooking skills gradually
- **Mobile Usage**: High (3-4 hours/day on smartphone)

### Secondary Persona: **Mike - The Novice Cook**
- **Age**: 22-30
- **Occupation**: College student or recent graduate
- **Tech Savviness**: High (early adopter of apps)
- **Pain Points**:
  - Limited cooking experience (beginner level)
  - Unclear instructions in traditional recipes
  - Intimidated by complex recipes
  - Budget-conscious (uses ingredients already purchased)
- **Goals**:
  - Learn basic cooking skills
  - Build confidence in the kitchen
  - Make affordable meals
- **Mobile Usage**: Very high (5+ hours/day on smartphone)

### Tertiary Persona: **Emma - The Health-Conscious Eater**
- **Age**: 30-45
- **Occupation**: Fitness instructor or health professional
- **Tech Savviness**: Moderate to high
- **Pain Points**:
  - Strict dietary requirements (vegan, keto, etc.)
  - Needs nutritional transparency
  - Wants variety in meal planning
- **Goals**:
  - Find recipes that align with diet goals
  - Track saved recipes for meal prep
  - Discover new healthy ingredients
- **Mobile Usage**: High (uses health/fitness apps regularly)

---

## 4. High-Level User Journeys

### Journey 1: First-Time User Onboarding
1. **Download & Install**: User finds app on App Store/Play Store
2. **Welcome Screen**: Sees app value proposition and primary action
3. **Authentication**: Signs up with email or Google Sign-In
4. **Profile Setup**: Sets cooking skill level, dietary restrictions, favorite cuisines
5. **Tutorial (Optional)**: Quick 3-step walkthrough: Scan → Generate → Save
6. **First Recipe**: Encouraged to scan ingredients or use sample photo
7. **Success**: Generates first recipe and saves to history

**Success Metric**: >80% of new users complete first recipe generation within 5 minutes

### Journey 2: Daily Recipe Generation (Core Workflow)
1. **App Launch**: User opens app, sees Home screen
2. **Scan Ingredients**: Taps "Scan Fridge" → Camera opens
3. **Camera Capture**: Takes photo of ingredients or selects from gallery
4. **AI Detection**: Gemini AI detects ingredients (2-5 seconds)
5. **Review & Edit**: User confirms detected ingredients, adds/removes as needed
6. **Optional Pantry**: Adds more ingredients from My Pantry (manual or previous scans)
7. **Generate Recipe**: Taps "Generate Recipe" → AI creates personalized recipe
8. **Recipe Display**: Views recipe with:
   - Name, description, cuisine type
   - Prep/cook time, servings
   - Ingredients list (with quantities)
   - Step-by-step instructions
   - Dietary tags (vegetarian, gluten-free, etc.)
9. **Save or Retry**: Saves to favorites OR generates another recipe
10. **View History**: Accesses saved recipes anytime from "My Recipes" tab

**Success Metric**: >70% of users complete full workflow without errors

### Journey 3: Manual Pantry Management
1. **Navigate to Pantry**: Taps "My Pantry" in bottom navigation
2. **View Pantry**: Sees list of previously detected ingredients
3. **Add Ingredient**: Taps "+" → Types ingredient name → Saves
4. **Manage Items**: Views all pantry items, deletes outdated ones
5. **Use in Recipe**: Selects ingredients → Taps "Use in Recipe" → Navigates to Home
6. **Generate Recipe**: Automatic recipe generation with selected ingredients

**Success Metric**: >50% of active users manually add at least 3 pantry items

### Journey 4: Recipe Discovery & Favorites
1. **Browse Recipes**: Opens "My Recipes" tab
2. **Filter Options**: Sorts by recent, cuisine type, or favorites
3. **View Recipe**: Taps on recipe card → Full recipe details
4. **Mark Favorite**: Taps heart icon to save as favorite
5. **Rate Recipe**: Provides 1-5 star rating (optional)
6. **Add Notes**: Personal notes on recipe (e.g., "Made on 11/10, loved it!")
7. **Regenerate Similar**: Taps "Make Again" → Uses same ingredients to generate new variant

**Success Metric**: >60% of users save at least one recipe as favorite

### Journey 5: Profile & Preferences Management
1. **Navigate to Profile**: Taps "Profile" in bottom navigation
2. **View Profile**: Sees display name, avatar, email
3. **Edit Preferences**: Updates:
   - Skill level (beginner/intermediate/advanced)
   - Dietary restrictions (vegetarian, vegan, gluten-free, etc.)
   - Spice tolerance (none, mild, medium, hot, very hot)
   - Cooking time preference (quick, moderate, long)
   - Favorite cuisines (Italian, Mexican, Asian, etc.)
   - Kitchen equipment available (oven, air fryer, slow cooker, etc.)
4. **Save Changes**: Updates stored in Firestore
5. **Future Recipes**: All generated recipes use updated preferences

**Success Metric**: >40% of users update preferences within first week

---

## 5. Business Requirements

### 5.1 Functional Requirements

#### Authentication & User Management
- ✅ Email/password authentication (Firebase Auth)
- ✅ Google Sign-In integration
- ✅ Automatic user profile creation on signup
- ✅ Session persistence (stay logged in)
- ✅ Password reset functionality
- ✅ Sign out capability
- ❌ Apple Sign-In (future: required for iOS App Store)

#### Camera & Ingredient Detection
- ✅ Camera integration with permission handling
- ✅ Real-time camera preview with capture button
- ✅ Flash toggle for low-light conditions
- ✅ Gallery/photo picker integration
- ✅ Image preprocessing (resize to 512×512, normalize)
- ✅ Gemini AI multimodal ingredient detection (image + text prompt)
- ✅ Ingredient list display with edit capabilities
- ✅ Add/remove detected ingredients manually
- ❌ Barcode scanning (future enhancement)
- ❌ Batch photo processing (future enhancement)

#### Recipe Generation
- ✅ AI recipe generation using Gemini API (gemini-2.5-flash)
- ✅ Personalized recipes based on:
  - Detected/selected ingredients
  - User dietary restrictions
  - Skill level
  - Cuisine preference
  - Cooking time preference
  - Spice tolerance
- ✅ Structured recipe output (JSON format):
  - Recipe name and description
  - Cuisine type, difficulty level, meal type
  - Prep time, cook time, total time
  - Servings
  - Ingredients with quantities
  - Step-by-step instructions
  - Dietary tags (vegetarian, vegan, etc.)
  - Allergen warnings
- ✅ Recipe caching in Firestore (avoid duplicate API calls)
- ✅ Retry logic with exponential backoff
- ✅ Error handling for API failures
- ❌ Streaming recipe generation (future: real-time text streaming)
- ❌ Multiple recipe suggestions (future: generate 3-5 options)

#### Pantry Management
- ✅ Manual ingredient entry (type to add)
- ✅ View all pantry items as list
- ✅ Delete individual ingredients
- ✅ Clear all pantry items (with confirmation)
- ✅ Use pantry ingredients for recipe generation
- 🔄 **Planned**: Category-based organization (vegetables, proteins, dairy, etc.)
- 🔄 **Planned**: Ingredient search and filtering
- 🔄 **Planned**: Quantity tracking (e.g., "2 cups", "500g")
- 🔄 **Planned**: Freshness indicators (use soon, use immediately)
- ❌ Expiration date tracking (future enhancement)

#### Recipe History & Favorites
- ✅ Save generated recipes to Firestore
- ✅ View all saved recipes ("My Recipes" tab)
- ✅ Mark recipes as favorites (heart icon)
- ✅ View favorite recipes separately
- ✅ Recipe detail view with full information
- ✅ Recipe rating (1-5 stars)
- ✅ Personal notes on recipes
- ✅ Delete saved recipes
- ❌ Recipe sharing (future: share via link/social media)
- ❌ Recipe export (future: PDF/image export)
- ❌ Meal planning calendar (future: assign recipes to dates)

#### User Profile & Preferences
- ✅ Display name, email, avatar (from Google Sign-In)
- ✅ Editable cooking preferences:
  - Skill level (beginner, intermediate, advanced)
  - Dietary restrictions (multi-select)
  - Spice tolerance (none to very hot)
  - Cooking time preference (quick <30min, moderate 30-60min, long >60min)
  - Favorite cuisines (multi-select)
  - Kitchen equipment (multi-select)
- ✅ Language preference (currently English only)
- ✅ Theme preference (light/dark mode)
- ✅ Notification settings (on/off toggle)
- ❌ Profile photo upload (future enhancement)
- ❌ Bio/description field (future enhancement)

#### Navigation & UI
- ✅ Bottom navigation bar with 5 tabs:
  1. **Home**: Quick scan/search, recent recipes
  2. **My Recipes**: Saved recipes and favorites
  3. **My Pantry**: Pantry management
  4. **Favorites**: Quick access to favorite recipes
  5. **Profile**: User settings and preferences
- ✅ App shell structure (persistent bottom nav)
- ✅ Smooth transitions between screens
- ✅ Loading states for async operations
- ✅ Error states with retry actions
- ✅ Empty states with helpful CTAs
- ✅ Splash screen with app initialization

### 5.2 Non-Functional Requirements

#### Performance
- **Target**: AI responses in 2-5 seconds under good network (4G/5G, WiFi)
- **Target**: UI maintains 60fps during navigation and scrolling
- **Target**: App startup time <3 seconds (cold start)
- **Target**: Camera preview latency <500ms
- **Constraint**: Gemini API free tier limits (15 RPM, 1,500 RPD)
- **Optimization**: Recipe caching in Firestore to reduce API calls
- **Optimization**: Local caching with Hive for offline recipe viewing
- **Monitoring**: Log slow API responses (>10 seconds) for debugging

#### Security & Privacy
- **Authentication**: Firebase Auth with email/password and Google Sign-In
- **Authorization**: Firestore security rules enforce user data isolation
  - Users can only access their own profiles, preferences, recipes, and pantry
  - Rules: `request.auth.uid == resource.data.user_id`
- **API Protection**: Firebase App Check enabled (debug mode for dev, Play Integrity/App Attest for prod)
- **Data Encryption**: Firebase encrypts data in transit (HTTPS) and at rest
- **Privacy**:
  - User images sent to Gemini API for processing (Google's privacy policy applies)
  - No user data shared with third parties beyond Firebase/Google Cloud
  - Users can delete their data (account deletion in future)
- **Compliance**: GDPR-ready (data export/deletion in future), no PII collected beyond email

#### Data Model Alignment
- **Firestore Collections**:
  1. **`profiles`**: User profile data (document ID = user's UID)
     - Fields: `user_id`, `email`, `display_name`, `avatar_url`, `bio`, `language_preference`, `theme_preference`, `notifications_enabled`, `created_at`, `updated_at`
  2. **`user_preferences`**: Cooking preferences (document ID = user's UID)
     - Fields: `user_id`, `skill_level`, `spice_tolerance`, `cooking_time_preference`, `dietary_restrictions` (array), `excluded_ingredients` (array), `favorite_cuisines` (array), `favorite_proteins` (array), `kitchen_equipment` (array), `created_at`, `updated_at`
  3. **`recipes`**: AI-generated recipes (auto-generated document IDs)
     - Fields: `user_id`, `recipe_name`, `description`, `cuisine_type`, `difficulty_level`, `meal_type`, `prep_time`, `cook_time`, `total_time`, `servings`, `ingredients` (array), `instructions` (array), `detected_ingredients` (array), `dietary_tags` (array), `allergens` (array), `is_favorite` (boolean), `rating` (1-5), `notes`, `created_at`, `updated_at`
  4. **`recipe_cache`**: Cached recipe generations (document ID = `{userId}_{cacheKey}`)
     - Fields: `user_id`, `cache_key` (hash of ingredients + preferences), `cached_recipe` (full recipe object), `created_at`
     - TTL: 7 days (configurable)

- **Field Naming**: snake_case (e.g., `user_id`, `created_at`)
- **Timestamps**: Firestore `FieldValue.serverTimestamp()`
- **Arrays**: Firestore array type for multi-value fields (e.g., `dietary_restrictions`)

#### API Quotas & Rate Limiting
- **Gemini API Free Tier**:
  - 15 requests per minute (RPM)
  - 1,500 requests per day (RPD)
  - Input: 1M tokens/min
  - Output: 32k tokens/min
- **Caching Strategy**:
  - Hash ingredients + preferences → Check `recipe_cache` collection
  - If cached (< 7 days old), return instantly
  - If not cached, call Gemini API → Save to cache
- **Retry Logic**: Exponential backoff (2s, 4s, 8s) with max 3 retries
- **Quota Handling**: User-friendly error message if quota exceeded, suggest retry later
- **Monitoring**: Track API usage in Firebase Console (AI Logic dashboard)

#### Accessibility
- **Color Contrast**: WCAG AA compliance (4.5:1 ratio for text)
- **Screen Reader Support**:
  - Semantic labels for all interactive elements
  - Meaningful button descriptions (e.g., "Capture photo" not "Button")
  - Alternative text for images
- **Touch Targets**: Minimum 48×48dp for all tappable elements
- **Font Scaling**: Support system font size settings (0.8x to 1.3x)
- **Dark Mode**: Full support with high contrast
- **Focus Indicators**: Visible focus states for keyboard navigation (future: tablet support)

#### Observability & Logging
- **Logging**:
  - Print statements for key events (AI initialization, API calls, errors)
  - Log format: `[Service]: Action - Details`
  - Example: `GeminiAIService: Starting ingredient detection`
- **Error Tracking**: Console logs for debugging (future: Crashlytics integration)
- **Performance Monitoring**: Manual logging of slow operations (future: Firebase Performance)
- **Analytics**: Basic usage tracking planned (future: Firebase Analytics)
  - Events: app_open, recipe_generated, recipe_saved, ingredient_detected
  - User properties: skill_level, dietary_restrictions

#### Platform-Specific Requirements
- **Android**:
  - Minimum SDK 21 (Android 5.0)
  - Target SDK 34 (Android 14)
  - Permissions: CAMERA, READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE
  - Google Play Services required (for Firebase and Google Sign-In)
  - App Check: Play Integrity API
- **iOS**:
  - Minimum iOS 13
  - Permissions: Camera, Photo Library
  - App Check: App Attest
  - Usage descriptions in Info.plist:
    - `NSCameraUsageDescription`: "We need camera access to scan your ingredients"
    - `NSPhotoLibraryUsageDescription`: "We need photo access to select ingredient photos"

---

## 6. Success Metrics

### 6.1 Primary KPIs (Must Track)

1. **Recipe Generation Completion Rate**
   - **Definition**: % of users who start recipe generation (tap "Generate Recipe") and receive a valid recipe
   - **Target**: >70%
   - **Measurement**: Track start event vs. success event in logs
   - **Failure Reasons**: API errors, quota exceeded, network timeout

2. **Average Recipe Generation Latency**
   - **Definition**: Time from "Generate Recipe" button tap to recipe display
   - **Target**: <5 seconds (good network), <10 seconds (poor network)
   - **Measurement**: Log timestamps for start and end events
   - **Breakdown**: API call time vs. UI rendering time

3. **Cache Hit Rate**
   - **Definition**: % of recipe generations served from Firestore cache vs. new Gemini API calls
   - **Target**: >30% (indicates users regenerate with similar ingredients)
   - **Measurement**: Log cache hit vs. cache miss events
   - **Impact**: Reduces API quota usage and improves latency

4. **Daily Active Users (DAU)**
   - **Definition**: Number of unique users who open the app per day
   - **Target**: >50 users (beta phase), >500 users (public launch)
   - **Measurement**: Track app_open events with user IDs

5. **Recipe Save Rate**
   - **Definition**: % of generated recipes that are saved to "My Recipes"
   - **Target**: >60%
   - **Measurement**: Track save events vs. generation events
   - **Insight**: Indicates recipe quality and user satisfaction

### 6.2 Secondary KPIs (Nice to Have)

6. **Ingredient Detection Accuracy (User Perception)**
   - **Definition**: % of detected ingredients that are NOT manually removed by user
   - **Target**: >70%
   - **Measurement**: Compare detected ingredients vs. final confirmed list
   - **Caveat**: User perception, not ground truth

7. **User Retention (7-Day)**
   - **Definition**: % of new users who return within 7 days
   - **Target**: >40%
   - **Measurement**: Track user cohorts and return visits

8. **Favorite Recipe Rate**
   - **Definition**: % of saved recipes that are marked as favorites
   - **Target**: >30%
   - **Measurement**: Track favorite events vs. save events

9. **Error Rate**
   - **Definition**: % of recipe generations that fail due to errors
   - **Target**: <10%
   - **Measurement**: Log error events (permission denied, quota exceeded, network error)
   - **Breakdown by Error Type**: API error, network error, permission error

10. **User Engagement (Session Duration)**
    - **Definition**: Average time spent in app per session
    - **Target**: >3 minutes
    - **Measurement**: Track session start/end timestamps

### 6.3 Operational Metrics (Internal)

11. **Gemini API Usage**
    - **Requests per Day (RPD)**: Monitor against 1,500 limit
    - **Requests per Minute (RPM)**: Monitor against 15 limit
    - **Token Usage**: Input/output tokens per request

12. **Firestore Usage**
    - **Reads per Day**: Monitor against 50k free tier limit
    - **Writes per Day**: Monitor against 20k free tier limit
    - **Storage**: Monitor document count and size

13. **App Crash Rate**
    - **Definition**: % of sessions that end in a crash
    - **Target**: <1%
    - **Measurement**: Future: Firebase Crashlytics

---

## 7. Out of Scope (Explicitly NOT in Prototype 1)

### Features Deferred to Prototype 2 or Later
- ❌ **Apple Sign-In**: Required for iOS App Store, but not for beta testing
- ❌ **Social Media Sign-In**: Facebook, Twitter authentication
- ❌ **Recipe Sharing**: Share recipes via link, social media, or export
- ❌ **Recipe Export**: PDF or image export of recipes
- ❌ **Meal Planning**: Calendar view, assign recipes to dates
- ❌ **Shopping List**: Auto-generate shopping list from recipe ingredients
- ❌ **Nutritional Information**: Calories, macros, vitamins
- ❌ **Ingredient Substitutions**: AI-suggested alternatives (e.g., "use honey instead of sugar")
- ❌ **Barcode Scanning**: Scan product barcodes to add ingredients
- ❌ **Batch Photo Processing**: Scan multiple photos at once
- ❌ **Streaming Responses**: Real-time text streaming for recipe generation
- ❌ **Multiple Recipe Suggestions**: Generate 3-5 recipe options per request
- ❌ **Recipe Variations**: "Make this vegan" or "Make this spicy" modifications
- ❌ **Community Features**: Share recipes with other users, comments, likes
- ❌ **Recipe Collections**: Organize recipes into custom collections (e.g., "Weekend Dinners")
- ❌ **Voice Input**: Voice-to-text for ingredient entry
- ❌ **Ingredient Expiration Tracking**: Track expiration dates and send reminders
- ❌ **Recipe Recommendations**: "You might like..." based on favorites
- ❌ **Cooking Timers**: In-app timers for recipe steps
- ❌ **Step-by-Step Mode**: Guided cooking mode with voice instructions
- ❌ **Profile Photo Upload**: Custom avatar upload
- ❌ **Account Deletion**: GDPR-compliant account deletion
- ❌ **Data Export**: Export all user data (GDPR requirement)
- ❌ **Multi-Language Support**: Translations beyond English
- ❌ **Web Version**: Browser-based app
- ❌ **Tablet Optimization**: Dedicated iPad/Android tablet UI
- ❌ **Offline Mode (Full)**: Full offline recipe generation (requires on-device AI)
- ❌ **Firebase Analytics**: Detailed event tracking and funnels
- ❌ **Firebase Crashlytics**: Automatic crash reporting
- ❌ **Firebase Performance Monitoring**: Detailed performance traces

### Technical Constraints
- **No Custom Backend**: Firebase only, no custom Node.js/Python servers
- **No Third-Party AI Models**: Gemini API only, no OpenAI/Anthropic integrations
- **No Payment Integration**: No in-app purchases or subscriptions
- **No Push Notifications**: No Firebase Cloud Messaging (FCM) integration
- **No A/B Testing**: No Firebase Remote Config or A/B testing

### Platform Limitations
- **No macOS/Windows Apps**: Mobile-first (iOS/Android only)
- **No Wearables**: No Apple Watch or Wear OS apps
- **No AR Features**: No augmented reality ingredient scanning

---

## 8. Business Value

### Estimated Business Value: **HIGH**

#### Justification

1. **Market Need**: High demand for meal planning and recipe discovery tools
   - 73% of home cooks report decision fatigue when planning meals (industry research)
   - Food waste reduction is a growing consumer priority
   - Personalized nutrition and dietary preferences are mainstream

2. **Differentiation**: AI-powered, camera-first approach
   - Traditional recipe apps require manual search and browsing
   - Competitors (Yummly, Tasty) focus on recipe discovery, not ingredient-driven generation
   - Gemini AI provides state-of-the-art multimodal understanding (image + text)

3. **Scalability**: Cloud-based architecture with low infrastructure costs
   - Firebase free tier supports up to 1,500 recipe generations/day
   - Minimal maintenance (no custom servers)
   - Pay-as-you-grow pricing model

4. **User Engagement**: High potential for daily usage
   - Daily meal planning = daily app usage
   - Habit-forming workflow (scan → generate → cook)
   - Saved recipes encourage repeat visits

5. **Monetization Potential** (Future):
   - Freemium model: Free tier (5 recipes/day) + Premium (unlimited)
   - Affiliate partnerships: Ingredient delivery services (Instacart, Amazon Fresh)
   - Premium features: Meal planning, nutritional info, custom recipe collections

6. **Learning Opportunity**: First prototype of 2 for MVP
   - Validate core assumptions (AI accuracy, user workflow, engagement)
   - Test Firebase + Gemini integration at scale
   - Gather user feedback to inform Prototype 2 scope

#### Risks
- **AI Accuracy**: Gemini's ingredient detection may not be 100% accurate
  - Mitigation: Allow manual editing of detected ingredients
- **API Quotas**: Free tier limits (1,500 RPD) may be insufficient for scale
  - Mitigation: Implement aggressive caching, monitor usage, plan for paid tier
- **User Adoption**: Requires behavior change (camera-first workflow)
  - Mitigation: Strong onboarding tutorial, clear value proposition
- **Competition**: Recipe apps are a saturated market
  - Mitigation: Focus on unique AI-powered, ingredient-driven experience

#### Expected ROI
- **Development Cost**: ~4-6 weeks (solo developer with Flutter + Firebase experience)
- **Operating Cost**: $0 (Firebase free tier) during beta phase
- **User Acquisition Cost**: $0 (organic growth, word-of-mouth during beta)
- **Expected Beta Users**: 50-100 users in first month
- **Path to Revenue**: Validate PMF (product-market fit) before monetization

---

## Appendix: Repository Context Reference

### Tech Stack Summary
- **Platform**: Flutter 3.24+ (Dart 3.9.2)
- **State Management**: Riverpod (flutter_riverpod 2.5.1, codegen with riverpod_generator)
- **Backend**: Firebase (Auth, Firestore, App Check)
- **AI**: Firebase AI Logic with Gemini API (gemini-2.5-flash)
- **Storage**: Firestore (cloud) + Hive (local cache)
- **Camera**: camera 0.11.0+2, image_picker 1.1.2, permission_handler 11.3.1
- **Build Tools**: build_runner, freezed, json_serializable

### Firestore Collections
1. **`profiles`**: User profiles (document ID = user UID)
2. **`user_preferences`**: Cooking preferences (document ID = user UID)
3. **`recipes`**: Saved recipes (auto-generated IDs, scoped to `user_id`)
4. **`recipe_cache`**: Cached AI generations (document ID = `{userId}_{cacheKey}`)

### Security
- **Firestore Rules**: Require authentication, per-user scoping (`request.auth.uid == resource.data.user_id`)
- **App Check**: Enabled (debug mode for dev, Play Integrity/App Attest for prod)
- **API Quotas**: Gemini API free tier (15 RPM, 1,500 RPD)

### Performance Targets
- **AI Response Time**: 2-5 seconds (good network)
- **UI Frame Rate**: 60fps
- **App Startup**: <3 seconds (cold start)
- **Camera Latency**: <500ms to preview

### Accessibility
- **Color Contrast**: WCAG AA (4.5:1)
- **Screen Reader**: Semantic labels for all UI
- **Touch Targets**: Minimum 48×48dp
- **Font Scaling**: 0.8x to 1.3x

### Monitoring
- **Logging**: Print statements for key events
- **Error Tracking**: Console logs (future: Crashlytics)
- **Analytics**: Planned (future: Firebase Analytics)

---

## Document Metadata

- **Epic Type**: Prototype 1 (MVP)
- **Total Prototypes Planned**: 2
- **Document Version**: 1.0
- **Created**: November 11, 2025
- **Last Updated**: November 11, 2025
- **Author**: Berkay 
- **Status**: ✅ Complete - Ready for Technical Architecture Specification

---
