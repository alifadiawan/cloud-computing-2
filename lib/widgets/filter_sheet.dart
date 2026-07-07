import 'package:flutter/material.dart';

class FilterSheet extends StatelessWidget {
  final String? selectedFilter;
  final ValueChanged<String> onSelected;

  const FilterSheet({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
            child: Row(
              children: [
                const Text(
                  'Urutkan bengkel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 16),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          _FilterOption(
            icon: Icons.navigation_rounded,
            iconBg: const Color(0xFFE1F5EE),
            iconColor: const Color(0xFF1D9E75),
            label: 'Jarak Terdekat',
            desc: 'Bengkel paling dekat dari lokasi Anda',
            selected: selectedFilter == 'Terdekat',
            onTap: () => onSelected('Terdekat'),
          ),
          _FilterOption(
            icon: Icons.open_with_rounded,
            iconBg: const Color(0xFFE6F1FB),
            iconColor: const Color(0xFF378ADD),
            label: 'Jarak Terjauh',
            desc: 'Bengkel paling jauh dari lokasi Anda',
            selected: selectedFilter == 'Terjauh',
            onTap: () => onSelected('Terjauh'),
          ),
          _FilterOption(
            icon: Icons.star_rounded,
            iconBg: const Color(0xFFFAEEDA),
            iconColor: const Color(0xFFBA7517),
            label: 'Rating Tertinggi',
            desc: 'Bengkel dengan ulasan terbaik',
            selected: selectedFilter == 'Rating',
            onTap: () => onSelected('Rating'),
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded,
                  size: 18, color: Color(0xFF185FA5)),
          ],
        ),
      ),
    );
  }
}