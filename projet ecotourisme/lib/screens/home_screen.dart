import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecoguide/models/site_model.dart';
import 'package:ecoguide/models/itinerary_model.dart';
import 'package:ecoguide/services/mock_data_service.dart';
import 'package:ecoguide/services/recommendation_service.dart';
import 'package:ecoguide/widgets/site_card.dart';
import 'package:ecoguide/widgets/itinerary_card.dart';
import 'package:ecoguide/widgets/map_widget.dart';
import 'package:ecoguide/widgets/premium_components.dart';
import 'package:ecoguide/screens/site_details_screen.dart';
import 'package:ecoguide/screens/itinerary_details_screen.dart';
import 'package:ecoguide/screens/sites_screen.dart';
import 'package:ecoguide/screens/itineraries_screen.dart';
import 'package:ecoguide/screens/bookings_screen.dart';
import 'package:ecoguide/screens/settings_screen.dart';
import 'package:ecoguide/utils/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ecoguide/services/weather_service.dart';
import 'package:ecoguide/services/location_service.dart';
import 'package:ecoguide/widgets/ai_assistant_chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Site> _sites = MockDataService.getMockSites();
  final List<Itinerary> _itineraries = MockDataService.getMockItineraries();
  late AnimationController _fabController;
  final ScrollController _scrollController = ScrollController();
  bool _showElevatedAppBar = false;
  bool _hideNavBar = false;
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  
  // Default weather data
  WeatherData _weather = WeatherData(
    temperature: 20,
    isRainy: false,
    isWindy: false,
    condition: 'sun',
  );

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController.addListener(_onScroll);
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final weather = await _weatherService.fetchWeather(
          position.latitude!,
          position.longitude!,
        );
        if (weather != null && mounted) {
          setState(() => _weather = weather);
        }
      }
    } catch (e) {
      print('Failed to load weather: $e');
    }
  }

  double _lastScrollPosition = 0;

  void _onScroll() {
    final currentScroll = _scrollController.offset;
    
    // Show/hide elevated app bar
    if (currentScroll > 100 && !_showElevatedAppBar) {
      setState(() => _showElevatedAppBar = true);
    } else if (currentScroll <= 100 && _showElevatedAppBar) {
      setState(() => _showElevatedAppBar = false);
    }
    
    // Hide nav bar when scrolling down, show when scrolling up
    if (currentScroll > _lastScrollPosition && currentScroll > 50) {
      if (!_hideNavBar) setState(() => _hideNavBar = true);
    } else {
      if (_hideNavBar) setState(() => _hideNavBar = false);
    }
    _lastScrollPosition = currentScroll;
  }

  void _onSearchTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recherche bientôt disponible !')),
    );
  }

  void _onShareTap() {
    Share.share('Découvrez EcoGuide, l\'application pour un tourisme durable ! https://ecoguide.app');
  }

  void _onNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pas de nouvelles notifications')),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const SitesScreen(),
          const ItinerariesScreen(),
          const BookingsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _hideNavBar ? const Offset(0, 2) : Offset.zero,
        child: _buildBottomNavBar(),
      ),
      floatingActionButton: _currentIndex == 0 && !_hideNavBar
          ? ScaleTransition(
              scale: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: _fabController..forward(), curve: Curves.elasticOut),
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showAIAssistant(),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Assistant IA'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            )
          : null,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explorer',
            ),
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route),
              label: 'Parcours',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Réserver',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero Section
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        // Weather & Quick Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildWeatherAndStats(),
          ),
        ),

        // AI Recommendations
        SliverToBoxAdapter(
          child: _buildAIRecommendations(),
        ),

        // Map Section
        SliverToBoxAdapter(
          child: _buildMapSection(),
        ),

        // Featured Sites
        SliverToBoxAdapter(
          child: _buildFeaturedSites(),
        ),

        // Eco Tips
        SliverToBoxAdapter(
          child: _buildEcoTipsSection(),
        ),

        // Itineraries
        SliverToBoxAdapter(
          child: _buildItinerariesSection(),
        ),

        // Carbon Footprint Calculator
        // SliverToBoxAdapter(
        //   child: _buildCarbonCalculator(),
        // ),

        // Bottom padding for nav bar
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.7),
                  Colors.transparent,
                ],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/hero/hero_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row(
                          //   children: [
                          //     Text(
                          //       'Bonjour',
                          //       style: TextStyle(
                          //         color: Colors.white.withOpacity(0.9),
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 6),
                          //     const PulseAnimation(
                          //       child: Text('👋', style: TextStyle(fontSize: 20)),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 6),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFE0F2E9)],
                            ).createShader(bounds),
                            child: const Text(
                              'EcoGuide',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '🌿 Tourisme responsable',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildHeaderIcon(Icons.search_rounded, _onSearchTap),
                          const SizedBox(width: 10),
                          _buildHeaderIcon(Icons.share_rounded, _onShareTap),
                          const SizedBox(width: 10),
                          Stack(
                            children: [
                              _buildHeaderIcon(Icons.notifications_rounded, _onNotificationTap),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Weather Card
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.amber.withOpacity(0.3),
                                Colors.orange.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _weather.condition == 'rain' 
                                ? Icons.water_drop 
                                : _weather.condition == 'cloud' 
                                    ? Icons.cloud 
                                    : Icons.wb_sunny_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${_weather.temperature.round()}°C',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _weather.isRainy ? 'Pluvieux' : 'Ensoleillé',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.hiking,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _weather.isRainy 
                                          ? 'Pensez à prendre un imperméable !' 
                                          : 'Parfait pour une randonnée !',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.success.withOpacity(0.4),
                                AppTheme.primaryGreen.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              const Text(
                                'Éco',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildWeatherAndStats() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Row(
        children: [
          Expanded(child: _buildQuickStat('4', 'Sites', Icons.place, AppTheme.primaryGreenLight)),
          const SizedBox(width: 12),
          Expanded(child: _buildQuickStat('3', 'Parcours', Icons.route, AppTheme.accentBlue)),
          const SizedBox(width: 12),
          Expanded(child: _buildQuickStat('87', 'Score Éco', Icons.eco, AppTheme.success)),
        ],
      ),
    );
  }
   Widget _buildCarbonCalculator() {
    final footprint = RecommendationService.calculateCarbonFootprint(
      distanceKm: 10,
      transportMode: 'walking',
      numberOfPeople: 1,
    );

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.oceanGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Votre impact carbone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildCarbonStat(
                    '${footprint.ecoScore}',
                    'Score Éco',
                    Icons.verified,
                  ),
                ),
                Expanded(
                  child: _buildCarbonStat(
                    '0',
                    'g CO₂',
                    Icons.cloud_off,
                  ),
                ),
                Expanded(
                  child: _buildCarbonStat(
                    '${footprint.treesToOffset}',
                    'Arbres',
                    Icons.park,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bravo ! Vos déplacements à pied sont 100% éco-responsables',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildQuickStat(String value, String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: label == 'Score Éco' ? _showCarbonCalculatorPopup : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            AnimatedCounter(
              value: int.tryParse(value) ?? 0,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarbonCalculatorPopup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _buildCarbonCalculator(),
      ),
    );
  }

  Widget _buildAIRecommendations() {
    final suggestions = RecommendationService.getWeatherBasedSuggestions(_weather);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.sunsetGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recommandations IA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentOrange.withOpacity(0.1),
                  AppTheme.accentGold.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
            ),
            child: Column(
              children: suggestions.take(3).map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(suggestion, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Sites à proximité', () => setState(() => _currentIndex = 1)),
          const SizedBox(height: 12),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: AppTheme.softShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              child: MapWidget(
                sites: _sites,
                onSiteTap: (site) => _navigateToSiteDetails(site),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSites() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSectionHeader('Sites populaires', () => setState(() => _currentIndex = 1)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: _sites.length,
              itemBuilder: (context, index) {
                final site = _sites[index];
                return AnimatedListItem(
                  index: index,
                  child: _buildPremiumSiteCard(site),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSiteCard(Site site) {
    final biodiversity = RecommendationService.calculateBiodiversityScore(site);
    
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => _navigateToSiteDetails(site),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusXL),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: site.photos.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: site.photos.first,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey.shade200),
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusXL),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Rating
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            site.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Biodiversity badge
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Bio: ${biodiversity.score}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(Icons.pets, '${site.animals.length}'),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.forest, '${site.plants.length}'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            site.type.toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoTipsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen.withOpacity(0.1),
              AppTheme.primaryGreenLight.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const PulseAnimation(
              child: Icon(Icons.lightbulb, color: AppTheme.accentGold, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conseil du jour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Privilégiez les sentiers balisés pour préserver la biodiversité locale 🌿',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItinerariesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Itinéraires durables', () => setState(() => _currentIndex = 2)),
          const SizedBox(height: 16),
          ..._itineraries.take(2).map((itinerary) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedListItem(
                index: _itineraries.indexOf(itinerary),
                child: ItineraryCard(
                  itinerary: itinerary,
                  onTap: () => _navigateToItineraryDetails(itinerary),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

 Widget _buildCarbonStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Row(
            children: [
              Text(
                'Voir tout',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 18, color: AppTheme.primaryGreen),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToSiteDetails(Site site) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SiteDetailsScreen(site: site),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _navigateToItineraryDetails(Itinerary itinerary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryDetailsScreen(itinerary: itinerary),
      ),
    );
  }

  void _showAIAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
        ),
        child: const AIAssistantChat(),
      ),
    );
  }
  // No additional helper methods needed for now
}

