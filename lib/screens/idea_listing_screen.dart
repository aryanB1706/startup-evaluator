import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/idea.dart';
import '../services/idea_service.dart';

class IdeaListingScreen extends StatefulWidget {
  const IdeaListingScreen({super.key});

  @override
  State<IdeaListingScreen> createState() => _IdeaListingScreenState();
}

class _IdeaListingScreenState extends State<IdeaListingScreen> {
  String _sortBy = 'votes'; // 'votes' or 'rating'

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

                // Sorting logic
                final sortedIdeas = List<Idea>.from(ideaService.ideas);
                if (_sortBy == 'votes') {
                  // Sort by vote count descending, then by AI rating descending
                  sortedIdeas.sort((a, b) {
                    final voteComparison = b.voteCount.compareTo(a.voteCount);
                    if (voteComparison != 0) return voteComparison;
                    return b.aiRating.compareTo(a.aiRating);
                  });
                } else {
                  // Sort by AI rating descending, then by vote count descending
                  sortedIdeas.sort((a, b) {
                    final ratingComparison = b.aiRating.compareTo(a.aiRating);
                    if (ratingComparison != 0) return ratingComparison;
                    return b.voteCount.compareTo(a.voteCount);
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Header Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore Pitches',
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${sortedIdeas.length} startup concepts loaded',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Segmented sorting control panel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSortButton(
                                label: 'Popular Votes',
                                icon: Icons.thumb_up_alt_outlined,
                                isActive: _sortBy == 'votes',
                                onClick: () => setState(() => _sortBy = 'votes'),
                                isDark: isDark,
                              ),
                            ),
                            Expanded(
                              child: _buildSortButton(
                                label: 'AI Score Rating',
                                icon: Icons.auto_awesome_outlined,
                                isActive: _sortBy == 'rating',
                                onClick: () => setState(() => _sortBy = 'rating'),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List of Ideas
                    Expanded(
                      child: sortedIdeas.isEmpty
                          ? _buildEmptyState(theme, isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              itemCount: sortedIdeas.length,
                              itemBuilder: (context, index) {
                                final idea = sortedIdeas[index];
                                return AnimatedFadeSlide(
                                  index: index, // Stagger effect
                                  child: IdeaCard(
                                    idea: idea,
                                    onUpvote: () => ideaService.toggleUpvote(idea.id),
                                    isDark: isDark,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onClick,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onClick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive && !isDark
              ? [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? (isDark ? Colors.white : const Color(0xFF6366F1))
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 64,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Ideas Submitted Yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to submit a revolutionary startup idea and get evaluated by our AI engine!',
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

/// Dynamic individual card with local expansion state for performance
class IdeaCard extends StatefulWidget {
  final Idea idea;
  final VoidCallback onUpvote;
  final bool isDark;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.onUpvote,
    required this.isDark,
  });

  @override
  State<IdeaCard> createState() => _IdeaCardState();
}

class _IdeaCardState extends State<IdeaCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Grade rating styling & labels helper
  Map<String, dynamic> _getRatingStyle(int rating) {
    if (rating >= 90) {
      return {
        'label': 'Unicorn Class',
        'icon': Icons.stars_rounded,
        'colors': [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Warm Orange to Red
        'text': Colors.white,
      };
    } else if (rating >= 80) {
      return {
        'label': 'High Potential',
        'icon': Icons.auto_awesome,
        'colors': [const Color(0xFF8B5CF6), const Color(0xFF6366F1)], // Purple to Indigo
        'text': Colors.white,
      };
    } else if (rating >= 70) {
      return {
        'label': 'Solid Concept',
        'icon': Icons.lightbulb_rounded,
        'colors': [const Color(0xFF10B981), const Color(0xFF06B6D4)], // Mint to Cyan
        'text': Colors.white,
      };
    } else {
      return {
        'label': 'Iterating concept',
        'icon': Icons.explore_outlined,
        'colors': [const Color(0xFF64748B), const Color(0xFF475569)], // Slate Cool Gray
        'text': Colors.white,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratingStyle = _getRatingStyle(widget.idea.aiRating);
    final List<Color> gradientColors = ratingStyle['colors'] as List<Color>;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark
              ? const Color(0xFF334155).withOpacity(0.5)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black26 : const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upper row (AI rating and category badge)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // AI score circle/badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ratingStyle['icon'] as IconData,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI: ${widget.idea.aiRating}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Unicorn Class / High Potential text label
                      Text(
                        ratingStyle['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: (gradientColors.first).withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Startup Title
                  Text(
                    widget.idea.name,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Tagline
                  Text(
                    widget.idea.tagline,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  // Expanded Section (Animated)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Text(
                            'CONCEPT DETAILS',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.idea.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.5,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
            
            // Card Footer containing Action Buttons (Upvote, Share & Read More)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E293B).withOpacity(0.4) : const Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(
                    color: widget.isDark
                        ? const Color(0xFF334155).withOpacity(0.3)
                        : const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Read more toggle
                  TextButton(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _isExpanded ? 'Show Less' : 'Read Full Pitch',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: widget.isDark ? Colors.white70 : Colors.black87,
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons group (Share & Upvote)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Share Button
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: widget.isDark ? Colors.white60 : Colors.black54,
                        ),
                        tooltip: 'Share Pitch',
                        onPressed: () {
                          // Copy formatted startup data to Clipboard
                          Clipboard.setData(
                            ClipboardData(
                              text: '🚀 *${widget.idea.name}*\n"${widget.idea.tagline}"\n🤖 *AI Evaluator Rating:* ${widget.idea.aiRating}/100\n\nSubmitted via Startup Evaluator AI App!',
                            ),
                          );
                          // Show customized premium SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pitch copied to Clipboard!',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),

                      // Upvote button
                      ElevatedButton(
                        onPressed: widget.onUpvote,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: widget.idea.isUpvoted
                              ? const Color(0xFF6366F1)
                              : (widget.isDark ? const Color(0xFF334155) : const Color(0xFFEEF2F6)),
                          foregroundColor: widget.idea.isUpvoted
                              ? Colors.white
                              : (widget.isDark ? Colors.white : Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: widget.idea.isUpvoted
                                  ? Colors.transparent
                                  : (widget.isDark ? Colors.transparent : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.idea.isUpvoted
                                  ? Icons.thumb_up_rounded
                                  : Icons.thumb_up_outlined,
                              size: 14,
                              color: widget.idea.isUpvoted
                                  ? Colors.white
                                  : (widget.isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.idea.voteCount}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
        (index * 0.06).clamp(0.0, 0.5),
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
