import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoguide/utils/app_theme.dart';
import 'package:ecoguide/services/auth_service.dart';
import 'package:ecoguide/services/firestore_service.dart';
import 'package:ecoguide/services/mock_data_service.dart';
import 'package:ecoguide/providers/theme_provider.dart';
import 'package:ecoguide/screens/login_screen.dart';
import 'package:ecoguide/screens/site_details_screen.dart';
import 'package:ecoguide/screens/reservations_screen.dart';
import 'package:ecoguide/screens/admin/admin_dashboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Français';
  final List<String> _languages = ['Français', 'English', 'العربية'];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authService.appUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          if (authService.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'Se déconnecter',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Déconnecter'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await authService.signOut();
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          if (user != null) _buildProfileCard(user, isDark),
          
          // Admin Section - right after profile for admins
          if (user != null && user.isAdmin) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
                title: const Text(
                  'Panneau Admin',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionTitle('Préférences'),
          _buildSettingCard(
            icon: Icons.palette_outlined,
            title: 'Thème',
            subtitle: themeProvider.themeModeLabel,
            onTap: () => _showThemeDialog(themeProvider),
            isDark: isDark,
          ),
          _buildSettingCard(
            icon: Icons.language,
            title: 'Langue',
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageDialog(),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Favorites Section
          _buildSectionTitle('Mes Favoris'),
          _buildFavoritesSection(user?.favoriteSites ?? [], isDark),

          const SizedBox(height: 24),

          // More Options
          _buildSectionTitle('Plus'),
          _buildSettingCard(
            icon: Icons.calendar_today,
            title: 'Mes Réservations',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationsScreen(userId: user?.id ?? 'demo'),
                ),
              );
            },
            isDark: isDark,
          ),
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'À propos',
            onTap: () => _showAboutDialog(),
            isDark: isDark,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFavoritesSection(List<String> favoriteIds, bool isDark) {
    if (favoriteIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.favorite_border, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Aucun favori pour le moment',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tapez ❤️ sur un site pour l\'ajouter ici',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final allSites = MockDataService.getMockSites();
    final favoriteSites = allSites.where((s) => favoriteIds.contains(s.id)).toList();

    return Column(
      children: favoriteSites.map((site) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: site.photos.isNotEmpty
                  ? Image.network(site.photos.first, width: 50, height: 50, fit: BoxFit.cover)
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.nature),
                    ),
            ),
            title: Text(site.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(site.type, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SiteDetailsScreen(site: site)),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Clair', ThemeMode.light, themeProvider),
            _buildThemeOption('Sombre', ThemeMode.dark, themeProvider),
            _buildThemeOption('Système', ThemeMode.system, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, ThemeMode mode, ThemeProvider provider) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: provider.themeMode,
      onChanged: (value) {
        if (value != null) {
          provider.setThemeMode(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Langue changée en $value')),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'EcoGuide',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.eco, size: 48, color: Colors.green),
      children: [
        const Text(
          'EcoGuide est votre compagnon pour découvrir les merveilles naturelles de manière responsable.',
        ),
      ],
    );
  }
}
