import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';

/// Reactive, most-recent-first location history for the map (and the
/// timeline). `range == null` is the original unfiltered view, capped so a
/// multi-year dataset doesn't get pulled into memory just to draw a route;
/// a filtered range gets a higher cap since it's already bounded in time.
/// `autoDispose` — each distinct filter range is its own drift `.watch()`
/// subscription, and shouldn't stay live once nothing's watching it.
final locationHistoryProvider = StreamProvider.autoDispose
    .family<List<LocationPoint>, DateTimeRange?>((ref, range) {
      final db = ref.watch(appDatabaseProvider);
      final query = db.select(db.locationPoints)
        ..where((t) => t.deletedAt.isNull());
      if (range != null) {
        query.where(
          (t) =>
              t.recordedAt.isBiggerOrEqualValue(range.start) &
              t.recordedAt.isSmallerThanValue(range.end),
        );
      }
      query.orderBy([(t) => OrderingTerm.desc(t.recordedAt)]);
      query.limit(range == null ? 500 : 2000);
      return query.watch();
    });
