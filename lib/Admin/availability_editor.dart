import 'package:flutter/material.dart';

import 'domain/Availability.dart';

class AvailabilityEditor extends StatefulWidget {
  final List<Availability> initial;
  final ValueChanged<List<Availability>> onChanged;

  const AvailabilityEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<AvailabilityEditor> createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  late List<Availability> _rows;

  static const _days = <int, String>{
    0: 'Sun',
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
  };

  @override
  void initState() {
    super.initState();
    _rows = List.of(widget.initial);
  }

  String _toHHMMSS(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return "$hh:$mm:00";
  }

  TimeOfDay _fromHHMMSS(String s) {
    final parts = s.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _pickStart(int i) async {
    final current = _fromHHMMSS(_rows[i].startTime);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;

    setState(() {
      _rows[i] = Availability(
        dayOfWeek: _rows[i].dayOfWeek,
        startTime: _toHHMMSS(picked),
        endTime: _rows[i].endTime,
        slotMinutes: _rows[i].slotMinutes,
      );
    });
    widget.onChanged(_rows);
  }

  Future<void> _pickEnd(int i) async {
    final current = _fromHHMMSS(_rows[i].endTime);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;

    setState(() {
      _rows[i] = Availability(
        dayOfWeek: _rows[i].dayOfWeek,
        startTime: _rows[i].startTime,
        endTime: _toHHMMSS(picked),
        slotMinutes: _rows[i].slotMinutes,
      );
    });
    widget.onChanged(_rows);
  }

  void _setDay(int i, int day) {
    setState(() {
      _rows[i] = Availability(
        dayOfWeek: day,
        startTime: _rows[i].startTime,
        endTime: _rows[i].endTime,
        slotMinutes: _rows[i].slotMinutes,
      );
    });
    widget.onChanged(_rows);
  }

  void _setSlotMinutes(int i, int minutes) {
    setState(() {
      _rows[i] = Availability(
        dayOfWeek: _rows[i].dayOfWeek,
        startTime: _rows[i].startTime,
        endTime: _rows[i].endTime,
        slotMinutes: minutes,
      );
    });
    widget.onChanged(_rows);
  }

  bool _isRowValid(Availability a) {
    // simple check: end > start lexicographically works for HH:MM:SS
    return a.endTime.compareTo(a.startTime) > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Availability",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        ...List.generate(_rows.length, (i) {
          final row = _rows[i];
          final valid = _isRowValid(row);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      DropdownButton<int>(
                        value: row.dayOfWeek,
                        items: _days.entries
                            .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                            .toList(),
                        onChanged: (v) => _setDay(i, v ?? row.dayOfWeek),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() => _rows.removeAt(i));
                          widget.onChanged(_rows);
                        },
                        icon: const Icon(Icons.delete_outline),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickStart(i),
                          child: Text("Start: ${row.startTime.substring(0, 5)}"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickEnd(i),
                          child: Text("End: ${row.endTime.substring(0, 5)}"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Slot"),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: row.slotMinutes,
                        items: const [10, 15, 20, 30, 45, 60]
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text("$m min"),
                        ))
                            .toList(),
                        onChanged: (v) => _setSlotMinutes(i, v ?? row.slotMinutes),
                      ),
                      const Spacer(),
                      if (!valid)
                        const Text(
                          "End must be after start",
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _rows.add(const Availability(
                dayOfWeek: 1,
                startTime: "09:00:00",
                endTime: "17:00:00",
                slotMinutes: 30,
              ));
            });
            widget.onChanged(_rows);
          },
          icon: const Icon(Icons.add),
          label: const Text("Add day/time"),
        ),
      ],
    );
  }
}
