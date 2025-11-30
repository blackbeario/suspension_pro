// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsStreamHash() => r'0f70b2255be0f0545cbb917064bfc297c55a6147';

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

/// Stream provider for settings from Firestore for a specific bike
///
/// Copied from [settingsStream].
@ProviderFor(settingsStream)
const settingsStreamProvider = SettingsStreamFamily();

/// Stream provider for settings from Firestore for a specific bike
///
/// Copied from [settingsStream].
class SettingsStreamFamily extends Family<AsyncValue<List<Setting>>> {
  /// Stream provider for settings from Firestore for a specific bike
  ///
  /// Copied from [settingsStream].
  const SettingsStreamFamily();

  /// Stream provider for settings from Firestore for a specific bike
  ///
  /// Copied from [settingsStream].
  SettingsStreamProvider call(
    String bikeId,
  ) {
    return SettingsStreamProvider(
      bikeId,
    );
  }

  @override
  SettingsStreamProvider getProviderOverride(
    covariant SettingsStreamProvider provider,
  ) {
    return call(
      provider.bikeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'settingsStreamProvider';
}

/// Stream provider for settings from Firestore for a specific bike
///
/// Copied from [settingsStream].
class SettingsStreamProvider extends AutoDisposeStreamProvider<List<Setting>> {
  /// Stream provider for settings from Firestore for a specific bike
  ///
  /// Copied from [settingsStream].
  SettingsStreamProvider(
    String bikeId,
  ) : this._internal(
          (ref) => settingsStream(
            ref as SettingsStreamRef,
            bikeId,
          ),
          from: settingsStreamProvider,
          name: r'settingsStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$settingsStreamHash,
          dependencies: SettingsStreamFamily._dependencies,
          allTransitiveDependencies:
              SettingsStreamFamily._allTransitiveDependencies,
          bikeId: bikeId,
        );

  SettingsStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bikeId,
  }) : super.internal();

  final String bikeId;

  @override
  Override overrideWith(
    Stream<List<Setting>> Function(SettingsStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SettingsStreamProvider._internal(
        (ref) => create(ref as SettingsStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bikeId: bikeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Setting>> createElement() {
    return _SettingsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsStreamProvider && other.bikeId == bikeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bikeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SettingsStreamRef on AutoDisposeStreamProviderRef<List<Setting>> {
  /// The parameter `bikeId` of this provider.
  String get bikeId;
}

class _SettingsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Setting>>
    with SettingsStreamRef {
  _SettingsStreamProviderElement(super.provider);

  @override
  String get bikeId => (origin as SettingsStreamProvider).bikeId;
}

String _$settingsNotifierHash() => r'9e315949976ea81163cbce9191641ee2ffbcc937';

abstract class _$SettingsNotifier
    extends BuildlessAutoDisposeNotifier<List<Setting>> {
  late final String bikeId;

  List<Setting> build(
    String bikeId,
  );
}

/// Provider for getting settings for a specific bike
/// This watches both Firestore stream and Hive for offline-first behavior
///
/// Copied from [SettingsNotifier].
@ProviderFor(SettingsNotifier)
const settingsNotifierProvider = SettingsNotifierFamily();

/// Provider for getting settings for a specific bike
/// This watches both Firestore stream and Hive for offline-first behavior
///
/// Copied from [SettingsNotifier].
class SettingsNotifierFamily extends Family<List<Setting>> {
  /// Provider for getting settings for a specific bike
  /// This watches both Firestore stream and Hive for offline-first behavior
  ///
  /// Copied from [SettingsNotifier].
  const SettingsNotifierFamily();

  /// Provider for getting settings for a specific bike
  /// This watches both Firestore stream and Hive for offline-first behavior
  ///
  /// Copied from [SettingsNotifier].
  SettingsNotifierProvider call(
    String bikeId,
  ) {
    return SettingsNotifierProvider(
      bikeId,
    );
  }

  @override
  SettingsNotifierProvider getProviderOverride(
    covariant SettingsNotifierProvider provider,
  ) {
    return call(
      provider.bikeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'settingsNotifierProvider';
}

/// Provider for getting settings for a specific bike
/// This watches both Firestore stream and Hive for offline-first behavior
///
/// Copied from [SettingsNotifier].
class SettingsNotifierProvider
    extends AutoDisposeNotifierProviderImpl<SettingsNotifier, List<Setting>> {
  /// Provider for getting settings for a specific bike
  /// This watches both Firestore stream and Hive for offline-first behavior
  ///
  /// Copied from [SettingsNotifier].
  SettingsNotifierProvider(
    String bikeId,
  ) : this._internal(
          () => SettingsNotifier()..bikeId = bikeId,
          from: settingsNotifierProvider,
          name: r'settingsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$settingsNotifierHash,
          dependencies: SettingsNotifierFamily._dependencies,
          allTransitiveDependencies:
              SettingsNotifierFamily._allTransitiveDependencies,
          bikeId: bikeId,
        );

  SettingsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bikeId,
  }) : super.internal();

  final String bikeId;

  @override
  List<Setting> runNotifierBuild(
    covariant SettingsNotifier notifier,
  ) {
    return notifier.build(
      bikeId,
    );
  }

  @override
  Override overrideWith(SettingsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SettingsNotifierProvider._internal(
        () => create()..bikeId = bikeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bikeId: bikeId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SettingsNotifier, List<Setting>>
      createElement() {
    return _SettingsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsNotifierProvider && other.bikeId == bikeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bikeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SettingsNotifierRef on AutoDisposeNotifierProviderRef<List<Setting>> {
  /// The parameter `bikeId` of this provider.
  String get bikeId;
}

class _SettingsNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<SettingsNotifier, List<Setting>>
    with SettingsNotifierRef {
  _SettingsNotifierProviderElement(super.provider);

  @override
  String get bikeId => (origin as SettingsNotifierProvider).bikeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
