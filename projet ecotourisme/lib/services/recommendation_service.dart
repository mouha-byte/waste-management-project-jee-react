import 'dart:math';
import 'package:ecoguide/models/site_model.dart';

/// Intelligent recommendation engine for EcoGuide
class RecommendationService {
  /// Get personalized site recommendations based on user preferences
  static List<Site> getPersonalizedRecommendations({
    required List<Site> allSites,
    required List<String> visitedSiteIds,
    required List<String> favoriteSiteIds,
    required Map<String, int> typePreferences,
    double? userLat,
    double? userLng,
  }) {
    // Score each site based on multiple factors
    final scoredSites = allSites.map((site) {
      double score = 0.0;

      // Factor 1: Type preference (40%)
      if (typePreferences.containsKey(site.type)) {
        score += (typePreferences[site.type]! / 10) * 40;
      }

      // Factor 2: Rating (25%)
      score += (site.rating / 5) * 25;

      // Factor 3: Proximity if location available (20%)
      if (userLat != null && userLng != null) {
        final distance = _calculateDistance(
          userLat,
          userLng,
          site.latitude,
          site.longitude,
        );
        // Closer = higher score (max 100km considered)
        score += (1 - min(distance / 100, 1)) * 20;
      }

      // Factor 4: Novelty - not visited yet (15%)
      if (!visitedSiteIds.contains(site.id)) {
        score += 15;
      }

      // Bonus for favorites
      if (favoriteSiteIds.contains(site.id)) {
        score += 10;
      }

      return MapEntry(site, score);
    }).toList();

    // Sort by score descending
    scoredSites.sort((a, b) => b.value.compareTo(a.value));

    return scoredSites.map((e) => e.key).toList();
  }

  /// Calculate carbon footprint for a trip
  static CarbonFootprint calculateCarbonFootprint({
    required double distanceKm,
    required String transportMode,
    required int numberOfPeople,
  }) {
    // CO2 emissions in g/km per person
    const emissionFactors = {
      'walking': 0.0,
      'cycling': 0.0,
      'bus': 89.0,
      'train': 41.0,
      'car': 171.0,
      'plane': 255.0,
    };

    final factor = emissionFactors[transportMode] ?? 171.0;
    final totalEmissions = distanceKm * factor * numberOfPeople;
    
    // Calculate trees needed to offset (1 tree absorbs ~21kg CO2/year)
    final treesNeeded = (totalEmissions / 21000).ceil();
    
    // Calculate eco-score (0-100)
    final ecoScore = transportMode == 'walking' || transportMode == 'cycling'
        ? 100
        : max(0, 100 - (factor / 2.55).round());

    return CarbonFootprint(
      totalEmissionsGrams: totalEmissions,
      treesToOffset: treesNeeded,
      ecoScore: ecoScore,
      equivalentCarKm: totalEmissions / 171,
      transportMode: transportMode,
    );
  }

  /// Get biodiversity score for a site
  static BiodiversityScore calculateBiodiversityScore(Site site) {
    final speciesCount = site.animals.length + site.plants.length;
    
    // Base score from species count
    int score = min(speciesCount * 5, 50);
    
    // Bonus for type
    const typeBonus = {
      'reserve': 30,
      'park': 25,
      'forest': 25,
      'wetland': 30,
      'beach': 15,
      'mountain': 20,
    };
    score += typeBonus[site.type] ?? 10;
    
    // Cap at 100
    score = min(score, 100);
    
    String level;
    if (score >= 80) {
      level = 'Exceptionnel';
    } else if (score >= 60) {
      level = 'Élevé';
    } else if (score >= 40) {
      level = 'Modéré';
    } else {
      level = 'Faible';
    }

    return BiodiversityScore(
      score: score,
      level: level,
      speciesCount: speciesCount,
      animalCount: site.animals.length,
      plantCount: site.plants.length,
    );
  }

