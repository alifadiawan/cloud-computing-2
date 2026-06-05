import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/place_model.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const PlaceCard({
  super.key,
  required this.place,
  this.onTap,
  this.onFavoriteTap,
});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              /// =========================
              /// PLACE IMAGE
              /// =========================
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: place.photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: place.photoUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          child:
                              const CircularProgressIndicator(),
                        ),
                        errorWidget:
                            (context, url, error) =>
                                buildPlaceholderImage(place.category),
                      )
                    : buildPlaceholderImage(place.category),
              ),

              const SizedBox(width: 14),

              /// =========================
              /// PLACE INFO
              /// =========================
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    /// NAME
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// CATEGORY
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        place.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// ADDRESS
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.red,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            place.address,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// DISTANCE
                    Row(
                      children: [
                        const Icon(
                          Icons.route,
                          size: 16,
                          color: Colors.green,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          place.distance == 0
                              ? 'Unknown distance'
                              : '${place.distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// =========================
              /// RATING
              /// =========================
              Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.orange,
                    size: 28,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    place.rating.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  GestureDetector(
                    onTap: onFavoriteTap,

                    child: Icon(
                      place.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,

                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// PLACEHOLDER IMAGE WITH UNSPLASH FALLBACK
  /// =========================
  Widget buildPlaceholderImage(String category) {
    final fallbackUrl = _getFallbackPhotoUrl(category);
    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 80,
        height: 80,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 80,
        height: 80,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Icons.store,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getFallbackPhotoUrl(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('mobil')) {
      // High quality car repair shop photo
      return 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=400&q=80';
    } else if (cat.contains('motor')) {
      // High quality motorcycle repair shop photo
      return 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=400&q=80';
    } else {
      // General high quality workshop tools / auto shop photo
      return 'https://images.unsplash.com/photo-1517524206127-48bbd363f3d7?auto=format&fit=crop&w=400&q=80';
    }
  }
}