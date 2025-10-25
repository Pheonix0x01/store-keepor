import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_product.dart';
import 'edit_product.dart';
import '../models/product.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    loadProducts();
    searchController.addListener(applySearchAndFilter);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final dbHelper = DatabaseHelper();
      final loadedProducts = await dbHelper.getProducts();
      setState(() {
        products = loadedProducts;
        applySearchAndFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  void applySearchAndFilter() {
    String query = searchController.text.toLowerCase();
    
    setState(() {
      filteredProducts = products.where((product) {
        bool matchesSearch = product.name.toLowerCase().contains(query);
        
        bool matchesFilter = true;
        if (selectedFilter == 'Low Stock') {
          matchesFilter = product.quantity < AppConstants.lowStockThreshold;
        } else if (selectedFilter == 'High Value') {
          matchesFilter = (product.price * product.quantity) > 1000;
        }
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  int get totalProducts => products.length;

  double get totalInventoryValue {
    return products.fold(0, (sum, product) => sum + (product.price * product.quantity));
  }

  int get lowStockCount {
    return products.where((p) => p.quantity < AppConstants.lowStockThreshold).length;
  }

  Future<void> deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.deleteProduct(product.id!);
        await loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final displayProducts = filteredProducts;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.textPrimary),
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
                applySearchAndFilter();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'All',
                child: Row(
                  children: [
                    Icon(
                      Icons.list,
                      color: selectedFilter == 'All' ? AppColors.accent : AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('All Products'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Low Stock',
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: selectedFilter == 'Low Stock' ? AppColors.error : AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('Low Stock'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'High Value',
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: selectedFilter == 'High Value' ? AppColors.success : AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('High Value'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );
          if (result == true) {
            loadProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (products.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            icon: Icons.inventory_2,
                            label: 'Total Products',
                            value: totalProducts.toString(),
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DashboardCard(
                            icon: Icons.attach_money,
                            label: 'Total Value',
                            value: currencyFormat.format(totalInventoryValue),
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DashboardCard(
                            icon: Icons.warning,
                            label: 'Low Stock',
                            value: lowStockCount.toString(),
                            color: lowStockCount > 0 ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: TextField(
                      controller: searchController,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: AppColors.textSecondary),
                                onPressed: () {
                                  searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                ],
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 100,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(height: AppSpacing.lg),
                              Text(
                                'No products yet',
                                style: AppTextStyles.heading2,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Tap + to add your first product',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : displayProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 100,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'No products found',
                                    style: AppTextStyles.heading3,
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Try a different search or filter',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: loadProducts,
                              color: AppColors.accent,
                              backgroundColor: AppColors.surface,
                              child: ListView.builder(
                                padding: EdgeInsets.all(AppSpacing.md),
                                itemCount: displayProducts.length,
                                itemBuilder: (context, index) {
                                  final product = displayProducts[index];
                                  return Hero(
                                    tag: 'product_${product.id}',
                                    child: ProductCard(
                                      product: product,
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditProductScreen(product: product),
                                          ),
                                        );
                                        if (result == true) {
                                          loadProducts();
                                        }
                                      },
                                      onLongPress: () => deleteProduct(product),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }
}