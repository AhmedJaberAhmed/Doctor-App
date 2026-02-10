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
