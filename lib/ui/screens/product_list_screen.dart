import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/error_widget.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = ""; 
  String sortOption = "none"; 
  List<Product> originalProducts = [];
  final FocusNode searchFocusNode = FocusNode();
  final GlobalKey _popupKey = GlobalKey();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void closeSortPopup() {
    final dynamic popupState = _popupKey.currentState;
    if (popupState != null && popupState.mounted) {
      popupState.deactivate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProductController>(context);


    if (controller.products.isNotEmpty && originalProducts.isEmpty) {
      originalProducts = List.from(controller.products);
    }

    
    final filteredProducts = controller.products
        .where((product) =>
        product.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (sortOption == "price_asc") {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOption == "price_desc") {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortOption == "name") {
      filteredProducts.sort((a, b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (sortOption == "featured") {
      filteredProducts.clear();
      filteredProducts.addAll(originalProducts);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        closeSortPopup();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Products',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    key: _popupKey,
                    onSelected: (value) {
                      setState(() {
                        sortOption = value;
                      });
                    },
                    onCanceled: closeSortPopup,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "featured",
                        child: Text("Featured"),
                      ),
                      PopupMenuItem(
                        value: "name",
                        child: Text("Name"),
                      ),
                      PopupMenuItem(
                        value: "price_asc",
                        child: Text("Price: Low to High"),
                      ),
                      PopupMenuItem(
                        value: "price_desc",
                        child: Text("Price: High to Low"),
                      ),
                    ],
                    icon: const Icon(Icons.sort, size: 30),
                  ),
                ],
              ),
            ),

            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.errorMessage != null
                  ? AppErrorWidget(error: controller.errorMessage!)
                  : filteredProducts.isEmpty
                  ? const Center(child: Text("No products found"))
                  : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 8.0, 
                  mainAxisSpacing: 8.0, 
                  childAspectRatio: 0.8, 
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: filteredProducts[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
