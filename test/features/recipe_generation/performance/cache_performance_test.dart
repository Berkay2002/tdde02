import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/recipe_generation/data/repositories/recipe_repository_impl.dart';

/// Performance benchmarking tests for recipe caching
/// 
/// These tests validate that cache operations meet performance targets:
/// - Cache hit: <500ms
/// - Cache miss: <100ms (no data to retrieve)
/// - Cache save: <1000ms
void main() {
  group('Cache Performance Benchmarks', () {
    late FakeFirebaseFirestore fakeFirestore;
    late RecipeRepositoryImpl repository;
    const testUserId = 'perf_test_user';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = RecipeRepositoryImpl(fakeFirestore);
    });

    test('cache miss performance (<100ms)', () async {
      final stopwatch = Stopwatch()..start();
      
      final result = await repository.getCachedRecipes(
        testUserId,
        ['chicken', 'rice', 'onion'],
        'vegetarian',
        'beginner',
        'Italian',
      );
      
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      expect(result, isNull);
      expect(duration, lessThan(100),
          reason: 'Cache miss took ${duration}ms, expected <100ms');
      
      print('✓ Cache miss performance: ${duration}ms');
    });

    test('cache hit performance (<500ms)', () async {
      // Setup: Create cached data
      final testRecipes = List.generate(
        3,
        (i) => {
          'name': 'Recipe ${i + 1}',
          'description': 'A delicious recipe with detailed instructions and ingredients',
          'difficulty': ['easy', 'medium', 'hard'][i % 3],
          'prepTime': 15 + (i * 5),
          'cookTime': 30 + (i * 10),
          'ingredients': List.generate(10, (j) => 'ingredient_${i}_$j'),
          'instructions': List.generate(8, (j) => 'Step ${j + 1}: Do something important'),
        },
      );

      await repository.saveCachedRecipes(
        testUserId,
        ['chicken', 'rice', 'onion', 'garlic', 'tomato'],
        testRecipes,
        'vegetarian, gluten-free',
        'intermediate',
        'Italian',
      );

      // Benchmark: Retrieve cached data
      final stopwatch = Stopwatch()..start();
      
      final result = await repository.getCachedRecipes(
        testUserId,
        ['chicken', 'rice', 'onion', 'garlic', 'tomato'],
        'vegetarian, gluten-free',
        'intermediate',
        'Italian',
      );
      
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      expect(result, isNotNull);
      expect(result, hasLength(3));
      expect(duration, lessThan(500),
          reason: 'Cache hit took ${duration}ms, expected <500ms');
      
      print('✓ Cache hit performance: ${duration}ms');
    });

    test('cache save performance (<1000ms)', () async {
      final testRecipes = List.generate(
        5,
        (i) => {
          'name': 'Recipe ${i + 1}',
          'description': 'Comprehensive recipe with all details included',
          'difficulty': 'medium',
          'prepTime': 20,
          'cookTime': 40,
          'ingredients': List.generate(15, (j) => 'ingredient_${i}_$j'),
          'instructions': List.generate(12, (j) => 'Step ${j + 1}: Detailed cooking instruction'),
          'tags': ['healthy', 'quick', 'family-friendly'],
        },
      );

      final stopwatch = Stopwatch()..start();
      
      await repository.saveCachedRecipes(
        testUserId,
        ['chicken', 'rice', 'onion', 'garlic', 'tomato', 'basil'],
        testRecipes,
        'vegetarian, gluten-free, dairy-free',
        'advanced',
        'Mediterranean',
      );
      
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      expect(duration, lessThan(1000),
          reason: 'Cache save took ${duration}ms, expected <1000ms');
      
      print('✓ Cache save performance: ${duration}ms');
    });

    test('sequential cache operations performance', () async {
      final operations = 20;
      final durations = <int>[];

      for (int i = 0; i < operations; i++) {
        final testRecipes = [
          {
            'name': 'Recipe $i',
            'difficulty': 'easy',
            'prepTime': 15,
            'cookTime': 30,
          }
        ];

        // Save
        final saveWatch = Stopwatch()..start();
        await repository.saveCachedRecipes(
          testUserId,
          ['ingredient_$i'],
          testRecipes,
          'vegetarian',
          'beginner',
          'Italian',
        );
        saveWatch.stop();

        // Retrieve
        final getWatch = Stopwatch()..start();
        await repository.getCachedRecipes(
          testUserId,
          ['ingredient_$i'],
          'vegetarian',
          'beginner',
          'Italian',
        );
        getWatch.stop();

        durations.add(saveWatch.elapsedMilliseconds + getWatch.elapsedMilliseconds);
      }

      final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
      final maxDuration = durations.reduce((a, b) => a > b ? a : b);

      expect(avgDuration, lessThan(300),
          reason: 'Average operation time was ${avgDuration}ms, expected <300ms');
      expect(maxDuration, lessThan(1500),
          reason: 'Max operation time was ${maxDuration}ms, expected <1500ms');
      
      print('✓ Sequential operations - Avg: ${avgDuration.toStringAsFixed(2)}ms, Max: ${maxDuration}ms');
    });

    test('cache key generation performance', () async {
      const iterations = 1000;
      final ingredients = List.generate(20, (i) => 'ingredient_$i');

      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < iterations; i++) {
        repository.getCachedRecipes(
          testUserId,
          ingredients,
          'vegetarian, vegan, gluten-free',
          'intermediate',
          'Asian',
        );
      }
      
      stopwatch.stop();
      final avgDuration = stopwatch.elapsedMilliseconds / iterations;

      expect(avgDuration, lessThan(10),
          reason: 'Average cache key generation took ${avgDuration.toStringAsFixed(2)}ms, expected <10ms');
      
      print('✓ Cache key generation - Avg: ${avgDuration.toStringAsFixed(2)}ms per key');
    });

    test('stress test: high-frequency cache operations', () async {
      const operationsCount = 50;
      final futures = <Future>[];
      final stopwatch = Stopwatch()..start();

      // Simulate high-frequency concurrent operations
      for (int i = 0; i < operationsCount; i++) {
        final testRecipes = [
          {'name': 'Recipe $i', 'difficulty': 'easy'}
        ];

        futures.add(
          repository.saveCachedRecipes(
            testUserId,
            ['ingredient_${i % 10}'],
            testRecipes,
            'vegetarian',
            'beginner',
            'Italian',
          ).then((_) => repository.getCachedRecipes(
            testUserId,
            ['ingredient_${i % 10}'],
            'vegetarian',
            'beginner',
            'Italian',
          )),
        );
      }

      await Future.wait(futures);
      stopwatch.stop();

      final avgTime = stopwatch.elapsedMilliseconds / operationsCount;

      expect(avgTime, lessThan(200),
          reason: 'Average time per operation was ${avgTime.toStringAsFixed(2)}ms, expected <200ms');
      
      print('✓ Stress test: $operationsCount operations in ${stopwatch.elapsedMilliseconds}ms (avg: ${avgTime.toStringAsFixed(2)}ms)');
    });

    test('memory efficiency: large recipe payload', () async {
      // Create a large recipe payload (simulating complex recipes)
      final largeRecipes = List.generate(
        10,
        (i) => {
          'name': 'Complex Recipe ${i + 1}',
          'description': 'A' * 500, // 500 char description
          'difficulty': 'advanced',
          'prepTime': 30,
          'cookTime': 90,
          'ingredients': List.generate(30, (j) => 'ingredient_${i}_$j'),
          'instructions': List.generate(20, (j) => 'Step ${j + 1}: ${"Instruction " * 10}'),
          'tags': List.generate(10, (j) => 'tag_$j'),
          'nutritionalInfo': {
            'calories': 450 + i * 10,
            'protein': 25 + i,
            'carbs': 50 + i * 2,
            'fat': 15 + i,
          }
        },
      );

      final saveWatch = Stopwatch()..start();
      await repository.saveCachedRecipes(
        testUserId,
        List.generate(20, (i) => 'ingredient_$i'),
        largeRecipes,
        'vegetarian, vegan, gluten-free, dairy-free',
        'advanced',
        'Mediterranean',
      );
      saveWatch.stop();

      final getWatch = Stopwatch()..start();
      final result = await repository.getCachedRecipes(
        testUserId,
        List.generate(20, (i) => 'ingredient_$i'),
        'vegetarian, vegan, gluten-free, dairy-free',
        'advanced',
        'Mediterranean',
      );
      getWatch.stop();

      expect(result, isNotNull);
      expect(result, hasLength(10));
      expect(saveWatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Large payload save took ${saveWatch.elapsedMilliseconds}ms');
      expect(getWatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Large payload retrieval took ${getWatch.elapsedMilliseconds}ms');
      
      print('✓ Large payload - Save: ${saveWatch.elapsedMilliseconds}ms, Get: ${getWatch.elapsedMilliseconds}ms');
    });
  });
}
