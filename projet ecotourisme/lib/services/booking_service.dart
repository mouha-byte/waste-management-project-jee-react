import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoguide/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';

  // Create a new booking
  Future<void> createBooking(Booking booking) async {
    try {
      await _firestore.collection(_collection).doc(booking.id).set(booking.toFirestore());
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  // Get bookings for a user
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        // .orderBy('date', descending: true) // Removed to avoid index requirement
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      bookings.sort((a, b) => b.date.compareTo(a.date)); // Sort client-side
      return bookings;
    });
  }

  // ==================== SPECIAL BOOKINGS (special_bookings) ====================
  // Create a new special booking
  Future<void> createSpecialBooking(Booking booking) async {
    try {
      await _firestore.collection('special_bookings').doc(booking.id).set(booking.toFirestore());
    } catch (e) {
      print('Error creating special booking: $e');
      rethrow;
    }
  }

  // Get special bookings for a user
  Stream<List<Booking>> getUserSpecialBookings(String userId) {
    return _firestore
        .collection('special_bookings') // Renamed collection
        .where('userId', isEqualTo: userId)
        // .orderBy('date', descending: true) // Removed to avoid index requirement
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      bookings.sort((a, b) => b.date.compareTo(a.date)); // Sort client-side
      return bookings;
    });
  }

  // Mock method for demo if Firestore is not fully set up or for immediate feedback
  Future<void> createMockBooking(Booking booking) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    // In a real app without auth for demo, we might just store locally or print
    print('Booking created: ${booking.activityName} for ${booking.date}');
  }
}
