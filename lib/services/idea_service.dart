import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/idea.dart';

class IdeaService extends ChangeNotifier {
  static const String _storageKey = 'startup_ideas';
  
  final List<Idea> _ideas = [];
  bool _isLoading = false;
  bool _isDarkMode = false;
  final Uuid _uuid = const Uuid();

  List<Idea> get ideas => List.unmodifiable(_ideas);
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  IdeaService() {
    loadIdeas();
  }

  /// Toggles the application's theme mode and persists choice to SharedPreferences.
  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Seed initial startup ideas if local storage is completely empty.
  List<Idea> _getInitialSeedIdeas() {
    return [
      Idea(
        id: _uuid.v4(),
        name: 'EcoTrack AI',
        tagline: 'Decarbonize your supply chain with predictive intelligence.',
        description: 'EcoTrack AI automatically ingests supply chain data, matches it with global emissions databases, and recommends the most cost-effective carbon reduction strategies using custom deep learning models.',
        aiRating: 89,
        voteCount: 14,
        isUpvoted: false,
      ),
      Idea(
        id: _uuid.v4(),
        name: 'ByteChef',
        tagline: 'Zero-waste culinary creations from your fridge leftovers.',
        description: 'ByteChef uses visual recognition to scan the inside of your refrigerator, detects ingredients, and generates step-by-step, gourmet recipes to eliminate food waste while optimizing for prep time and nutritional goals.',
        aiRating: 94,
        voteCount: 32,
        isUpvoted: false,
      ),
      Idea(
        id: _uuid.v4(),
        name: 'DocuSphere',
        tagline: 'Interactive Q&A for massive, multi-file codebases and documents.',
        description: 'An enterprise-grade retrieval-augmented generation engine that allows engineering teams to ask natural language questions across thousands of legacy PDF, Markdown, and source code files, returning exact citations and context.',
        aiRating: 91,
        voteCount: 25,
        isUpvoted: false,
      ),
    ];
  }

  /// Loads ideas from SharedPreferences. Seeding initial ideas if empty.
  Future<void> loadIdeas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      final jsonString = prefs.getString(_storageKey);
      
      _ideas.clear();
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
        _ideas.addAll(jsonList.map((jsonItem) => Idea.fromJson(jsonItem as Map<String, dynamic>)));
      } else {
        // Seed initial ideas if there's no data in storage yet
        final seedIdeas = _getInitialSeedIdeas();
        _ideas.addAll(seedIdeas);
        // Save seed ideas to storage immediately
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Error loading ideas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves the current list of ideas to SharedPreferences.
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_ideas.map((idea) => idea.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving ideas to SharedPreferences: $e');
    }
  }

  /// Evaluates and saves a new startup idea to SharedPreferences.
  /// Standardizes inputs, clamps AI rating between 0 and 100.
  Future<void> addIdea({
    required String name,
    required String tagline,
    required String description,
    required int aiRating,
  }) async {
    final newIdea = Idea(
      id: _uuid.v4(),
      name: name,
      tagline: tagline,
      description: description,
      aiRating: aiRating.clamp(0, 100),
      voteCount: 0,
      isUpvoted: false,
    );

    _ideas.add(newIdea);
    notifyListeners();
    await _saveToStorage();
  }

  /// Toggles the upvote status of an idea.
  /// Enforces a maximum of 1 vote per idea per user (local toggle).
  Future<void> toggleUpvote(String id) async {
    final index = _ideas.indexWhere((idea) => idea.id == id);
    if (index != -1) {
      final idea = _ideas[index];
      final isUpvoted = !idea.isUpvoted;
      
      // Enforce toggling: if upvoted, add 1; if un-upvoted, subtract 1 (clamp to 0 to prevent negative votes)
      final voteCount = isUpvoted 
          ? idea.voteCount + 1 
          : (idea.voteCount - 1).clamp(0, double.infinity).toInt();
      
      _ideas[index] = idea.copyWith(
        isUpvoted: isUpvoted,
        voteCount: voteCount,
      );
      
      notifyListeners();
      await _saveToStorage();
    }
  }
}
