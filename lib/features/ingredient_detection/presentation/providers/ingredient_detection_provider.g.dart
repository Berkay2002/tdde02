// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_detection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gemmaInferenceServiceHash() =>
    r'9b6fc38a697aa3ed3190281b8ebfa8cc11b1efda';

/// Provider for the GemmaInferenceService singleton
///
/// Copied from [gemmaInferenceService].
@ProviderFor(gemmaInferenceService)
final gemmaInferenceServiceProvider =
    AutoDisposeProvider<GemmaInferenceService>.internal(
  gemmaInferenceService,
  name: r'gemmaInferenceServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gemmaInferenceServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GemmaInferenceServiceRef
    = AutoDisposeProviderRef<GemmaInferenceService>;
String _$ingredientDetectionHash() =>
    r'b946113dbb1076e06fc9145f65029c8b37fadbe8';

/// Provider for ingredient detection logic
///
/// Copied from [IngredientDetection].
@ProviderFor(IngredientDetection)
final ingredientDetectionProvider = AutoDisposeNotifierProvider<
    IngredientDetection, IngredientDetectionState>.internal(
  IngredientDetection.new,
  name: r'ingredientDetectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ingredientDetectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IngredientDetection = AutoDisposeNotifier<IngredientDetectionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
