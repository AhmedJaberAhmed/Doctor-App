import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/categories_cubit.dart';
import 'cubits/categories_state.dart';
import 'cubits/doctors_cubit.dart';
import 'cubits/doctors_state.dart';
import 'doctor_details_page.dart';
import 'doctor_photo.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  final List<dynamic> _allDoctors = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
    // Load all doctors initially
    context.read<CategoriesCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterDoctors(List<dynamic> doctors) {
    var filtered = doctors;

    // Apply text search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doctor) {
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

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 24.0 : 20.0);
    final maxContentWidth = isDesktop ? 1400.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: isDesktop,
        title: Text(
          'Search Doctors',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 24 : 22,
          ),
        ),
        leading: isDesktop
            ? Padding(
          padding: EdgeInsets.only(left: horizontalPadding),
          child: const Icon(Icons.search, color: Color(0xFF4A90E2)),
        )
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search by name, specialty, or location...',
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category filters
                    BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, state) {
                        if (state is CategoriesLoaded) {
                          return SizedBox(
                            height: 45,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                FilterChip(
                                  label: const Text('All'),
                                  selected: _selectedCategoryFilter == null,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategoryFilter = null;
                                    });
                                    context.read<DoctorsCubit>().load(state.selectedCategoryId);
                                  },
                                  selectedColor: const Color(0xFF4A90E2),
                                  checkmarkColor: Colors.white,
                                  backgroundColor: Colors.grey[100],
                                  labelStyle: TextStyle(
                                    color: _selectedCategoryFilter == null
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ...state.categories.map((category) {
                                  final selected = _selectedCategoryFilter == category.id;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(category.name),
                                      selected: selected,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedCategoryFilter = category.id;
                                        });
                                        context.read<DoctorsCubit>().load(category.id);
                                      },
                                      selectedColor: const Color(0xFF4A90E2),
                                      checkmarkColor: Colors.white,
                                      backgroundColor: Colors.grey[100],
                                      labelStyle: TextStyle(
                                        color: selected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              // Results header
              if (_searchQuery.isNotEmpty)
                Container(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Search results for "$_searchQuery"',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),

              // Results
              Expanded(
                child: BlocBuilder<DoctorsCubit, DoctorsState>(
                  builder: (context, state) {
                    if (state is DoctorsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is DoctorsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is DoctorsLoaded) {
                      final filteredDoctors = _filterDoctors(state.doctors);

                      if (_searchQuery.isEmpty && filteredDoctors.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 24),
                              Text(
                                'Search for Doctors',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Enter a doctor name, specialty, or location to find the perfect match',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (filteredDoctors.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text(
                                'No doctors found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedCategoryFilter = null;
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Clear All'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF4A90E2),
                                  side: const BorderSide(color: Color(0xFF4A90E2)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.all(horizontalPadding),
                        itemCount: filteredDoctors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) => _buildDoctorCard(filteredDoctors[i]),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 24),
                          Text(
                            'Search for Doctors',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Enter a doctor name, specialty, or location to find the perfect match',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(dynamic d) {
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          width: 80,
                          height: 80,
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
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (d.title != null && d.title!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            d.title!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (d.city != null && d.city!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                d.city!,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          d.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${d.ratingCount})',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      children: [
                        Text(
                          '${(d.consultationFeeCents / 100).toStringAsFixed(0)} ${d.currency}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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