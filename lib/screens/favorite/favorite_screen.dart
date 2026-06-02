import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/place_provider.dart';
import '../../widgets/place_card.dart';

class FavoriteScreen
    extends StatelessWidget {
  const FavoriteScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<PlaceProvider>(
      context,
    );

    final favorites =
        provider.favoritePlaces;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Workshops',
        ),
      ),

      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Belum ada bengkel favorit',
              ),
            )
          : ListView.builder(
              itemCount:
                  favorites.length,

              itemBuilder:
                  (context, index) {
                final place =
                    favorites[index];

                return PlaceCard(
                  place: place,

                  onFavoriteTap: () {
                    provider
                        .toggleFavorite(
                      place.id,
                    );
                  },
                );
              },
            ),
    );
  }
}