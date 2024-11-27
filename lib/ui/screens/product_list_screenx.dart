import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/error_widget.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = ""; // Store the search query
  String sortOption = "none"; // Sorting option (price ascending/descending, name, relevance)
  List<Product> originalProducts = []; // Store the original list for "relevance"
  final FocusNode searchFocusNode = FocusNode(); // FocusNode for the search bar
  final GlobalKey _popupKey = GlobalKey(); // Key to manage PopupMenuButton state

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void closeSortPopup() {
    final dynamic popupState = _popupKey.currentState;
    if (popupState != null && popupState.mounted) {
      popupState.deactivate(); // Manually close the PopupMenuButton
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProductController>(context);

    // Store the original products list only once when the data is first loaded
    if (controller.products.isNotEmpty && originalProducts.isEmpty) {
      originalProducts = List.from(controller.products); // Store the original order
    }

    // Filtered product list based on the search query
    final filteredProducts = controller.products
        .where((product) =>
        product.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // Sort the filtered products based on the selected sort option
    if (sortOption == "price_asc") {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOption == "price_desc") {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortOption == "name") {
      filteredProducts.sort((a, b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (sortOption == "relevance") {
      filteredProducts.clear(); // Clear the list to restore original order
      filteredProducts.addAll(originalProducts); // Restore original order
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Close keyboard
        closeSortPopup(); // Close the popup menu if open
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Column(
          children: [
            // Search Bar and Sort Button
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
                          searchQuery = value; // Update search query dynamically
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  PopupMenuButton<String>(
                    key: _popupKey, // Assign the key for manual state management
                    onSelected: (value) {
                      setState(() {
                        sortOption = value; // Update sorting option
                      });
                    },
                    onCanceled: closeSortPopup, // Close popup when canceled
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "relevance",
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
                    icon: Icon(Icons.sort, size: 30),
                  ),
                ],
              ),
            ),
            // Product Grid
            Expanded(
              child: controller.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : controller.errorMessage != null
                  ? AppErrorWidget(error: controller.errorMessage!)
                  : filteredProducts.isEmpty
                  ? Center(child: Text("No products found"))
                  : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 8.0, // Spacing between columns
                  mainAxisSpacing: 8.0, // Spacing between rows
                  childAspectRatio: 0.8, // Adjust layout
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
