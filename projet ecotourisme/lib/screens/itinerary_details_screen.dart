import 'package:ecoguide/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:ecoguide/models/itinerary_model.dart';
import 'package:ecoguide/widgets/map_widget.dart';
import 'package:ecoguide/utils/app_theme.dart';
import 'package:ecoguide/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecoguide/services/recommendation_service.dart';
import 'package:ecoguide/services/booking_service.dart';
import 'package:ecoguide/models/booking_model.dart';
import 'package:ecoguide/screens/reservations_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ItineraryDetailsScreen extends StatelessWidget {
  final Itinerary itinerary;
  final BookingService _bookingService = BookingService();

  ItineraryDetailsScreen({super.key, required this.itinerary});

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppTheme.success;
      case 'moderate':
        return AppTheme.warning;
      case 'hard':
        return AppTheme.error;
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
 Widget build(BuildContext context) {
  final routePoints = itinerary.waypoints
      .map((w) => LatLng(w.latitude, w.longitude))
      .toList();

  return Scaffold(
    body: CustomScrollView(
      slivers: [
        // HEADER
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                itinerary.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: itinerary.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.route, size: 80),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.route, size: 80),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    itinerary.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              tooltip: 'Guide Intelligent',
              onPressed: () => _showSmartGuide(context),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                try {
                  await Share.share(
                      'Découvrez le parcours ${itinerary.name} sur EcoGuide !');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur de partage: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),

        // CONTENT
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: itinerary.transportMode == 'walking'
                            ? Icons.directions_walk
                            : Icons.directions_bike,
                        label: AppConstants
                                .transportModes[itinerary.transportMode] ??
                            itinerary.transportMode,
                        color: AppTheme.primaryGreen,
                      ),
                      _buildStatItem(
                        icon: Icons.straighten,
                        label: itinerary.formattedDistance,
                        color: AppTheme.accentBlue,
                      ),
                      _buildStatItem(
                        icon: Icons.access_time,
                        label: itinerary.formattedDuration,
                        color: AppTheme.accentOrange,
                      ),
                      _buildStatItem(
                        icon: Icons.trending_up,
                        label: AppConstants
                                .difficultyLevels[itinerary.difficulty] ??
                            itinerary.difficulty,
                        color: _getDifficultyColor(itinerary.difficulty),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  itinerary.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Eco Impact
                _buildEcoImpactSection(),

                const SizedBox(height: 24),

                // Map
                const Text(
                  'Parcours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 250,
                    child: MapWidget(
                      routePoints: routePoints,
                      initialCenter:
                          routePoints.isNotEmpty ? routePoints.first : null,
                      initialZoom: 12,
                      showUserLocation: true,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Waypoints
                const Text(
                  'Points de passage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...itinerary.waypoints.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isFirst = index == 0;
                  final isLast = index == itinerary.waypoints.length - 1;

                  return _buildWaypointItem(
                    index: index + 1,
                    label: isFirst
                        ? 'Départ'
                        : isLast
                            ? 'Arrivée'
                            : 'Point ${index + 1}',
                    isFirst: isFirst,
                    isLast: isLast,
                  );
                }),

                const SizedBox(height: 24),

                // Tips
                Card(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates,
                                color: AppTheme.primaryGreen),
                            const SizedBox(width: 8),
                            const Text(
                              'Conseils pratiques',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Partez tôt le matin pour éviter la chaleur\n'
                          '• Emportez suffisamment d\'eau (2L minimum)\n'
                          '• Portez des chaussures adaptées\n'
                          '• Consultez la météo avant de partir',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showReservationDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Réserver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchNavigation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Naviguer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWaypointItem({
    required int index,
    required String label,
    required bool isFirst,
    required bool isLast,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isFirst || isLast
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isFirst
                    ? const Icon(Icons.play_arrow, color: Colors.white, size: 18)
                    : isLast
                        ? const Icon(Icons.flag, color: Colors.white, size: 18)
                        : Text(
                            '$index',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEcoImpactSection() {
    final carFootprint = RecommendationService.calculateCarbonFootprint(
      distanceKm: itinerary.distanceKm,
      transportMode: 'car',
      numberOfPeople: 1,
    );
    
    // Emissions saved (since walking/biking is ~0)
    final savedCo2 = carFootprint.totalEmissionsGrams;
    final savedCo2String = savedCo2 >= 1000 
        ? '${(savedCo2/1000).toStringAsFixed(1)} kg' 
        : '${savedCo2.toStringAsFixed(0)} g';
        
    final calories = (itinerary.distanceKm * 50).round(); // Approximate

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Impact Écologique',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEcoStat('CO₂ Économisé', savedCo2String, Icons.cloud_off),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildEcoStat('Calories', '$calories kcal', Icons.local_fire_department),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildEcoStat('Score Éco', '100/100', Icons.check_circle),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'En choisissant ce parcours éco-responsable, vous contribuez à la préservation de notre environnement ! 🌿',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _showSmartGuide(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                const Text(
                  'Guide Intelligent IA',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: Future.delayed(const Duration(seconds: 2)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Analyse de l\'itinéraire en cours...',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basé sur les données météo et le terrain :',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAiTip(
                      'Conditions',
                      'Le terrain sera sec aujourd\'hui. Idéal pour ${itinerary.transportMode == 'walking' ? 'la marche rapide' : 'le VTT'}.',
                      Icons.wb_sunny,
                    ),
                    const SizedBox(height: 12),
                    _buildAiTip(
                      'Équipement',
                      'Prévoyez de bonnes chaussures et de l\'eau, le dénivelé est modéré sur les premiers km.',
                      Icons.backpack,
                    ),
                    const SizedBox(height: 12),
                    _buildAiTip(
                      'Faune',
                      'Chance élevée d\'apercevoir des oiseaux migrateurs près du point d\'eau à mi-parcours.',
                      Icons.pets,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTip(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReservationDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    int numberOfPeople = 1;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réserver ${itinerary.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Date', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nombre de personnes', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPersonCounter(
                        icon: Icons.remove,
                        onTap: () {
                          if (numberOfPeople > 1) setState(() => numberOfPeople--);
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$numberOfPeople',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      _buildPersonCounter(
                        icon: Icons.add,
                        onTap: () {
                          if (numberOfPeople < 20) setState(() => numberOfPeople++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _createBooking(context, selectedDate, numberOfPeople);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirmer la réservation'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPersonCounter({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Future<void> _createBooking(BuildContext context, DateTime date, int people) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour réserver')),
      );
      return;
    }

    // Generate a simple ID
    final bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    
    final booking = Booking(
      id: bookingId,
      userId: user.uid,
      activityId: itinerary.id,
      activityName: itinerary.name,
      activityType: 'activity',
      date: date,
      numberOfPeople: people,
      totalPrice: itinerary.price * people, // Calculate based on itinerary price
      status: 'confirmed',
    );

    await _bookingService.createBooking(booking);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Réservation confirmée !'),
          backgroundColor: AppTheme.primaryGreen,
          action: SnackBarAction(
            label: 'Voir mes réservations',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReservationsScreen(userId: 'current_user'),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _launchNavigation(BuildContext context) async {
    if (itinerary.waypoints.isEmpty) return;

    final start = itinerary.waypoints.first;
    final end = itinerary.waypoints.last;
    
    // Build waypoints string (excluding start and end)
    String waypoints = '';
    if (itinerary.waypoints.length > 2) {
      waypoints = '&waypoints=${itinerary.waypoints
          .sublist(1, itinerary.waypoints.length - 1)
          .map((w) => '${w.latitude},${w.longitude}')
          .join('|')}';
    }

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${start.latitude},${start.longitude}'
      '&destination=${end.latitude},${end.longitude}'
      '$waypoints'
      '&travelmode=${itinerary.transportMode == "walking" ? "walking" : "bicycling"}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir les cartes')),
        );
      }
    }
  }
}
