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
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<PlaceProvider>()
          .fetchNearestPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<PlaceProvider>(context);

    /// =========================
    /// FILTER SEARCH
    /// =========================
    final filteredPlaces =
        provider.places.where((place) {
      return place.name
              .toLowerCase()
              .contains(
                searchQuery.toLowerCase(),
              ) ||
          place.category
              .toLowerCase()
              .contains(
                searchQuery.toLowerCase(),
              );
    }).toList();

    //sort filter//
    if (selectedFilter == 'Terdekat') {
      filteredPlaces.sort(
        (a, b) =>
            a.distance.compareTo(
          b.distance,
        ),
      );
    }

    if (selectedFilter == 'Terjauh') {
      filteredPlaces.sort(
        (a, b) =>
            b.distance.compareTo(
          a.distance,
        ),
      );
    }

    if (selectedFilter == 'Rating') {
      filteredPlaces.sort(
        (a, b) =>
            b.rating.compareTo(
          a.rating,
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )

            /// ERROR
            : provider.errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      provider.errorMessage,
                    ),
                  )

                /// SUCCESS
                : RefreshIndicator(
                    onRefresh:
                        provider.refreshPlaces,

                    child: ListView(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      children: [
                        /// =========================
                        /// HEADER
                        /// =========================
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Hello 👋',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Colors.grey,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                const Text(
                                  'Find Nearby\nWorkshops',
                                  style:
                                      TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight
                                            .bold,
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
                                  margin:
                                      const EdgeInsets.only(
                                    right: 10,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.05),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),

                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const FavoriteScreen(),
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
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      16,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                          0.05,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),

                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MapScreen(),
                                        ),
                                      );
                                    },

                                    icon: const Icon(
                                      Icons.map,
                                      color: Color(
                                        0xFF2563EB,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        /// SEARCH BAR
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withOpacity(
                                  0.04,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                          ),

                          child: Row(
                            children: [

                              /// SEARCH
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },

                                  decoration:
                                      const InputDecoration(
                                    hintText:
                                        'Search workshop...',
                                    prefixIcon:
                                        Icon(Icons.search),
                                    border:
                                        InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                              ),

                              /// FILTER BUTTON
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) {
                                      return Column(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [

                                          ListTile(
                                            leading:
                                                const Icon(
                                              Icons.near_me,
                                            ),
                                            title: const Text(
                                              'Jarak Terdekat',
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedFilter =
                                                    'Terdekat';
                                              });

                                              Navigator.pop(
                                                context,
                                              );
                                            },
                                          ),

                                          ListTile(
                                            leading:
                                                const Icon(
                                              Icons.social_distance,
                                            ),
                                            title: const Text(
                                              'Jarak Terjauh',
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedFilter =
                                                    'Terjauh';
                                              });

                                              Navigator.pop(
                                                context,
                                              );
                                            },
                                          ),

                                          ListTile(
                                            leading:
                                                const Icon(
                                              Icons.star,
                                            ),
                                            title: const Text(
                                              'Rating Tertinggi',
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedFilter =
                                                    'Rating';
                                              });

                                              Navigator.pop(
                                                context,
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },

                                icon: const Icon(
                                  Icons.filter_alt_outlined,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),

                        /// =========================
                        /// TOTAL CARD
                        /// =========================
                        Container(
                          padding:
                              const EdgeInsets.all(
                            18,
                          ),

                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                  0xFF2563EB,
                                ),
                                Color(
                                  0xFF3B82F6,
                                ),
                              ],
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(22),
                          ),

                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets
                                        .all(14),

                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    0.2,
                                  ),

                                  shape:
                                      BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.store,
                                  color:
                                      Colors.white,
                                  size: 32,
                                ),
                              ),

                              const SizedBox(
                                width: 18,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      '${filteredPlaces.length} Workshops Available',
                                      style:
                                          const TextStyle(
                                        color: Colors
                                            .white,
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    const Text(
                                      'Find the nearest workshop easily around your location.',
                                      style:
                                          TextStyle(
                                        color: Colors
                                            .white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        /// =========================
                        /// SECTION TITLE
                        /// =========================
                        const Text(
                          'Nearby Workshops',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        /// =========================
                        /// LIST
                        /// =========================
                        if (filteredPlaces.isEmpty)
                          const Padding(
                            padding:
                                EdgeInsets.only(
                              top: 60,
                            ),
                            child: Center(
                              child: Text(
                                'Workshop not found',
                              ),
                            ),
                          ),

                        ...filteredPlaces.map(
                          (place) {
                            return PlaceCard(
                              place: place,

                              onFavoriteTap: () {
                                provider.toggleFavorite(
                                  place.id,
                                );
                              },

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PlaceDetailScreen(
                                      place:
                                          place,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  String selectedFilter = 'Terdekat';
}