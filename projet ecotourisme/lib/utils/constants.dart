class AppConstants {
  // App Info
  static const String appName = 'EcoGuide';
  static const String appVersion = '1.0.0';

  // Default Location (France center)
  static const double defaultLatitude = 46.603354;
  static const double defaultLongitude = 1.888334;
  static const double defaultZoom = 6.0;

  // Map Settings
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;
  static const double siteDetailZoom = 14.0;

  // Firebase Collections
  static const String sitesCollection = 'sites';
  static const String itinerariesCollection = 'itineraries';
  static const String bookingsCollection = 'bookings';
  static const String usersCollection = 'users';
  static const String activitiesCollection = 'activities';

  // Site Types
  static const Map<String, String> siteTypes = {
    'reserve': 'Réserve Naturelle',
    'park': 'Parc National',
    'forest': 'Forêt',
    'beach': 'Plage',
    'mountain': 'Montagne',
    'wetland': 'Zone Humide',
  };

  // Transport Modes
  static const Map<String, String> transportModes = {
    'walking': 'À pied',
    'cycling': 'À vélo',
  };

  // Difficulty Levels
  static const Map<String, String> difficultyLevels = {
    'easy': 'Facile',
    'moderate': 'Modéré',
    'hard': 'Difficile',
  };

  // Booking Status
  static const Map<String, String> bookingStatus = {
    'pending': 'En attente',
    'confirmed': 'Confirmée',
    'cancelled': 'Annulée',
  };
}
