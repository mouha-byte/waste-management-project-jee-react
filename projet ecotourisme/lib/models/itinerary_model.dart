import 'package:cloud_firestore/cloud_firestore.dart';

class Itinerary {
  final String id;
  final String name;
  final String description;
  final List<LatLngPoint> waypoints;
  final double distanceKm;
  final int durationMinutes;
  final String transportMode; // 'walking', 'cycling', 'car', 'public_transport'
  final String difficulty; // 'easy', 'moderate', 'hard'
  final List<String> siteIds; // Sites along this itinerary
  final String imageUrl;
  
  // New fields for rich data
  final List<String> photos; // Multiple photos for gallery
  final List<String> equipment; // Recommended equipment
  final List<String> pointsOfInterest; // Notable points along the route
  final String bestSeason; // Best time to visit
  final double estimatedCarbonKg; // Estimated carbon footprint
  final int elevationGain; // Elevation gain in meters
  final String region; // Geographic region
  final double price; // Price in Euros (0.0 if free)

  Itinerary({
    required this.id,
    required this.name,
    required this.description,
    required this.waypoints,
    required this.distanceKm,
    required this.durationMinutes,
    this.transportMode = 'walking',
    this.difficulty = 'easy',
    this.siteIds = const [],
    this.imageUrl = '',
    this.photos = const [],
    this.equipment = const [],
    this.pointsOfInterest = const [],
    this.bestSeason = 'Toute l\'année',
    this.estimatedCarbonKg = 0.0,
    this.elevationGain = 0,
    this.region = '',
    this.price = 0.0,
  });

  factory Itinerary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Itinerary(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      waypoints: (data['waypoints'] as List<dynamic>?)
              ?.map((w) => LatLngPoint.fromMap(w as Map<String, dynamic>))
              .toList() ??
          [],
      distanceKm: (data['distanceKm'] ?? 0.0).toDouble(),
      durationMinutes: data['durationMinutes'] ?? 0,
      transportMode: data['transportMode'] ?? 'walking',
      difficulty: data['difficulty'] ?? 'easy',
      siteIds: List<String>.from(data['siteIds'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      equipment: List<String>.from(data['equipment'] ?? []),
      pointsOfInterest: List<String>.from(data['pointsOfInterest'] ?? []),
      bestSeason: data['bestSeason'] ?? 'Toute l\'année',
      estimatedCarbonKg: (data['estimatedCarbonKg'] ?? 0.0).toDouble(),
      elevationGain: data['elevationGain'] ?? 0,
      region: data['region'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'waypoints': waypoints.map((w) => w.toMap()).toList(),
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'transportMode': transportMode,
      'difficulty': difficulty,
      'siteIds': siteIds,
      'imageUrl': imageUrl,
      'photos': photos,
      'equipment': equipment,
      'pointsOfInterest': pointsOfInterest,
      'bestSeason': bestSeason,
      'estimatedCarbonKg': estimatedCarbonKg,
      'elevationGain': elevationGain,
      'region': region,
      'price': price,
    };
  }

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}min';
    }
    return '${mins}min';
  }

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return 'Facile';
      case 'moderate':
        return 'Modéré';
      case 'hard':
        return 'Difficile';
      default:
        return difficulty;
    }
  }

  String get transportModeLabel {
    switch (transportMode) {
      case 'walking':
        return 'À pied';
      case 'cycling':
        return 'À vélo';
      case 'car':
        return 'En voiture';
      case 'public_transport':
        return 'Transport en commun';
      default:
        return transportMode;
    }
  }

  String get transportModeIcon {
    switch (transportMode) {
      case 'walking':
        return '🚶';
      case 'cycling':
        return '🚴';
      case 'car':
        return '🚗';
      case 'public_transport':
        return '🚌';
      default:
        return '🚶';
    }
  }

  // Get all images including main image and photos
  List<String> get allImages {
    final images = <String>[];
    if (imageUrl.isNotEmpty) images.add(imageUrl);
    images.addAll(photos.where((p) => p.isNotEmpty && p != imageUrl));
    return images;
  }

  // Calculate eco score (0-100)
  int get ecoScore {
    int score = 50;
    
    // Transport mode impact
    switch (transportMode) {
      case 'walking':
        score += 30;
        break;
      case 'cycling':
        score += 25;
        break;
      case 'public_transport':
        score += 10;
        break;
      case 'car':
        score -= 20;
        break;
    }
    
    // Carbon footprint impact
    if (estimatedCarbonKg == 0) {
      score += 20;
    } else if (estimatedCarbonKg < 1) {
      score += 10;
    } else if (estimatedCarbonKg > 5) {
      score -= 10;
    }
    
    return score.clamp(0, 100);
  }
}

class LatLngPoint {
  final double latitude;
  final double longitude;

  LatLngPoint({required this.latitude, required this.longitude});

  factory LatLngPoint.fromMap(Map<String, dynamic> map) {
    return LatLngPoint(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
