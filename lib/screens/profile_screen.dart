import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/gamification_service.dart';
import '../models/chef_stats.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GamificationService _gamificationService = GamificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    await _gamificationService.load();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRankTitle(BuildContext context, int level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level) {
      case 1:
        return l10n.rankRookie;
      case 2:
        return l10n.rankArtisan;
      case 3:
        return l10n.rankAlchemist;
      case 4:
        return l10n.rankSousChef;
      default:
        return l10n.rankExecutive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();
    final l10n = AppLocalizations.of(context)!;
    final stats = _gamificationService.stats;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. Аватарка
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 60, color: Colors.green)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Имя
            Text(
              user?.displayName ?? 'Chef',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 3. Email
            Text(
              user?.email ?? 'chef@zerowaste.com',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),

            // 4. КАРТОЧКА ГЕЙМИФИКАЦИИ (Chef Tier & XP)
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  )
                : _buildChefCard(context, stats),

            const SizedBox(height: 32),

            // 5. Кнопка Выхода
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  l10n.logoutButton,
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await authService.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChefCard(BuildContext context, ChefStats stats) {
    final rankTitle = _getRankTitle(context, stats.level);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${stats.level} • $rankTitle',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.xp} Total XP',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Полоска прогресса
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stats.levelProgress,
                minHeight: 10,
                backgroundColor: Colors.green.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
              ),
            ),
            const SizedBox(height: 8),

            // Подпись под полоской: сколько XP до следующего уровня
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats.xpIntoLevel} XP',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  stats.level >= ChefStats.levelThresholds.length
                      ? 'MAX LEVEL'
                      : '${stats.xpToNextLevel} XP to next level',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}