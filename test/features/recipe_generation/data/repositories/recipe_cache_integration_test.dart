import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/recipe_generation/data/repositories/recipe_repository_impl.dart';

void main() {
  group('Recipe Cache Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late RecipeRepositoryImpl repository;
    const testUserId = 'test_user_123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = RecipeRepositoryImpl(fakeFirestore);
    });

    group('Cache Hit/Miss Flow', () {
      test('should return null on cache miss (no cached data)', () async {
        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNull);
      });

      test('should return cached recipes on cache hit', () async {
        // First, save recipes to cache
        final testRecipes = [
          {
            'name': 'Chicken Rice Bowl',
            'difficulty': 'easy',
            'prepTime': 15,
            'cookTime': 30,
          },
          {
            'name': 'Fried Rice',
            'difficulty': 'medium',
            'prepTime': 10,
            'cookTime': 20,
          },
        ];

        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        // Now try to retrieve them
        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNotNull);
        expect(cachedRecipes, hasLength(2));
        expect(cachedRecipes![0]['name'], equals('Chicken Rice Bowl'));
        expect(cachedRecipes[1]['name'], equals('Fried Rice'));
      });

      test('should return cached recipes regardless of ingredient order', () async {
        final testRecipes = [
          {'name': 'Test Recipe', 'difficulty': 'easy'},
        ];

        // Save with one order
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice', 'onion'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        // Retrieve with different order
        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['rice', 'onion', 'chicken'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNotNull);
        expect(cachedRecipes, hasLength(1));
        expect(cachedRecipes![0]['name'], equals('Test Recipe'));
      });

      test('should return null for different user even with same ingredients', () async {
        final testRecipes = [
          {'name': 'Test Recipe', 'difficulty': 'easy'},
        ];

        // Save for user 1
        await repository.saveCachedRecipes(
          'user_1',
          ['chicken', 'rice'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        // Try to retrieve for user 2
        final cachedRecipes = await repository.getCachedRecipes(
          'user_2',
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNull);
      });

      test('should return null for different preferences', () async {
        final testRecipes = [
          {'name': 'Test Recipe', 'difficulty': 'easy'},
        ];

        // Save with vegetarian restriction
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        // Try to retrieve with vegan restriction
        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegan',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNull);
      });

      test('should return null for different skill level', () async {
        final testRecipes = [
          {'name': 'Test Recipe', 'difficulty': 'easy'},
        ];

        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'intermediate',
          'Italian',
        );

        expect(cachedRecipes, isNull);
      });
    });

    group('Cache Expiration (TTL)', () {
      test('should return null for expired cache', () async {
        final testRecipes = [
          {'name': 'Expired Recipe', 'difficulty': 'easy'},
        ];

        // Manually create an expired cache entry
        final expiredDate = DateTime.now().subtract(const Duration(days: 8));
        final cacheDoc = {
          'id': '${testUserId}_test123',
          'user_id': testUserId,
          'ingredients': ['chicken', 'rice'],
          'recipes': testRecipes,
          'dietary_restrictions': 'vegetarian',
          'skill_level': 'beginner',
          'cuisine_preference': 'Italian',
          'created_at': Timestamp.fromDate(expiredDate),
          'expires_at': Timestamp.fromDate(expiredDate.add(const Duration(days: 7))),
        };

        await fakeFirestore
            .collection('recipe_cache')
            .doc('${testUserId}_test123')
            .set(cacheDoc);

        // Try to get cached recipes (should detect expiration and return null)
        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNull,
            reason: 'Expired cache should return null');

        // Note: fake_cloud_firestore doesn't actually delete documents,
        // but the real implementation does. This test validates the null return.
      });

      test('should return valid cache that has not expired', () async {
        final testRecipes = [
          {'name': 'Valid Recipe', 'difficulty': 'easy'},
        ];

        // Create cache that expires tomorrow
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNotNull);
        expect(cachedRecipes![0]['name'], equals('Valid Recipe'));
      });
    });

    group('Cache Overwrite', () {
      test('should overwrite existing cache with same key', () async {
        final oldRecipes = [
          {'name': 'Old Recipe', 'difficulty': 'easy'},
        ];
        final newRecipes = [
          {'name': 'New Recipe', 'difficulty': 'medium'},
          {'name': 'Another New Recipe', 'difficulty': 'hard'},
        ];

        // Save first set of recipes
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          oldRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        // Save second set with same parameters (should overwrite)
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          newRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        // Retrieve and verify we get the new recipes
        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNotNull);
        expect(cachedRecipes, hasLength(2));
        expect(cachedRecipes![0]['name'], equals('New Recipe'));
        expect(cachedRecipes[1]['name'], equals('Another New Recipe'));
      });
    });

    group('Performance Validation', () {
      test('cache retrieval should be fast (<500ms)', () async {
        final testRecipes = [
          {'name': 'Performance Test Recipe', 'difficulty': 'easy'},
        ];

        // Save recipes
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );

        // Measure retrieval time
        final stopwatch = Stopwatch()..start();
        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );
        stopwatch.stop();

        expect(cachedRecipes, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Cache retrieval took ${stopwatch.elapsedMilliseconds}ms, expected <500ms');
      });

      test('cache save should be fast (<1000ms)', () async {
        final testRecipes = [
          {'name': 'Performance Test Recipe', 'difficulty': 'easy'},
        ];

        // Measure save time
        final stopwatch = Stopwatch()..start();
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Cache save took ${stopwatch.elapsedMilliseconds}ms, expected <1000ms');
      });

      test('should handle multiple concurrent cache operations', () async {
        final futures = <Future>[];

        // Simulate concurrent cache operations
        for (int i = 0; i < 10; i++) {
          final testRecipes = [
            {'name': 'Recipe $i', 'difficulty': 'easy'},
          ];
          
          futures.add(
            repository.saveCachedRecipes(
              testUserId,
              ['ingredient_$i'],
              testRecipes,
              'vegetarian',
              'beginner',
              'Italian',
            ),
          );
        }

        // Wait for all to complete
        await Future.wait(futures);

        // Verify all were saved
        for (int i = 0; i < 10; i++) {
          final cached = await repository.getCachedRecipes(
            testUserId,
            ['ingredient_$i'],
            'vegetarian',
            'beginner',
            'Italian',
          );
          expect(cached, isNotNull);
          expect(cached![0]['name'], equals('Recipe $i'));
        }
      });
    });

    group('Error Handling', () {
      test('should handle null preferences gracefully', () async {
        final testRecipes = [
          {'name': 'Null Prefs Recipe', 'difficulty': 'easy'},
        ];

        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          testRecipes,
          null,
          null,
          null,
        );

        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          null,
          null,
          null,
        );

        expect(cachedRecipes, isNotNull);
        expect(cachedRecipes![0]['name'], equals('Null Prefs Recipe'));
      });

      test('should handle empty recipe list', () async {
        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          [],
          'vegetarian',
          'beginner',
          'Italian',
        );

        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNotNull);
        expect(cachedRecipes, isEmpty);
      });

      test('should handle very large recipe lists', () async {
        final largeRecipeList = List.generate(
          100,
          (i) => {
            'name': 'Recipe $i',
            'difficulty': i % 3 == 0 ? 'easy' : (i % 3 == 1 ? 'medium' : 'hard'),
            'prepTime': i * 5,
            'cookTime': i * 10,
          },
        );

        await repository.saveCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          largeRecipeList,
          'vegetarian',
          'beginner',
          'Italian',
        );

        final cachedRecipes = await repository.getCachedRecipes(
          testUserId,
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(cachedRecipes, isNotNull);
        expect(cachedRecipes, hasLength(100));
      });
    });
  });
}
