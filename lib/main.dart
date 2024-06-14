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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final notifier = ref.read(aiResponseProvider.notifier);
    notifier.fetchAIResponse(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiResponseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My AppBar'),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
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
                        hintText: "Input Text",
                      ),
                    ),
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
                    itemCount: state.questions.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.questions.length) {
                        return state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }
                      return Card(
                        child: ListTile(
                          title: Text(state.questions[index]),
                          subtitle: Text(state.aiAnswers[index]),
                        ),
                      );


                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextBox extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;

  const CustomTextBox({
    super.key,
    required this.textEditingController,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.green.withOpacity(0.5)),
        border: const OutlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.solid, color: Colors.blue),
        ),
      ),
    );
  }
}