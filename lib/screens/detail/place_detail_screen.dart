import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/place_model.dart';
import '../map/map_screen.dart';

class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceDetailScreen({super.key, required this.place});

  // ---> TEMA 2: Trust & Professional (Navy & Steel) <---
  final Color _primaryColor = const Color(0xFF1A365D); // Navy Blue
  final Color _secondaryColor = const Color(0xFF2B6CB0); // Bright Blue
  final Color _titleColor = const Color(0xFF1A365D);
  final Color _bgBottom = const Color(0xFFF4F7FB);

  // List urutan hari untuk menampilkan jadwal seminggu secara berurutan
  final List<String> _orderedDays = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  /// Fungsi mengambil jam operasional hari ini secara manual
  String _getTodayOpeningHours(Map<String, dynamic>? openingHoursMap) {
    if (openingHoursMap == null || openingHoursMap.isEmpty) {
      return 'Jam tidak tersedia';
    }

    final int weekday = DateTime.now().weekday;
    final String currentDay = _orderedDays[weekday - 1];

    return openingHoursMap[currentDay] ?? openingHoursMap['Senin'] ?? 'Tutup';
  }

  /// Fungsi untuk memunculkan Bottom Sheet jadwal seminggu penuh
  void _showWeeklyHoursBottomSheet(BuildContext context, Map<String, dynamic>? openingHoursMap) {
    if (openingHoursMap == null || openingHoursMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Detail jam operasional tidak tersedia')),
      );
      return;
    }

    final int todayWeekday = DateTime.now().weekday;
    final String todayName = _orderedDays[todayWeekday - 1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis handle kecil di atas bottom sheet
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.access_time_filled_rounded, color: _secondaryColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Jam Operasional Seminggu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade100, thickness: 1.5),
              const SizedBox(height: 8),
              
              // Looping daftar hari dari Senin - Minggu
              ..._orderedDays.map((day) {
                final bool isToday = (day == todayName);
                final String hours = openingHoursMap[day] ?? 'Tutup';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isToday ? _secondaryColor.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday ? Border.all(color: _secondaryColor.withValues(alpha: 0.3)) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                              color: isToday ? _secondaryColor : Colors.grey.shade700,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _secondaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Hari ini',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        hours,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? _secondaryColor : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka dialer telepon ke $phoneNumber')),
        );
      }
    }
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        color: _titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _bgBottom,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _secondaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('places').doc(place.id.toString()).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: _bgBottom,
            body: Center(child: CircularProgressIndicator(color: _primaryColor)),
          );
        }

        Map<String, dynamic>? firebaseData;
        if (snapshot.hasData && snapshot.data!.exists) {
          firebaseData = snapshot.data!.data() as Map<String, dynamic>?;
        }

        final String name = firebaseData?['name'] ?? place.name;
        final String category = firebaseData?['category'] ?? place.category;
        final double rating = (firebaseData?['rating'] ?? place.rating).toDouble();
        final String address = firebaseData?['address'] ?? place.address;
        final String description = firebaseData?['description'] ?? 'Tempat bengkel kendaraan roda dua tepercaya.';
        
        final Map<String, dynamic>? openingHoursMap = firebaseData?['opening_hours'] as Map<String, dynamic>?;
        final String todayHours = _getTodayOpeningHours(openingHoursMap);
        final String phoneNumber = firebaseData?['phone'] ?? 'Tidak ada nomor';

        // Logika untuk mengumpulkan URL gambar menjadi List (Mendukung lebih dari 1 gambar)
        List<String> imageUrls = [];
        if (firebaseData?['photo_url'] != null && firebaseData!['photo_url'].toString().isNotEmpty) {
          imageUrls.add(firebaseData['photo_url']);
        }
        if (firebaseData?['photo_url_2'] != null && firebaseData!['photo_url_2'].toString().isNotEmpty) {
          imageUrls.add(firebaseData['photo_url_2']);
        }
        
        // Fallback jika kosong
        if (imageUrls.isEmpty && place.photoUrl.isNotEmpty) {
          imageUrls.add(place.photoUrl);
        }

        return Scaffold(
          backgroundColor: _bgBottom,
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.green),
                      onPressed: () => _makePhoneCall(phoneNumber, context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapScreen(destinationPlace: place),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          elevation: 2,
                          shadowColor: _primaryColor.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Petunjuk Arah',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: _primaryColor,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Memanggil Widget Auto Slide Carousel
                      AutoSlideCarousel(
                        imageUrls: imageUrls,
                        fallbackName: name,
                        fallbackCategory: category,
                        secondaryColor: _secondaryColor,
                        bgBottom: _bgBottom,
                      ),
                      // Gradient Overlay agar tombol back tetap terlihat jelas
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: _titleColor,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _secondaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: _secondaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildQuickInfoCard(
                              icon: Icons.access_time_filled_rounded,
                              iconColor: _secondaryColor,
                              title: 'JAM HARI INI',
                              value: todayHours,
                              onTap: () => _showWeeklyHoursBottomSheet(context, openingHoursMap),
                            ),
                            const SizedBox(width: 12),
                            _buildQuickInfoCard(
                              icon: Icons.phone_rounded,
                              iconColor: Colors.green,
                              title: 'HUBUNGI BENGKEL',
                              value: phoneNumber,
                              onTap: () => _makePhoneCall(phoneNumber, context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 20),
                        const Text(
                          'Fasilitas & Layanan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFacilityTag('Mekanik Berpengalaman', Icons.gavel_rounded),
                            _buildFacilityTag('Ruang Tunggu', Icons.chair_rounded),
                            _buildFacilityTag('Suku Cadang Asli', Icons.verified_rounded),
                            _buildFacilityTag('Garansi Servis', Icons.workspace_premium_rounded),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Lokasi Bengkel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Tentang Bengkel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// =======================================================================
/// WIDGET BARU: AutoSlideCarousel
/// Digunakan khusus untuk menampilkan gambar bergeser secara otomatis
/// =======================================================================
class AutoSlideCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String fallbackName;
  final String fallbackCategory;
  final Color secondaryColor;
  final Color bgBottom;

  const AutoSlideCarousel({
    super.key,
    required this.imageUrls,
    required this.fallbackName,
    required this.fallbackCategory,
    required this.secondaryColor,
    required this.bgBottom,
  });

  @override
  State<AutoSlideCarousel> createState() => _AutoSlideCarouselState();
}

class _AutoSlideCarouselState extends State<AutoSlideCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Jalankan timer hanya jika gambar lebih dari 1
    if (widget.imageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_currentPage < widget.imageUrls.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; // Kembali ke awal
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPlaceholderImage() {
    final searchWord = widget.fallbackName.split(' ').first;
    final cleanCategory = widget.fallbackCategory
        .replaceAll('Bengkel ', '')
        .replaceAll(' ', '-')
        .toLowerCase();
    final fallbackUrl = 'https://loremflickr.com/800/600/workshop,repair,$searchWord,$cleanCategory';

    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: widget.bgBottom,
        child: Center(
          child: CircularProgressIndicator(color: widget.secondaryColor),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(Icons.store_mall_directory_rounded, size: 80, color: Colors.grey.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: widget.bgBottom,
                child: Center(
                  child: CircularProgressIndicator(color: widget.secondaryColor),
                ),
              ),
              errorWidget: (context, url, error) => _buildPlaceholderImage(),
            );
          },
        ),
        // Indikator Titik (Dots) di bagian bawah gambar
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 40, // Diletakkan di atas efek rounded container bawah
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}