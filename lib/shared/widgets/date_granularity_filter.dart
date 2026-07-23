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
    final firstDate = DateTime(now.year - 20);
    final picked = switch (_granularity) {
      _Granularity.year => await _pickYear(
        initialDate: _anchor ?? now,
        firstDate: firstDate,
        lastDate: now,
      ),
      _Granularity.month => await _pickMonth(
        initialDate: _anchor ?? now,
        firstDate: firstDate,
        lastDate: now,
      ),
      _Granularity.all || _Granularity.day => await _pickDay(
        initialDate: _anchor ?? now,
        firstDate: firstDate,
        lastDate: now,
      ),
    };
    if (picked == null) return;
    setState(() => _anchor = picked);
    widget.onChanged(_range);
  }

  Future<DateTime?> _pickDay({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  Future<DateTime?> _pickYear({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SizedBox(
          width: 320,
          height: 320,
          child: YearPicker(
            firstDate: firstDate,
            lastDate: lastDate,
            selectedDate: initialDate,
            onChanged: (date) => Navigator.pop(dialogContext, date),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickMonth({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => _MonthPickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
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

/// Month-only picker dialog — year navigator + 12-month grid, no day view.
class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year = widget.initialDate.year;

  bool _monthEnabled(int month) {
    final date = DateTime(_year, month, 1);
    if (date.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    )) {
      return false;
    }
    if (date.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _year > widget.firstDate.year
                        ? () => setState(() => _year--)
                        : null,
                  ),
                  Text(
                    '$_year',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _year < widget.lastDate.year
                        ? () => setState(() => _year++)
                        : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final enabled = _monthEnabled(month);
                  final selected =
                      _year == widget.initialDate.year &&
                      month == widget.initialDate.month;
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: enabled
                        ? (selected
                              ? FilledButton(
                                  onPressed: () => Navigator.pop(
                                    context,
                                    DateTime(_year, month, 1),
                                  ),
                                  child: Text(
                                    DateFormat.MMM().format(DateTime(0, month)),
                                  ),
                                )
                              : OutlinedButton(
                                  onPressed: () => Navigator.pop(
                                    context,
                                    DateTime(_year, month, 1),
                                  ),
                                  child: Text(
                                    DateFormat.MMM().format(DateTime(0, month)),
                                  ),
                                ))
                        : OutlinedButton(
                            onPressed: null,
                            child: Text(
                              DateFormat.MMM().format(DateTime(0, month)),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
