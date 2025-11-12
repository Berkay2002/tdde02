import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/recipe_generation/data/models/recipe_cache_model.dart';

void main() {
  group('RecipeCacheModel', () {
    group('generateCacheKey', () {
      test('should generate consistent cache key for same inputs', () {
        final ingredients = ['chicken', 'rice', 'onion'];
        final key1 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(key1, equals(key2));
      });

      test('should generate same key regardless of ingredient order', () {
        final key1 = RecipeCacheModel.generateCacheKey(
          ['chicken', 'rice', 'onion'],
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ['rice', 'onion', 'chicken'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(key1, equals(key2));
      });

      test('should generate different keys for different ingredients', () {
        final key1 = RecipeCacheModel.generateCacheKey(
          ['chicken', 'rice'],
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ['chicken', 'pasta'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(key1, isNot(equals(key2)));
      });

      test('should generate different keys for different dietary restrictions', () {
        final ingredients = ['chicken', 'rice'];
        final key1 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegan',
          'beginner',
          'Italian',
        );

        expect(key1, isNot(equals(key2)));
      });

      test('should generate different keys for different skill levels', () {
        final ingredients = ['chicken', 'rice'];
        final key1 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegetarian',
          'intermediate',
          'Italian',
        );

        expect(key1, isNot(equals(key2)));
      });

      test('should generate different keys for different cuisine preferences', () {
        final ingredients = ['chicken', 'rice'];
        final key1 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ingredients,
          'vegetarian',
          'beginner',
          'Asian',
        );

        expect(key1, isNot(equals(key2)));
      });

      test('should handle null preferences consistently', () {
        final ingredients = ['chicken', 'rice'];
        final key1 = RecipeCacheModel.generateCacheKey(
          ingredients,
          null,
          null,
          null,
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ingredients,
          null,
          null,
          null,
        );

        expect(key1, equals(key2));
      });

      test('should treat null and empty string as equivalent', () {
        // Both null and empty string mean "no restriction" - should generate same key
        final ingredients = ['chicken', 'rice'];
        final key1 = RecipeCacheModel.generateCacheKey(
          ingredients,
          null,
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ingredients,
          '',
          'beginner',
          'Italian',
        );

        expect(key1, equals(key2),
            reason: 'Null and empty string should be treated as equivalent (no restriction)');
      });
    });

    group('isValid', () {
      test('should return true for cache without expiration', () {
        final cache = RecipeCacheModel(
          id: 'test_123',
          userId: 'user123',
          ingredients: ['chicken', 'rice'],
          recipes: [],
          createdAt: DateTime.now(),
          expiresAt: null,
        );

        expect(cache.isValid, isTrue);
      });

      test('should return true for cache not yet expired', () {
        final cache = RecipeCacheModel(
          id: 'test_123',
          userId: 'user123',
          ingredients: ['chicken', 'rice'],
          recipes: [],
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        );

        expect(cache.isValid, isTrue);
      });

      test('should return false for expired cache', () {
        final cache = RecipeCacheModel(
          id: 'test_123',
          userId: 'user123',
          ingredients: ['chicken', 'rice'],
          recipes: [],
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(cache.isValid, isFalse);
      });

      test('should return false for cache expiring right now', () {
        final cache = RecipeCacheModel(
          id: 'test_123',
          userId: 'user123',
          ingredients: ['chicken', 'rice'],
          recipes: [],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          expiresAt: DateTime.now().subtract(const Duration(milliseconds: 100)),
        );

        expect(cache.isValid, isFalse);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(days: 7));
        
        final cache = RecipeCacheModel(
          id: 'test_123',
          userId: 'user123',
          ingredients: ['chicken', 'rice', 'onion'],
          recipes: [
            {'name': 'Recipe 1', 'difficulty': 'easy'},
            {'name': 'Recipe 2', 'difficulty': 'medium'},
          ],
          dietaryRestrictions: 'vegetarian',
          skillLevel: 'beginner',
          cuisinePreference: 'Italian',
          createdAt: now,
          expiresAt: expiresAt,
        );

        final json = cache.toJson();

        expect(json['id'], equals('test_123'));
        expect(json['user_id'], equals('user123'));
        expect(json['ingredients'], equals(['chicken', 'rice', 'onion']));
        expect(json['recipes'], hasLength(2));
        expect(json['dietary_restrictions'], equals('vegetarian'));
        expect(json['skill_level'], equals('beginner'));
        expect(json['cuisine_preference'], equals('Italian'));
        expect(json['created_at'], isA<Timestamp>());
        expect(json['expires_at'], isA<Timestamp>());
      });

      test('should deserialize from JSON correctly', () {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(days: 7));
        
        final json = {
          'id': 'test_123',
          'user_id': 'user123',
          'ingredients': ['chicken', 'rice', 'onion'],
          'recipes': [
            {'name': 'Recipe 1', 'difficulty': 'easy'},
            {'name': 'Recipe 2', 'difficulty': 'medium'},
          ],
          'dietary_restrictions': 'vegetarian',
          'skill_level': 'beginner',
          'cuisine_preference': 'Italian',
          'created_at': Timestamp.fromDate(now),
          'expires_at': Timestamp.fromDate(expiresAt),
        };

        final cache = RecipeCacheModel.fromJson(json);

        expect(cache.id, equals('test_123'));
        expect(cache.userId, equals('user123'));
        expect(cache.ingredients, equals(['chicken', 'rice', 'onion']));
        expect(cache.recipes, hasLength(2));
        expect(cache.dietaryRestrictions, equals('vegetarian'));
        expect(cache.skillLevel, equals('beginner'));
        expect(cache.cuisinePreference, equals('Italian'));
        expect(cache.createdAt, equals(now));
        expect(cache.expiresAt, equals(expiresAt));
      });

      test('should handle null optional fields in JSON', () {
        final now = DateTime.now();
        
        final json = {
          'id': 'test_123',
          'user_id': 'user123',
          'ingredients': ['chicken', 'rice'],
          'recipes': [],
          'dietary_restrictions': null,
          'skill_level': null,
          'cuisine_preference': null,
          'created_at': Timestamp.fromDate(now),
          'expires_at': null,
        };

        final cache = RecipeCacheModel.fromJson(json);

        expect(cache.dietaryRestrictions, isNull);
        expect(cache.skillLevel, isNull);
        expect(cache.cuisinePreference, isNull);
        expect(cache.expiresAt, isNull);
      });

      test('should round-trip correctly through JSON', () {
        final original = RecipeCacheModel(
          id: 'test_123',
          userId: 'user123',
          ingredients: ['chicken', 'rice'],
          recipes: [{'name': 'Test Recipe'}],
          dietaryRestrictions: 'vegan',
          skillLevel: 'intermediate',
          cuisinePreference: 'Asian',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        );

        final json = original.toJson();
        final restored = RecipeCacheModel.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.userId, equals(original.userId));
        expect(restored.ingredients, equals(original.ingredients));
        expect(restored.recipes, equals(original.recipes));
        expect(restored.dietaryRestrictions, equals(original.dietaryRestrictions));
        expect(restored.skillLevel, equals(original.skillLevel));
        expect(restored.cuisinePreference, equals(original.cuisinePreference));
      });
    });

    group('Edge cases', () {
      test('should handle empty ingredient list', () {
        final key = RecipeCacheModel.generateCacheKey(
          [],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(key, isNotEmpty);
      });

      test('should handle very long ingredient lists', () {
        final longList = List.generate(100, (i) => 'ingredient_$i');
        final key = RecipeCacheModel.generateCacheKey(
          longList,
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(key, isNotEmpty);
      });

      test('should handle special characters in ingredients', () {
        final key1 = RecipeCacheModel.generateCacheKey(
          ['chicken & rice', 'salt/pepper', 'oil (olive)'],
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ['chicken & rice', 'salt/pepper', 'oil (olive)'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(key1, equals(key2));
      });

      test('should handle unicode characters in ingredients', () {
        final key1 = RecipeCacheModel.generateCacheKey(
          ['チキン', 'ライス', 'ταυτόχρονα'],
          'vegetarian',
          'beginner',
          'Italian',
        );
        final key2 = RecipeCacheModel.generateCacheKey(
          ['チキン', 'ライス', 'ταυτόχρονα'],
          'vegetarian',
          'beginner',
          'Italian',
        );

        expect(key1, equals(key2));
      });
    });
  });
}
