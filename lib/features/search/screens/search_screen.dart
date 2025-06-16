import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopsphere/features/search/services/search_services.dart';
import 'package:shopsphere/features/home/services/home_services.dart';
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


  void addToCart(product) {
    if (product.stock < 1) {
      // Fluttertoast.showToast(msg: "Out of Stock.");
      return;
    }
    // Your add to cart logic
    // Fluttertoast.showToast(msg: "Added to cart");
  }

  Widget _buildProductCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(product.photos[0].url, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("\$${product.price}", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => addToCart(product),
              child: Text("Add to Cart"),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: options.entries.map((entry) {
                      final isSelected = tempSelectedKey == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (_) => setState(() => tempSelectedKey = entry.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => tempSelectedKey = "");
                          },
                          child: const Text("Clear"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onApply(tempSelectedKey);
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
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
        // backgroundColor: Colors.white,
        elevation: 1,
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: TextEditingController(text: search),
            onSubmitted: (val) {
              setState(() => search = val);
              fetchProducts();
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              hintText: "Search products...",
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips (Brand, Price, RAM, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text("Category"),
                    selected: selectedCategory != "",
                    onSelected: (_) {
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
                  SizedBox(width: 16),
                  ChoiceChip(
                    label: Text("Sort"),
                    selected: selectedSort != "",
                    onSelected: (_) {
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
                  SizedBox(width: 16),
                  ChoiceChip(
                    label: Text("Price"),
                    selected: selectedPrice != '',
                    onSelected: (_) {
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
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(8,8,8,48),
              itemCount: products.length + (isLoadingMore ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
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

