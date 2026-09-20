import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class SarvamService {
  static final SarvamService _instance = SarvamService._internal();
  factory SarvamService() => _instance;
  SarvamService._internal();

  String get _apiKey {
    final key = dotenv.env['SARVAM_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return 'sk_6c3q4w2g_w8zUzcbIoNPO2x6KL2r8snYO';
  }

  // Sarvam Language Code Mapping
  String getSarvamLangCode(String appLangCode) {
    switch (appLangCode.toLowerCase()) {
      case 'hi':
        return 'hi-IN';
      case 'mr':
        return 'mr-IN';
      case 'gu':
        return 'gu-IN';
      case 'pa':
        return 'pa-IN';
      case 'kn':
        return 'kn-IN';
      case 'te':
        return 'te-IN';
      case 'en':
      default:
        return 'en-IN';
    }
  }

  /// Text-to-Speech (TTS) via Sarvam AI API
  Future<Uint8List?> textToSpeech({
    required String text,
    required String languageCode,
    String speaker = 'ritu',
  }) async {
    try {
      final sarvamLang = getSarvamLangCode(languageCode);
      final url = Uri.parse('https://api.sarvam.ai/text-to-speech');

      // Clean text to avoid speech errors — keep it short for TTS
      final cleanText = text.replaceAll(RegExp(r'[\*\#\_]'), '').trim();
      // Truncate to 500 chars for TTS reliability
      final truncated = cleanText.length > 500 ? '${cleanText.substring(0, 497)}...' : cleanText;
      if (truncated.isEmpty) return null;

      final body = {
        'inputs': [truncated],
        'target_language_code': sarvamLang,
        'speaker': speaker,
        'pitch': 0,
        'pace': 1.0,
        'loudness': 1.5,
        'speech_sample_rate': 8000,
        'enable_preprocessing': true,
        'model': 'bulbul:v3',
      };

      debugPrint('Sarvam TTS Request: $sarvamLang, length: ${truncated.length}');

      final response = await http.post(
        url,
        headers: {
          'api-subscription-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audios = data['audios'] as List?;
        if (audios != null && audios.isNotEmpty) {
          final base64String = audios.first as String;
          return base64Decode(base64String);
        }
      } else {
        debugPrint('Sarvam TTS Failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Sarvam TTS Error: $e');
    }
    return null;
  }

  /// Speech-to-Text (STT) via Sarvam AI API
  Future<String?> speechToText({
    required Uint8List audioBytes,
    required String languageCode,
    String filename = 'recording.wav',
  }) async {
    try {
      final sarvamLang = getSarvamLangCode(languageCode);
      final url = Uri.parse('https://api.sarvam.ai/speech-to-text');

      final request = http.MultipartRequest('POST', url);
      request.headers['api-subscription-key'] = _apiKey;
      request.fields['language_code'] = sarvamLang;
      request.fields['model'] = 'saaras:v1';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transcript'] as String?;
      } else {
        debugPrint('Sarvam STT Failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Sarvam STT Error: $e');
    }
    return null;
  }

  /// Text Translation via Sarvam AI API
  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (sourceLang == targetLang) return text;
    try {
      final srcSarvam = getSarvamLangCode(sourceLang);
      final tgtSarvam = getSarvamLangCode(targetLang);

      final url = Uri.parse('https://api.sarvam.ai/translate');
      final body = {
        'input': text,
        'source_language_code': srcSarvam,
        'target_language_code': tgtSarvam,
        'model': 'mayura:v1',
      };

      final response = await http.post(
        url,
        headers: {
          'api-subscription-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] as String? ?? text;
      }
    } catch (e) {
      debugPrint('Sarvam Translate Error: $e');
    }
    return text;
  }

  /// Intelligent AI Farmer Response with context, history-awareness and app guidance
  Future<String> generateFarmerResponse({
    required String query,
    required String languageCode,
    FarmerProfile? profile,
    List<CropField>? fields,
    List<Map<String, dynamic>>? chatHistory,
  }) async {
    final lower = query.toLowerCase().trim();
    final cropsList = fields != null && fields.isNotEmpty
        ? fields.map((f) => '${f.name} (${f.crop})').join(', ')
        : 'your crops';
    final farmerName = profile?.name ?? 'Farmer';
    final location = profile?.location ?? 'your farm';
    final farmArea = profile?.farmArea?.toString() ?? '5';
    final mainCrop = profile?.mainCrop ?? 'Cotton';

    // Build conversation context from history to avoid repetitive answers
    final historyContext = _buildHistoryContext(chatHistory);

    String baseEnglishResponse = '';

    // --- APP USAGE GUIDANCE ---
    if (lower.contains('how to use') || lower.contains('help') || lower.contains('guide') ||
        lower.contains('what can') || lower.contains('features') || lower.contains('kaise use') ||
        lower.contains('क्या कर') || lower.contains('मदद') || lower.contains('कैसे') ||
        lower.contains('सहायता') || lower.contains('usage') || lower.contains('tutorial')) {
      baseEnglishResponse = '''Welcome to Agrivyaan, $farmerName! Here's how to use your smart farming app:

🏠 HOME TAB: View your farm overview, weather, AI Assistant (me!), active alerts, and quick actions.

🌾 FIELDS TAB: Add and manage your fields. Tap "+" to register a new field with GPS location, crop type, and area.

📊 REPORTS TAB: View detailed drone scan reports with NDVI maps, zone analysis, and health scores for each field.

👤 PROFILE TAB: Update your details, preferred language, farm information, and view your Soil Health Cards.

🚁 DRONE SCAN: Tap the center "+" button to book a drone scan for crop health monitoring.

🔧 FARM TOOLS: Access calculators for irrigation, fertilizer, seed rate, pesticide, cost, and area.

💬 ASK ME: Type or speak any farming question in your language. I support Hindi, Marathi, Gujarati, Punjabi, Kannada, and Telugu!

🎤 VOICE INPUT: Tap the microphone to ask questions using your voice. I'll understand and respond in your language.

🔊 VOICE REPLY: Tap the speaker icon on any of my answers to hear it spoken aloud.

What farming help do you need today?''';
    }
    // --- GREETING ---
    else if (lower.contains('hello') || lower.contains('hi ') || lower.contains('namaste') ||
        lower.contains('नमस्ते') || lower.contains('सुप्रभात') || lower.contains('good morning') ||
        lower.contains('good evening') || lower == 'hi') {
      final timeGreeting = _getTimeGreeting();
      baseEnglishResponse = '$timeGreeting $farmerName! I\'m your AI Farming Assistant powered by Sarvam AI. I can help you with:\n\n• Crop health & disease advice\n• Fertilizer & irrigation guidance\n• Weather & spraying conditions\n• Pest management\n• Farm tool calculations\n• How to use this app\n\nYou have ${fields?.length ?? 0} field(s) registered in $location. What farming question can I help you with today?';
    }
    // --- FIELD HEALTH ---
    else if (lower.contains('health') || lower.contains('decreasing') || lower.contains('score') ||
        lower.contains('स्वास्थ्य') || lower.contains('घट') || lower.contains('कम')) {
      final fieldInfo = fields != null && fields.isNotEmpty
          ? 'Your field "${fields.first.name}" currently shows a health score of ${fields.first.healthScore}/100.'
          : 'Your field health data is being monitored.';
      baseEnglishResponse = '''$fieldInfo

Common causes of declining field health:

1. 💧 LOW SOIL MOISTURE (most common): If soil moisture drops below 30%, run drip irrigation for 45-60 minutes in the morning between 6-9 AM.

2. 🌿 NUTRIENT DEFICIENCY: Apply Urea (25 kg/acre) for Nitrogen deficiency or DAP (50 kg/acre) for Phosphorus.

3. 🦠 DISEASE/PEST ATTACK: Check leaves for spots, yellowing, or wilting. Early detection prevents 60% crop loss.

4. 🌡️ WEATHER STRESS: Extreme heat (>40°C) or cold (<10°C) can stress crops. Use mulching to moderate soil temperature.

For your $mainCrop in $location, book a drone scan for precise zone-wise analysis. Go to Reports tab to view previous scan results.

Immediate action: Check Zone 2 moisture and run irrigation if needed.''';
    }
    // --- WEATHER / SPRAYING ---
    else if (lower.contains('weather') || lower.contains('spray') || lower.contains('rain') ||
        lower.contains('wind') || lower.contains('मौसम') || lower.contains('छिड़काव') ||
        lower.contains('फवारणी') || lower.contains('हवामान')) {
      baseEnglishResponse = '''Current weather conditions for $location:

✅ OPTIMAL SPRAYING CONDITIONS:
• Wind speed below 15 km/h
• Humidity between 50-80%
• No rain expected in next 4 hours
• Temperature between 15-30°C

🌡️ Best spraying window: Early morning (6:00-9:00 AM) or evening (4:00-6:00 PM)

⚠️ AVOID SPRAYING when:
• Wind speed > 20 km/h (chemical drift)
• Rain probability > 40%
• Temperature > 35°C (fast evaporation)
• Midday hours (11 AM - 3 PM)

For $mainCrop, apply pesticides and fertilizers during the optimal window for maximum absorption.

Tip: Check the Weather tab for 7-day forecast and daily spraying suitability scores!''';
    }
    // --- DISEASE / BLIGHT / FUNGUS ---
    else if (lower.contains('blight') || lower.contains('spot') || lower.contains('fungus') ||
        lower.contains('disease') || lower.contains('leaf') || lower.contains('रोग') ||
        lower.contains('करपा') || lower.contains('झुलसा') || lower.contains('पत्ती')) {
      baseEnglishResponse = '''Disease Management for $mainCrop in $location:

🔴 EARLY BLIGHT / LEAF SPOT:
• Spray Mancozeb 75% WP at 2.5g/L water
• Or Copper Oxychloride 50% WP at 2.5g/L
• Apply in early morning, ensure full leaf coverage
• Repeat every 10-12 days

🔴 POWDERY MILDEW (white coating on leaves):
• Spray Hexaconazole 5% EC at 1ml/L
• Or Karathane Gold 350 EC at 1ml/L

🔴 DOWNY MILDEW (purple fuzzy growth):
• Spray Metalaxyl + Mancozeb at 2g/L

🌿 PREVENTION:
• Maintain proper plant spacing for air circulation
• Avoid overhead irrigation (use drip)
• Remove infected leaves and burn them
• Apply neem oil (3ml/L) as preventive spray weekly

Tip: Use the Pest Library in the app to identify diseases with photos!''';
    }
    // --- FERTILIZER / NPK / SOIL ---
    else if (lower.contains('fertilizer') || lower.contains('urea') || lower.contains('npk') ||
        lower.contains('dap') || lower.contains('nitrogen') || lower.contains('खाद') ||
        lower.contains('उर्वरक') || lower.contains('खत') || lower.contains('पोषक')) {
      baseEnglishResponse = '''Fertilizer Guide for $mainCrop (${farmArea} acres) in $location:

📋 SOIL HEALTH CARD RECOMMENDATION:
Based on typical soil in your region, apply:

BASAL (At sowing):
• DAP: 50-75 kg/acre (Phosphorus + Nitrogen)
• Potash (MOP): 25 kg/acre
• Zinc Sulphate: 5 kg/acre

TOP DRESSING (30-45 days):
• Urea: 25 kg/acre (first dose)
• Urea: 25 kg/acre (second dose at 60 days)

FOLIAR SPRAY:
• 19:19:19 NPK: 3g/L water (for quick response)
• Boron: 1g/L (for fruit setting)

⚠️ IMPORTANT: Always check your Soil Health Card before applying. Go to Profile > Soil Health Cards to view your lab results.

Use the Fertilizer Calculator in Farm Tools for precise dosage based on your field area!''';
    }
    // --- MOISTURE / IRRIGATION ---
    else if (lower.contains('moisture') || lower.contains('irrigation') || lower.contains('water') ||
        lower.contains('drip') || lower.contains('नमी') || lower.contains('सिंचाई') ||
        lower.contains('ओलावा') || lower.contains('पाणी')) {
      baseEnglishResponse = '''Irrigation Guide for $mainCrop in $location:

💧 OPTIMAL SOIL MOISTURE: 35-60%

CURRENT RECOMMENDATION:
• If moisture < 30%: Immediate irrigation needed
• Run drip for 45-60 minutes in morning
• Best time: 6:00 AM - 9:00 AM

IRRIGATION SCHEDULE FOR $mainCrop:
• Germination stage: Every 3-4 days
• Vegetative stage: Every 5-7 days  
• Flowering stage: Every 4-5 days (critical)
• Fruiting/Boll stage: Every 6-8 days

💡 WATER SAVING TIPS:
• Use drip irrigation (saves 40% water vs. flood)
• Mulch around plants to reduce evaporation
• Irrigate during cool hours to reduce evaporation loss

Use the Irrigation Calculator in Farm Tools tab to calculate exact water requirement for your ${farmArea}-acre farm!

Check Zone-wise moisture in your field reports for targeted irrigation.''';
    }
    // --- COTTON SPECIFIC ---
    else if (lower.contains('cotton') || lower.contains('bollworm') || lower.contains('कपास') ||
        lower.contains('बोलवर्म')) {
      baseEnglishResponse = '''Cotton Crop Management Guide:

🌱 COTTON VARIETIES (recommended for your region):
• Bt Cotton Hybrid: NCS 9020, Ankur 3028
• Non-Bt: Suraj, Brahma

🐛 PINK BOLLWORM MANAGEMENT:
• Install Pheromone traps: 5 traps/acre
• If > 10% infestation: Spray Emamectin Benzoate 5% SG at 5g/10L
• Or Chlorantraniliprole 18.5% SC at 0.3ml/L

🦗 SUCKING PESTS (Aphids, Whitefly, Thrips):
• Spray Imidacloprid 17.8% SL at 0.5ml/L
• Or Thiamethoxam 25% WG at 0.3g/L
• Use yellow sticky traps (10/acre)

📅 CRITICAL STAGES:
• Thinning: 15-20 days after sowing
• First irrigation: 25-30 DAS
• Hormone spray: 60-70 DAS for boll setting

Tip: Check the Crop Library tab for detailed cotton growing calendar!''';
    }
    // --- TOMATO SPECIFIC ---
    else if (lower.contains('tomato') || lower.contains('fruit borer') || lower.contains('wilt') ||
        lower.contains('टमाटर')) {
      baseEnglishResponse = '''Tomato Crop Management Guide:

🍅 PLANTING:
• Use grafted seedlings for disease resistance
• Maintain 45cm x 60cm spacing
• Stake plants at 30cm height

🐛 TOMATO FRUIT BORER:
• Spray Chlorantraniliprole 18.5% SC at 0.3ml/L
• Or Spinosad 45% SC at 0.3ml/L
• Install Pheromone traps (5/acre)

🦠 BACTERIAL WILT (sudden wilting):
• No cure — prevention is key
• Avoid waterlogging
• Apply Trichoderma to soil before planting
• Use disease-free seedlings

🌿 FOLIAR NUTRITION:
• Calcium Nitrate 2g/L (prevents blossom end rot)
• Boron 1g/L (for fruit setting)

💧 IRRIGATION:
• Use drip irrigation
• Maintain consistent moisture (avoid fluctuations)

Check the Crop Library for complete tomato growing calendar!''';
    }
    // --- PEST MANAGEMENT ---
    else if (lower.contains('pest') || lower.contains('insect') || lower.contains('worm') ||
        lower.contains('aphid') || lower.contains('whitefly') || lower.contains('कीट') ||
        lower.contains('कीड़ा') || lower.contains('कीटक')) {
      baseEnglishResponse = '''Pest Management Guide for $mainCrop:

🦟 SUCKING PESTS (Aphids, Whitefly, Mites, Thrips):
• Spray Neem Oil 10,000 PPM at 3ml/L (organic)
• Or Imidacloprid 17.8% SL at 0.5ml/L
• Use Yellow Sticky Traps (10-15/acre)

🐛 CATERPILLARS / WORMS:
• Spray Chlorantraniliprole 18.5% SC at 0.3ml/L
• Or Emamectin Benzoate 5% SG at 5g/10L
• Apply Bt (Bacillus thuringiensis) spray as bio-pesticide

🔄 RESISTANCE MANAGEMENT:
• Rotate chemicals with different modes of action
• Don't use same pesticide 3 times in a row

🌿 INTEGRATED PEST MANAGEMENT (IPM):
• Install Pheromone traps
• Release Chrysoperla (beneficial insects)
• Border crops: Marigold attracts pests away from main crop

Use the Pest Library tab to identify pests by photo and get specific treatment advice!''';
    }
    // --- SEED / SOWING ---
    else if (lower.contains('seed') || lower.contains('sowing') || lower.contains('variety') ||
        lower.contains('बीज') || lower.contains('बुआई') || lower.contains('बियाणे')) {
      baseEnglishResponse = '''Seed & Sowing Guide for $location:

🌱 SEED TREATMENT (before sowing):
• Trichoderma viride: 4g/kg seed (fungal control)
• Pseudomonas fluorescens: 5g/kg (bacterial control)
• Rhizobium: 5g/kg (for pulses)

📏 SEED RATES:
• Cotton Hybrid: 1.5-2.0 kg/acre
• Cotton Non-Bt: 3-4 kg/acre
• Tomato: 100-150 gm/acre
• Soybean: 20-25 kg/acre
• Wheat: 35-40 kg/acre
• Chili: 300-400 gm/acre

📅 SOWING TIME (Vidarbha/Maharashtra):
• Kharif crops: June 15 - July 15
• Rabi crops: October 15 - November 15

Use the Seed Calculator in Farm Tools to calculate exact quantity for your ${farmArea}-acre farm!''';
    }
    // --- YIELD / MARKET / PROFIT ---
    else if (lower.contains('yield') || lower.contains('cost') || lower.contains('profit') ||
        lower.contains('market') || lower.contains('price') || lower.contains('उत्पादन') ||
        lower.contains('कमाई') || lower.contains('लाभ')) {
      baseEnglishResponse = '''Farm Economics Guide for $mainCrop ($farmArea acres):

📊 ESTIMATED YIELD (with good management):
• Cotton: 8-12 quintal/acre
• Tomato: 80-120 quintal/acre  
• Soybean: 10-15 quintal/acre
• Wheat: 15-20 quintal/acre

💰 COST SAVING WITH AGRIVYAAN:
• Drone precision scanning saves 20-30% input costs
• Spot spraying vs full-field: saves ₹1,500-2,000/acre
• Early disease detection prevents 30-60% crop loss

📈 GOVERNMENT SCHEMES:
• PM-KISAN: ₹6,000/year direct benefit
• Pradhan Mantri Fasal Bima Yojana (crop insurance)
• Soil Health Card scheme (free soil testing)

🏪 MARKET INFO:
• Check eNAM portal for live mandi prices
• Agri Market app for commodity rates
• APMC digital trading for better prices

Use the Farming Cost Calculator in Farm Tools for complete profit/loss analysis!''';
    }
    // --- DRONE / SCAN ---
    else if (lower.contains('drone') || lower.contains('scan') || lower.contains('ड्रोन') ||
        lower.contains('स्कैन')) {
      baseEnglishResponse = '''Drone Scanning with Agrivyaan:

🚁 HOW TO BOOK A DRONE SCAN:
1. Tap the "+" button in the bottom navigation bar
2. Select "Book Drone Scan"
3. Choose your field and scan type
4. Select preferred date and time
5. Our certified drone operator will visit

📊 SCAN TYPES AVAILABLE:
• Crop Health (NDVI): Detect disease & stress zones
• Soil Moisture Mapping: Find dry/wet zones
• Pest Detection: Identify infestation areas
• Stand Count: Estimate plant population

🗺️ REPORT FEATURES:
• Color-coded zone maps
• Health score per zone
• Recommended actions
• Before/After comparison

📱 VIEW REPORTS:
• Go to Reports tab to view all scan history
• Each report has zone-wise recommendations
• Export PDF for government records

Current scan status: Check your Scans tab for booking history!''';
    }
    // --- SOIL HEALTH CARD ---
    else if (lower.contains('soil health') || lower.contains('shc') || lower.contains('मृदा') ||
        lower.contains('soil card') || lower.contains('मिट्टी जांच')) {
      baseEnglishResponse = '''Soil Health Card (SHC) Guide:

📋 WHAT IS SOIL HEALTH CARD?
Government-issued card showing your soil's nutrient status, helping you apply the right fertilizers.

🔬 PARAMETERS TESTED:
• NPK (Nitrogen, Phosphorus, Potassium)
• pH (acidity/alkalinity)
• Organic Carbon
• Secondary nutrients (Sulphur, Zinc, Boron)
• Micronutrients

📱 IN AGRIVYAAN:
• Go to Profile → Soil Health Cards
• Upload your card photo for digital storage
• View lab results and recommendations
• Get AI-powered fertilizer suggestions based on your results

🏛️ HOW TO GET YOUR SHC:
• Visit your nearest Krishi Vigyan Kendra (KVK)
• Collect soil sample from 0-6 inch depth
• Submit to soil testing lab
• Receive card within 15-30 days (free government service)

Tip: Test your soil every 2 years for optimal fertilization!''';
    }
    // --- GENERAL / UNKNOWN ---
    else {
      // Build a context-aware response using chat history
      final recentTopics = _extractRecentTopics(chatHistory);
      final contextNote = recentTopics.isNotEmpty
          ? 'Based on our conversation about ${recentTopics.join(', ')}, '
          : '';

      baseEnglishResponse = '''${contextNote}Regarding your question about "$query" for $mainCrop farming in $location:

I can help you with specific farming advice. Here are topics I specialize in:

🌾 Ask me about:
• Field health & disease management
• Fertilizer dosage & timing
• Irrigation scheduling
• Pest identification & control
• Seed variety selection
• Weather & spraying conditions
• Drone scan booking
• Soil health card reading
• Farm cost calculations
• How to use this app

💬 You can also tap the microphone 🎤 to ask in your language!

Try asking: "How do I increase my cotton yield?" or "What pesticide for leaf spot?"''';
    }

    if (languageCode == 'en') {
      return baseEnglishResponse;
    }

    // Translate dynamic response using Sarvam Mayura model
    final translated = await translateText(
      text: baseEnglishResponse,
      sourceLang: 'en',
      targetLang: languageCode,
    );

    return translated;
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _buildHistoryContext(List<Map<String, dynamic>>? history) {
    if (history == null || history.isEmpty) return '';
    final recent = history.length > 4 ? history.sublist(history.length - 4) : history;
    return recent
        .where((m) => m['isUser'] == true)
        .map((m) => m['text'] as String? ?? '')
        .join(', ');
  }

  List<String> _extractRecentTopics(List<Map<String, dynamic>>? history) {
    if (history == null || history.length < 2) return [];
    final topics = <String>[];
    final recent = history.length > 6 ? history.sublist(history.length - 6) : history;
    for (final msg in recent) {
      if (msg['isUser'] == true) {
        final text = (msg['text'] as String? ?? '').toLowerCase();
        if (text.contains('health')) topics.add('crop health');
        if (text.contains('fertilizer') || text.contains('urea')) topics.add('fertilizer');
        if (text.contains('water') || text.contains('irrigation')) topics.add('irrigation');
        if (text.contains('pest') || text.contains('disease')) topics.add('pest control');
        if (text.contains('weather')) topics.add('weather');
      }
    }
    return topics.toSet().toList();
  }
}
