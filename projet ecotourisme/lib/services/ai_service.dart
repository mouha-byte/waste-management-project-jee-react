import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ecoguide/models/site_model.dart';
import 'package:ecoguide/models/itinerary_model.dart';

class AIService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with your API key
  
  late final GenerativeModel _model;
  bool _isInitialized = false;

  // Cache for recommendations to reduce API calls
  final Map<String, String> _cache = {};

  AIService() {
    _initializeModel();
  }

  void _initializeModel() {
    try {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
      );
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      print('Error initializing AI model: $e');
    }
  }

  bool get isInitialized => _isInitialized && _apiKey != 'YOUR_GEMINI_API_KEY';

  /// Generate personalized itinerary recommendations based on user preferences
  Future<String> getPersonalizedRecommendations({
    required List<String> preferences,
    required String difficulty,
    required int maxDuration,
    String? season,
  }) async {
    if (!isInitialized) {
      return _getMockRecommendation(preferences, difficulty);
    }

    final cacheKey = '${preferences.join(',')}_${difficulty}_$maxDuration';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final prompt = '''
Tu es un expert en écotourisme en France. Recommande des itinéraires basés sur ces critères:
- Préférences: ${preferences.join(', ')}
- Niveau de difficulté souhaité: $difficulty
- Durée maximale: $maxDuration minutes
${season != null ? '- Saison: $season' : ''}

Donne 3 recommandations d'itinéraires avec:
1. Nom de l'itinéraire
2. Description courte (2-3 phrases)
3. Points d'intérêt écologiques
4. Conseils pour un tourisme responsable

Réponds en français de manière concise et enthousiaste.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final result = response.text ?? _getMockRecommendation(preferences, difficulty);
      _cache[cacheKey] = result;
      
      return result;
    } catch (e) {
      return _getMockRecommendation(preferences, difficulty);
    }
  }

  /// Generate ecological information about a specific site
  Future<String> getSiteEcoInfo(Site site) async {
    if (!isInitialized) {
      return _getMockSiteInfo(site);
    }

    final cacheKey = 'site_${site.id}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final prompt = '''
Tu es un expert naturaliste. Donne des informations écologiques sur ce site:
- Nom: ${site.name}
- Type: ${site.type}
- Description: ${site.description}
- Animaux présents: ${site.animals.join(', ')}
- Plantes: ${site.plants.join(', ')}

Fournis:
1. L'importance écologique du site (2-3 phrases)
2. Les espèces emblématiques et leur rôle dans l'écosystème
3. Les menaces actuelles et efforts de conservation
4. Comment les visiteurs peuvent contribuer à la protection

Réponds en français de manière éducative et engageante.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final result = response.text ?? _getMockSiteInfo(site);
      _cache[cacheKey] = result;
      
      return result;
    } catch (e) {
      return _getMockSiteInfo(site);
    }
  }

  /// Answer ecological questions from users
  Future<String> answerEcoQuestion(String question) async {
    if (!isInitialized) {
      return _getMockAnswer(question);
    }

    try {
      final prompt = '''
Tu es EcoBot, un assistant virtuel spécialisé en écotourisme et environnement.
Question de l'utilisateur: $question

Réponds de manière:
- Informative et précise
- Accessible à tous
- Avec des conseils pratiques quand c'est pertinent
- En français

Si la question n'est pas liée à l'écologie ou au tourisme durable, redirige poliment vers ces sujets.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? _getMockAnswer(question);
    } catch (e) {
      return _getMockAnswer(question);
    }
  }

  /// Calculate carbon footprint for an itinerary
  Future<Map<String, dynamic>> calculateCarbonFootprint(Itinerary itinerary) async {
    // Base calculations without AI
    double carbonKg = 0;
    String recommendation = '';

    switch (itinerary.transportMode) {
      case 'walking':
        carbonKg = 0;
        recommendation = '🌿 Excellent choix ! La marche n\'émet aucun CO2.';
        break;
      case 'cycling':
        carbonKg = 0;
        recommendation = '🚴 Parfait ! Le vélo est 100% écologique.';
        break;
      case 'public_transport':
        carbonKg = itinerary.distanceKm * 0.089; // kg CO2 per km
        recommendation = '🚌 Bon choix ! Les transports en commun réduisent l\'empreinte carbone.';
        break;
      case 'car':
        carbonKg = itinerary.distanceKm * 0.21; // kg CO2 per km
        recommendation = '🚗 Pensez au covoiturage pour réduire votre impact.';
        break;
      default:
        carbonKg = itinerary.distanceKm * 0.15;
        recommendation = 'Optez pour des modes de transport doux quand c\'est possible.';
    }

    // Trees equivalent (1 tree absorbs ~22kg CO2/year)
    final treesEquivalent = (carbonKg / 22 * 365).toStringAsFixed(1);

    return {
      'carbonKg': carbonKg.toStringAsFixed(2),
      'treesEquivalent': treesEquivalent,
      'recommendation': recommendation,
      'transportMode': itinerary.transportMode,
      'distance': itinerary.distanceKm,
    };
  }

  /// Get weather-based activity suggestions
  Future<List<String>> getWeatherBasedSuggestions({
    required String weather,
    required double temperature,
  }) async {
    if (!isInitialized) {
      return _getMockWeatherSuggestions(weather, temperature);
    }

    try {
      final prompt = '''
Météo actuelle: $weather, Température: ${temperature.toStringAsFixed(0)}°C

Suggère 3 activités d'écotourisme adaptées à ces conditions météo.
Réponds en JSON avec le format: ["activité 1", "activité 2", "activité 3"]
Activités en français.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      // Simple parsing - in production, use proper JSON parsing
      final text = response.text ?? '';
      if (text.contains('[')) {
        final start = text.indexOf('[');
        final end = text.lastIndexOf(']') + 1;
        final jsonStr = text.substring(start, end);
        // Parse manually for simplicity
        return jsonStr
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      
      return _getMockWeatherSuggestions(weather, temperature);
    } catch (e) {
      return _getMockWeatherSuggestions(weather, temperature);
    }
  }

  // Mock responses when AI is not available
  String _getMockRecommendation(List<String> preferences, String difficulty) {
    return '''
🌿 **Recommandations personnalisées**

**1. Sentier des Flamants Roses - Camargue**
Une balade magique à travers les marais pour observer les flamants dans leur habitat naturel. Idéal pour les photographes et amoureux de la nature.
- 🦩 Points d'intérêt: Colonies de flamants, chevaux sauvages, salines
- ♻️ Conseil: Restez silencieux et utilisez des jumelles pour ne pas déranger la faune

**2. Circuit des Calanques - Marseille**
Randonnée spectaculaire entre mer et falaises calcaires. Paysages à couper le souffle garantis!
- 🌊 Points d'intérêt: Calanque d'En-Vau, flore méditerranéenne
- ♻️ Conseil: Emportez vos déchets et restez sur les sentiers balisés

**3. Forêt de Fontainebleau - Île-de-France**
Un écrin de verdure aux portes de Paris, parfait pour une escapade nature.
- 🌲 Points d'intérêt: Rochers d'escalade, arbres centenaires, biodiversité unique
- ♻️ Conseil: Privilégiez les transports en commun pour y accéder

*Basé sur vos préférences: ${preferences.join(', ')} | Niveau: $difficulty*
''';
  }

  String _getMockSiteInfo(Site site) {
    return '''
🌍 **Importance écologique de ${site.name}**

Ce site représente un écosystème unique en France, abritant une biodiversité remarquable. Les espèces présentes (${site.animals.take(3).join(', ')}) jouent un rôle crucial dans l'équilibre naturel local.

**🐾 Espèces emblématiques:**
Les animaux de ce site sont essentiels à la chaîne alimentaire et à la pollinisation. Leur présence indique un environnement sain et équilibré.

**⚠️ Menaces et conservation:**
Comme beaucoup de sites naturels, cet espace fait face à la pression humaine et au changement climatique. Des efforts de conservation sont en cours pour préserver cet habitat précieux.

**🤝 Comment contribuer:**
- Restez sur les sentiers balisés
- N'emportez que des photos, ne laissez que vos empreintes
- Signalez toute observation d'espèces rares aux gardes
- Partagez vos connaissances avec votre entourage
''';
  }

  String _getMockAnswer(String question) {
    return '''
🌱 **Réponse d'EcoBot**

Merci pour votre question sur l'écotourisme ! 

L'écotourisme responsable repose sur trois piliers essentiels:
1. **Respect de la nature** - Minimiser notre impact sur les écosystèmes
2. **Soutien aux communautés locales** - Favoriser l'économie durable
3. **Éducation** - Apprendre et partager nos connaissances

Pour des conseils plus spécifiques, n'hésitez pas à explorer nos itinéraires et sites qui mettent en avant ces valeurs !

*Je suis là pour répondre à toutes vos questions sur l'écologie et le tourisme durable.* 🌿
''';
  }

  List<String> _getMockWeatherSuggestions(String weather, double temperature) {
    if (weather.toLowerCase().contains('pluie') || weather.toLowerCase().contains('rain')) {
      return [
        'Visite d\'un musée d\'histoire naturelle',
        'Observation des oiseaux sous abri',
        'Atelier de fabrication de nichoirs',
      ];
    } else if (temperature > 25) {
      return [
        'Randonnée matinale en forêt',
        'Kayak sur rivière ombragée',
        'Observation de la faune aquatique',
      ];
    } else if (temperature < 10) {
      return [
        'Balade d\'observation des oiseaux migrateurs',
        'Randonnée dans les zones humides',
        'Photographie de paysages hivernaux',
      ];
    } else {
      return [
        'Randonnée nature commentée',
        'Vélo sur voie verte',
        'Pique-nique zéro déchet en plein air',
      ];
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
