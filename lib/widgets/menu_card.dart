import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'menu_image.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu;
  final String kantinNama;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const MenuCard({
    super.key,
    required this.menu,
    required this.kantinNama,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final bisa = menu.bisaDipesan;
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MenuImage(url: menu.fotoUrl, iconSize: 40),
                  if (!bisa)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: const Text(
                        'Habis',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(menu.harga),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cta,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            kantinNama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: bisa ? onAdd : null,
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: Text(bisa ? 'Tambah' : 'Habis'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(34),
                          padding: EdgeInsets.zero,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
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
}
