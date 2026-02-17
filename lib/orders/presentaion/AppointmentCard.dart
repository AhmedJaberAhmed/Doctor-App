

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/Appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isCancelling;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isCancelling = false,
    this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                children: [
                  _DoctorAvatar(photoPath: appointment.doctorPhotoPath),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName ?? 'Unknown Doctor',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (appointment.doctorTitle != null)
                          Text(
                            appointment.doctorTitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: appointment.status),
                ],
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 14),

               Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_rounded,
                    label: DateFormat('MMM d, yyyy').format(appointment.startsAt.toLocal()),
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label:
                    '${DateFormat('h:mm a').format(appointment.startsAt.toLocal())} – ${DateFormat('h:mm a').format(appointment.endsAt.toLocal())}',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  if (appointment.clinicName != null)
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.location_on_rounded,
                        label: appointment.clinicName!,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${appointment.currency} ${appointment.feeAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

               if (_isCancellable(appointment.status)) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: isCancelling
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel Booking'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isCancellable(AppointmentStatus status) {
    return status == AppointmentStatus.pendingPayment ||
        status == AppointmentStatus.confirmed;
  }
}

class _DoctorAvatar extends StatelessWidget {
  final String? photoPath;
  const _DoctorAvatar({this.photoPath});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: photoPath != null ? NetworkImage(photoPath!) : null,
      child: photoPath == null
          ? Icon(Icons.person_rounded, color: colorScheme.onPrimaryContainer)
          : null,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = _colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colors(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case AppointmentStatus.confirmed:
        return (Colors.green.shade700, Colors.green.shade50);
      case AppointmentStatus.pendingPayment:
        return (Colors.orange.shade700, Colors.orange.shade50);
      case AppointmentStatus.cancelled:
        return (cs.error, cs.errorContainer);
      case AppointmentStatus.completed:
        return (cs.primary, cs.primaryContainer);
      case AppointmentStatus.refunded:
        return (Colors.purple.shade700, Colors.purple.shade50);
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}