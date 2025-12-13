import 'package:ecoguide/services/firestore_service.dart';
import 'package:ecoguide/services/mock_data_service.dart';

/// Service to initialize Firestore with mock data
/// 
/// Use this service to populate your Firestore database with the initial
/// sites, itineraries, and activities data.
/// 
/// Usage:
/// ```dart
/// final initService = DataInitializationService();
/// await initService.initializeAllData();
/// ```
class DataInitializationService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Initialize all data (sites, itineraries, activities)
  Future<void> initializeAllData() async {
    await initializeSites();
    await initializeItineraries();
    await initializeActivities();
  }

  /// Initialize sites from mock data
  Future<void> initializeSites() async {
    print('🌿 Initializing sites...');
    final sites = MockDataService.getMockSites();
    
    for (var site in sites) {
      try {
        await _firestoreService.addSite(site);
        print('✅ Added site: ${site.name}');
      } catch (e) {
        print('❌ Error adding site ${site.name}: $e');
      }
    }
    
    print('✅ Sites initialization complete!');
  }

  /// Initialize itineraries from mock data
  Future<void> initializeItineraries() async {
    print('🗺️ Initializing itineraries...');
    final itineraries = MockDataService.getMockItineraries();
    
    for (var itinerary in itineraries) {
      try {
        await _firestoreService.addItinerary(itinerary);
        print('✅ Added itinerary: ${itinerary.name}');
      } catch (e) {
        print('❌ Error adding itinerary ${itinerary.name}: $e');
      }
    }
    
    print('✅ Itineraries initialization complete!');
  }

  /// Initialize activities from mock data
  Future<void> initializeActivities() async {
    print('🎯 Initializing activities...');
    final activities = MockDataService.getMockActivities();
    
    for (var activity in activities) {
      try {
        await _firestoreService.addActivity(activity);
        print('✅ Added activity: ${activity.name}');
      } catch (e) {
        print('❌ Error adding activity ${activity.name}: $e');
      }
    }
    
    print('✅ Activities initialization complete!');
  }

  /// Check if data already exists in Firestore
  Future<bool> hasExistingData() async {
    try {
      // Check if there are any sites
      final sites = await _firestoreService.getSites().first;
      return sites.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Initialize data only if it doesn't exist
  Future<void> initializeIfNeeded() async {
    final hasData = await hasExistingData();
    
    if (!hasData) {
      print('📊 No existing data found. Initializing...');
      await initializeAllData();
    } else {
      print('📊 Data already exists. Skipping initialization.');
    }
  }
}
