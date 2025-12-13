import 'package:flutter/material.dart';
import 'package:ecoguide/models/site_model.dart';
import 'package:ecoguide/models/itinerary_model.dart';
import 'package:ecoguide/services/mock_data_service.dart';
import 'package:ecoguide/utils/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Site> _sites = MockDataService.getMockSites();
  final List<Itinerary> _itineraries = MockDataService.getMockItineraries();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: AppTheme.accentOrange,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Vue d\'ensemble'),
            Tab(icon: Icon(Icons.place), text: 'Sites'),
            Tab(icon: Icon(Icons.route), text: 'Itinéraires'),
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSitesTab(),
          _buildItinerariesTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mobile layout: Stack vertically
                return Column(
                  children: [
                    _buildStatCard(
                      'Sites',
                      '${_sites.length}',
                      Icons.place,
                      AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Itinéraires',
                      '${_itineraries.length}',
                      Icons.route,
                      AppTheme.accentBlue,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Utilisateurs',
                      '156',
                      Icons.people,
                      AppTheme.accentOrange,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Réservations',
                      '42',
                      Icons.calendar_today,
                      Colors.purple,
                    ),
                  ],
                );
              } else {
                // Tablet/Desktop layout: 2 Rows of 2
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Sites',
                            '${_sites.length}',
                            Icons.place,
                            AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Itinéraires',
                            '${_itineraries.length}',
                            Icons.route,
                            AppTheme.accentBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Utilisateurs',
                            '156',
                            Icons.people,
                            AppTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Réservations',
                            '42',
                            Icons.calendar_today,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Activité récente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildActivityItem(
                  'Nouvelle réservation',
                  'Safari Photo Camargue',
                  Icons.calendar_today,
                  'Il y a 2h',
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'Nouvel utilisateur',
                  'marie.durand@email.com',
                  Icons.person_add,
                  'Il y a 5h',
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'Avis ajouté',
                  'Parc National des Calanques',
                  Icons.star,
                  'Hier',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Ajouter un site',
                  Icons.add_location,
                  () => _showAddSiteDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Ajouter un itinéraire',
                  Icons.add_road,
                  () => _showAddItineraryDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSitesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un site...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: 'addSite',
                onPressed: () => _showAddSiteDialog(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sites.length,
            itemBuilder: (context, index) {
              final site = _sites[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: Icon(
                    Icons.place,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                title: Text(site.name),
                subtitle: Text(site.type),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditSiteDialog(site);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation('site', site.name);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItinerariesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un itinéraire...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: 'addItinerary',
                onPressed: () => _showAddItineraryDialog(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _itineraries.length,
            itemBuilder: (context, index) {
              final itinerary = _itineraries[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.accentBlue.withOpacity(0.1),
                  child: Icon(
                    itinerary.transportMode == 'walking'
                        ? Icons.directions_walk
                        : Icons.directions_bike,
                    color: AppTheme.accentBlue,
                  ),
                ),
                title: Text(itinerary.name),
                subtitle: Text(
                    '${itinerary.formattedDistance} • ${itinerary.formattedDuration}'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation('itinéraire', itinerary.name);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryGreen),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSiteDialog() {
    _showFormDialog('Ajouter un site', [
      const TextField(decoration: InputDecoration(labelText: 'Nom du site')),
      const SizedBox(height: 12),
      const TextField(
        decoration: InputDecoration(labelText: 'Description'),
        maxLines: 3,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Type'),
        items: const [
          DropdownMenuItem(value: 'reserve', child: Text('Réserve')),
          DropdownMenuItem(value: 'park', child: Text('Parc')),
          DropdownMenuItem(value: 'forest', child: Text('Forêt')),
          DropdownMenuItem(value: 'beach', child: Text('Plage')),
        ],
        onChanged: (value) {},
      ),
    ]);
  }

  void _showEditSiteDialog(Site site) {
    _showFormDialog('Modifier: ${site.name}', [
      TextFormField(
        initialValue: site.name,
        decoration: const InputDecoration(labelText: 'Nom du site'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: site.description,
        decoration: const InputDecoration(labelText: 'Description'),
        maxLines: 3,
      ),
    ]);
  }

  void _showAddItineraryDialog() {
    _showFormDialog('Ajouter un itinéraire', [
      const TextField(
          decoration: InputDecoration(labelText: 'Nom de l\'itinéraire')),
      const SizedBox(height: 12),
      const TextField(
        decoration: InputDecoration(labelText: 'Description'),
        maxLines: 3,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Mode de transport'),
        items: const [
          DropdownMenuItem(value: 'walking', child: Text('À pied')),
          DropdownMenuItem(value: 'cycling', child: Text('À vélo')),
        ],
        onChanged: (value) {},
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Difficulté'),
        items: const [
          DropdownMenuItem(value: 'easy', child: Text('Facile')),
          DropdownMenuItem(value: 'moderate', child: Text('Modéré')),
          DropdownMenuItem(value: 'hard', child: Text('Difficile')),
        ],
        onChanged: (value) {},
      ),
    ]);
  }

  void _showFormDialog(String title, List<Widget> fields) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enregistré ! (Firebase requis)'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String type, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le $type "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type supprimé ! (Firebase requis)'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    // Mock users for demo - in production, fetch from Firestore
    final mockUsers = [
      {'name': 'Admin User', 'email': 'admin@ecoguide.app', 'isAdmin': true, 'joined': '2024-01-01'},
      {'name': 'Jean Dupont', 'email': 'jean.dupont@email.com', 'isAdmin': false, 'joined': '2024-03-15'},
      {'name': 'Marie Martin', 'email': 'marie.m@email.com', 'isAdmin': false, 'joined': '2024-05-20'},
      {'name': 'Karim Benali', 'email': 'k.benali@email.com', 'isAdmin': false, 'joined': '2024-07-10'},
      {'name': 'Sophie Laurent', 'email': 's.laurent@email.com', 'isAdmin': false, 'joined': '2024-09-01'},
    ];

    return Column(
      children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.accentOrange.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildUserStat('${mockUsers.length}', 'Total', Icons.people),
              _buildUserStat('${mockUsers.where((u) => u['isAdmin'] == true).length}', 'Admins', Icons.admin_panel_settings),
              _buildUserStat('${mockUsers.where((u) => u['isAdmin'] == false).length}', 'Utilisateurs', Icons.person),
            ],
          ),
        ),
        // Users list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mockUsers.length,
            itemBuilder: (context, index) {
              final user = mockUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user['isAdmin'] == true 
                        ? AppTheme.accentOrange 
                        : AppTheme.primaryGreen,
                    child: Text(
                      (user['name'] as String)[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(user['name'] as String),
                      if (user['isAdmin'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['email'] as String),
                      Text(
                        'Inscrit le ${user['joined']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'toggle_admin') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              user['isAdmin'] == true 
                                  ? 'Droits admin retirés (Firebase requis)' 
                                  : 'Droits admin accordés (Firebase requis)',
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation('utilisateur', user['name'] as String);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle_admin',
                        child: Row(
                          children: [
                            Icon(
                              user['isAdmin'] == true ? Icons.person : Icons.admin_panel_settings,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(user['isAdmin'] == true ? 'Retirer droits admin' : 'Rendre admin'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentOrange, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
