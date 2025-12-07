import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsphere/constants/global_variables.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopsphere/features/search/services/search_services.dart';
import 'package:shopsphere/features/home/services/home_services.dart';
import 'package:shopsphere/providers/cart_provider.dart';
import 'package:shopsphere/features/product_details/screens/product_details_screen.dart';
import 'package:shopsphere/models/cart_item.dart';
import 'package:shopsphere/models/product.dart';
class SearchScreen extends StatefulWidget {
  static const String routeName = '/search-screen';
  final String? initialSearch;
  final String? initialCategory;
  const SearchScreen({this.initialSearch, this.initialCategory, super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchServices searchServices = SearchServices();
  final HomeServices homeServices = HomeServices();
  Map<String, String> sortOptions = {
    "asc": 'Price: Low to High',
    "dsc": 'Price: High to Low',
  };

  Map<String, String> priceOptions = {
    '0-10000': "Under \$10,000",
    '10000-20000': '\$10,000 - \$20,000',
    '20000-30000': '\$20,000 - \$30,000',
    '30000-50000': '\$30,000 - \$50,000',
    '50000-': 'Above \$50,000',
  };
  String search = "";
  String selectedSort = "";
  String selectedPrice = "";
  String selectedCategory = "";
  String tempSelectedCategory = ""; // used for modal selection
  int page = 1;

  bool isLoading = false;
  bool isCategoryLoading = false;
  List<String> categories = [];
  List<dynamic> products = [];
  int totalPage = 1;
  bool isLoadingMore = false;
  bool isLastPage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    search = widget.initialSearch ?? "";
    selectedCategory = widget.initialCategory ?? "";
    fetchCategories();
    fetchProducts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        if (!isLoadingMore && !isLastPage) {
          setState(() => page++);
          fetchProducts(isLoadMore: true);
        }
      }
    });
  }
  

  void fetchCategories() async {
    setState(() => isCategoryLoading = true);
    categories = await homeServices.getProductCategories(context: context);
    setState(() => isCategoryLoading = false);
  }

  // void fetchProducts() async {
  //   setState(() => isLoading = true);
  //   SearchProductResponse response = await searchServices.fetchSearchedProduct(
  //     context: context,
  //     search: search,
  //     sort: selectedSort,
  //     minPrice: selectedPrice.split("-").length == 2 ? selectedPrice.split("-")[0] : "0",
  //     maxPrice: selectedPrice.split("-").length == 2 ? selectedPrice.split("-")[1] : "",
  //     category: selectedCategory,
  //     page: page,
  //   );

  //   products = response.products;
  //   totalPage = response.totalPage;
  //   // setState(() {});
  //   // try {
  //   //   final response = await fetchProductsFromAPI(
  //   //     search: search,
  //   //     sort: sort,
  //   //     maxPrice: maxPrice,
  //   //     category: category,
  //   //     page: page,
  //   //   );
  //   //   products = response.products;
  //   //   totalPage = response.totalPage;
  //   // } catch (e) {
  //   //   // Fluttertoast.showToast(msg: "Failed to fetch products");
  //   // }
  //   setState(() => isLoading = false);
  // }

  Future<void> fetchProducts({bool isLoadMore = false}) async {
    if (isLoadingMore) return;

    setState(() => isLoadingMore = true);

    final response = await searchServices.fetchSearchedProduct(
      context: context,
      search: search,
      sort: selectedSort,
      minPrice: selectedPrice.split("-").length == 2 ? selectedPrice.split("-")[0] : "0",
      maxPrice: selectedPrice.split("-").length == 2 ? selectedPrice.split("-")[1] : "",
      category: selectedCategory,
      page: page,
    );

    if (response != null) {
      final newProducts = response.products;
      final totalPage = response.totalPage;

      setState(() {
        if (!isLoadMore) {
          products = newProducts;
        } else {
          products.addAll(newProducts);
        }

        isLastPage = page >= totalPage;
        isLoadingMore = false;
      });
    }
  }


  void _addToCart(CartItem cartItem, BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isCurrentVariantInCart = cartProvider.cartItems.indexWhere((e) =>
      e.productId == cartItem.productId &&
      (e.variant?.id == cartItem.variant?.id)) != -1;

    if(isCurrentVariantInCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text("Item already in cart."),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/actual-home', arguments: 2);
              },
              child: Text("Go to Cart", style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.cyan)),
            )
          ]
        )),
      );
      return;
    }
    
    if( cartItem.stock < 1 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Out of Stock.")),
      );
      return;
    }
    
      cartProvider.addToCart(cartItem, updateIfExists: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cartItem.name} added to cart')),
      );
  }

  void navigateToProductDetailsScreen(String productId) {
    Navigator.pushNamed(context, ProductDetailsScreen.routeName, arguments: ProductDetailsParams(productId,""));
  }

  Widget _buildProductCard(Product product) {
    final price = product.variants.isNotEmpty ? product.variants[0].price : product.price;
    final stock = product.variants.isNotEmpty ? product.variants[0].stock : product.stock;
    return GestureDetector(
      onTap: () {
        navigateToProductDetailsScreen(product.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Image.network(product.photos[0].url, fit: BoxFit.cover, width: double.infinity),
                    if (stock < 1)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: Text('Out of Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("\$$price", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color.fromARGB(255, 114, 226, 221))),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 114, 226, 221),
                              foregroundColor: Colors.white,
                              elevation: 1,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: stock < 1 ? null : () => _addToCart(
                              CartItem(
                                productId: product.id,
                                photo: product.photos[0].url,
                                name: product.name,
                                price: price,
                                quantity: 1,
                                stock: stock,
                                variant: product.variants.isNotEmpty ? product.variants[0] : null,
                              ),
                              context
                            ),
                            child: const Text("Add to Cart", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
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

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 114, 226, 221) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 114, 226, 221) : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: const Color.fromARGB(255, 114, 226, 221).withOpacity(0.2), blurRadius: 4)] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check : Icons.tune,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMappedFilterBottomSheet({
    required BuildContext context,
    required String title,
    required Map<String, String> options,
    required String selectedKey,
    required void Function(String) onApply,
  }) {
    String tempSelectedKey = selectedKey;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[700], size: 20),
                          onPressed: () => Navigator.pop(context),
                          constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: options.entries.map((entry) {
                      final isSelected = tempSelectedKey == entry.key;
                      return FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (_) => setState(() => tempSelectedKey = entry.key),
                        backgroundColor: Colors.white,
                        selectedColor: const Color.fromARGB(255, 114, 226, 221),
                        side: BorderSide(
                          color: isSelected ? const Color.fromARGB(255, 114, 226, 221) : Colors.grey[300]!,
                          width: 1,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? const Color.fromARGB(255, 114, 226, 221) : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            setState(() => tempSelectedKey = "");
                          },
                          child: Text("Clear", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 114, 226, 221),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            onApply(tempSelectedKey);
                          },
                          child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: SizedBox(
          height: 48,
          child: TextField(
            controller: TextEditingController(text: search),
            onSubmitted: (val) {
              setState(() => search = val);
              fetchProducts();
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: "Search products...",
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color.fromARGB(255, 114, 226, 221), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips (Brand, Price, RAM, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: "Category",
                    isSelected: selectedCategory != "",
                    onTap: () {
                      showMappedFilterBottomSheet(
                        context: context,
                        title: "Select Category",
                        options: { for (var category in categories) category: category },
                        selectedKey: selectedCategory,
                        onApply: (value){
                          setState((){
                            selectedCategory = value;
                            page = 1;
                          });
                          fetchProducts();
                        }
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: "Sort",
                    isSelected: selectedSort != "",
                    onTap: () {
                      showMappedFilterBottomSheet(
                        context: context,
                        title: "Sort by",
                        options: sortOptions,
                        selectedKey: selectedSort,
                        onApply: (value){
                          setState((){
                            selectedSort = value;
                            page = 1;
                          });
                          fetchProducts();
                        }
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: "Price",
                    isSelected: selectedPrice != '',
                    onTap: () {
                      showMappedFilterBottomSheet(
                        context: context,
                        title: "Price Range",
                        options: priceOptions,
                        selectedKey: selectedPrice,
                        onApply: (value){
                          setState((){
                            selectedPrice = value;
                            page = 1;
                          });
                          fetchProducts();
                        }
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Product List or Grid
          if (!isLoadingMore && products.isEmpty)
            const Expanded(
              child: Center(
                child: Text("No products found."),
              ),
            )
          else
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 48),
              itemCount: products.length + (isLoadingMore ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.52,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                if (index < products.length) {
                  final product = products[index];
                  return _buildProductCard(product);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

