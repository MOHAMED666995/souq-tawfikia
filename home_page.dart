
// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souq_tawfikia/Login_Page.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final int remaining;
  final double? discount;
  final String? description;
  final String? imageUrl;
  final String type;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.remaining,
    this.discount,
    this.description,
    this.imageUrl,
    required this.type,
    this.isActive = true,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? 'اسم غير متوفر',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      remaining: (data['remaining'] as num?)?.toInt() ?? 0,
      discount: (data['discount'] as num?)?.toDouble(),
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      type: data['type'] ?? 'part',
      isActive: data['isActive'] ?? true,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _selectedFilterValue;
  final TextEditingController _searchController = TextEditingController();

  late PageController _adPageController;
  Timer? _adTimer;
  int _currentAdPageIndex = 0;
  static const Duration _adChangeInterval = Duration(seconds: 5);
  static const Duration _adAnimationDuration = Duration(milliseconds: 700);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> _adBannerImagePaths = [
    'assets/images/03.png',
    'assets/images/auto_gas.png',
    'assets/images/phoenix.png',
  ];

  late final List<Widget> _adBanners;

  // --- New Colors Palette ---
  static const Color primaryColor = Color(0xFF3DB2FF); // Blue
static const Color secondaryColor = Color(0xFFFFB830); // Yellow/Accent
static const Color backgroundColor = Color(0xFFFFEDDA); // Light Beige
static const Color cardColor = Colors.white;
static const Color discountColor = Color(0xFFFF2442); // Red for discounts or alerts
static const Color priceColor = Color(0xFF3DB2FF); // Blue for price tags
static const Color placeholderBg = Color(0xFFE3F2FD); // Keep if needed, or adapt
static const Color placeholderIconColor = Color(0xFF3DB2FF); // Blue icons
static const Color filterSelectedBg = Color(0xFFFFB830); // Highlight selected filters

  @override
  void initState() {
    super.initState();
    _adBanners = _adBannerImagePaths
        .map((path) => _buildImageAdBannerWidget(path))
        .toList();
    _adPageController = PageController(initialPage: _currentAdPageIndex);
    if (_adBanners.isNotEmpty) {
      _startAdTimer();
    }
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startAdTimer() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(_adChangeInterval, (timer) {
      if (!mounted || _adBanners.isEmpty || !_adPageController.hasClients) {
        timer.cancel();
        return;
      }
      _currentAdPageIndex = (_currentAdPageIndex + 1) % _adBanners.length;
      _adPageController.animateToPage(
        _currentAdPageIndex,
        duration: _adAnimationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    // Add navigation if needed
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _searchController.text.toLowerCase();
    return products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(query) ||
          (p.description?.toLowerCase().contains(query) ?? false);
      final matchesFilter = _selectedFilterValue == null ||
          (p.type == _selectedFilterValue);
      return matchesSearch && matchesFilter && p.isActive;
    }).toList();
  }

  Widget _buildImageAdBannerWidget(String imagePath) {
  return Container(
    height: 140, // ✅ تصغير حجم الإعلان
    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 4),
        )
      ],
    ),
    clipBehavior: Clip.antiAlias,
    // child: Image.asset(
    //   imagePath,
    //   fit: BoxFit.cover,
    //   width: double.infinity,
    //   height: 140,
      child: Padding(
      padding: const EdgeInsets.all(10.0), // إضافة حشو حول الصورة لجعلها أصغر
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        color: placeholderBg,
        child: const Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey),
      ),
      ),
    ),
  );
}


  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ابحث هنا...',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: PopupMenuButton<String?>(
              tooltip: 'فلترة البحث',
              icon: Icon(Icons.filter_list, color: primaryColor),
              onSelected: (value) {
                setState(() {
                  _selectedFilterValue = value;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'part',
                  child: Text('قطع غيار السيارات',
                      style: TextStyle(
                          color: _selectedFilterValue == 'part'
                              ? primaryColor
                              : Colors.black87)),
                  // Highlight selected item background
                  textStyle: TextStyle(
                    backgroundColor:
                        _selectedFilterValue == 'part' ? filterSelectedBg : null,
                  ),
                ),
                PopupMenuItem(
                  value: 'accessory',
                  child: Text('اكسسوارات السيارات',
                      style: TextStyle(
                          color: _selectedFilterValue == 'accessory'
                              ? primaryColor
                              : Colors.black87)),
                  textStyle: TextStyle(
                    backgroundColor:
                        _selectedFilterValue == 'accessory' ? filterSelectedBg : null,
                  ),
                ),
                PopupMenuItem(
                  value: null,
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAdCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _adPageController,
        itemCount: _adBanners.length,
        itemBuilder: (_, i) => _adBanners[i],
        onPageChanged: (page) {
          if (mounted) {
            setState(() => _currentAdPageIndex = page);
          }
        },
      ),
    );
  }

    Widget _buildAdIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_adBanners.length, (index) {
        bool isActive = index == _currentAdPageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : primaryColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(Product product) {
    double priceAfterDiscount = product.discount != null
        ? product.price - product.discount!
        : product.price;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Handle product tap if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: placeholderBg,
                  borderRadius: BorderRadius.circular(12),
                  image: product.imageUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(product.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imageUrl == null
                    ? Icon(Icons.image_not_supported_outlined,
                        size: 50, color: placeholderIconColor)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description ?? 'لا يوجد وصف',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (product.discount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: discountColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'خصم ${product.discount!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (product.discount != null) const SizedBox(width: 10),
                        Text(
                          '${priceAfterDiscount.toStringAsFixed(2)} ج.م',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: priceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'المتبقي: ${product.remaining}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
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

  Widget _buildProductsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('حدث خطأ: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data!.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();
        final filteredProducts = _filterProducts(products);

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Text('لا توجد منتجات متاحة'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(filteredProducts[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
  backgroundColor: primaryColor,
  elevation: 6,
  centerTitle: true,
  // title: const Text('الرئيسية', style: TextStyle(fontWeight: FontWeight.bold)),
  leading: IconButton(
    icon: const Icon(Icons.notifications_none, size: 28),
    onPressed: () {
      // هنا تضيف أكشن الإشعارات
      print('تم الضغط على الإشعارات');
    },
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Image.asset(
        'assets/images/01.png', // تأكد من مسار اللوجو عندك
        height: 32,
        fit: BoxFit.contain,
      ),
    ),
  ],
),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          _buildAdCarousel(),
          const SizedBox(height: 8),
          _buildAdIndicator(),
          const SizedBox(height: 8),
          Expanded(child: _buildProductsList()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
