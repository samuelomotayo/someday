// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analysisNotifierHash() => r'74b04d0329b3ea1b4c52a369bfe6ca1d10bb4a72';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AnalysisNotifier
    extends BuildlessAutoDisposeNotifier<AnalysisState> {
  late final String ideaId;

  AnalysisState build(String ideaId);
}

/// See also [AnalysisNotifier].
@ProviderFor(AnalysisNotifier)
const analysisNotifierProvider = AnalysisNotifierFamily();

/// See also [AnalysisNotifier].
class AnalysisNotifierFamily extends Family<AnalysisState> {
  /// See also [AnalysisNotifier].
  const AnalysisNotifierFamily();

  /// See also [AnalysisNotifier].
  AnalysisNotifierProvider call(String ideaId) {
    return AnalysisNotifierProvider(ideaId);
  }

  @override
  AnalysisNotifierProvider getProviderOverride(
    covariant AnalysisNotifierProvider provider,
  ) {
    return call(provider.ideaId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'analysisNotifierProvider';
}

/// See also [AnalysisNotifier].
class AnalysisNotifierProvider
    extends AutoDisposeNotifierProviderImpl<AnalysisNotifier, AnalysisState> {
  /// See also [AnalysisNotifier].
  AnalysisNotifierProvider(String ideaId)
    : this._internal(
        () => AnalysisNotifier()..ideaId = ideaId,
        from: analysisNotifierProvider,
        name: r'analysisNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$analysisNotifierHash,
        dependencies: AnalysisNotifierFamily._dependencies,
        allTransitiveDependencies:
            AnalysisNotifierFamily._allTransitiveDependencies,
        ideaId: ideaId,
      );

  AnalysisNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ideaId,
  }) : super.internal();

  final String ideaId;

  @override
  AnalysisState runNotifierBuild(covariant AnalysisNotifier notifier) {
    return notifier.build(ideaId);
  }

  @override
  Override overrideWith(AnalysisNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: AnalysisNotifierProvider._internal(
        () => create()..ideaId = ideaId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ideaId: ideaId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AnalysisNotifier, AnalysisState>
  createElement() {
    return _AnalysisNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalysisNotifierProvider && other.ideaId == ideaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ideaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnalysisNotifierRef on AutoDisposeNotifierProviderRef<AnalysisState> {
  /// The parameter `ideaId` of this provider.
  String get ideaId;
}

class _AnalysisNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<AnalysisNotifier, AnalysisState>
    with AnalysisNotifierRef {
  _AnalysisNotifierProviderElement(super.provider);

  @override
  String get ideaId => (origin as AnalysisNotifierProvider).ideaId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
