import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_context.dart';
import '../../data/models/recipe_reference.dart';

/// Notifier for managing chat context
class ChatContextNotifier extends StateNotifier<ChatContext> {
  ChatContextNotifier() : super(ChatContext.empty());

  /// Update current screen
  void setScreen(ChatScreen screen) {
    state = state.copyWith(currentScreen: screen);
  }

  /// Set session ingredients (from home screen quick scan)
  void setSessionIngredients(List<String> ingredients) {
    state = state.copyWith(sessionIngredients: ingredients);
  }

  /// Set pantry items
  void setPantryItems(List<Map<String, dynamic>> items) {
    state = state.copyWith(pantryItems: items);
  }

  /// Set user profile
  void setUserProfile(Map<String, dynamic> profile) {
    state = state.copyWith(userProfile: profile);
  }

  /// Set current recipe ID (for recipe detail screen)
  void setCurrentRecipe(String recipeId, RecipeReference? recipe) {
    state = state.copyWith(
      currentRecipeId: recipeId,
      attachedRecipes: recipe != null ? [recipe] : null,
    );
  }

  /// Add a recipe reference to context (@recipe mention)
  void addRecipeReference(RecipeReference recipe) {
    state = state.addRecipeReference(recipe);
  }

  /// Remove a recipe reference from context
  void removeRecipeReference(String recipeId) {
    state = state.removeRecipeReference(recipeId);
  }

  /// Clear all attached recipes
  void clearAttachedRecipes() {
    state = state.copyWith(attachedRecipes: []);
  }

  /// Reset context to empty
  void reset() {
    state = ChatContext.empty();
  }

  /// Update context with current app state
  void updateFromAppState({
    ChatScreen? screen,
    List<String>? sessionIngredients,
    List<Map<String, dynamic>>? pantryItems,
    Map<String, dynamic>? userProfile,
    String? currentRecipeId,
    RecipeReference? currentRecipe,
  }) {
    state = ChatContext(
      currentScreen: screen ?? state.currentScreen,
      sessionIngredients: sessionIngredients ?? state.sessionIngredients,
      pantryItems: pantryItems ?? state.pantryItems,
      userProfile: userProfile ?? state.userProfile,
      currentRecipeId: currentRecipeId ?? state.currentRecipeId,
      attachedRecipes: currentRecipe != null
          ? [currentRecipe]
          : state.attachedRecipes,
    );
  }
}

/// Provider for chat context
final chatContextProvider =
    StateNotifierProvider<ChatContextNotifier, ChatContext>(
      (ref) => ChatContextNotifier(),
    );
