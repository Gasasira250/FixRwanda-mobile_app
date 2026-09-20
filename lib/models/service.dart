class Service {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String category;
  final int priceRwf;
  final String professionalId;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.category = '',
    this.priceRwf = 0,
    this.professionalId = '',
  });
}
