import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/idea.dart';
import '../services/idea_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background soft gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                      : [const Color(0xFFF8FAFC), const Color(0xFFEEF2F6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer<IdeaService>(
              builder: (context, ideaService, child) {
                if (ideaService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  );
                }

                // Sort ideas by voteCount descending, then by aiRating descending
                final rankedIdeas = List<Idea>.from(ideaService.ideas);
                rankedIdeas.sort((a, b) {
                  final voteComparison = b.voteCount.compareTo(a.voteCount);
                  if (voteComparison != 0) return voteComparison;
                  return b.aiRating.compareTo(a.aiRating);
                });

                // Display ONLY the Top 5 ideas
                final top5Ideas = rankedIdeas.take(5).toList();

                if (top5Ideas.isEmpty) {
                  return _buildEmptyState(theme);
                }

                // Extract Top 3 for the podium
                final top1 = top5Ideas.isNotEmpty ? top5Ideas[0] : null;
                final top2 = top5Ideas.length > 1 ? top5Ideas[1] : null;
                final top3 = top5Ideas.length > 2 ? top5Ideas[2] : null;

                // Extract remaining Top 5 ideas as runners-up (Rank 4 & 5)
                final runnersUp = top5Ideas.length > 3 ? top5Ideas.sublist(3) : <Idea>[];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leaderboard',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Top 5 performing startup pitches sorted by community upvotes',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Podium Area (Top 3) - Animated mounting
                    AnimatedFadeSlide(
                      index: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : const Color(0xFF6366F1).withOpacity(0.06),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155).withOpacity(0.5)
                                  : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 2nd Place (Silver) - Render on the Left
                              Expanded(
                                child: _buildPodiumColumn(
                                  context: context,
                                  idea: top2,
                                  rank: 2,
                                  height: 95,
                                  color: const Color(0xFF94A3B8),
                                  icon: Icons.workspace_premium_rounded,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 1st Place (Gold) - Render in the Center
                              Expanded(
                                child: _buildPodiumColumn(
                                  context: context,
                                  idea: top1,
                                  rank: 1,
                                  height: 125,
                                  color: const Color(0xFFF59E0B),
                                  icon: Icons.emoji_events_rounded,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 3rd Place (Bronze) - Render on the Right
                              Expanded(
                                child: _buildPodiumColumn(
                                  context: context,
                                  idea: top3,
                                  rank: 3,
                                  height: 75,
                                  color: const Color(0xFFB45309),
                                  icon: Icons.military_tech_rounded,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Runners-up Header
                    if (runnersUp.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'RUNNERS UP',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                          ),
                        ),
                      ),
                      
                      // Runners-up List (Rank 4 and 5)
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: runnersUp.length,
                          physics: const NeverScrollableScrollPhysics(), // Fits Top 5, no scrolling needed
                          itemBuilder: (context, index) {
                            final idea = runnersUp[index];
                            final rank = index + 4;
                            return AnimatedFadeSlide(
                              index: index + 1, // Stagger entry
                              child: _buildRunnerUpRow(idea, rank, theme, isDark),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const Spacer(),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Text(
                            'Submit more ideas to see the Top 5!',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required BuildContext context,
    required Idea? idea,
    required int rank,
    required double height,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    if (idea == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withOpacity(0.3) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155).withOpacity(0.3) : const Color(0xFFE2E8F0),
              ),
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.grey, size: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '-',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trophy/Medal Icon
        Icon(icon, color: color, size: rank == 1 ? 32 : 26),
        const SizedBox(height: 6),
        // Score/Votes info
        Text(
          '${idea.voteCount} votes',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        // 3D looking Podium pedestal
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.75)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.outfit(
                fontSize: rank == 1 ? 36 : 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Startup Name
        Text(
          idea.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: rank == 1 ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'AI: ${idea.aiRating}',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRunnerUpRow(Idea idea, int rank, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : const Color(0x03000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155).withOpacity(0.5)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Number Badge
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFEEF2F6),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Idea Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idea.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  idea.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // AI Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.thumb_up_rounded, size: 12, color: Color(0xFF6366F1)),
                  const SizedBox(width: 4),
                  Text(
                    '${idea.voteCount}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              Text(
                'AI: ${idea.aiRating}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black12,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Rankings Available',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Once concepts are submitted and upvoted, the leaderboard will display the Top 5 pitches.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A lightweight custom staggered fade-in + slide-up entry animator
class AnimatedFadeSlide extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedFadeSlide({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 550),
      // Apply curve and a calculated staggered delay based on list item index
      curve: Interval(
        (index * 0.1).clamp(0.0, 0.5),
        1.0,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0.0, (1.0 - value) * 20.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
