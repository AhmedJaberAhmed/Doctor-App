import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/Availability.dart';
import '../domain/create_doctor_input.dart';
import 'Cubits/admin_add_doctor/admin_add_doctor_cubit.dart';
import 'Cubits/admin_add_doctor/admin_add_doctor_state.dart';

class CategoryVm {
  final String id;
  final String name;

  const CategoryVm({required this.id, required this.name});

  factory CategoryVm.fromJson(Map<String, dynamic> json) {
    return CategoryVm(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

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
    0: 'Sunday',
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
  };

  @override
  void initState() {
    super.initState();
    _rows = List.of(widget.initial);
  }

  String _toHHMMSS(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

  TimeOfDay _fromHHMMSS(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isRowValid(Availability a) => a.endTime.compareTo(a.startTime) > 0;

  Future<void> _pickStart(int i) async {
    final picked = await showTimePicker(
        context: context, initialTime: _fromHHMMSS(_rows[i].startTime));
    if (picked == null) return;

    setState(() {
      _rows[i] = _rows[i].copyWith(startTime: _toHHMMSS(picked));
    });
    widget.onChanged(_rows);
  }

  Future<void> _pickEnd(int i) async {
    final picked = await showTimePicker(
        context: context, initialTime: _fromHHMMSS(_rows[i].endTime));
    if (picked == null) return;

    setState(() {
      _rows[i] = _rows[i].copyWith(endTime: _toHHMMSS(picked));
    });
    widget.onChanged(_rows);
  }

  void _setDay(int i, int day) {
    setState(() {
      _rows[i] = _rows[i].copyWith(dayOfWeek: day);
    });
    widget.onChanged(_rows);
  }

  void _setSlotMinutes(int i, int minutes) {
    setState(() {
      _rows[i] = _rows[i].copyWith(slotMinutes: minutes);
    });
    widget.onChanged(_rows);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_rows.length, (i) {
          final row = _rows[i];
          final valid = _isRowValid(row);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: valid ? Colors.grey[300]! : Colors.red[300]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: row.dayOfWeek,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A90E2), size: 20),
                              isExpanded: true,
                              isDense: true,
                              items: _days.entries
                                  .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey[700]),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                                  .toList(),
                              onChanged: (v) => _setDay(i, v ?? row.dayOfWeek),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() => _rows.removeAt(i));
                            widget.onChanged(_rows);
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          tooltip: 'Remove',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _pickStart(i),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 18,
                                        color: Color(0xFF4A90E2)),
                                    const SizedBox(width: 8),
                                    Text(
                                      row.startTime.substring(0, 5),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _pickEnd(i),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 18,
                                        color: Color(0xFF4A90E2)),
                                    const SizedBox(width: 8),
                                    Text(
                                      row.endTime.substring(0, 5),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot Duration',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: row.slotMinutes,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                            isExpanded: true,
                            isDense: true,
                            items: const [10, 15, 20, 30, 45, 60]
                                .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                "$m minutes",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ))
                                .toList(),
                            onChanged: (v) => _setSlotMinutes(i, v ?? row.slotMinutes),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!valid) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "End time must be after start time",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _rows.add(const Availability(
                    dayOfWeek: 1,
                    startTime: "09:00:00",
                    endTime: "17:00:00",
                    slotMinutes: 30));
              });
              widget.onChanged(_rows);
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              "Add Time Slot",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4A90E2),
              side: const BorderSide(color: Color(0xFF4A90E2), width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension AvailabilityCopy on Availability {
  Availability copyWith({
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? slotMinutes,
  }) {
    return Availability(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotMinutes: slotMinutes ?? this.slotMinutes,
    );
  }
}

class AdminAddDoctorPage extends StatefulWidget {
  const AdminAddDoctorPage({super.key});

  @override
  State<AdminAddDoctorPage> createState() => _AdminAddDoctorPageState();
}

class _AdminAddDoctorPageState extends State<AdminAddDoctorPage> {
  final _name = TextEditingController();
  final _title = TextEditingController();
  final _bio = TextEditingController();
  final _fee = TextEditingController();
  final _clinicName = TextEditingController();
  final _clinicAddress = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();

  Uint8List? _photo;
  String? _photoExt;

  final _supabase = Supabase.instance.client;
  final List<String> _selectedCategoryIds = [];
  List<CategoryVm> _allCategories = [];
  bool _categoriesLoading = false;
  String? _categoriesError;

  final List<Availability> _availability = [
    const Availability(
        dayOfWeek: 1,
        startTime: "09:00:00",
        endTime: "17:00:00",
        slotMinutes: 30)
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _bio.dispose();
    _fee.dispose();
    _clinicName.dispose();
    _clinicAddress.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = null;
    });

    try {
      final data = await _supabase
          .from('categories')
          .select('id, name')
          .order('name', ascending: true);

      final list = (data as List)
          .map((e) => CategoryVm.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _allCategories = list;
        _categoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        _categoriesError = e.toString();
        _categoriesLoading = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img == null) return;

    final bytes = await img.readAsBytes();
    final ext = img.name.split('.').last.toLowerCase();

    setState(() {
      _photo = bytes;
      _photoExt = ext.isEmpty ? 'jpg' : ext;
    });
  }

  Widget _buildCategorySelector() {
    if (_categoriesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categoriesError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Failed to load categories",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[700]!),
              ),
            ),
          ],
        ),
      );
    }

    if (_allCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No categories found. Add categories first.",
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _allCategories.map((cat) {
        final selected = _selectedCategoryIds.contains(cat.id);
        return FilterChip(
          label: Text(cat.name),
          selected: selected,
          selectedColor: const Color(0xFF4A90E2),
          checkmarkColor: Colors.white,
          backgroundColor: Colors.grey[100],
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selected ? const Color(0xFF4A90E2) : Colors.transparent,
              width: 2,
            ),
          ),
          onSelected: (v) {
            setState(() {
              if (v) {
                _selectedCategoryIds.add(cat.id);
              } else {
                _selectedCategoryIds.remove(cat.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  bool _availabilityValid() {
    for (final a in _availability) {
      if (a.endTime.compareTo(a.startTime) <= 0) return false;
    }
    return _availability.isNotEmpty;
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar("Please enter doctor name");
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      _showErrorSnackBar("Please select at least one category");
      return;
    }

    if (!_availabilityValid()) {
      _showErrorSnackBar("Please add valid availability");
      return;
    }

    final feeValue = double.tryParse(_fee.text.trim()) ?? 0;
    final feeCents = (feeValue * 100).toInt();

    final input = CreateDoctorInput(
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      fullName: name,
      title: _title.text.trim().isEmpty ? null : _title.text.trim(),
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      consultationFeeCents: feeCents,
      currency: "USD",
      clinicName:
      _clinicName.text.trim().isEmpty ? null : _clinicName.text.trim(),
      clinicAddress: _clinicAddress.text.trim().isEmpty
          ? null
          : _clinicAddress.text.trim(),
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      categoryIds: _selectedCategoryIds,
      availability: List.of(_availability),
      photoBytes: _photo?.toList(),
      photoFileExt: _photoExt,
    );

    context.read<AdminAddDoctorCubit>().submit(input);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final maxWidth = isDesktop ? 1000.0 : (isTablet ? 800.0 : double.infinity);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Add New Doctor",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: isDesktop || isTablet,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AdminAddDoctorCubit, AdminAddDoctorState>(
        listener: (context, state) {
          if (state is AdminAddDoctorSuccess) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text('Doctor Added!', textAlign: TextAlign.center),
                  ],
                ),
                content: Text(
                  'Dr. ${state.doctor.fullName} has been successfully added to the system.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            );

            // Reset form
            _name.clear();
            _title.clear();
            _bio.clear();
            _fee.clear();
            _clinicName.clear();
            _clinicAddress.clear();
            _city.clear();
            _phone.clear();

            setState(() {
              _photo = null;
              _photoExt = null;
              _selectedCategoryIds.clear();
              _availability
                ..clear()
                ..add(const Availability(
                    dayOfWeek: 1,
                    startTime: "09:00:00",
                    endTime: "17:00:00",
                    slotMinutes: 30));
            });
          } else if (state is AdminAddDoctorError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          final loading = state is AdminAddDoctorLoading;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: AbsorbPointer(
                absorbing: loading,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 30 : 20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Section
                      _buildSection(
                        title: "Doctor Photo",
                        icon: Icons.photo_camera,
                        child: Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickPhoto,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _photo != null
                                      ? ClipOval(
                                    child: Image.memory(
                                      _photo!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _pickPhoto,
                                icon: const Icon(Icons.upload, size: 20),
                                label: Text(_photo != null ? "Change Photo" : "Upload Photo"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF4A90E2),
                                  side: const BorderSide(color: Color(0xFF4A90E2)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Basic Information
                      _buildSection(
                        title: "Basic Information",
                        icon: Icons.person,
                        child: Column(
                          children: [
                            _buildTextField(_name, "Full Name", Icons.badge, required: true),
                            _buildTextField(_title, "Specialty/Title", Icons.medical_services),
                            _buildTextField(_phone, "Phone Number", Icons.phone,
                                keyboardType: TextInputType.phone),
                            _buildTextField(_bio, "Biography", Icons.description,
                                maxLines: 4),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Consultation Fee
                      _buildSection(
                        title: "Consultation Fee",
                        icon: Icons.attach_money,
                        child: _buildTextField(
                          _fee,
                          "Fee Amount (USD)",
                          Icons.payments,
                          keyboardType: TextInputType.number,
                          required: true,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Clinic Information
                      _buildSection(
                        title: "Clinic Information",
                        icon: Icons.local_hospital,
                        child: Column(
                          children: [
                            _buildTextField(_clinicName, "Clinic Name", Icons.business),
                            _buildTextField(_clinicAddress, "Clinic Address", Icons.location_on),
                            _buildTextField(_city, "City", Icons.location_city),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Specialties
                      _buildSection(
                        title: "Specialties",
                        icon: Icons.category,
                        subtitle: "Select one or more specialties",
                        required: true,
                        child: _buildCategorySelector(),
                      ),

                      const SizedBox(height: 24),

                      // Availability
                      _buildSection(
                        title: "Availability Schedule",
                        icon: Icons.schedule,
                        subtitle: "Set the doctor's working hours",
                        required: true,
                        child: AvailabilityEditor(
                          initial: _availability,
                          onChanged: (rows) {
                            setState(() {
                              _availability
                                ..clear()
                                ..addAll(rows);
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: loading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, size: 22),
                              SizedBox(width: 12),
                              Text(
                                "Save Doctor",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    String? subtitle,
    bool required = false,
    required Widget child,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4A90E2), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (required) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        bool required = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
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
    );
  }
}