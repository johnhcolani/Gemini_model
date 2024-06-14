import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_response_notifier.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AI Response Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _maxLines = 1;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        _maxLines = controller.text.split('\n').length;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final notifier = ref.read(aiResponseProvider.notifier);
    notifier.fetchAIResponse(controller.text);
    controller.clear();
    setState(() {
      _maxLines = 1;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiResponseProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.isLoading || state.currentAnswer.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
            height: 60,
            child: Image.asset('images/img.png', fit: BoxFit.contain)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'images/background.gif', // Replace with your image path
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (state.needsUpdate)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.red,
                      child: const Text(
                        'Please update the AI model',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextBox(
                          textEditingController: controller,
                          hintText: "Enter your question...",
                          enabled: !state.isLoading,
                          maxLines: _maxLines,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: controller.text.isEmpty ? null : _handleSubmit,
                        icon: controller.text.isEmpty
                            ? const Icon(Icons.pause, color: Colors.white)
                            : const Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.questions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                color: Colors.blueGrey[900]?.withOpacity(0.7),
                                child: ListTile(
                                  title: Text(
                                    'Q: ${state.questions[index]}',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                              Card(
                                color: Colors.blueGrey[800]?.withOpacity(0.7),
                                child: ListTile(
                                  title: Text(
                                    'A: ${index == state.questions.length - 1 && state.isLoading ? state.currentAnswer : state.aiAnswers[index]}',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextBox extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool enabled;
  final int maxLines;

  const CustomTextBox({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      controller: textEditingController,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white24,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
