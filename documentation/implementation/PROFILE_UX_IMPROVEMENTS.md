# Profile Screen UX/UI Improvements - Implementation Plan

**Status**: 📋 Planning Phase  
**Last Updated**: November 12, 2025

## Overview
This document outlines planned improvements for the Profile screen to enhance user experience, visual appeal, and functionality, following similar patterns established in the Pantry, Recipes, and Favorites screen improvements.

## Current State Analysis

### Profile Screen (`profile_screen.dart`)
**Current Features:**
- Basic user info card with avatar
- Dietary restrictions selector (8 options via FilterChips)
- Cooking skill level selector (3 levels via RadioListTiles)
- Cuisine preference selector (10+ cuisines via RadioListTiles)
- Theme mode toggle (light/dark)
- Reset to defaults button with confirmation

**Missing Features:**
- No statistics or cooking insights
- No account information (email, join date, etc.)
- Basic card designs without visual hierarchy
- No user avatar upload/customization
- No excluded ingredients management
- No notification preferences
- No app settings (language, units, etc.)
- No about/help section
- No data export/import
- No gamification (badges, achievements)
- Limited visual polish and animations
- No quick stats (recipes generated, favorites, pantry items)

---

## Phase 1: Enhanced User Profile Header ✨

### 1.1 Improved User Info Card
**Goal**: Create a visually appealing profile header with key stats

**Current**: Basic card with generic person icon and static text

**Improved Design**:
```
┌─────────────────────────────────────────────┐
│                                              │
│       [Large Avatar - 80px]                  │
│          user@email.com                      │
│       Member since Nov 2025                  │
│                                              │
│  ┌──────────┬──────────┬──────────────┐    │
│  │    15    │    42    │      8       │    │
│  │ Recipes  │Favorites │ Pantry Items │    │
│  └──────────┴──────────┴──────────────┘    │
│                                              │
└─────────────────────────────────────────────┘
```

**Features**:
- Larger avatar (80px) with gradient border
- User email from Firebase Auth
- Member since date
- Quick stats row: total recipes, favorites count, pantry items
- Edit profile button (future: avatar upload)

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/profile_header_card.dart
class ProfileHeaderCard extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final recipesCount = ref.watch(favoriteRecipesProvider).length;
    final pantryCount = ref.watch(pantryIngredientsProvider).length;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Large avatar with gradient border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(...),
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(radius: 40, ...),
            ),
            
            // Email & join date
            Text(user?.email ?? 'Guest'),
            Text('Member since ${_formatDate(user?.createdAt)}'),
            
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(count: recipesCount, label: 'Recipes'),
                _StatColumn(count: recipesCount, label: 'Favorites'),
                _StatColumn(count: pantryCount, label: 'Pantry Items'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: titleLarge.bold),
        Text(label, style: bodySmall.gray),
      ],
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/profile_header_card.dart`

**Files to modify**:
- `lib/features/profile/presentation/screens/profile_screen.dart` - Replace basic user info card

---

## Phase 2: Cooking Insights & Statistics 📊

### 2.1 Cooking Stats Card
**Goal**: Show personalized cooking insights and achievements

**Metrics**:
- Total recipes generated
- Favorite recipes count
- Pantry items managed
- Most common cuisine preference
- Most common dietary restrictions
- Average skill level progression
- Recipes generated this week/month

**Design**:
```
┌──────────────────────────────────────────┐
│  🍳 Your Cooking Journey                  │
│  ─────────────────────────────────        │
│                                           │
│  📖 42 recipes discovered                 │
│  ❤️ 15 favorites saved                    │
│  🥬 8 pantry items tracked                │
│  🍝 Most loved: Italian cuisine           │
│  📅 5 recipes generated this week         │
│                                           │
└──────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/cooking_stats_card.dart
class CookingStatsCard extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteRecipesProvider);
    final pantryItems = ref.watch(pantryIngredientsProvider);
    final profile = ref.watch(dietaryProfileProvider);
    
    // Calculate stats
    final recipesThisWeek = _countRecentRecipes(favorites, days: 7);
    final mostLovedCuisine = profile.cuisinePreference ?? 'All Cuisines';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, size: 28),
                SizedBox(width: 12),
                Text('Your Cooking Journey', style: titleMedium.bold),
              ],
            ),
            Divider(),
            _StatRow(icon: Icons.book, text: '${favorites.length} recipes discovered'),
            _StatRow(icon: Icons.favorite, text: '${favorites.length} favorites saved'),
            _StatRow(icon: Icons.eco, text: '${pantryItems.length} pantry items tracked'),
            _StatRow(icon: Icons.restaurant_menu, text: 'Most loved: $mostLovedCuisine'),
            _StatRow(icon: Icons.calendar_today, text: '$recipesThisWeek recipes this week'),
          ],
        ),
      ),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/cooking_stats_card.dart`

### 2.2 Achievement Badges (Future)
**Goal**: Gamification to encourage engagement

**Badges**:
- 🥉 First Recipe Generated
- 🥈 10 Recipes Saved
- 🥇 100 Recipes Discovered
- 🌟 Recipe Master (50+ favorites)
- 🥗 Health Conscious (vegetarian/vegan)
- 🌍 World Explorer (tried 5+ cuisines)
- 🔥 Weekly Streak (generated recipes 7 days in a row)

**Priority**: Low - Future enhancement

---

## Phase 3: Enhanced Preference Selectors 🎨

### 3.1 Visual Dietary Restrictions Selector
**Goal**: More engaging and informative restriction selector

**Current**: Basic FilterChips in a Card

**Improved**:
- Icons for each restriction
- Color-coded chips
- Description tooltips on long press
- "Select All" / "Clear All" buttons
- Count indicator

**Design**:
```
Dietary Restrictions (3 selected)
[Select All] [Clear All]

