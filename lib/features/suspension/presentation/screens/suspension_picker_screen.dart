import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/suspension/domain/models/suspension_product.dart';
import 'package:ridemetrx/features/suspension/domain/suspension_products_notifier.dart';
import 'package:ridemetrx/features/suspension/presentation/widgets/product_card.dart';
import 'package:ridemetrx/features/suspension/presentation/widgets/product_detail_sheet.dart';

class SuspensionPickerScreen extends ConsumerStatefulWidget {
  final SuspensionType type;
  final Function(SuspensionProduct) onSelect;

  const SuspensionPickerScreen({
    Key? key,
    required this.type,
    required this.onSelect,
  }) : super(key: key);

  @override
  ConsumerState<SuspensionPickerScreen> createState() =>
      _SuspensionPickerScreenState();
}

class _SuspensionPickerScreenState
    extends ConsumerState<SuspensionPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedBrand;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SuspensionProduct> _getFilteredProducts() {
    final productsState = ref.watch(suspensionProductsNotifierProvider);

    return productsState.when(
      data: (state) {
        // Use sortedProducts to respect current sort option
        var products = state.sortedProducts.where((p) => p.type == widget.type).toList();

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.toLowerCase();
          products = products.where((product) {
            final searchString =
                '${product.brand} ${product.model} ${product.year}'
                    .toLowerCase();
            return searchString.contains(lowerQuery);
          }).toList();
        }

        // Apply brand filter
        if (_selectedBrand != null) {
          products = products
              .where((p) => p.brand.toLowerCase() == _selectedBrand!.toLowerCase())
              .toList();
        }

        return products;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  List<String> _getAvailableBrands() {
    final productsState = ref.watch(suspensionProductsNotifierProvider);

    return productsState.when(
      data: (state) {
        final brands = state.products
            .where((p) => p.type == widget.type)
            .map((p) => p.brand)
            .toSet()
            .toList()
          ..sort();
        return brands;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  void _showProductDetail(SuspensionProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(
        product: product,
        onSelect: (selectedProduct, configuration) {
          Navigator.pop(context); // Close bottom sheet
          widget.onSelect(selectedProduct);
          // TODO: Pass configuration to parent - will integrate later
          print('Selected configuration: $configuration');
          Navigator.pop(context); // Close picker screen
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedBrand = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool get _hasActiveFilters =>
      _selectedBrand != null ||
      _searchQuery.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(suspensionProductsNotifierProvider);
    final filteredProducts = _getFilteredProducts();
    final availableBrands = _getAvailableBrands();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Select ${widget.type == SuspensionType.fork ? 'Fork' : 'Shock'}'),
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear All'),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context); // Close picker
              // User will use manual entry in bike form
            },
            icon: const Icon(Icons.edit),
            label: const Text('Manual'),
          ),
        ],
      ),
      body: productsState.when(
        data: (state) {
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(suspensionProductsNotifierProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by brand, model, or year...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Filter chips
              if (availableBrands.isNotEmpty)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...availableBrands.map((brand) {
                        final isSelected = _selectedBrand == brand;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(brand),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedBrand = selected ? brand : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const Divider(height: 1),

              // Sort dropdown bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    // Sort dropdown button
                    Expanded(
                      child: PopupMenuButton<SuspensionProductSort>(
                        onSelected: (sort) {
                          ref.read(suspensionProductsNotifierProvider.notifier).setSortOption(sort);
                        },
                        itemBuilder: (context) {
                          final currentSort = state.sortBy;

                          return SuspensionProductSort.values.map((sort) {
                            return PopupMenuItem<SuspensionProductSort>(
                              value: sort,
                              child: Row(
                                children: [
                                  if (currentSort == sort)
                                    Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor)
                                  else
                                    const SizedBox(width: 18),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(sort.displayName)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sort, size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  state.sortBy.displayName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade700),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Product count
                    Text(
                      '${filteredProducts.length} ${filteredProducts.length == 1 ? 'product' : 'products'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Products list
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_hasActiveFilters) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _clearFilters,
                                child: const Text('Clear filters'),
                              ),
                            ],
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // Returns to bike form for manual entry
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Enter Details Manually'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () => _showProductDetail(product),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading products: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(suspensionProductsNotifierProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
