import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Admin/presentation/admin_add_doctor_page.dart';
import 'cubits/categories_cubit.dart';
import 'cubits/categories_state.dart';
import 'cubits/doctors_cubit.dart';
import 'cubits/doctors_state.dart';
import 'doctor_details_page.dart';
import 'doctor_photo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().load();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterDoctors(List<dynamic> doctors) {
    if (_searchQuery.isEmpty) return doctors;

    return doctors.where((doctor) {
      final name = doctor.fullName?.toLowerCase() ?? '';
      final title = doctor.title?.toLowerCase() ?? '';
      final city = doctor.city?.toLowerCase() ?? '';
      final clinicName = doctor.clinicName?.toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          title.contains(_searchQuery) ||
          city.contains(_searchQuery) ||
          clinicName.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Calculate responsive padding
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 24.0 : 20.0);
    final maxContentWidth = isDesktop ? 1400.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: isDesktop,
        title: Text(
          'Find Your Doctor',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 24 : 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminAddDoctorPage()),
              );

            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {
              // Notifications
            },
          ),
          if (isDesktop) SizedBox(width: horizontalPadding),
        ],
        leading: isDesktop
            ? Padding(
          padding: EdgeInsets.only(left: horizontalPadding),
          child: const Icon(Icons.medical_services, color: Color(0xFF4A90E2)),
        )
            : null,
      ),
      body: BlocListener<CategoriesCubit, CategoriesState>(
        listener: (context, state) {
          if (state is CategoriesLoaded) {
            context.read<DoctorsCubit>().load(state.selectedCategoryId);
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              children: [
                // Search bar (desktop/tablet)
                if (isDesktop || isTablet)
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 16),
                    child: _buildSearchBar(context),
                  ),

                // Categories section
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          (isDesktop || isTablet) ? 8 : 16,
                          horizontalPadding,
                          12,
                        ),
                        child: Text(
                          'Specialties',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildCategoriesSection(context, horizontalPadding, isDesktop, isTablet),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Search bar (mobile)
                if (!isDesktop && !isTablet)
                  Container(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
                    child: _buildSearchBar(context),
                  ),

                // Doctors list header
                Container(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 12),
                  alignment: Alignment.centerLeft,
                  child: BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, state) {
                      if (state is CategoriesLoaded) {
                        final category = state.categories.firstWhere(
                              (c) => c.id == state.selectedCategoryId,
                          orElse: () => state.categories.first,
                        );

                        if (_searchQuery.isNotEmpty) {
                          return Text(
                            'Search results for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          );
                        }

                        return Text(
                          'Available ${category.name}',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        );
                      }
                      return Text(
                        _searchQuery.isNotEmpty
                            ? 'Search results for "$_searchQuery"'
                            : 'Available Doctors',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),

                // Doctors list with responsive grid
                Expanded(
                  child: _buildDoctorsList(context, horizontalPadding, isDesktop, isTablet),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search doctors, specialties, locations...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, color: Colors.grey[500]),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 12),
                  const Text(
                    'Search Doctors',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSearchBar(context),
              const SizedBox(height: 16),
              Text(
                'You can search by doctor name, specialty, city, or clinic',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, double horizontalPadding, bool isDesktop, bool isTablet) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            child: const LinearProgressIndicator(),
          );
        }

        if (state is CategoriesError) {
          return Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.message,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CategoriesLoaded) {
          // Desktop/Tablet: Show as wrapped chips
          if (isDesktop || isTablet) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: state.categories.map((c) {
                  final selected = c.id == state.selectedCategoryId;
                  return FilterChip(
                    label: Text(
                      c.name,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: isDesktop ? 15 : 14,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) {
                      context.read<CategoriesCubit>().select(c.id);
                      // Clear search when category changes
                      if (_searchQuery.isNotEmpty) {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      }
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF4A90E2),
                    checkmarkColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : 16,
                      vertical: isDesktop ? 12 : 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: selected ? const Color(0xFF4A90E2) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    elevation: selected ? 2 : 0,
                  );
                }).toList(),
              ),
            );
          }

          // Mobile: Horizontal scrolling
          return SizedBox(
            height: 50,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final c = state.categories[i];
                final selected = c.id == state.selectedCategoryId;

                return FilterChip(
                  label: Text(
                    c.name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) {
                    context.read<CategoriesCubit>().select(c.id);
                    // Clear search when category changes
                    if (_searchQuery.isNotEmpty) {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    }
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: const Color(0xFF4A90E2),
                  checkmarkColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: selected ? const Color(0xFF4A90E2) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  elevation: selected ? 2 : 0,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDoctorsList(
      BuildContext context, double horizontalPadding, bool isDesktop, bool isTablet) {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        if (state is DoctorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DoctorsError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DoctorsLoaded) {
          // Apply search filter
          final filteredDoctors = _filterDoctors(state.doctors);

          if (filteredDoctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isNotEmpty ? Icons.search_off : Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty ? 'No doctors found' : 'No doctors available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'Try selecting another specialty',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Search'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          if (isDesktop || isTablet) {
            final crossAxisCount = isDesktop ? 3 : 2;
            final childAspectRatio = isDesktop ? 1.15 : 1.0;

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: filteredDoctors.length,
              itemBuilder: (_, i) => _buildDoctorCard(context, filteredDoctors[i], isDesktop),
            );
          }

          // Mobile: List view
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 20),
            itemCount: filteredDoctors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => _buildDoctorCard(context, filteredDoctors[i], false),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDoctorCard(BuildContext context, dynamic d, bool isCompact) {
    // Highlight search matches
    final hasMatch = _searchQuery.isNotEmpty &&
        (d.fullName.toLowerCase().contains(_searchQuery) ||
            (d.title?.toLowerCase().contains(_searchQuery) ?? false) ||
            (d.city?.toLowerCase().contains(_searchQuery) ?? false) ||
            (d.clinicName?.toLowerCase().contains(_searchQuery) ?? false));

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DoctorDetailsPage(doctorId: d.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: hasMatch
              ? Border.all(color: const Color(0xFF4A90E2).withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(hasMatch ? 0.08 : 0.06),
              blurRadius: hasMatch ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor photo with badge
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4A90E2).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: DoctorPhoto(
                          photoPath: d.photoPath,
                          width: isCompact ? 70 : 80,
                          height: isCompact ? 70 : 80,
                          radius: 14,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isCompact ? 15 : 17,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (d.title != null && d.title!.isNotEmpty)
                          Text(
                            d.title!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isCompact ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        // Location row
                        if (d.city != null && d.city!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  d.city!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isCompact ? 11 : 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Clinic name (if available and space permits)
              if (!isCompact && d.clinicName != null && d.clinicName!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        d.clinicName!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Divider
              Divider(height: 1, color: Colors.grey[200]),

              const SizedBox(height: 12),

              // Bottom row: Rating and Price
              Row(
                children: [
                  // Rating
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 8 : 12,
                      vertical: isCompact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: isCompact ? 16 : 18),
                        const SizedBox(width: 4),
                        Text(
                          d.ratingAvg.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isCompact ? 13 : 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${d.ratingCount})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isCompact ? 11 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Price with booking button style
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 16,
                      vertical: isCompact ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF5BA3F5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(d.consultationFeeCents / 100).toStringAsFixed(0)} ${d.currency}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isCompact ? 14 : 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: isCompact ? 16 : 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}