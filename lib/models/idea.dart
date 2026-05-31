class Idea {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final int aiRating; // 0 to 100
  final int voteCount;
  final bool isUpvoted;

  Idea({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.aiRating,
    this.voteCount = 0,
    this.isUpvoted = false,
  });

  /// Creates a copy of this [Idea] but with the given fields replaced with the new values.
  Idea copyWith({
    String? id,
    String? name,
    String? tagline,
    String? description,
    int? aiRating,
    int? voteCount,
    bool? isUpvoted,
  }) {
    return Idea(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      aiRating: aiRating ?? this.aiRating,
      voteCount: voteCount ?? this.voteCount,
      isUpvoted: isUpvoted ?? this.isUpvoted,
    );
  }

  /// Converts this [Idea] instance into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'aiRating': aiRating,
      'voteCount': voteCount,
      'isUpvoted': isUpvoted,
    };
  }

  /// Creates an [Idea] instance from a JSON-compatible map.
  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      description: json['description'] as String,
      aiRating: json['aiRating'] as int,
      voteCount: json['voteCount'] as int? ?? 0,
      isUpvoted: json['isUpvoted'] as bool? ?? false,
    );
  }
}
