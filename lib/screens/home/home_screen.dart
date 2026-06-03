import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/place_provider.dart';
import '../../widgets/place_card.dart';
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PlaceProvider>().fetchNearestPlaces();
    });
  }

  Widget _buildChip(String label, IconData icon) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF185FA5) : Colors.grey.shade200,

          borderRadius: BorderRadius.circular(100),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              icon,

              size: 13,

              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),

            const SizedBox(width: 5),

            Text(
              label,

              style: TextStyle(
                fontSize: 12.5,

                fontWeight: FontWeight.w500,

                color: isSelected ? Colors.white : Colors.grey.shade600,
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
    /// FILTER SEARCH
    /// =========================
    final filteredPlaces = provider.places.where((place) {
      return place.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          place.category.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    //sort filter//
    if (selectedFilter == 'Terdekat') {
      filteredPlaces.sort((a, b) => a.distance.compareTo(b.distance));
    }

    if (selectedFilter == 'Terjauh') {
      filteredPlaces.sort((a, b) => b.distance.compareTo(a.distance));
    }

    if (selectedFilter == 'Rating') {
      filteredPlaces.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            /// ERROR
            : provider.errorMessage.isNotEmpty
            ? Center(child: Text(provider.errorMessage))
            /// SUCCESS
            : RefreshIndicator(
                onRefresh: provider.refreshPlaces,

                child: ListView(
                  padding: const EdgeInsets.all(20),

                  children: [
                    /// =========================
                    /// HEADER
                    /// =========================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halo 👋',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Temukan \nBengkel Terdekat',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),

                        /// MAP BUTTON
                        Row(
                          children: [
                            /// FAVORITE BUTTON
                            Container(
                              margin: const EdgeInsets.only(right: 10),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),

                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FavoriteScreen(),
                                    ),
                                  );
                                },

                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                            ),

                            /// MAP BUTTON
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),

                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MapScreen(),
                                    ),
                                  );
                                },

                                icon: const Icon(
                                  Icons.map,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// SEARCH BAR
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: TextField(
                                  onChanged: (v) =>
                                      setState(() => searchQuery = v),
                                  decoration: InputDecoration(
                                    hintText: 'Cari bengkel...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                    suffixIcon: searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              size: 17,
                                              color: Colors.grey.shade400,
                                            ),
                                            onPressed: () => setState(
                                              () => searchQuery = '',
                                            ),
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Filter button
                            GestureDetector(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: selectedFilter != null
                                      ? const Color(0xFFE6F1FB)
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 20,
                                      color: selectedFilter != null
                                          ? const Color(0xFF185FA5)
                                          : Colors.grey.shade500,
                                    ),
                                    if (selectedFilter != null)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF378ADD),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Filter chips
                        SingleChildScrollView(
                          padding: EdgeInsetsDirectional.only(bottom: 30),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildChip('Terdekat', Icons.navigation_rounded),
                              const SizedBox(width: 7),
                              _buildChip('Terjauh', Icons.open_with_rounded),
                              const SizedBox(width: 7),
                              _buildChip('Rating', Icons.star_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),

                    /// =========================
                    /// TOTAL CARD
                    /// =========================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF185FA5), Color(0xFF0C447C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Icon box
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.build_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${filteredPlaces.length} ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'Bengkel Tersedia',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      margin: const EdgeInsets.only(
                                        right: 6,
                                        top: 1,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5DCAA5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'Cari bengkel terdekat dari lokasi anda sekarang.',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Pin icon accent
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white24,
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// =========================
                    /// SECTION TITLE
                    /// =========================
                    const Text(
                      'Bengkel Terdekat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// =========================
                    /// LIST
                    /// =========================
                    // Empty state
                    if (filteredPlaces.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_searching_rounded,
                                size: 28,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bengkel tidak ditemukan',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Coba sesuaikan pencarian atau filter Anda..',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // Place cards
                    ...filteredPlaces.map((place) {
                      return PlaceCard(
                        place: place,
                        onFavoriteTap: () => provider.toggleFavorite(place.id),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailScreen(place: place),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }

  String selectedFilter = 'Terdekat';
}
