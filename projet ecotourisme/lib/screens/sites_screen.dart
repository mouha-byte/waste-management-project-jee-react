import 'package:flutter/material.dart';
import 'package:ecoguide/models/site_model.dart';
import 'package:ecoguide/services/mock_data_service.dart';
import 'package:ecoguide/widgets/site_card.dart';
import 'package:ecoguide/widgets/map_widget.dart';
import 'package:ecoguide/screens/site_details_screen.dart';

class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key});

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final List<Site> _sites = MockDataService.getMockSites();
  bool _isMapView = false;
  String _selectedType = 'all';
  String _searchQuery = '';

  List<Site> get _filteredSites {
    return _sites.where((site) {
      final matchesType = _selectedType == 'all' || site.type == _selectedType;
      final matchesSearch = _searchQuery.isEmpty ||
          site.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          site.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites naturels'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un site...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tous', 'all'),
                _buildFilterChip('Réserves', 'reserve'),
                _buildFilterChip('Parcs', 'park'),
                _buildFilterChip('Forêts', 'forest'),
                _buildFilterChip('Plages', 'beach'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isMapView
                ? MapWidget(
                    sites: _filteredSites,
                    onSiteTap: (site) => _navigateToDetails(site),
                  )
                : _filteredSites.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucun site trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredSites.length,
                        itemBuilder: (context, index) {
                          final site = _filteredSites[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SiteCard(
                              site: site,
                              onTap: () => _navigateToDetails(site),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedType = selected ? value : 'all');
        },
      ),
    );
  }

  void _navigateToDetails(Site site) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteDetailsScreen(site: site),
      ),
    );
  }
}
