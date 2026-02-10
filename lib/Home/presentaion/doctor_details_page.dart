import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Booking/data/start_paypal_appointment.dart';
import '../domain/booking_slot.dart';
import '../favourites/presentaion/favourites_cubit.dart';
import '../favourites/presentaion/favourites_state.dart';
import 'cubits/DoctorDetailsState.dart';
import 'cubits/booking_cubit.dart';
import 'cubits/booking_state.dart';
import 'cubits/doctor_details_cubit.dart';
import 'doctor_photo.dart';

class DoctorDetailsPage extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsPage({super.key, required this.doctorId});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  BookingSlot? _selectedSlot;
  DateTime? _selectedDay;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DoctorDetailsCubit>().load(widget.doctorId);
    // Load favourites to check if this doctor is favourite
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<FavouritesCubit>().loadFavourites(userId);
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: !isDesktop,
      appBar: AppBar(
        backgroundColor: isDesktop ? Colors.white : Colors.transparent,
        elevation: isDesktop ? 1 : 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: isDesktop ? const Text('Doctor Details') : null,
        actions: [
          BlocBuilder<FavouritesCubit, FavouritesState>(
            builder: (context, favouritesState) {
              final isFavourite = favouritesState is FavouritesLoaded &&
                  favouritesState.isFavourite(widget.doctorId);

              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: isFavourite ? Colors.red : Colors.black87,
                  ),
                  onPressed: () async {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Please sign in first'),
                            ],
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    final state =
                        context.read<DoctorDetailsCubit>().state;
                    if (state is! DoctorDetailsLoaded) return;

                    final d = state.doctor;

                    if (isFavourite) {
                      // Remove from favourites
                      await context.read<FavouritesCubit>().removeFavourite(
                        userId: userId,
                        doctorId: widget.doctorId,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.favorite_border,
                                    color: Colors.white),
                                SizedBox(width: 12),
                                Text('Removed from favourites'),
                              ],
                            ),
                            backgroundColor: Colors.grey[800],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } else {
                      // Add to favourites
                      await context.read<FavouritesCubit>().addFavourite(
                        userId: userId,
                        doctorId: widget.doctorId,
                        fullName: d.fullName,
                        title: d.title,
                        city: d.city,
                        clinicName: d.clinicName,
                        photoPath: d.photoPath,
                        ratingAvg: d.ratingAvg,
                        ratingCount: d.ratingCount,
                        consultationFeeCents: d.consultationFeeCents,
                        currency: d.currency,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.favorite, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Added to favourites'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
          if (isDesktop) const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text('Booking Confirmed!', textAlign: TextAlign.center),
                  ],
                ),
                content: const Text(
                  'Your appointment has been successfully booked. You will receive a confirmation shortly.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
          builder: (context, state) {
            if (state is DoctorDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DoctorDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.red[700], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is DoctorDetailsLoaded) {
              final d = state.doctor;
              final slots = state.slots;

              // Auto select the first day that has any slots
              final days = _nextDays(7);
              _selectedDay ??= days.firstWhere(
                    (day) => slots.any((s) => _isSameDay(s.startsAt, day)),
                orElse: () => days.first,
              );

              final selectedDay = _selectedDay ?? days.first;

              // Slots for selected day
              final daySlots = slots
                  .where((s) => _isSameDay(s.startsAt, selectedDay))
                  .toList()
                ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

              // Desktop/Tablet: Two column layout
              if (isDesktop || isTablet) {
                return _buildDesktopLayout(
                  context,
                  d,
                  slots,
                  days,
                  selectedDay,
                  daySlots,
                  userId,
                  isDesktop,
                );
              }

              // Mobile: Single column layout
              return _buildMobileLayout(
                context,
                d,
                slots,
                days,
                selectedDay,
                daySlots,
                userId,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      dynamic d,
      List<BookingSlot> slots,
      List<DateTime> days,
      DateTime selectedDay,
      List<BookingSlot> daySlots,
      String? userId,
      ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(context, d, false),
          const SizedBox(height: 24),
          _buildDoctorInfoCard(context, d, false),
          const SizedBox(height: 20),
          if (d.clinicName != null ||
              d.clinicAddress != null ||
              d.city != null)
            _buildClinicCard(context, d, false),
          if (d.bio != null && d.bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAboutCard(context, d, false),
          ],
          const SizedBox(height: 20),
          _buildBookingCard(
              context, d, slots, days, selectedDay, daySlots, false),
          const SizedBox(height: 20),
          _buildNotesCard(context, false),
          const SizedBox(height: 20),
          _buildBookingButton(context, d, userId, false),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      dynamic d,
      List<BookingSlot> slots,
      List<DateTime> days,
      DateTime selectedDay,
      List<BookingSlot> daySlots,
      String? userId,
      bool isDesktop,
      ) {
    final maxWidth = isDesktop ? 1200.0 : 900.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 40.0 : 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Doctor info
                Expanded(
                  flex: isDesktop ? 5 : 1,
                  child: Column(
                    children: [
                      _buildHeroSection(context, d, true),
                      const SizedBox(height: 24),
                      _buildDoctorInfoCard(context, d, true),
                      const SizedBox(height: 20),
                      if (d.clinicName != null ||
                          d.clinicAddress != null ||
                          d.city != null)
                        _buildClinicCard(context, d, true),
                      if (d.bio != null && d.bio!.trim().isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildAboutCard(context, d, true),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: isDesktop ? 40 : 24),
                // Right column - Booking
                Expanded(
                  flex: isDesktop ? 4 : 1,
                  child: Column(
                    children: [
                      _buildBookingCard(
                          context, d, slots, days, selectedDay, daySlots, true),
                      const SizedBox(height: 20),
                      _buildNotesCard(context, true),
                      const SizedBox(height: 20),
                      _buildBookingButton(context, d, userId, true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, dynamic d, bool isDesktopLayout) {
    if (isDesktopLayout) {
      // Desktop: Horizontal layout with photo on side
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.2), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  DoctorPhoto(
                    photoPath: d.photoPath,
                    width: 120,
                    height: 120,
                    radius: 60,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.check,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.fullName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (d.title != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      d.title!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile: Vertical layout with centered photo
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF4A90E2).withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: DoctorPhoto(
                photoPath: d.photoPath,
                width: 140,
                height: 140,
                radius: 70,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: MediaQuery.of(context).size.width / 2 - 12,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfoCard(
      BuildContext context, dynamic d, bool isDesktopLayout) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktopLayout ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isDesktopLayout) ...[
            Text(
              d.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (d.title != null) ...[
              const SizedBox(height: 8),
              Text(
                d.title!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
          ],
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                Icons.people_outline,
                '${d.ratingCount}+',
                'Patients',
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[300],
              ),
              _buildStatItem(
                Icons.star,
                d.ratingAvg.toStringAsFixed(1),
                'Rating',
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[300],
              ),
              _buildStatItem(
                Icons.work_outline,
                '5+',
                'Years',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClinicCard(BuildContext context, dynamic d, bool isDesktopLayout) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktopLayout ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Clinic Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (d.clinicName != null) ...[
            Text(
              d.clinicName!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (d.clinicAddress != null) ...[
            Text(
              d.clinicAddress!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (d.city != null)
            Text(
              d.city!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // Open maps
            },
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4A90E2),
              side: const BorderSide(color: Color(0xFF4A90E2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, dynamic d, bool isDesktopLayout) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktopLayout ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            d.bio!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
      BuildContext context,
      dynamic d,
      List<BookingSlot> slots,
      List<DateTime> days,
      DateTime selectedDay,
      List<BookingSlot> daySlots,
      bool isDesktopLayout,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktopLayout ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Date & Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Calendar view - Responsive based on screen size
          if (isDesktopLayout)
          // Desktop/Tablet: Grid view
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal number of columns based on available width
                final itemWidth = 85.0; // minimum width for each day card
                final spacing = 12.0;
                final availableWidth = constraints.maxWidth;
                final crossAxisCount = (availableWidth / (itemWidth + spacing))
                    .floor()
                    .clamp(3, 7);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, i) =>
                      _buildDayCard(days[i], selectedDay, slots),
                );
              },
            )
          else
          // Mobile: Horizontal scroll
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _buildDayCard(days[i], selectedDay, slots),
              ),
            ),
          const SizedBox(height: 24),
          // Available time slots
          const Text(
            'Available Time Slots',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (daySlots.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No slots available for this day',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
          // Responsive wrap for time slots
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: daySlots.map((s) => _buildTimeSlot(s)).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
      DateTime day, DateTime selectedDay, List<BookingSlot> slots) {
    final isSelected = _isSameDay(day, selectedDay);
    final hasSlots = slots.any((s) => _isSameDay(s.startsAt, day));
    final isToday = _isSameDay(day, DateTime.now());

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
          _selectedSlot = null;
        });
      },
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF5BA3F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : null,
          color: isSelected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90E2)
                : hasSlots
                ? Colors.grey[300]!
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weekdayShort(day),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : hasSlots
                    ? Colors.black87
                    : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isSelected
                    ? Colors.white
                    : hasSlots
                    ? Colors.black87
                    : Colors.grey[400],
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 4),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                ),
              ),
            ] else
              const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(BookingSlot s) {
    final selected = _selectedSlot?.startsAt == s.startsAt;

    return GestureDetector(
      onTap: () => setState(() => _selectedSlot = s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF5BA3F5)],
          )
              : null,
          color: selected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4A90E2) : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Text(
          s.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, bool isDesktopLayout) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktopLayout ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe your symptoms or reason for visit (optional)',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(
      BuildContext context, dynamic d, String? userId, bool isDesktopLayout) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktopLayout ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consultation Fee',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(d.consultationFeeCents / 100).toStringAsFixed(0)} ${d.currency}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Please sign in first'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }

                if (_selectedSlot == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Please select a time slot'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }

                // Replace old booking logic with PayPal integration
                await startPayPalAppointment(
                  context: context,
                  doctorId: d.id,
                  startsAt: _selectedSlot!.startsAt,
                  endsAt: _selectedSlot!.endsAt,
                  feeCents: d.consultationFeeCents,
                  currency: d.currency,
                  patientNote: _note.text.trim().isEmpty ? null : _note.text.trim(),

                  // TODO: Replace with your actual PayPal credentials
                  paypalClientId: "ATVF9Vb5xfE6CoS-UE8oSD8SG_YIC2jCJBOjZ7IOCLgarV-WmygB3H_Owf4EjFxshxiP6tMbnnEWUFYJ",
                  paypalSecret: "EII2zxQig_w4xzkJLIrNplRlxcQ6O7TuANsHIB4W8oHZMPfaaq_3RAojikx0sGTs41iqq3hDySZANhBv",
                  sandboxMode: true, // Set to false for production
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: const Color(0xFF4A90E2).withOpacity(0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4A90E2), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ===== Helpers =====
  List<DateTime> _nextDays(int count) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return List.generate(count, (i) => start.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayShort(DateTime d) {
    const map = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return map[d.weekday] ?? '';
  }
}