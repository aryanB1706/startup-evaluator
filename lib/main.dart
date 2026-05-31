import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/idea_service.dart';
import 'screens/idea_submission_screen.dart';
import 'screens/idea_listing_screen.dart';
import 'screens/leaderboard_screen.dart';

void main() {
  // Ensure Flutter binding is initialized for SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IdeaService()),
      ],
      child: Consumer<IdeaService>(
        builder: (context, ideaService, child) {
          return MaterialApp(
            title: 'Startup Evaluator AI',
            debugShowCheckedModeBanner: false,
            // Premium Light Theme Design System
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1), // Indigo primary
                primary: const Color(0xFF6366F1),
                secondary: const Color(0xFF8B5CF6), // Violet secondary
                background: const Color(0xFFF8FAFC),
                surface: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black87),
                titleTextStyle: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFF6366F1).withOpacity(0.12),
                labelTextStyle: MaterialStateProperty.all(
                  GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // Premium Dark Theme Design System (Slate/Indigo blend)
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF818CF8),
                brightness: Brightness.dark,
                primary: const Color(0xFF818CF8),
                secondary: const Color(0xFFA78BFA),
                background: const Color(0xFF0F172A),
                surface: const Color(0xFF1E293B),
              ),
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E293B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: const Color(0xFF0F172A),
                indicatorColor: const Color(0xFF818CF8).withOpacity(0.18),
                labelTextStyle: MaterialStateProperty.all(
                  GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            themeMode: ideaService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to IdeaListingScreen (Explore) on app start

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      IdeaSubmissionScreen(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const IdeaListingScreen(),
      const LeaderboardScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ideaService = Provider.of<IdeaService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        actions: [
          IconButton(
            icon: Icon(
              ideaService.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: ideaService.isDarkMode ? Colors.amber : const Color(0xFF6366F1),
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => ideaService.toggleThemeMode(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded, color: Color(0xFF6366F1)),
            label: 'Submit Pitch',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: Color(0xFF6366F1)),
            label: 'Explore Pitches',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded, color: Color(0xFF6366F1)),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
