
class MenuModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String canteenLocation;
  final String imageUrl;
  final bool isAvailable;

  const MenuModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.canteenLocation,
    this.imageUrl = '',
    this.isAvailable = true,
  });

  // Mengubah data dari Firebase/API menjadi objek MenuModel
  factory MenuModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MenuModel(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      category: data['category'] ?? '',
      canteenLocation: data['canteenLocation'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  // Mengubah objek MenuModel menjadi Map untuk Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'canteenLocation': canteenLocation,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}
