import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoguide/models/site_model.dart';
import 'package:ecoguide/models/itinerary_model.dart';
import 'package:ecoguide/models/booking_model.dart';
import 'package:ecoguide/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== SITES ====================
  Stream<List<Site>> getSites() {
    return _db.collection('sites').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Site.fromFirestore(doc)).toList());
  }

  Future<Site?> getSiteById(String id) async {
    final doc = await _db.collection('sites').doc(id).get();
    if (doc.exists) {
      return Site.fromFirestore(doc);
    }
    return null;
  }

  Future<void> addSite(Site site) async {
    await _db.collection('sites').add(site.toFirestore());
  }

  Future<void> updateSite(Site site) async {
    await _db.collection('sites').doc(site.id).update(site.toFirestore());
  }

  Future<void> deleteSite(String id) async {
    await _db.collection('sites').doc(id).delete();
  }

  // ==================== ITINERARIES ====================
  Stream<List<Itinerary>> getItineraries() {
    return _db.collection('itineraries').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Itinerary.fromFirestore(doc)).toList());
  }

  Future<Itinerary?> getItineraryById(String id) async {
    final doc = await _db.collection('itineraries').doc(id).get();
    if (doc.exists) {
      return Itinerary.fromFirestore(doc);
    }
    return null;
  }

  Future<void> addItinerary(Itinerary itinerary) async {
    await _db.collection('itineraries').add(itinerary.toFirestore());
  }

  Future<void> updateItinerary(Itinerary itinerary) async {
    await _db
        .collection('itineraries')
        .doc(itinerary.id)
        .update(itinerary.toFirestore());
  }

  Future<void> deleteItinerary(String id) async {
    await _db.collection('itineraries').doc(id).delete();
  }

  // ==================== BOOKINGS ====================
  Stream<List<Booking>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Stream<List<Booking>> getAllBookings() {
    return _db.collection('bookings').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Future<void> createBooking(Booking booking) async {
    await _db.collection('bookings').add(booking.toFirestore());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  // ==================== ACTIVITIES ====================
  Stream<List<Activity>> getActivities() {
    return _db.collection('activities').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
  }

  Future<void> addActivity(Activity activity) async {
    await _db.collection('activities').add(activity.toFirestore());
  }

  // ==================== USERS ====================
  Future<AppUser?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  Stream<AppUser?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<void> updateUser(AppUser user) async {
    await _db.collection('users').doc(user.id).update(user.toFirestore());
  }

  Future<void> toggleFavorite(String userId, String siteId) async {
    final userDoc = _db.collection('users').doc(userId);
    final user = await userDoc.get();
    if (user.exists) {
      final favorites = List<String>.from(user.data()?['favoriteSites'] ?? []);
      if (favorites.contains(siteId)) {
        favorites.remove(siteId);
      } else {
        favorites.add(siteId);
      }
      await userDoc.update({'favoriteSites': favorites});
    }
  }
}
