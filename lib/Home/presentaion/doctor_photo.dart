import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorPhoto extends StatelessWidget {
  final String? photoPath; // value from doctors.photo_path
  final double width;
  final double height;
  final double radius;

  /// ✅ CHANGE THIS to your real storage bucket name
  static const String bucket = 'doctor-media';

  const DoctorPhoto({
    super.key,
    required this.photoPath,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath == null || photoPath!.trim().isEmpty) {
      return _placeholder();
    }

    final supabase = Supabase.instance.client;

    // PUBLIC bucket URL
    final url = supabase.storage.from(bucket).getPublicUrl(photoPath!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.grey.shade200,
      ),
      child: const Icon(Icons.person, size: 32, color: Colors.grey),
    );
  }
}
