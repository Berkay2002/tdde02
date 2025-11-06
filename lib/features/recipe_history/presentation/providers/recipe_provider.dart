import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../../recipe_generation/domain/entities/recipe.dart';
import '../../../recipe_generation/domain/repositories/recipe_repository.dart';
import '../../../recipe_generation/data/repositories/recipe_repository_impl.dart';

part 'recipe_provider.g.dart';

/// Provider for RecipeRepository
@riverpod
RecipeRepository recipeRepository(RecipeRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return RecipeRepositoryImpl(supabase);
}

/// Provider for user's recipes
@riverpod
Future<List<Recipe>> userRecipes(UserRecipesRef ref) async {
  final userId = ref.watch(supabaseProvider).auth.currentUser?.id;
  if (userId == null) return [];

  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getUserRecipes(userId);
}

/// Provider for favorite recipes
@riverpod
Future<List<Recipe>> favoriteRecipes(FavoriteRecipesRef ref) async {
  final userId = ref.watch(supabaseProvider).auth.currentUser?.id;
  if (userId == null) return [];

  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getFavoriteRecipes(userId);
}

/// Recipe notifier for managing recipes
@riverpod
class RecipeNotifier extends _$RecipeNotifier {
  @override
  FutureOr<List<Recipe>> build() async {
    final userId = ref.watch(supabaseProvider).auth.currentUser?.id;
    if (userId == null) return [];

    final repository = ref.watch(recipeRepositoryProvider);
    return await repository.getUserRecipes(userId);
  }

  Future<void> createRecipe(Recipe recipe) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      final newRecipe = await repository.createRecipe(recipe);
      
      final currentRecipes = state.value ?? [];
      return [newRecipe, ...currentRecipes];
    });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      final updatedRecipe = await repository.updateRecipe(recipe);
      
      final currentRecipes = state.value ?? [];
      return currentRecipes.map((r) {
        return r.id == updatedRecipe.id ? updatedRecipe : r;
      }).toList();
    });
  }

  Future<void> deleteRecipe(String recipeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      await repository.deleteRecipe(recipeId);
      
      final currentRecipes = state.value ?? [];
      return currentRecipes.where((r) => r.id != recipeId).toList();
    });
  }

  Future<void> toggleFavorite(String recipeId, bool isFavorite) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      final updatedRecipe = await repository.toggleFavorite(recipeId, isFavorite);
      
      final currentRecipes = state.value ?? [];
      return currentRecipes.map((r) {
        return r.id == updatedRecipe.id ? updatedRecipe : r;
      }).toList();
    });
  }

  Future<void> rateRecipe(String recipeId, int rating) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      final updatedRecipe = await repository.rateRecipe(recipeId, rating);
      
      final currentRecipes = state.value ?? [];
      return currentRecipes.map((r) {
        return r.id == updatedRecipe.id ? updatedRecipe : r;
      }).toList();
    });
  }

  Future<void> refreshRecipes() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(supabaseProvider).auth.currentUser?.id;
      if (userId == null) return [];

      final repository = ref.read(recipeRepositoryProvider);
      return await repository.getUserRecipes(userId);
    });
  }
}
