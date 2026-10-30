import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_waste_chef/services/app_logger.dart';

import '../models/chef_stats.dart';

class GamificationService {
  String _localKeyFor(String? uid) {
  return uid == null ? 'chef_stats_guest' : 'chef_stats_$uid';
}


  ChefStats _stats = const ChefStats();
  ChefStats get stats => _stats;


  Future<void> load() async {
  final user = FirebaseAuth.instance.currentUser;
  final localKey = _localKeyFor(user?.uid);

_stats = const ChefStats();

final prefs = await SharedPreferences.getInstance();


  // 1. Try to load from local cache first (Instant UI update)
  final String? localData = prefs.getString(localKey);
  if (localData != null) {
    _stats = ChefStats.fromMap(jsonDecode(localData));
  }

  // 2. Sync with Firestore if user is logged in
  if (user != null) {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();

      if (doc.exists) {
        _stats = ChefStats.fromMap(doc.data()!);
        // Update local cache with latest cloud data
        await prefs.setString(localKey, jsonEncode(_stats.toMap()));
      }
    } catch (e, stack) {
      // Логируем в Debug Console красиво с трейсом, без мусора в релизе:
      logger.w("⚠️ Failed to sync stats from Firestore (using local cache): $e", error: e, stackTrace: stack);
    }
}
  }

  Future<void> _save(ChefStats newStats) async {
    final user = FirebaseAuth.instance.currentUser;
    final localKey = _localKeyFor(user?.uid);

    _stats = newStats;

    // 1. Локально (SharedPreferences):
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localKey, jsonEncode(_stats.toMap()));

    // 2. В облако (Firestore):
    if (user != null) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('stats')
            .doc('gamification');

        // 🟢 ТВОЯ СТРОЧКА ЗДЕСЬ: вызови docRef.set(...) и передай туда мапу!
        await docRef.set(_stats.toMap());
        
      } catch (e, stack) {
        logger.w("⚠️ Could not save stats to Firestore: $e", error: e, stackTrace: stack);
      }
    }
  }


  
  Future<void> addXp(int amount) async {
  if (amount <= 0) return;

  final updatedStats = _stats.copyWith(xp: _stats.xp + amount);
  await _save(updatedStats);
}

}
