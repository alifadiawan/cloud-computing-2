import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/place_provider.dart';
import '../../widgets/place_card.dart';
import '../../widgets/FilterSheet.dart';
import '../detail/place_detail_screen.dart';
import '../map/map_screen.dart';
import '../favorite/favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String? selectedFilter = 'Terdekat';

  // ---> TEMA 2: Trust & Professional (Navy & Steel) <---
  final Color _primaryColor = const Color(0xFF1A365D); // Navy Blue
  final Color _secondaryColor = const Color(0xFF2B6CB0); // Bright Blue
  final Color _titleColor = const Color(0xFF1A365D); // Navy Blue
  final Color _bgTop = const Color(0xFFEBF8FF); // Soft Blue Latar Atas
  final Color _bgBottom = const Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PlaceProvider>().fetchNearestPlaces();
    });
  }

  /// Widget bantuan untuk tombol di header agar seragam dan rapi
  Widget _buildHeaderButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }

  /// Widget bantuan untuk Filter Chips
  Widget _buildChip(String label, IconData icon) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);

    /// =========================
    /// FILTER SEARCH & SORTING
    /// =========================
    final filteredPlaces = provider.places.where((place) {
      return place.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          place.category.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (selectedFilter == 'Terdekat') {
      filteredPlaces.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (selectedFilter == 'Terjauh') {
      filteredPlaces.sort((a, b) => b.distance.compareTo(a.distance));
    } else if (selectedFilter == 'Rating') {
      filteredPlaces.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: _bgBottom, // Warna dasar yang konsisten
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgTop, _bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: provider.isLoading
              ? Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                )
              : provider.errorMessage.isNotEmpty
                  ? Center(child: Text(provider.errorMessage))
                  : RefreshIndicator(
                      color: _primaryColor,
                      onRefresh: provider.refreshPlaces,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        children: [
                          /// =========================
                          /// HEADER SECTION
                          /// =========================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo, ${FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'Pengguna'} 👋',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cari Bengkel\nAndalanmu',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: _titleColor,
                                        height: 1.2,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildHeaderButton(
                                    icon: Icons.favorite_rounded,
                                    iconColor: Colors.redAccent,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const FavoriteScreen()),
                                    ),
                                  ),
                                  _buildHeaderButton(
                                    icon: Icons.map_rounded,
                                    iconColor: _secondaryColor,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MapScreen()),
                                    ),
                                  ),
                                  _buildHeaderButton(
                                    icon: Icons.logout_rounded,
                                    iconColor: Colors.grey.shade600,
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: Text(
                                            'Keluar',
                                            style: TextStyle(color: _titleColor, fontWeight: FontWeight.bold),
                                          ),
                                          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseAuth.instance.signOut();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          /// =========================
                          /// SEARCH BAR & FILTER BUTTON
                          /// =========================
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryColor.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    onChanged: (v) => setState(() => searchQuery = v),
                                    decoration: InputDecoration(
                                      hintText: 'Cari nama atau kategori bengkel...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: _secondaryColor,
                                        size: 24,
                                      ),
                                      suffixIcon: searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.cancel_rounded,
                                                size: 20,
                                                color: Colors.grey.shade400,
                                              ),
                                              onPressed: () => setState(() => searchQuery = ''),
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 17),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: (_) => FilterSheet(
                                      selectedFilter: selectedFilter,
                                      onSelected: (value) {
                                        setState(() => selectedFilter = value);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),

                          /// =========================
                          /// FILTER CHIPS (Kategori Cepat)
                          /// =========================
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildChip('Terdekat', Icons.near_me_rounded),
                                const SizedBox(width: 10),
                                _buildChip('Terjauh', Icons.map_outlined),
                                const SizedBox(width: 10),
                                _buildChip('Rating', Icons.star_rounded),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          /// =========================
                          /// INFO CARD (Lebih Minimalis)
                          /// =========================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryColor, _secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_rounded,
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
                                        '${filteredPlaces.length} Bengkel Tersedia',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Terverifikasi dan siap melayani kendaraan Anda.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// =========================
                          /// LIST BENGKEL TITLE
                          /// =========================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Bengkel',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _titleColor,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),

                          /// =========================
                          /// LIST CONTENT
                          /// =========================
                          if (filteredPlaces.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Bengkel tidak ditemukan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _titleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Coba kata kunci atau filter lain.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ...filteredPlaces.map((place) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PlaceCard(
                                place: place,
                                onFavoriteTap: () => provider.toggleFavorite(place.id),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaceDetailScreen(place: place),
                                  ),
                                ),
                              ),
                            );
                          }),
                          
                          // Tambahan padding bawah agar list tidak terpotong (Safe Area bottom)
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}