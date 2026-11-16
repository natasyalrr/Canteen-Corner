
import 'package:flutter/material.dart';
import '../models/menu_model.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.menu,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF176B78);
  static const Color accentColor = Color(0xFF4CA3B5);

  String formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 125,
              width: double.infinity,
              child: menu.imageUrl.isNotEmpty
                  ? Image.network(
                      menu.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      formatRupiah(menu.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            menu.canteenLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'Lihat Detail',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFDDF0F1),
      width: double.infinity,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            color: primaryColor,
            size: 45,
          ),
          SizedBox(height: 5),
          Text(
            'Foto Menu',
            style: TextStyle(
              color: primaryColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
