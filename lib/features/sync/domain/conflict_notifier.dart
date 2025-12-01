import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/features/sync/domain/models/data_conflict.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conflict_notifier.g.dart';

/// Manages data conflicts between local and remote versions
@riverpod
class ConflictNotifier extends _$ConflictNotifier {
  @override
  List<DataConflict> build() {
    // Load conflicts from Hive
    return _getConflictsFromHive();
  }

  /// Get all conflicts from Hive
  List<DataConflict> _getConflictsFromHive() {
    final box = Hive.box<DataConflict>('conflicts');
    return box.values.toList();
  }

  /// Add a new conflict
  Future<void> addConflict(DataConflict conflict) async {
    final box = Hive.box<DataConflict>('conflicts');
    await box.put(conflict.id, conflict);

    // Update state
    state = _getConflictsFromHive();

    print('ConflictNotifier: Added conflict ${conflict.id} for ${conflict.itemType} ${conflict.itemId}');
  }

  /// Resolve conflict by keeping local version
  Future<void> resolveKeepLocal(String conflictId) async {
    final box = Hive.box<DataConflict>('conflicts');
    final conflict = box.get(conflictId);

    if (conflict == null) {
      print('ConflictNotifier: Conflict $conflictId not found');
      return;
    }

    // Remove conflict from Hive
    await box.delete(conflictId);

    // Update state
    state = _getConflictsFromHive();

    // Note: The local version is already in Hive, and it's marked as dirty,
    // so it will sync to Firebase on the next sync cycle
    print('ConflictNotifier: Resolved conflict $conflictId - kept local version');
  }

  /// Resolve conflict by keeping remote version
  Future<void> resolveKeepRemote(String conflictId) async {
    final box = Hive.box<DataConflict>('conflicts');
    final conflict = box.get(conflictId);

    if (conflict == null) {
      print('ConflictNotifier: Conflict $conflictId not found');
      return;
    }

    // Remove conflict from Hive
    await box.delete(conflictId);

    // Update state
    state = _getConflictsFromHive();

    // Return the conflict data so caller can apply the remote version
    print('ConflictNotifier: Resolved conflict $conflictId - kept remote version');
  }

  /// Get conflicts for a specific item
  List<DataConflict> getConflictsForItem(String itemType, String itemId) {
    return state.where((c) => c.itemType == itemType && c.itemId == itemId).toList();
  }

  /// Check if an item has conflicts
  bool hasConflict(String itemType, String itemId) {
    return state.any((c) => c.itemType == itemType && c.itemId == itemId);
  }

  /// Get count of unresolved conflicts
  int get conflictCount => state.length;
}

/// Provider to get conflict count
@riverpod
int conflictCount(Ref ref) {
  final conflicts = ref.watch(conflictNotifierProvider);
  return conflicts.length;
}
