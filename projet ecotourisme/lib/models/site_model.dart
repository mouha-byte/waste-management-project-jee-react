import 'package:cloud_firestore/cloud_firestore.dart';

class Site {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final List<String> animals;
  final List<String> plants;
  final List<String> ecoTips;
  final String type; // 'reserve', 'park', 'beach', 'forest', etc.
  final double rating;
  final bool isFavorite;

  Site({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.photos = const [],
    this.animals = const [],
    this.plants = const [],
    this.ecoTips = const [],
    this.type = 'park',
    this.rating = 0.0,
    this.isFavorite = false,
  });

  factory Site.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Site(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      photos: List<String>.from(data['photos'] ?? []),
      animals: List<String>.from(data['animals'] ?? []),
      plants: List<String>.from(data['plants'] ?? []),
      ecoTips: List<String>.from(data['ecoTips'] ?? []),
      type: data['type'] ?? 'park',
      rating: (data['rating'] ?? 0.0).toDouble(),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'animals': animals,
      'plants': plants,
      'ecoTips': ecoTips,
      'type': type,
      'rating': rating,
      'isFavorite': isFavorite,
    };
  }

  Site copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? photos,
    List<String>? animals,
    List<String>? plants,
    List<String>? ecoTips,
    String? type,
    double? rating,
    bool? isFavorite,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
      animals: animals ?? this.animals,
      plants: plants ?? this.plants,
      ecoTips: ecoTips ?? this.ecoTips,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
