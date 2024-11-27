import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';  

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  int currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 24,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);  
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               
              Stack(
                children: [
                    SizedBox(
                    height: 300,  
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemCount: widget.product.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () => _showFullScreenImage(context, widget.product.images[index]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                widget.product.images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _placeholderImage();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                   
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.product.images.length,
                            (index) => AnimatedContainer(
                          duration:const  Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentPage == index ? Colors.white : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
               
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     
                    Text(
                      widget.product.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                     
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Price",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${widget.product.price}",
                          style: const TextStyle(fontSize: 22, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                     
                    Text(
                      widget.product.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text(
                    "$quantity",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
               
              ElevatedButton(
                onPressed: () {
                   
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "BUY NOW",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   
  void _showFullScreenImage(BuildContext context, String initialImageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,  
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();  
            },
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: PageView.builder(
                  itemCount: widget.product.images.length,
                  itemBuilder: (context, index) {
                    return _buildImagePage(widget.product.images[index]);
                  },
                  controller: PageController(initialPage: widget.product.images.indexOf(initialImageUrl)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePage(String? imageUrl) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),  
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
          imageUrl,
          fit: BoxFit.contain,  
          errorBuilder: (context, error, stackTrace) {
            return _placeholderImage();  
          },
        )
            : _placeholderImage(),  
      ),
    );
  }

 
  Widget _placeholderImage() {
    return Container(
      width: 200,  
      height: 200,  
      decoration: BoxDecoration(
        color: Colors.grey.shade300,  
        borderRadius: BorderRadius.circular(20.0),  
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey.shade500,
        size: 48,  
      ),
    );
  }
}