  /// Get weather-based activity suggestions
  static List<String> getWeatherBasedSuggestions(WeatherData weather) {
    final suggestions = <String>[];
    
    if (weather.temperature > 25) {
      suggestions.add('🌊 Idéal pour les activités aquatiques');
      suggestions.add('🧴 N\'oubliez pas la protection solaire');
      suggestions.add('💧 Hydratez-vous régulièrement');
    } else if (weather.temperature > 15) {
      suggestions.add('🚶 Parfait pour la randonnée');
      suggestions.add('🚴 Excellent temps pour le vélo');
    } else if (weather.temperature > 5) {
      suggestions.add('🧥 Prévoyez des vêtements chauds');
      suggestions.add('☕ Emportez une boisson chaude');
    } else {
      suggestions.add('❄️ Attention au gel');
      suggestions.add('🧤 Équipement d\'hiver recommandé');
    }

    if (weather.isRainy) {
      suggestions.add('☔ Prenez un imperméable');
      suggestions.add('🏠 Privilégiez les activités couvertes');
    }

    if (weather.isWindy) {
      suggestions.add('💨 Évitez les crêtes exposées');
    }

    return suggestions;
  }

  /// Get best time to visit a site
  static BestTimeToVisit getBestTimeToVisit(Site site) {
    // Simplified logic - in real app, would use historical data
    final now = DateTime.now();
    
    if (site.type == 'beach') {
      return BestTimeToVisit(
        bestMonths: ['Juin', 'Juillet', 'Août', 'Septembre'],
        bestTimeOfDay: '10h - 18h',
        crowdLevel: now.month >= 6 && now.month <= 8 ? 'Élevé' : 'Modéré',
        recommendation: 'Préférez début septembre pour éviter la foule',
      );
    } else if (site.type == 'reserve') {
      return BestTimeToVisit(
        bestMonths: ['Mars', 'Avril', 'Mai', 'Septembre', 'Octobre'],
        bestTimeOfDay: '6h - 10h (observation animaux)',
        crowdLevel: 'Faible',
        recommendation: 'Le lever du soleil est idéal pour observer la faune',
      );
    }
    
    return BestTimeToVisit(
      bestMonths: ['Avril', 'Mai', 'Juin', 'Septembre', 'Octobre'],
      bestTimeOfDay: '9h - 17h',
      crowdLevel: 'Modéré',
      recommendation: 'Évitez les week-ends de ponts',
    );
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

class CarbonFootprint {
  final double totalEmissionsGrams;
  final int treesToOffset;
  final int ecoScore;
  final double equivalentCarKm;
  final String transportMode;

  CarbonFootprint({
    required this.totalEmissionsGrams,
    required this.treesToOffset,
    required this.ecoScore,
    required this.equivalentCarKm,
    required this.transportMode,
  });

  String get formattedEmissions {
    if (totalEmissionsGrams >= 1000) {
      return '${(totalEmissionsGrams / 1000).toStringAsFixed(1)} kg CO₂';
    }
    return '${totalEmissionsGrams.toStringAsFixed(0)} g CO₂';
  }
}

class BiodiversityScore {
  final int score;
  final String level;
  final int speciesCount;
  final int animalCount;
  final int plantCount;

  BiodiversityScore({
    required this.score,
    required this.level,
    required this.speciesCount,
    required this.animalCount,
    required this.plantCount,
  });
}

class WeatherData {
  final double temperature;
  final bool isRainy;
  final bool isWindy;
  final String condition;

  WeatherData({
    required this.temperature,
    this.isRainy = false,
    this.isWindy = false,
    this.condition = 'sunny',
  });
}

class BestTimeToVisit {
  final List<String> bestMonths;
  final String bestTimeOfDay;
  final String crowdLevel;
  final String recommendation;

  BestTimeToVisit({
    required this.bestMonths,
    required this.bestTimeOfDay,
    required this.crowdLevel,
    required this.recommendation,
  });
}
