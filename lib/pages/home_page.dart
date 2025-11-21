import 'package:ai_salesman/services/open_ai_service.dart';
import 'package:flutter/material.dart';

// Constants
const kProductDetailsJson = {
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

// Models
class ProductDetails {
  final String name;
  final String description;
  final double price;
  final String image;

  const ProductDetails({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  const ChatMessage({required this.text, required this.isUserMessage});
}

// Main Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProductDetails productDetails;
  late final OpenAiService _openAiService;
  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _msgController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    productDetails = ProductDetails.fromJson(kProductDetailsJson);
    // Pass the complete product details JSON to the AI service
    _openAiService = OpenAiService(productDetails: kProductDetailsJson);
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(StateSetter modalSetState) async {
    final userMessage = _msgController.text.trim();
    if (userMessage.isEmpty) return;

    // Add user message
    modalSetState(() {
      _chatMessages.add(ChatMessage(text: userMessage, isUserMessage: true));
      _isLoading = true;
    });
    _msgController.clear();

    try {
      // Get AI response
      final response = await _openAiService.getCompletion(userMessage);

      if (response != null && response.isNotEmpty) {
        modalSetState(() {
          _chatMessages.add(ChatMessage(text: response, isUserMessage: false));
        });
      }
    } catch (e) {
      modalSetState(() {
        _chatMessages.add(
          const ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUserMessage: false,
          ),
        );
      });
    } finally {
      modalSetState(() {
        _isLoading = false;
      });
    }
  }

  void _openChatModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChatHeader(),
                    const SizedBox(height: 12),
                    Expanded(child: _buildMessageList()),
                    const SizedBox(height: 12),
                    _buildMessageInput(modalSetState),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset conversation when dialog closes
      _openAiService.resetConversation();
      setState(() {
        _chatMessages.clear();
      });
    });
  }

  Widget _buildChatHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Sales Assistant 🤖',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Product: ${productDetails.name}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_chatMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Hi! 👋 How can I help you today?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about the ${productDetails.name}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];
        return _ChatBubble(message: message);
      },
    );
  }

  Widget _buildMessageInput(StateSetter modalSetState) {
    return TextField(
      controller: _msgController,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: 'Ask about features, pricing, etc...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(modalSetState),
              ),
      ),
      onSubmitted: (_) => _sendMessage(modalSetState),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Salesman'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              productDetails.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              productDetails.description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                productDetails.image,
                height: 300,
                width: 300,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 300,
                    width: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '\$${productDetails.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChatModal,
        label: const Text('How can I help you?'),
        icon: const Icon(Icons.chat),
      ),
    );
  }
}

// Chat Bubble Widget
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: message.isUserMessage
              ? Colors.blue.shade100
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUserMessage
                ? const Radius.circular(4)
                : const Radius.circular(16),
            bottomLeft: message.isUserMessage
                ? const Radius.circular(16)
                : const Radius.circular(4),
          ),
        ),
        child: Text(message.text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
