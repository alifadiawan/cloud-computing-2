class PlaceModel {
  final int id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final double rating;
  final String photoUrl;

  // Optional future features
  final bool isFavorite;
  final double distance;

  PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.rating,
    required this.photoUrl,
    this.isFavorite = false,
    this.distance = 0.0,
  });

  /// FIREBASE -> MODEL
  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      photoUrl: map['photo_url'] ?? '',
      isFavorite: map['is_favorite'] ?? false,
      distance: (map['distance'] ?? 0).toDouble(),
    );
  }

  /// MODEL -> FIREBASE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'rating': rating,
      'photo_url': photoUrl,
      'is_favorite': isFavorite,
      'distance': distance,
    };
  }

  /// COPY WITH
  PlaceModel copyWith({
    int? id,
    String? name,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    double? rating,
    String? photoUrl,
    bool? isFavorite,
    double? distance,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      photoUrl: photoUrl ?? this.photoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
    );
  }

  @override
  String toString() {
    return '''
PlaceModel(
  id: $id,
  name: $name,
  category: $category,
  latitude: $latitude,
  longitude: $longitude
)
''';
  }
}