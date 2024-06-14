import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'constants.dart';

class AIResponseState {
  final List<String> questions;
  final List<String> aiAnswers;
  final bool isLoading;
  final bool needsUpdate;

  AIResponseState({
    required this.questions,
    required this.aiAnswers,
    this.isLoading = false,
    this.needsUpdate = false,
  });

  AIResponseState copyWith({
    List<String>? questions,
    List<String>? aiAnswers,
    bool? isLoading,
    bool? needsUpdate,
  }) {
    return AIResponseState(
      questions: questions ?? this.questions,
      aiAnswers: aiAnswers ?? this.aiAnswers,
      isLoading: isLoading ?? this.isLoading,
      needsUpdate: needsUpdate ?? this.needsUpdate,
    );
  }
}

class AIResponseNotifier extends StateNotifier<AIResponseState> {
  final GenerativeModel model;

  AIResponseNotifier(this.model)
      : super(AIResponseState(questions: [], aiAnswers: []));

  Future<void> fetchAIResponse(String question) async {
    state = state.copyWith(isLoading: true);
    final content = [Content.text(question)];
    try {
      final response = await model.generateContent(content);
      state = state.copyWith(
        questions: [...state.questions, question],
        aiAnswers: [...state.aiAnswers, response.text!],
        isLoading: false,
        needsUpdate: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        needsUpdate: true,
      );
    }
  }
}

final aiResponseProvider =
StateNotifierProvider<AIResponseNotifier, AIResponseState>((ref) {
  final model = GenerativeModel(model: 'gemini-pro', apiKey: Constants.apiKey);
  return AIResponseNotifier(model);
});
