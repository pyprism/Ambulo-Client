import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Granularity { all, day, month, year }

/// Day/Month/Year filter control — shared by Timeline and Map. Fully
/// self-contained (owns its own granularity + anchor date); the caller only
/// ever sees the resolved `DateTimeRange?` via `onChanged` (`null` = "All",
/// the original unfiltered behavior).
class DateGranularityFilter extends StatefulWidget {
  const DateGranularityFilter({super.key, required this.onChanged});

  final ValueChanged<DateTimeRange?> onChanged;

  @override
  State<DateGranularityFilter> createState() => _DateGranularityFilterState();
}

class _DateGranularityFilterState extends State<DateGranularityFilter> {
  _Granularity _granularity = _Granularity.all;
  DateTime? _anchor;

  DateTimeRange? get _range {
    final anchor = _anchor;
    if (anchor == null) return null;
    return switch (_granularity) {
      _Granularity.all => null,
      _Granularity.day => DateTimeRange(
        start: DateTime(anchor.year, anchor.month, anchor.day),
        end: DateTime(anchor.year, anchor.month, anchor.day + 1),
      ),
      _Granularity.month => DateTimeRange(
        start: DateTime(anchor.year, anchor.month, 1),
        end: DateTime(anchor.year, anchor.month + 1, 1),
      ),
      _Granularity.year => DateTimeRange(
        start: DateTime(anchor.year, 1, 1),
        end: DateTime(anchor.year + 1, 1, 1),
      ),
    };
  }

  String get _chipLabel {
    final anchor = _anchor;
    if (anchor == null) return '';
    return switch (_granularity) {
      _Granularity.all => '',
      _Granularity.day => DateFormat.yMMMd().format(anchor),
      _Granularity.month => DateFormat.yMMM().format(anchor),
      _Granularity.year => DateFormat('yyyy').format(anchor),
    };
  }

  Future<void> _pickAnchor() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _anchor = picked);
    widget.onChanged(_range);
  }

  Future<void> _setGranularity(_Granularity granularity) async {
    setState(() => _granularity = granularity);
    if (granularity == _Granularity.all) {
      widget.onChanged(null);
    } else if (_anchor != null) {
      widget.onChanged(_range);
    } else {
      await _pickAnchor();
      // Cancelled the picker with no prior anchor — there's nothing to
      // filter by, so don't leave the segment highlighted on a lie.
      if (mounted && _anchor == null) {
        setState(() => _granularity = _Granularity.all);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<_Granularity>(
          segments: const [
            ButtonSegment(value: _Granularity.all, label: Text('All')),
            ButtonSegment(value: _Granularity.day, label: Text('Day')),
            ButtonSegment(value: _Granularity.month, label: Text('Month')),
            ButtonSegment(value: _Granularity.year, label: Text('Year')),
          ],
          selected: {_granularity},
          onSelectionChanged: (s) => _setGranularity(s.first),
        ),
        if (_granularity != _Granularity.all && _anchor != null)
          InputChip(
            label: Text(_chipLabel),
            onPressed: _pickAnchor,
            onDeleted: () => _setGranularity(_Granularity.all),
          ),
      ],
    );
  }
}
