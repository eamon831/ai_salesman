class OpenAiService {
  static const String apiKey = 'sk-';
  static const String apiEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String model = 'gpt-3.5-turbo';
  static const String prompt = 'You are a helpful assistant.';
  static const String role = 'user';
  static const String temperature = '0.7';
  static const String maxTokens = '100';
  static const String topP = '1';
  static const String frequencyPenalty = '0';
  static const String presencePenalty = '0';
  static const String stop = '["\\n\\n"]';
}
