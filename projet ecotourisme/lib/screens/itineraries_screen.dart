import 'package:flutter/material.dart';
import 'package:ecoguide/models/itinerary_model.dart';
import 'package:ecoguide/services/mock_data_service.dart';
import 'package:ecoguide/widgets/itinerary_card.dart';
import 'package:ecoguide/screens/itinerary_details_screen.dart';
import 'package:ecoguide/utils/app_theme.dart';

class ItinerariesScreen extends StatefulWidget {
  const ItinerariesScreen({super.key});

  @override
  State<ItinerariesScreen> createState() => _ItinerariesScreenState();
}

class _ItinerariesScreenState extends State<ItinerariesScreen> {
  final List<Itinerary> _itineraries = MockDataService.getMockItineraries();
  String _selectedDifficulty = 'all';
  String _selectedTransport = 'all';

  List<Itinerary> get _filteredItineraries {
    return _itineraries.where((it) {
      final matchesDifficulty =
          _selectedDifficulty == 'all' || it.difficulty == _selectedDifficulty;
      final matchesTransport =
          _selectedTransport == 'all' || it.transportMode == _selectedTransport;
      return matchesDifficulty && matchesTransport;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinéraires'),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Difficulté',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDifficultyChip('Tous', 'all', Colors.grey),
                      _buildDifficultyChip('Facile', 'easy', AppTheme.success),
                      _buildDifficultyChip('Modéré', 'moderate', AppTheme.warning),
                      _buildDifficultyChip('Difficile', 'hard', AppTheme.error),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transport',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTransportChip('Tous', 'all', Icons.route),
                    const SizedBox(width: 8),
                    _buildTransportChip('À pied', 'walking', Icons.directions_walk),
                    const SizedBox(width: 8),
                    _buildTransportChip('À vélo', 'cycling', Icons.directions_bike),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _filteredItineraries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.route, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun itinéraire trouvé',
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
                    itemCount: _filteredItineraries.length,
                    itemBuilder: (context, index) {
                      final itinerary = _filteredItineraries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ItineraryCard(
                          itinerary: itinerary,
                          onTap: () => _navigateToDetails(itinerary),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String label, String value, Color color) {
    final isSelected = _selectedDifficulty == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: color.withOpacity(0.3),
        onSelected: (selected) {
          setState(() => _selectedDifficulty = selected ? value : 'all');
        },
      ),
    );
  }

  Widget _buildTransportChip(String label, String value, IconData icon) {
    final isSelected = _selectedTransport == value;
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedTransport = selected ? value : 'all');
      },
    );
  }

  void _navigateToDetails(Itinerary itinerary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryDetailsScreen(itinerary: itinerary),
      ),
    );
  }
}
