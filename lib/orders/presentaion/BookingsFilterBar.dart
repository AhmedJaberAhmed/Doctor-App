
import 'package:flutter/material.dart';

import '../data/Appointment.dart';


class BookingsFilterBar extends StatelessWidget {
  final AppointmentStatus? activeFilter;
  final ValueChanged<AppointmentStatus?> onFilterChanged;

  const BookingsFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const _filters = [
    (null, 'All'),
    (AppointmentStatus.confirmed, 'Confirmed'),
    (AppointmentStatus.pendingPayment, 'Pending'),
    (AppointmentStatus.completed, 'Completed'),
    (AppointmentStatus.cancelled, 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (status, label) = _filters[i];
          final isSelected = activeFilter == status;
          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onFilterChanged(status),
            showCheckmark: false,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    );
  }
}