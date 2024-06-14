import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async'; // For delay in typing animation
import 'constants.dart';

class AIResponseState {
  final List<String> questions;
  final List<String> aiAnswers;
  final bool isLoading;
  final bool needsUpdate;
  final String currentAnswer;

  AIResponseState({
    required this.questions,
    required this.aiAnswers,
    this.isLoading = false,
    this.needsUpdate = false,
    this.currentAnswer = '',
  });

  AIResponseState copyWith({
    List<String>? questions,
    List<String>? aiAnswers,
    bool? isLoading,
    bool? needsUpdate,
    String? currentAnswer,
  }) {
    return AIResponseState(
      questions: questions ?? this.questions,
      aiAnswers: aiAnswers ?? this.aiAnswers,
      isLoading: isLoading ?? this.isLoading,
      needsUpdate: needsUpdate ?? this.needsUpdate,
      currentAnswer: currentAnswer ?? this.currentAnswer,
    );
  }
}

class AIResponseNotifier extends StateNotifier<AIResponseState> {
  final GenerativeModel model;

  AIResponseNotifier(this.model)
      : super(AIResponseState(questions: [], aiAnswers: []));

  Future<void> fetchAIResponse(String question) async {
    state = state.copyWith(isLoading: true, currentAnswer: '');
    final content = [Content.text(question)];
    try {
      final response = await model.generateContent(content);
      final answer = response.text ?? '';
      state = state.copyWith(questions: [...state.questions, question], aiAnswers: [...state.aiAnswers, ''], isLoading: true);
      _typeAnswer(answer);
    } catch (e) {
      state = state.copyWith(isLoading: false, needsUpdate: true);
    }
  }

  void _typeAnswer(String answer) {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (state.currentAnswer.length < answer.length) {
        state = state.copyWith(currentAnswer: state.currentAnswer + answer[state.currentAnswer.length]);
      } else {
        timer.cancel();
        final updatedAnswers = [...state.aiAnswers];
        updatedAnswers[state.questions.length - 1] = state.currentAnswer;
        state = state.copyWith(aiAnswers: updatedAnswers, currentAnswer: '', isLoading: false);
      }
    });
  }
}

final aiResponseProvider = StateNotifierProvider<AIResponseNotifier, AIResponseState>((ref) {
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: Constants.apiKey);
  return AIResponseNotifier(model);
});
