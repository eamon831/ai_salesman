import 'dart:convert';

import 'package:ai_salesman/core/utils/color_print.dart';
import 'package:http/http.dart' as http;

const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

class OpenAiService {
  static const String apiEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const  model = 'gpt-3.5-turbo';
  static const  prompt = 'You are a helpful assistant.';
  static const  role = 'user';
  static const  temperature = 0.7;
  static const maxTokens = 100;
  static const  topP = 1;
  static const  frequencyPenalty = 0;
  static const  presencePenalty = 0;
  static const  stop = '["\\n\\n"]';

  Future<String?> getCompletion(String message) async {
    try {
      colorPrint('Key : $openAiApiKey');
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': prompt},
            {'role': role, 'content': message},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
          'top_p': topP,
          'frequency_penalty': frequencyPenalty,
          'presence_penalty': presencePenalty,
          'stop': stop,
        }),
      );

      colorPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        colorPrint('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e, s) {
      colorPrint('$e $s');
      return null;
    }
  }
}