[✓ 🥗 Vegetarian]  [✓ 🌾 Gluten-Free]  [ 🥛 Dairy-Free]
[ 🥜 Nut-Free]     [ ☪️ Halal]          [✓ 🔻 Low-Carb]
[ ✡️ Kosher]       [ 🌱 Vegan]
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/dietary_restrictions_card.dart
class DietaryRestrictionsCard extends StatelessWidget {
  final List<String> selectedRestrictions;
  final ValueChanged<List<String>> onChanged;
  
  static const _restrictionsWithIcons = {
    'Vegetarian': '🥗',
    'Vegan': '🌱',
    'Gluten-Free': '🌾',
    'Dairy-Free': '🥛',
    'Nut-Free': '🥜',
    'Halal': '☪️',
    'Kosher': '✡️',
    'Low-Carb': '🔻',
  };
  
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dietary Restrictions (${selectedRestrictions.length} selected)',
                  style: titleMedium.bold,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => onChanged(_restrictionsWithIcons.keys.toList()),
                      child: Text('Select All'),
                    ),
                    TextButton(
                      onPressed: () => onChanged([]),
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Chips with icons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _restrictionsWithIcons.entries.map((entry) {
                final isSelected = selectedRestrictions.contains(entry.key);
                return FilterChip(
                  avatar: Text(entry.value, style: TextStyle(fontSize: 18)),
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedRestrictions);
                    selected ? updated.add(entry.key) : updated.remove(entry.key);
                    onChanged(updated);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/dietary_restrictions_card.dart`

### 3.2 Skill Level with Progress Visualization
**Goal**: Show skill level as a journey, not just radio buttons

**Design**:
```
┌─────────────────────────────────────────┐
│ Cooking Skill Level                      │
│ ─────────────────────────────────        │
│                                          │
│ [Beginner] ──●────○────○ [Advanced]     │
│              ▲                           │
│         Intermediate                     │
│                                          │
│ Simple recipes with basic techniques     │
│                                          │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/skill_level_card.dart
class SkillLevelCard extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onChanged;
  
  static const _levels = [
    SkillLevelData(
      value: 'beginner',
      label: 'Beginner',
      description: 'Simple recipes with basic techniques',
      icon: Icons.egg,
    ),
    SkillLevelData(
      value: 'intermediate',
      label: 'Intermediate',
      description: 'Moderate complexity and cooking time',
      icon: Icons.restaurant,
    ),
    SkillLevelData(
      value: 'advanced',
      label: 'Advanced',
      description: 'Complex recipes and techniques',
      icon: Icons.whatshot,
    ),
  ];
  
  Widget build(BuildContext context) {
    final currentIndex = _levels.indexWhere((l) => l.value == selectedLevel);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cooking Skill Level', style: titleMedium.bold),
            SizedBox(height: 16),
            
            // Visual slider/progress indicator
            Row(
              children: List.generate(3, (index) {
                final isSelected = index == currentIndex;
                final isPassed = index < currentIndex;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(_levels[index].value),
                    child: Column(
                      children: [
                        Icon(
                          _levels[index].icon,
                          size: isSelected ? 40 : 28,
                          color: isSelected || isPassed 
                            ? theme.primaryColor 
                            : theme.disabledColor,
                        ),
                        Text(
                          _levels[index].label,
                          style: isSelected ? bodyMedium.bold : bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            
            SizedBox(height: 12),
            Text(
              _levels[currentIndex].description,
              style: bodyMedium.gray,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/skill_level_card.dart`

### 3.3 Collapsible Cuisine Preference
**Goal**: Better UX for long list of cuisines

**Current**: Long RadioListTile list (10+ items) in a Card

**Improved**:
- Grid view with cuisine icons
- Search/filter for cuisines
- "No Preference" as default chip
- Visual cuisine icons (🍝 🍜 🌮 etc.)

**Design**:
```
┌─────────────────────────────────────────┐
│ Preferred Cuisine                        │
│ [Search cuisines...]                     │
│                                          │
│ [✓ No Preference]                       │
│                                          │
│ [🍝 Italian]  [🍜 Asian]    [🌮 Mexican] │
│ [🥖 French]   [🍛 Indian]   [🌍 Mediter.]│
│ [🍔 American] [🍱 Japanese] [🥙 Middle E.]│
│                                          │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/cuisine_preference_card.dart
class CuisinePreferenceCard extends StatefulWidget {
  final String? selectedCuisine;
  final ValueChanged<String?> onChanged;
  
  _CuisinePreferenceCardState createState() => _CuisinePreferenceCardState();
}

class _CuisinePreferenceCardState extends State<CuisinePreferenceCard> {
  String _searchQuery = '';
  
  static const _cuisinesWithIcons = {
    'Italian': '🍝',
    'Asian': '🍜',
    'Mexican': '🌮',
    'Mediterranean': '🌍',
    'American': '🍔',
    'Indian': '🍛',
    'French': '🥖',
    'Thai': '🌶️',
    'Japanese': '🍱',
    'Middle Eastern': '🥙',
  };
  
  Widget build(BuildContext context) {
    final filteredCuisines = _searchQuery.isEmpty
        ? _cuisinesWithIcons.entries.toList()
        : _cuisinesWithIcons.entries
            .where((e) => e.key.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferred Cuisine', style: titleMedium.bold),
            SizedBox(height: 12),
            
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search cuisines...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            SizedBox(height: 12),
            
            // No Preference chip
            FilterChip(
              label: Text('No Preference'),
              selected: widget.selectedCuisine == null,
              onSelected: (_) => widget.onChanged(null),
            ),
            SizedBox(height: 12),
            
            // Cuisine grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredCuisines.map((entry) {
                final isSelected = widget.selectedCuisine == entry.key;
                return FilterChip(
                  avatar: Text(entry.value, style: TextStyle(fontSize: 18)),
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (_) => widget.onChanged(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/cuisine_preference_card.dart`

---

## Phase 4: Additional Settings & Preferences ⚙️

### 4.1 Excluded Ingredients Manager
**Goal**: Manage ingredients user never wants in recipes

**Features**:
- List of excluded ingredients
- Add ingredient with autocomplete
- Remove ingredient with swipe
- Quick tags (common allergens)

**Design**:
```
┌─────────────────────────────────────────┐
│ Excluded Ingredients                     │
│ Never include these in recipes           │
│                                          │
│ [+ Add ingredient...]                    │
│                                          │
│ Quick add: [Peanuts] [Shellfish] [Soy]  │
│                                          │
│ Your exclusions:                         │
│ • Mushrooms              [×]             │
│ • Olives                 [×]             │
│ • Anchovies              [×]             │
│                                          │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/excluded_ingredients_card.dart
class ExcludedIngredientsCard extends StatefulWidget {
  final List<String> excludedIngredients;
  final ValueChanged<List<String>> onChanged;
  
  _ExcludedIngredientsCardState createState() => _ExcludedIngredientsCardState();
}

class _ExcludedIngredientsCardState extends State<ExcludedIngredientsCard> {
  final _controller = TextEditingController();
  
  static const _quickAddIngredients = [
    'Peanuts', 'Shellfish', 'Soy', 'Eggs', 'Fish', 'Mushrooms',
  ];
  
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Excluded Ingredients', style: titleMedium.bold),
            Text(
              'Never include these in recipes',
              style: bodySmall.gray,
            ),
            SizedBox(height: 12),
            
            // Add ingredient field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Add ingredient...',
                prefixIcon: Icon(Icons.add),
                suffixIcon: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: _addIngredient,
                ),
              ),
              onSubmitted: (_) => _addIngredient(),
            ),
            SizedBox(height: 12),
            
            // Quick add chips
            Text('Quick add:', style: bodySmall),
            Wrap(
              spacing: 8,
              children: _quickAddIngredients.map((ingredient) {
                final isExcluded = widget.excludedIngredients.contains(ingredient);
                return ActionChip(
                  label: Text(ingredient),
                  onPressed: isExcluded ? null : () => _quickAdd(ingredient),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            
            // List of excluded ingredients
            if (widget.excludedIngredients.isNotEmpty) ...[
              Text('Your exclusions:', style: bodyMedium.bold),
              SizedBox(height: 8),
              ...widget.excludedIngredients.map((ingredient) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.circle, size: 8),
                  title: Text(ingredient),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _removeIngredient(ingredient),
                  ),
                );
              }),
            ] else
              Text('No exclusions yet', style: bodySmall.gray),
          ],
        ),
      ),
    );
  }
  
  void _addIngredient() {
    final ingredient = _controller.text.trim();
    if (ingredient.isNotEmpty && !widget.excludedIngredients.contains(ingredient)) {
      widget.onChanged([...widget.excludedIngredients, ingredient]);
      _controller.clear();
    }
  }
  
  void _quickAdd(String ingredient) {
    widget.onChanged([...widget.excludedIngredients, ingredient]);
  }
  
  void _removeIngredient(String ingredient) {
    widget.onChanged(
      widget.excludedIngredients.where((i) => i != ingredient).toList(),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/excluded_ingredients_card.dart`

**Files to modify**:
- `lib/shared/providers/app_state_provider.dart` - Add excludedIngredients to DietaryProfile

### 4.2 App Settings Section
**Goal**: Centralize app-level preferences

**Settings**:
- Measurement units (metric/imperial)
- Language (future)
- Notifications (future)
- Default serving size
- Auto-save recipes

**Design**:
```
┌─────────────────────────────────────────┐
│ App Settings                             │
│                                          │
│ ⚖️ Measurement Units      [Metric ▼]    │
│ 🍽️ Default Serving Size   [4 people]    │
│ 💾 Auto-save Recipes      [Toggle ON]   │
│                                          │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/app_settings_card.dart
class AppSettingsCard extends StatelessWidget {
  final String measurementUnit;
  final int defaultServingSize;
  final bool autoSaveRecipes;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onServingSizeChanged;
  final ValueChanged<bool> onAutoSaveChanged;
  
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.scale),
            title: Text('Measurement Units'),
            trailing: DropdownButton<String>(
              value: measurementUnit,
              items: [
                DropdownMenuItem(value: 'metric', child: Text('Metric')),
                DropdownMenuItem(value: 'imperial', child: Text('Imperial')),
              ],
              onChanged: (value) => onUnitChanged(value!),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.restaurant),
            title: Text('Default Serving Size'),
            trailing: DropdownButton<int>(
              value: defaultServingSize,
              items: List.generate(10, (i) => i + 1).map((n) {
                return DropdownMenuItem(
                  value: n,
                  child: Text('$n ${n == 1 ? 'person' : 'people'}'),
                );
              }).toList(),
              onChanged: (value) => onServingSizeChanged(value!),
            ),
          ),
          Divider(),
          SwitchListTile(
            secondary: Icon(Icons.save),
            title: Text('Auto-save Recipes'),
            subtitle: Text('Automatically save generated recipes'),
            value: autoSaveRecipes,
            onChanged: onAutoSaveChanged,
          ),
        ],
      ),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/app_settings_card.dart`

---

## Phase 5: Account & Data Management 🔐

### 5.1 Account Information Card
**Goal**: Display account details and auth status

**Features**:
- Display name (editable)
- Email address
- Account creation date
- Sign out button
- Delete account button (with confirmation)

**Design**:
```
┌─────────────────────────────────────────┐
│ Account Information                      │
│                                          │
│ 📧 Email: user@email.com                │
│ 📅 Member since: Nov 12, 2025           │
│                                          │
│ [Edit Profile] [Sign Out]               │
│                                          │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/account_info_card.dart
class AccountInfoCard extends StatelessWidget {
  final String email;
  final DateTime? createdAt;
  final VoidCallback onSignOut;
  final VoidCallback onEditProfile;
  
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Information', style: titleMedium.bold),
            SizedBox(height: 12),
            
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text(email),
            ),
            
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Member since'),
              subtitle: Text(_formatDate(createdAt)),
            ),
            
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEditProfile,
                    icon: Icon(Icons.edit),
                    label: Text('Edit Profile'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSignOut,
                    icon: Icon(Icons.logout),
                    label: Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/account_info_card.dart`

### 5.2 Data Management Section
**Goal**: Export, import, and clear data

**Features**:
- Export all data (JSON)
- Export favorites (PDF/text)
- Import data from file
- Clear all data (with confirmation)
- Reset preferences only

**Design**:
```
┌─────────────────────────────────────────┐
│ Data Management                          │
│                                          │
│ 📤 Export Data                          │
│ 📥 Import Data                          │
│ 🗑️ Clear All Data                       │
│ ↺  Reset Preferences                    │
│                                          │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/data_management_card.dart
class DataManagementCard extends StatelessWidget {
  final VoidCallback onExportData;
  final VoidCallback onImportData;
  final VoidCallback onClearData;
  final VoidCallback onResetPreferences;
  
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('Export Data'),
            subtitle: Text('Save all your data as JSON'),
            trailing: Icon(Icons.chevron_right),
            onTap: onExportData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('Import Data'),
            subtitle: Text('Restore from a backup file'),
            trailing: Icon(Icons.chevron_right),
            onTap: onImportData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Clear All Data', style: TextStyle(color: Colors.red)),
            subtitle: Text('Remove all recipes, pantry, and favorites'),
            trailing: Icon(Icons.chevron_right),
            onTap: onClearData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Reset Preferences'),
            subtitle: Text('Reset dietary restrictions and settings'),
            trailing: Icon(Icons.chevron_right),
            onTap: onResetPreferences,
          ),
        ],
      ),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/data_management_card.dart`

---

## Phase 6: Help & About Section ℹ️

### 6.1 Help & Support Card
**Goal**: Provide user assistance and support

**Features**:
- FAQ section
- Tutorial/Getting Started
- Contact support
- Report a bug
- Feature requests
- App version

**Design**:
```
┌─────────────────────────────────────────┐
│ Help & Support                           │
│                                          │
│ ❓ FAQ & Help                           │
│ 🎓 Getting Started Tutorial             │
│ 📧 Contact Support                      │
│ 🐛 Report a Bug                         │
│ 💡 Suggest a Feature                    │
│                                          │
│ Version 1.0.0                            │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
// Create lib/features/profile/presentation/widgets/help_support_card.dart
class HelpSupportCard extends StatelessWidget {
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.help),
            title: Text('FAQ & Help'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _openFAQ(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Getting Started Tutorial'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _openTutorial(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Contact Support'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _contactSupport(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('Report a Bug'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _reportBug(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lightbulb),
            title: Text('Suggest a Feature'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _suggestFeature(),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Version 1.0.0'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }
}
```

**Files to create**:
- `lib/features/profile/presentation/widgets/help_support_card.dart`

---

## Phase 7: Visual Polish & Animations ✨

### 7.1 Section Headers with Icons
**Goal**: Clear visual hierarchy for settings sections

**Implementation**:
```dart
Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        Expanded(child: Divider(indent: 12)),
      ],
    ),
  );
}
```

### 7.2 Smooth Transitions
**Goal**: Animated transitions for better UX

**Features**:
- Fade in cards on scroll
- Expand/collapse animations for collapsible sections
- Smooth theme transitions
- Ripple effects on all interactive elements

**Implementation**:
```dart
class _AnimatedProfileCard extends StatelessWidget {
  final Widget child;
  final int delay;
  
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (delay * 100)),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

### 7.3 Loading States
**Goal**: Feedback during async operations

**Operations**:
- Saving preferences
- Exporting data
- Signing out
- Clearing data

**Implementation**: Use CircularProgressIndicator with disabled buttons

---

## Implementation Priority

### 🔴 Phase 1 - High Priority (Implement First)
**Goal**: Core visual improvements and essential features

1. ✅ Enhanced profile header with stats
2. ✅ Cooking insights/stats card
3. ✅ Improved dietary restrictions selector with icons
4. ✅ Visual skill level card
5. ✅ Better cuisine preference with search and grid
6. ✅ Section headers with icons
7. ✅ Basic animations and transitions

**Estimated Time**: 3-4 days

### 🟡 Phase 2 - Medium Priority
**Goal**: Extended functionality and settings

8. ⏳ Excluded ingredients manager
9. ⏳ App settings section (units, defaults)
10. ⏳ Account information card
11. ⏳ Data management (export/import)
12. ⏳ Help & support section

**Estimated Time**: 3-4 days

### 🟢 Phase 3 - Low Priority (Polish)
**Goal**: Nice-to-have features

13. ⏳ Achievement badges
14. ⏳ Avatar upload/customization
15. ⏳ Weekly cooking insights
16. ⏳ Recipe recommendations based on profile

**Estimated Time**: 2-3 days

### ⚪ Phase 4 - Future Enhancements
**Goal**: Advanced features

17. ⏳ Social features (share profile)
18. ⏳ Notification preferences
19. ⏳ Multi-language support
20. ⏳ Accessibility settings
21. ⏳ Dark mode scheduling
22. ⏳ Cooking timers integration
23. ⏳ Meal planning preferences

**Estimated Time**: 5-7 days (ongoing)

---

## Technical Dependencies

### Packages to Add
```yaml
dependencies:
  # Already in pubspec.yaml
  flutter_riverpod: ^2.6.1
  hive_flutter: ^1.1.0
  
  # New packages needed
  intl: ^0.19.0 # For date formatting
  file_picker: ^8.0.0 # For import data
  path_provider: ^2.1.1 # For export data
  share_plus: ^7.2.1 # For sharing
  
dev_dependencies:
  build_runner: ^2.4.6
```

### File Structure
```
lib/features/profile/
├── domain/
│   ├── entities/
│   │   └── app_settings.dart (new - units, serving size, etc.)
│   └── services/
│       └── data_export_service.dart (new)
│
├── presentation/
│   ├── screens/
│   │   └── profile_screen.dart (major update)
│   └── widgets/
│       ├── profile_header_card.dart (new)
│       ├── cooking_stats_card.dart (new)
│       ├── dietary_restrictions_card.dart (new)
│       ├── skill_level_card.dart (new)
│       ├── cuisine_preference_card.dart (new)
│       ├── excluded_ingredients_card.dart (new)
│       ├── app_settings_card.dart (new)
│       ├── account_info_card.dart (new)
│       ├── data_management_card.dart (new)
│       └── help_support_card.dart (new)
```

---

## Design Specifications

### Color Scheme
- **Section Headers**: Primary color
- **Success Actions**: Green (#4CAF50)
- **Destructive Actions**: Red (#F44336)
- **Info/Stats**: Blue (#2196F3)
- **Cards**: Surface color with elevation 1-2

### Typography
- **Screen Title**: 22sp, Bold (App Bar)
- **Section Headers**: 14sp, Bold, Primary color
- **Card Titles**: 18sp, Medium
- **Body Text**: 14sp, Regular
- **Captions/Hints**: 12sp, Regular, Gray
- **Stats Numbers**: 24sp, Bold

### Spacing
- **Screen Padding**: 16dp
- **Card Margin**: 16dp bottom
- **Section Spacing**: 24dp
- **Within Cards**: 16dp padding
- **Between Elements**: 12dp

### Card Design
- **Elevation**: 1-2dp
- **Corner Radius**: 12dp
- **Border**: None (use elevation)
- **Padding**: 16dp

### Icons
- **Section Headers**: 20px
- **List Tiles**: 24px
- **Avatar**: 80px (profile header)
- **Emoji Icons**: 18-20px

---

## Key Learnings Applied

### From Recipes Screen
1. **Smart Detection**: Use helper classes for consistent categorization
2. **Visual Hierarchy**: Icons and colors guide users effectively
3. **Empty States**: Provide context-specific guidance
4. **Search/Filter**: Real-time feedback is essential

### From Favorites Screen
1. **Stats Cards**: Users love seeing their progress
2. **Filter Chips**: Quick selection beats long lists
3. **Export Features**: Data portability builds trust
4. **Multi-select**: Bulk actions save time

### From Pantry Screen
1. **Category Icons**: Visual grouping improves scannability
2. **Search Bar**: Essential for large lists
3. **Swipe Actions**: Quick interactions enhance UX
4. **Clear CTAs**: Guide users with obvious next steps

---

## Success Metrics

After implementation, track:

1. **User Engagement**
   - Time spent on profile screen
   - Preference update frequency
   - Feature adoption rate

2. **Feature Usage**
   - % using dietary restrictions
   - % using skill level
   - % using excluded ingredients
   - % using data export

3. **User Satisfaction**
   - Profile completion rate
   - Settings saved per session
   - Help/FAQ access rate

4. **Performance**
   - Screen load time
   - Animation smoothness (FPS)
   - Save operation latency

---

## Timeline Estimate

- **Phase 1 (Core Improvements)**: 3-4 days
- **Phase 2 (Extended Features)**: 3-4 days
- **Phase 3 (Polish)**: 2-3 days
- **Phase 4 (Future)**: 5-7 days (ongoing)

**Total for MVP (Phases 1-2)**: ~6-8 days of development work

---

## Notes

- Maintain consistency with existing app design language
- Ensure all changes work with existing Hive storage
- Test theme switching (light/dark) for all new components
- Add proper error handling for data import/export
- Consider accessibility (screen readers, high contrast)
- Add analytics tracking for feature usage (future)

Last updated: 2025-11-12
