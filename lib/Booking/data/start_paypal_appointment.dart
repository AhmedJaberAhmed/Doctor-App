import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/appointments_repository.dart';
import '../domain/payments_repository.dart';


String _paypalCurrency(String appCurrency) {
  const supported = {'USD', 'EUR', 'GBP', 'AUD', 'CAD'};
  final c = appCurrency.toUpperCase();
  return supported.contains(c) ? c : 'USD';
}

String? _extractPaypalOrderId(Map params) {
  try {
    final data = params['data'];
    if (data is Map && data['id'] != null) return data['id'].toString();
  } catch (_) {}
  return null;
}

Future<void> startPayPalAppointment({
  required BuildContext context,
  required String doctorId,
  required DateTime startsAt,
  required DateTime endsAt,
  required int feeCents,
  required String currency,
  String? patientNote,

  // WARNING: putting secret in app is not secure (see note below)
  required String paypalClientId,
  required String paypalSecret,
  bool sandboxMode = true,
}) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please sign in first')),
    );
    return;
  }

  final apptRepo = AppointmentsRepository(supabaseClient: supabase);
  final payRepo = PaymentsRepository(supabaseClient: supabase);

  final payCurrency = _paypalCurrency(currency);
  final total = (feeCents / 100.0).toStringAsFixed(2);

  // 1) Create pending appointment
  final appointmentId = await apptRepo.createPendingAppointment(
    userId: user.id,
    doctorId: doctorId,
    startsAt: startsAt,
    endsAt: endsAt,
    patientNote: patientNote,
    feeCents: feeCents,
    currency: payCurrency,
  );

  // 2) Create payment row
  await payRepo.createPayment(
    appointmentId: appointmentId,
    userId: user.id,
    amountCents: feeCents,
    currency: payCurrency,
  );

  // 3) Go to PayPal checkout
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PaypalCheckoutView(
        sandboxMode: sandboxMode,
        clientId: paypalClientId,
        secretKey: paypalSecret,
        transactions: [
          {
            "amount": {
              "total": total,
              "currency": payCurrency,
              "details": {"subtotal": total, "shipping": "0", "shipping_discount": 0}
            },
            "description": "Doctor appointment payment",
            "item_list": {
              "items": [
                {
                  "name": "Doctor Appointment",
                  "quantity": 1,
                  "price": total,
                  "currency": payCurrency,
                }
              ],
            }
          }
        ],
        note: "Contact us if you have any questions.",

        onSuccess: (Map params) async {
          log("PAYPAL SUCCESS: $params");

          if (Navigator.canPop(context)) Navigator.pop(context);

          final messenger = ScaffoldMessenger.of(context);
          final paypalOrderId = _extractPaypalOrderId(params);

          try {
            // You might choose 'approved' or 'captured' based on your flow
            await payRepo.updatePayment(
              appointmentId: appointmentId,
              status: 'approved',
              paypalOrderId: paypalOrderId,
              raw: Map<String, dynamic>.from(params),
            );

            await apptRepo.setAppointmentStatus(
              appointmentId: appointmentId,
              status: 'confirmed',
            );

            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Payment successful — Appointment confirmed'),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // optionally pop doctor details page or refresh state here
          } catch (e) {
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text('Paid, but failed to save appointment: $e'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },

        onError: (error) async {
          log("PAYPAL ERROR: $error");

          if (Navigator.canPop(context)) Navigator.pop(context);

          // mark failed/cancelled
          await payRepo.updatePayment(
            appointmentId: appointmentId,
            status: 'failed',
            raw: {'error': error.toString()},
          );
          await apptRepo.setAppointmentStatus(
            appointmentId: appointmentId,
            status: 'cancelled',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: $error')),
          );
        },

        onCancel: () async {
          log("PAYPAL CANCELLED");

          if (Navigator.canPop(context)) Navigator.pop(context);

          await payRepo.updatePayment(
            appointmentId: appointmentId,
            status: 'failed',
            raw: {'cancelled': true},
          );
          await apptRepo.setAppointmentStatus(
            appointmentId: appointmentId,
            status: 'cancelled',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled')),
          );
        },
      ),
    ),
  );
}
