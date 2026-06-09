import 'dart:async';

import 'package:flutter/material.dart';

import '../data/cart_entry.dart';
import '../data/product.dart';
import '../data/product_repository.dart';
import '../theme/apple_theme.dart';
import '../widgets/animated_product_grid_item.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final int cartCount;
  final List<CartEntry> cartEntries;
  final void Function(Product product) onAddToCart;
  final void Function(Product product) onIncrement;
  final void Function(Product product) onDecrement;
  final void Function(Product product) onRemoveFromCart;

  const DiscoverScreen({
    super.key,
    required this.cartCount,
    required this.cartEntries,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemoveFromCart,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _sortOption = 'featured';
  int _animationTick = 0;
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();

  static const _horizontalPadding = 16.0;
  static const _gridSpacing = 14.0;
  static const _cardHeight = 298.0;

  List<String> get _categories {
    final labels = _products.map((product) => product.categoryLabel).toSet().toList()
      ..sort();
    return ['All', ...labels];
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleFilter() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), _applyFilters);
  }

  Future<void> _loadProducts() async {
    final products = await ProductRepository.loadProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    var results = _products.where((product) {
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.tagline.toLowerCase().contains(query) ||
          product.categoryLabel.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == 'All' ||
          product.categoryLabel == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (_sortOption == 'price_low') {
      results.sort((a, b) => a.priceValue.compareTo(b.priceValue));
    } else if (_sortOption == 'price_high') {
      results.sort((a, b) => b.priceValue.compareTo(a.priceValue));
    } else if (_sortOption == 'name') {
      results.sort((a, b) => a.name.compareTo(b.name));
    } else {
      results.sort((a, b) => a.id.compareTo(b.id));
    }

    setState(() {
      _filteredProducts = results;
      _animationTick++;
    });
  }

  void _selectCategory(String category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    _applyFilters();
  }

  Future<void> _showSortOptions() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppleColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppleColors.separator,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Sort By', style: AppleTextStyles.title3),
                const SizedBox(height: 12),
                _SortTile(
                  label: 'Featured',
                  value: 'featured',
                  groupValue: _sortOption,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
                _SortTile(
                  label: 'Price: Low to High',
                  value: 'price_low',
                  groupValue: _sortOption,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
                _SortTile(
                  label: 'Price: High to Low',
                  value: 'price_high',
                  groupValue: _sortOption,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
                _SortTile(
                  label: 'Name: A to Z',
                  value: 'name',
                  groupValue: _sortOption,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _sortOption = selected);
      _applyFilters();
    }
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      createAppleRoute(
        ProductDetailScreen(
          product: product,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      createAppleRoute(
        CartScreen(
          cartEntries: widget.cartEntries,
          onIncrement: widget.onIncrement,
          onDecrement: widget.onDecrement,
          onRemove: widget.onRemoveFromCart,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  String get _resultsLabel {
    final count = _filteredProducts.length;
    if (_selectedCategory != 'All') {
      return '$count $_selectedCategory products';
    }
    if (_searchController.text.trim().isNotEmpty) {
      return '$count results';
    }
    return '$count products';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleColors.canvas,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppleColors.blue,
                  strokeWidth: 2,
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _horizontalPadding,
                        12,
                        12,
                        0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Discover', style: AppleTextStyles.largeTitle),
                                SizedBox(height: 10),
                                Text(
                                  'Find your perfect device.',
                                  style: AppleTextStyles.subheadline,
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openCart,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Badge(
                                  isLabelVisible: widget.cartCount > 0,
                                  backgroundColor: AppleColors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  label: Text('${widget.cartCount}'),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 24,
                                    color: AppleColors.label,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _horizontalPadding,
                        26,
                        _horizontalPadding,
                        20,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppleColors.searchFill,
                          borderRadius: BorderRadius.circular(AppleRadius.search),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: AppleTextStyles.body.copyWith(
                            fontSize: 16,
                            color: AppleColors.label,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search products',
                            hintStyle: AppleTextStyles.subheadline,
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppleColors.secondaryLabel,
                              size: 22,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                      _applyFilters();
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: AppleColors.secondaryLabel,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 4,
                            ),
                          ),
                          onChanged: (_) {
                            setState(() {});
                            _scheduleFilter();
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _horizontalPadding,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppleRadius.card),
                        child: AspectRatio(
                          aspectRatio: 2118 / 474,
                          child: Image.asset(
                            'assets/images/banner.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _horizontalPadding,
                        28,
                        _horizontalPadding,
                        14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shop by Category', style: AppleTextStyles.title3),
                          const SizedBox(height: 14),
                          CategoryFilterBar(
                            categories: _categories,
                            selectedCategory: _selectedCategory,
                            onSelected: _selectCategory,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _horizontalPadding,
                        8,
                        _horizontalPadding,
                        16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.15),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                _resultsLabel,
                                key: ValueKey<String>(_resultsLabel),
                                style: AppleTextStyles.subheadline.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppleColors.label,
                                ),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showSortOptions,
                            icon: const Icon(Icons.swap_vert_rounded, size: 18),
                            label: const Text('Sort'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppleColors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      _horizontalPadding,
                      0,
                      _horizontalPadding,
                      36,
                    ),
                    sliver: _filteredProducts.isEmpty
                        ? SliverToBoxAdapter(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              child: Container(
                                key: const ValueKey('empty-state'),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 48),
                                decoration: AppleDecorations.card,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 44,
                                      color: AppleColors.fill,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No products found',
                                      style: AppleTextStyles.title3,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try a different search or category.',
                                      style: AppleTextStyles.subheadline,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverGrid(
                            key: ValueKey<int>(_animationTick),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: _gridSpacing,
                              crossAxisSpacing: _gridSpacing,
                              mainAxisExtent: _cardHeight,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = _filteredProducts[index];
                                return AnimatedProductGridItem(
                                  key: ValueKey<int>(product.id),
                                  index: index,
                                  animationTick: _animationTick,
                                  child: ProductCard(
                                    product: product,
                                    onTap: () => _openProductDetail(product),
                                  ),
                                );
                              },
                              childCount: _filteredProducts.length,
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _SortTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppleTextStyles.body),
      trailing: groupValue == value
          ? const Icon(Icons.check_rounded, color: AppleColors.blue)
          : null,
      onTap: () => onChanged(value),
    );
  }
}
