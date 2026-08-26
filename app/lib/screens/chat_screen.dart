import 'package:flutter/material.dart';
import '../services/app_state.dart';

class ChatScreen extends StatefulWidget {
  final String? prefilledPrompt;

  const ChatScreen({super.key, this.prefilledPrompt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isVoiceRecording = false;

  final List<String> _suggestedPrompts = [
    'Why is my field health decreasing?',
    'Is the weather suitable for spraying?',
    'What is the problem in Zone 2?',
    'Explain the latest drone report.',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add({
      'isUser': false,
      'text': 'Hello! I am your AgriSwarm AI Farm Intelligence Companion. I see you are farming Cotton and Tomato in Wardha.\n\nAsk me about health decreases, spraying windows, or how to resolve moisture alerts.',
    });

    if (widget.prefilledPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.prefilledPrompt!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(appState.translate('ai_assistant')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Active Context Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green.shade50,
            child: Row(
              children: [
                Icon(Icons.psychology_outlined, color: Colors.green.shade800, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Connected Context: Field A (Cotton), Field B (Tomato)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),

          // Messages View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isUser = msg['isUser'] as bool;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green.shade700 : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                      border: isUser ? null : Border.all(color: Colors.grey.shade200),
                      boxShadow: isUser
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Prepopulated Suggestions
          if (_messages.length == 1)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestedPrompts.length,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                    child: ActionChip(
                      label: Text(_suggestedPrompts[idx], style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.green.shade200),
                      onPressed: () {
                        _handleSendMessage(_suggestedPrompts[idx]);
                      },
                    ),
                  );
                },
              ),
            ),

          // Input Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Simulated voice recognition trigger
                IconButton(
                  icon: Icon(
                    _isVoiceRecording ? Icons.mic : Icons.mic_none,
                    color: _isVoiceRecording ? Colors.red : Colors.green.shade700,
                  ),
                  onPressed: () => _triggerVoiceSimulation(appState),
                  tooltip: 'Voice Command',
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Ask AgriSwarm Assistant...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        _handleSendMessage(v);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green.shade700),
                  onPressed: () {
                    final text = _inputController.text.trim();
                    if (text.isNotEmpty) {
                      _handleSendMessage(text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage(String text) {
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _inputController.clear();
    });
    _scrollToBottom();

    // AI thinking effect
    Future.delayed(const Duration(milliseconds: 600), () {
      final answer = _generateAIResponse(text);
      if (mounted) {
        setState(() {
          _messages.add({'isUser': false, 'text': answer});
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateAIResponse(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('health') || lower.contains('field a') || lower.contains('decreasing')) {
      return 'Field A (Cotton) health score decreased to 78/100 (down 6 points) because soil moisture fell to 27% in Zone 2. Let\'s record an irrigation action in Zone 2 to restore health.';
    }
    if (lower.contains('weather') || lower.contains('spraying') || lower.contains('suitable')) {
      return 'Today\'s spraying condition is GOOD because wind speed is 8 km/h and rain probability is only 10%. Tomorrow is AVOID because rain is expected (75% probability).';
    }
    if (lower.contains('zone 2') || lower.contains('moisture') || lower.contains('problem')) {
      return 'Zone 2 of Field A shows "Low Moisture" at 27% (Normal is 35-60%). The recommended action is to checked irrigation in Zone 2 immediately and log it.';
    }
    if (lower.contains('report') || lower.contains('explain')) {
      return 'The latest report for Field A shows soil moisture at 27% in Zone 2, and possible leaf blight warnings in Field B Zone 2. All recommendations have been compiled under the Fields dashboard.';
    }
    if (lower.contains('blight') || lower.contains('tomato')) {
      return 'Possible tomato disease early blight detected in Field B Zone 2. Early blight causes target-like dark concentric circles on leaves. Treatment: Spray copper fungicide on affected areas. Consult product labels.';
    }
    if (lower.contains('khet') || lower.contains('problem') || lower.contains('mere')) {
      return 'Zone 2 of Field A has soil moisture at 27% (LOW). Irrigation check are recommended. (ज़ोन २ में नमी कम है, कृपया सिंचाई की जांच करें।)';
    }

    return 'I am your AgriSwarm AI Assistant. I monitor your fields (Cotton, Tomato, Wheat) and weather. Ask me: "Why is field health decreasing?" or "Is spraying suitable today?"';
  }

  void _triggerVoiceSimulation(AppState appState) {
    setState(() {
      _isVoiceRecording = true;
    });

    // Mock speaking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice input listening... speak now.')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVoiceRecording = false;
        });
        
        // Populate standard farmer voice query
        String voiceText = 'Mere khet mein kya problem hai?';
        if (appState.currentLanguage == 'en') {
          voiceText = 'Why is my field health decreasing?';
        }
        
        _handleSendMessage(voiceText);
      }
    });
  }
}
