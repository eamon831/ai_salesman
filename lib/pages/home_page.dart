import 'package:ai_salesman/services/open_ai_service.dart';
import 'package:flutter/material.dart';

final productDetailsJson = {
  "name": "Apple iPhone 16",
  "description":
      "The iPhone 16 features a 6.1″ Super Retina XDR OLED display, IP68 water/dust resistance, the A18 chip, Apple Intelligence, a dual-camera system (48 MP + 12 MP), and USB-C charging.",
  "price": 799,
  "image":
      "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-16-gallery-1-202409?wid=2000&hei=2000&fmt=jpeg&qlt=90&.v=1704540861158",
  "specs": {
    "storageOptions": ["128 GB", "256 GB", "512 GB"],
    "chip": "A18 (3 nm)",
    "display": {
      "size": "6.1″",
      "resolution": "2556 × 1179",
      "type": "Super Retina XDR OLED",
      "brightness": "2000 nits (peak, outdoor)",
    },
    "cameras": {
      "rear": "48 MP (wide) + 12 MP (ultrawide)",
      "front": "12 MP TrueDepth",
      "video": "4K @ 24/25/30/60 fps, Dolby Vision HDR",
    },
    "battery": {
      "capacity": "3561 mAh",
      "charging":
          "USB-C (PD 2.0), 50% in ~30 min; MagSafe wireless; Qi2 wireless",
    },
    "build": {
      "frame": "Aluminum",
      "frontGlass": "Ceramic Shield",
      "backGlass": "Color-infused glass",
      "waterResistance": "IP68 (up to 6 m for 30 min)",
    },
    "os": "iOS 18",
    "weight": "170 g",
  },
};

class ProductDetails {
  final String name;
  final String description;
  final double price;
  final String image;

  ProductDetails({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUserMessage: json['isUserMessage'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProductDetails productDetails = ProductDetails.fromJson(productDetailsJson);
  List<ChatMessage> chatMessages = <ChatMessage>[];

  TextEditingController msgController = TextEditingController();

  void openChatModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Dialog(
              child: Container(
                height: 380,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ask any question related to this product',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Product: ${productDetails.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatMessages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final message = chatMessages[index];
                          return Align(
                            alignment: message.isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: message.isUserMessage
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(message.text),
                            ),
                          );
                        },
                      ),
                    ),
                    TextFormField(
                      controller: msgController,
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            if (msgController.text.trim().isEmpty) return;
                            await OpenAiService()
                                .getCompletion(msgController.text.trim())
                                .then((value) {
                                  if (value != null) {
                                    modalSetState(() {
                                      chatMessages.add(
                                        ChatMessage(
                                          text: value ?? '',
                                          isUserMessage: false,
                                        ),
                                      );
                                    });
                                  }
                                });

                            msgController.clear();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salesman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Text(
              productDetails.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(productDetails.description),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              width: 220,
              child: Image.network(productDetails.image, fit: BoxFit.cover),
            ),
          ],
        ),
      ),

      // Floating Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openChatModal,
        label: const Text("How can I help you?"),
        icon: const Icon(Icons.chat),
      ),
    );
  }
}
