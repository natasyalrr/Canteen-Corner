
import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../widgets/menu_search.dart';
import '../widgets/category_filter.dart';
import '../widgets/menu_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const Color primaryColor = Color(0xFF176B78);
  static const Color accentColor = Color(0xFF4CA3B5);
  static const Color backgroundColor = Color(0xFFEEE8E4);

  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'Semua';
  String searchQuery = '';
  String selectedLocation = 'Semua Kantin';

  RangeValues selectedPrice =
      const RangeValues(0, 50000);

  // DATA SEMENTARA UNTUK PREVIEW
  final List<MenuModel> menus = [
    const MenuModel(
      id: '1',
      name: 'Nasi Goreng',
      description: 'Nasi goreng spesial dengan telur dan sayuran.',
      price: 15000,
      category: 'Makanan',
      canteenLocation: 'Kantin Pusat',
    ),
    const MenuModel(
      id: '2',
      name: 'Mie Ayam',
      description: 'Mie ayam dengan topping ayam dan sayuran.',
      price: 12000,
      category: 'Makanan',
      canteenLocation: 'Kantin Pusat',
    ),
    const MenuModel(
      id: '3',
      name: 'Es Teh',
      description: 'Minuman teh segar.',
      price: 5000,
      category: 'Minuman',
      canteenLocation: 'Kantin Utara',
    ),
    const MenuModel(
      id: '4',
      name: 'Kentang Goreng',
      description: 'Kentang goreng renyah.',
      price: 10000,
      category: 'Snack',
      canteenLocation: 'Kantin Selatan',
    ),
    const MenuModel(
      id: '5',
      name: 'Ayam Geprek',
      description: 'Ayam crispy dengan sambal pedas.',
      price: 18000,
      category: 'Makanan',
      canteenLocation: 'Kantin Utara',
    ),
    const MenuModel(
      id: '6',
      name: 'Jus Alpukat',
      description: 'Jus alpukat segar.',
      price: 12000,
      category: 'Minuman',
      canteenLocation: 'Kantin Selatan',
    ),
    const MenuModel(
      id: '7',
      name: 'Nasi Ayam',
      description: 'Nasi dengan ayam goreng dan sambal.',
      price: 17000,
      category: 'Makanan',
      canteenLocation: 'Kantin Pusat',
    ),
    const MenuModel(
      id: '8',
      name: 'Roti Bakar',
      description: 'Roti bakar dengan berbagai topping.',
      price: 10000,
      category: 'Snack',
      canteenLocation: 'Kantin Utara',
    ),
    const MenuModel(
      id: '9',
      name: 'Es Jeruk',
      description: 'Minuman jeruk segar.',
      price: 6000,
      category: 'Minuman',
      canteenLocation: 'Kantin Selatan',
    ),
    const MenuModel(
      id: '10',
      name: 'Bakso',
      description: 'Bakso dengan kuah hangat.',
      price: 14000,
      category: 'Makanan',
      canteenLocation: 'Kantin Pusat',
    ),
  ];

  List<MenuModel> get filteredMenus {
    return menus.where((menu) {
      final matchesSearch =
          menu.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
          menu.canteenLocation.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

      final matchesCategory =
          selectedCategory == 'Semua' ||
          menu.category == selectedCategory;

      final matchesLocation =
          selectedLocation == 'Semua Kantin' ||
          menu.canteenLocation == selectedLocation;

      final matchesPrice =
          menu.price >= selectedPrice.start &&
          menu.price <= selectedPrice.end;

      return matchesSearch &&
          matchesCategory &&
          matchesLocation &&
          matchesPrice &&
          menu.isAvailable;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  void showPriceFilter() {
    RangeValues temporaryPrice = selectedPrice;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Harga',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  RangeSlider(
                    values: temporaryPrice,
                    min: 0,
                    max: 50000,
                    divisions: 50,
                    activeColor: primaryColor,
                    labels: RangeLabels(
                      formatRupiah(temporaryPrice.start.round()),
                      formatRupiah(temporaryPrice.end.round()),
                    ),
                    onChanged: (value) {
                      setSheetState(() {
                        temporaryPrice = value;
                      });
                    },
                  ),

                  Text(
                    '${formatRupiah(temporaryPrice.start.round())} - '
                    '${formatRupiah(temporaryPrice.end.round())}',
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedPrice = temporaryPrice;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Terapkan Filter'),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedPrice =
                            const RangeValues(0, 50000);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Reset Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showLocationFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Lokasi Kantin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 10),

              ...[
                'Semua Kantin',
                'Kantin Pusat',
                'Kantin Utara',
                'Kantin Selatan',
              ].map((location) {
                return RadioListTile<String>(
                  title: Text(location),
                  value: location,
                  groupValue: selectedLocation,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void showMenuDetail(MenuModel menu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF0F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: menu.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            menu.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(
                                  Icons.restaurant,
                                  size: 60,
                                  color: primaryColor,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          size: 60,
                          color: primaryColor,
                        ),
                ),

                const SizedBox(height: 18),

                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  formatRupiah(menu.price),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  menu.description,
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(menu.canteenLocation),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedMenus = filteredMenus;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Menu Kantin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuSearch(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 10),

              CategoryFilter(
                selectedCategory: selectedCategory,
                onCategorySelected: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: showPriceFilter,
                      icon: const Icon(
                        Icons.price_change_outlined,
                        size: 18,
                      ),
                      label: const Text('Filter Harga'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: showLocationFilter,
                      icon: const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                      ),
                      label: const Text('Lokasi Kantin'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${displayedMenus.length} Menu Tersedia',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  if (selectedCategory != 'Semua' ||
                      selectedLocation != 'Semua Kantin' ||
                      selectedPrice.start > 0 ||
                      selectedPrice.end < 50000)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'Semua';
                          selectedLocation = 'Semua Kantin';
                          selectedPrice =
                              const RangeValues(0, 50000);
                        });
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              Expanded(
                child: displayedMenus.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Menu tidak ditemukan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;

                          final columns = width >= 1200
                              ? 5
                              : width >= 800
                                  ? 3
                                  : 2;

                          final ratio = width >= 800
                              ? 0.85
                              : 0.68;

                          return GridView.builder(
                            itemCount: displayedMenus.length,

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: ratio,
                            ),

                            itemBuilder: (context, index) {
                              final menu = displayedMenus[index];

                              return MenuCard(
                                menu: menu,
                                onTap: () {
                                  showMenuDetail(menu);
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
