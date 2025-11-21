import 'dart:convert';

import 'package:ai_salesman/core/utils/color_print.dart';
import 'package:http/http.dart' as http;

const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

class OpenAiService {
  static const String _apiEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-3.5-turbo';
  static const double _temperature = 0.8;
  static const int _maxTokens = 300;
  static const double _topP = 1.0;
  static const double _frequencyPenalty = 0.3;
  static const double _presencePenalty = 0.3;

  final Map<String, dynamic> _productDetails;
  final List<Map<String, String>> _conversationHistory = [];

  OpenAiService({required Map<String, dynamic> productDetails})
    : _productDetails = productDetails;

  String _formatProductDetails() {
    final name = _productDetails['name'] ?? 'Unknown Product';
    final description = _productDetails['description'] ?? '';
    final price = _productDetails['price'] ?? 0;
    final specs = _productDetails['specs'] as Map<String, dynamic>?;

    final buffer = StringBuffer();
    buffer.writeln('Product: $name');
    buffer.writeln('Price: \$$price');
    buffer.writeln('');
    buffer.writeln('Description:');
    buffer.writeln(description);
    buffer.writeln('');

    if (specs != null) {
      buffer.writeln('Detailed Specifications:');

      // Storage Options
      if (specs['storageOptions'] != null) {
        final storage = (specs['storageOptions'] as List).join(', ');
        buffer.writeln('- Storage Options: $storage');
      }

      // Chip
      if (specs['chip'] != null) {
        buffer.writeln('- Processor: ${specs['chip']}');
      }

      // Display
      if (specs['display'] != null) {
        final display = specs['display'] as Map<String, dynamic>;
        buffer.writeln('- Display: ${display['size']} ${display['type']}');
        buffer.writeln('  Resolution: ${display['resolution']}');
        buffer.writeln('  Brightness: ${display['brightness']}');
      }

      // Cameras
      if (specs['cameras'] != null) {
        final cameras = specs['cameras'] as Map<String, dynamic>;
        buffer.writeln('- Rear Camera: ${cameras['rear']}');
        buffer.writeln('- Front Camera: ${cameras['front']}');
        buffer.writeln('- Video: ${cameras['video']}');
      }

      // Battery
      if (specs['battery'] != null) {
        final battery = specs['battery'] as Map<String, dynamic>;
        buffer.writeln('- Battery: ${battery['capacity']}');
        buffer.writeln('- Charging: ${battery['charging']}');
      }

      // Build
      if (specs['build'] != null) {
        final build = specs['build'] as Map<String, dynamic>;
        buffer.writeln('- Frame: ${build['frame']}');
        buffer.writeln('- Front Glass: ${build['frontGlass']}');
        buffer.writeln('- Water Resistance: ${build['waterResistance']}');
      }

      // OS and Weight
      if (specs['os'] != null) {
        buffer.writeln('- Operating System: ${specs['os']}');
      }
      if (specs['weight'] != null) {
        buffer.writeln('- Weight: ${specs['weight']}');
      }
    }

    return buffer.toString();
  }

  String _buildSystemPrompt() {
    return '''You are an expert, enthusiastic, and knowledgeable AI salesman. Your goal is to help customers understand the product, answer their questions, and guide them toward making a purchase decision.

${_formatProductDetails()}

Your Approach:
1. Be friendly, conversational, and genuinely helpful
2. Ask clarifying questions to understand the customer's needs
3. Highlight features that match their specific requirements
4. Address concerns with honest, helpful information
5. Use persuasive language without being pushy
6. Share relevant comparisons when asked
7. Create urgency naturally (limited stock, special offers)
8. Guide toward closing the sale when appropriate
9. Keep responses concise and engaging (2-4 sentences usually)
10. Use emojis occasionally to seem approachable 😊

Sales Techniques:
- Build rapport and trust first
- Listen to pain points and offer solutions
- Use social proof ("This is our best-selling model")
- Emphasize value, not just features
- Handle objections professionally (price, competition, timing)
- Use assumptive closing ("Which storage size works best for you?")
- Highlight the key benefits that solve customer problems

Key Benefits to Emphasize:
- Performance: Powerful processor for smooth multitasking
- Camera: Capture professional-quality photos and videos
- Durability: Built to last with premium materials
- Battery: All-day power with fast charging
- Ecosystem: Seamless integration with other devices
- Value: Long-term investment in quality

Remember: You're here to help the customer find the right solution, not just make a sale. Build trust and provide genuine value. Always relate features to real-world benefits.''';
  }

  Future<String?> getCompletion(String message) async {
    try {
      // Add user message to history
      _conversationHistory.add({'role': 'user', 'content': message});

      // Build messages array with system prompt and conversation history
      final messages = [
        {'role': 'system', 'content': _buildSystemPrompt()},
        ..._conversationHistory,
      ];

      colorPrint('Sending request to OpenAI...');

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': _temperature,
          'max_tokens': _maxTokens,
          'top_p': _topP,
          'frequency_penalty': _frequencyPenalty,
          'presence_penalty': _presencePenalty,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage =
            data['choices'][0]['message']['content'] as String;

        // Add assistant response to history
        _conversationHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        colorPrint('✓ Success: Got response from AI salesman');
        return assistantMessage;
      } else if (response.statusCode == 401) {
        colorPrint('✗ Error: Invalid API key');
        return 'Sorry, there seems to be an authentication issue. Please check the API configuration.';
      } else if (response.statusCode == 429) {
        colorPrint('✗ Error: Rate limit exceeded');
        return 'I\'m getting too many requests right now. Please try again in a moment.';
      } else {
        colorPrint('✗ Request failed with status: ${response.statusCode}');
        colorPrint('Response: ${response.body}');
        return 'I\'m having trouble connecting right now. Please try again.';
      }
    } catch (e, s) {
      colorPrint('✗ Exception occurred: $e');
      colorPrint('Stack trace: $s');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  /// Reset conversation history
  void resetConversation() {
    _conversationHistory.clear();
    colorPrint('Conversation history cleared');
  }

  /// Get conversation history length
  int get conversationLength => _conversationHistory.length;

  /// Check if conversation has started
  bool get hasConversation => _conversationHistory.isNotEmpty;
}
