import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/place_provider.dart';
import '../../widgets/place_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  // ---> TEMA 2: Trust & Professional (Navy & Steel) <---
  final Color _primaryColor = const Color(0xFF1A365D); // Navy Blue
  final Color _titleColor = const Color(0xFF1A365D); // Navy Blue
  final Color _bgTop = const Color(0xFFEBF8FF); // Soft Blue Latar Atas
  final Color _bgBottom = const Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);
    final favorites = provider.favoritePlaces;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _titleColor),
        title: Text(
          'Bengkel Favorit',
          style: TextStyle(
            color: _titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgTop, _bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.25],
          ),
        ),
        child: SafeArea(
          child: favorites.isEmpty
              /// =========================
              /// EMPTY STATE
              /// =========================
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark_border_rounded, // Kesan lebih profesional
                          size: 64,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Belum ada favorit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simpan bengkel andalan untuk diakses cepat.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              /// =========================
              /// LIST CONTENT
              /// =========================
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final place = favorites[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PlaceCard(
                        place: place,
                        onFavoriteTap: () {
                          provider.toggleFavorite(place.id);
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}