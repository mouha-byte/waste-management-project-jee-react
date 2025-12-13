import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String activityId;
  final String activityName;
  final String activityType; // 'accommodation', 'activity'
  final DateTime date;
  final int numberOfPeople;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;
  final String? notes;

  Booking({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.activityName,
    required this.activityType,
    required this.date,
    required this.numberOfPeople,
    required this.totalPrice,
    this.status = 'pending',
    DateTime? createdAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      activityId: data['activityId'] ?? '',
      activityName: data['activityName'] ?? '',
      activityType: data['activityType'] ?? 'activity',
      date: (data['date'] as Timestamp).toDate(),
      numberOfPeople: data['numberOfPeople'] ?? 1,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'activityId': activityId,
      'activityName': activityName,
      'activityType': activityType,
      'date': Timestamp.fromDate(date),
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? activityId,
    String? activityName,
    String? activityType,
    DateTime? date,
    int? numberOfPeople,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      activityType: activityType ?? this.activityType,
      date: date ?? this.date,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}

class Activity {
  final String id;
  final String name;
  final String description;
  final String type; // 'accommodation', 'activity'
  final double pricePerPerson;
  final String imageUrl;
  final String siteId;
  final bool isEcoFriendly;
  final List<String> ecoLabels;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.pricePerPerson,
    this.imageUrl = '',
    this.siteId = '',
    this.isEcoFriendly = true,
    this.ecoLabels = const [],
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'activity',
      pricePerPerson: (data['pricePerPerson'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      siteId: data['siteId'] ?? '',
      isEcoFriendly: data['isEcoFriendly'] ?? true,
      ecoLabels: List<String>.from(data['ecoLabels'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'pricePerPerson': pricePerPerson,
      'imageUrl': imageUrl,
      'siteId': siteId,
      'isEcoFriendly': isEcoFriendly,
      'ecoLabels': ecoLabels,
    };
  }
}
