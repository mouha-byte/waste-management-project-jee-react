import 'package:flutter/material.dart';
import 'package:ecoguide/utils/app_theme.dart';

class AIAssistantChat extends StatefulWidget {
  const AIAssistantChat({super.key});

  @override
  State<AIAssistantChat> createState() => _AIAssistantChatState();
}

class _AIAssistantChatState extends State<AIAssistantChat> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimController;

  final List<Map<String, dynamic>> _quickActions = [
    {'label': '🗺️ Découvrir les sites', 'query': 'Quels sites me recommandes-tu ?'},
    {'label': '🥾 Planifier une randonnée', 'query': 'Je veux planifier une randonnée'},
    {'label': '🌱 Impact écologique', 'query': 'Comment réduire mon impact ?'},
    {'label': '🦋 Faune locale', 'query': 'Quels animaux puis-je observer ?'},
    {'label': '📍 Près de moi', 'query': 'Quels sites sont proches de ma position ?'},
    {'label': '☀️ Météo aujourd\'hui', 'query': 'Quel temps fait-il pour une sortie ?'},
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    
    // Initial greeting with delay for effect
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text': 'Bonjour ! 👋\n\nJe suis votre guide EcoGuide intelligent. Je peux vous aider à :\n\n• Découvrir des sites naturels\n• Planifier des itinéraires éco-responsables\n• Calculer votre empreinte carbone\n• Donner des conseils sur la faune et la flore\n\nQue souhaitez-vous explorer aujourd\'hui ?',
            'timestamp': DateTime.now(),
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _typingAnimController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': text,
        'timestamp': DateTime.now(),
      });
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Simulate AI thinking with variable delay
    await Future.delayed(Duration(milliseconds: 800 + (text.length * 20).clamp(0, 1500)));

    String response = _getEnhancedAIResponse(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'ai',
          'text': response,
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
    }
  }

  String _getEnhancedAIResponse(String input) {
    final lower = input.toLowerCase();
    
    // Site discovery
    if (lower.contains('site') || lower.contains('découvrir') || lower.contains('recommand') || lower.contains('visiter')) {
      return '🏞️ **Sites recommandés pour vous :**\n\n'
          '1. **Parc National de Chréa** - Forêts de cèdres et ski en hiver\n'
          '2. **Jardin d\'Essai du Hamma** - Biodiversité exceptionnelle en ville\n'
          '3. **Réserve de Mergueb** - Gazelles et faune saharienne\n\n'
          '💡 Astuce : Visitez tôt le matin pour observer la faune active !';
    }
    
    // Hiking/Itinerary
    if (lower.contains('randonnée') || lower.contains('itinéraire') || lower.contains('marche') || lower.contains('planifier')) {
      return '🥾 **Randonnées populaires :**\n\n'
          '• **Sentier des Cèdres** (Chréa) - 8km, difficulté modérée\n'
          '• **Tour du Lac** (Béni Haroun) - 5km, facile\n'
          '• **Crête de l\'Atlas** - 12km, difficile\n\n'
          '📱 Utilisez l\'onglet "Parcours" pour naviguer en temps réel avec GPS !';
    }
    
    // Ecological impact
    if (lower.contains('impact') || lower.contains('carbone') || lower.contains('écolog') || lower.contains('réduire')) {
      return '🌱 **Conseils éco-responsables :**\n\n'
          '• Privilégiez la marche ou le vélo (0 émission !)\n'
          '• Covoiturez pour les sites éloignés\n'
          '• Apportez une gourde réutilisable\n'
          '• Ne cueillez pas de plantes\n\n'
          '📊 Votre score éco actuel : **85/100** - Excellent !';
    }
    
    // Wildlife
    if (lower.contains('animal') || lower.contains('faune') || lower.contains('observer') || lower.contains('oiseau')) {
      return '🦋 **Faune à observer :**\n\n'
          '**Oiseaux** : Aigle royal, Cigogne blanche, Flamant rose\n'
          '**Mammifères** : Gazelle dorcas, Fennec, Sanglier\n'
          '**Reptiles** : Tortue mauresque, Caméléon\n\n'
          '🔭 Meilleur moment : Lever et coucher du soleil\n'
          '📸 N\'oubliez pas vos jumelles !';
    }
    
    // Location-based
    if (lower.contains('proche') || lower.contains('position') || lower.contains('près')) {
      return '📍 **Sites à proximité :**\n\n'
          'Basé sur votre position, voici les sites les plus proches :\n\n'
          '1. Jardin d\'Essai (2.3 km)\n'
          '2. Forêt de Baïnem (8.5 km)\n'
          '3. Parc de Dounia (12 km)\n\n'
          '🚶 Le Jardin d\'Essai est accessible à pied !';
    }
    
    // Weather
    if (lower.contains('météo') || lower.contains('temps') || lower.contains('sortie')) {
      return '☀️ **Conditions actuelles :**\n\n'
          '• Température : 22°C\n'
          '• Ciel : Ensoleillé\n'
          '• Vent : 12 km/h\n\n'
          '✅ Conditions idéales pour une sortie nature !\n'
          '💧 N\'oubliez pas l\'eau et la protection solaire.';
    }
    
    // Greetings
    if (lower.contains('bonjour') || lower.contains('salut') || lower.contains('hello')) {
      return 'Bonjour ! 😊\n\nRavi de vous revoir ! Comment puis-je vous aider aujourd\'hui ?\n\nVous pouvez me demander des recommandations de sites, des conseils de randonnée, ou des informations sur la faune locale.';
    }
    
    // Thanks
    if (lower.contains('merci') || lower.contains('thanks')) {
      return 'Avec plaisir ! 🌿\n\nN\'hésitez pas si vous avez d\'autres questions. Bonne exploration éco-responsable !';
    }
    
    // Help
    if (lower.contains('aide') || lower.contains('help') || lower.contains('quoi faire')) {
      return '🆘 **Je peux vous aider avec :**\n\n'
          '• 🗺️ Découverte de sites naturels\n'
          '• 🥾 Planification d\'itinéraires\n'
          '• 🌱 Conseils écologiques\n'
          '• 🦋 Information sur la faune/flore\n'
          '• 📍 Sites à proximité\n'
          '• ☀️ Conditions météo\n\n'
          'Posez-moi une question ou utilisez les suggestions rapides !';
    }
    
    // Default
    return '🤔 Je comprends votre question.\n\n'
        'Pour mieux vous aider, essayez de me demander :\n'
        '• Des recommandations de sites\n'
        '• Des conseils de randonnée\n'
        '• Des informations sur la faune\n\n'
        'Ou utilisez les suggestions rapides ci-dessous !';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assistant EcoGuide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Votre guide intelligent',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                    SizedBox(width: 4),
                    Text('En ligne', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Chat Area
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_messages.length <= 1 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                } else {
                  return _buildQuickActionsGrid();
                }
              },
            ),
          ),
        ),

        // Typing Indicator
        if (_isTyping)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                _buildTypingDots(),
                const SizedBox(width: 12),
                Text(
                  'L\'assistant réfléchit...',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),

        // Input Area
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Posez votre question...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400, size: 20),
                      ),
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () => _sendMessage(_controller.text),
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingDots() {
    return Row(
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _typingAnimController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(
                  0.3 + (_typingAnimController.value * 0.7 * (i == 1 ? 1 : 0.5)),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isAi = msg['role'] == 'ai';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.eco, color: AppTheme.primaryGreen, size: 18),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAi ? Colors.white : AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isAi ? 4 : 18),
                  bottomRight: Radius.circular(isAi ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg['text'],
                style: TextStyle(
                  color: isAi ? Colors.black87 : Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isAi) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Suggestions rapides',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickActions.map((action) {
            return InkWell(
              onTap: () => _sendMessage(action['query']),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Text(
                  action['label'],
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
