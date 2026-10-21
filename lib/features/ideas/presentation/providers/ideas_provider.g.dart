// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ideas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ideasHash() => r'da52c1f2d5c46f93381588a934fb98d2c11886c8';

/// See also [ideas].
@ProviderFor(ideas)
final ideasProvider = AutoDisposeStreamProvider<List<domain.Idea>>.internal(
  ideas,
  name: r'ideasProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ideasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IdeasRef = AutoDisposeStreamProviderRef<List<domain.Idea>>;
String _$ideaByIdHash() => r'4cb73080df895333e48a9d799dd46e8d0bda2e12';

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

/// See also [ideaById].
@ProviderFor(ideaById)
const ideaByIdProvider = IdeaByIdFamily();

/// See also [ideaById].
class IdeaByIdFamily extends Family<AsyncValue<domain.Idea?>> {
  /// See also [ideaById].
  const IdeaByIdFamily();

  /// See also [ideaById].
  IdeaByIdProvider call(String id) {
    return IdeaByIdProvider(id);
  }

  @override
  IdeaByIdProvider getProviderOverride(covariant IdeaByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ideaByIdProvider';
}

/// See also [ideaById].
class IdeaByIdProvider extends AutoDisposeStreamProvider<domain.Idea?> {
  /// See also [ideaById].
  IdeaByIdProvider(String id)
    : this._internal(
        (ref) => ideaById(ref as IdeaByIdRef, id),
        from: ideaByIdProvider,
        name: r'ideaByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ideaByIdHash,
        dependencies: IdeaByIdFamily._dependencies,
        allTransitiveDependencies: IdeaByIdFamily._allTransitiveDependencies,
        id: id,
      );

  IdeaByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<domain.Idea?> Function(IdeaByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IdeaByIdProvider._internal(
        (ref) => create(ref as IdeaByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<domain.Idea?> createElement() {
    return _IdeaByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IdeaByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IdeaByIdRef on AutoDisposeStreamProviderRef<domain.Idea?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _IdeaByIdProviderElement
    extends AutoDisposeStreamProviderElement<domain.Idea?>
    with IdeaByIdRef {
  _IdeaByIdProviderElement(super.provider);

  @override
  String get id => (origin as IdeaByIdProvider).id;
}

String _$ideasNotifierHash() => r'bde7ed6b4164cdac27a480a8b4802c3f3bcac028';

/// See also [IdeasNotifier].
@ProviderFor(IdeasNotifier)
final ideasNotifierProvider =
    AutoDisposeNotifierProvider<IdeasNotifier, void>.internal(
      IdeasNotifier.new,
      name: r'ideasNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ideasNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IdeasNotifier = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
