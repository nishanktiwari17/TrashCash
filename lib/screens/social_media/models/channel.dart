class Channel {
  final String id;
  final String title;
  final String profilePictureUrl;
  final String subscriberCount;
  final String videoCount;
  final String uploadPlaylistId;
  List<Video> videos;

  // Constructor with required fields
  Channel({
    required this.id,
    required this.title,
    required this.profilePictureUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.uploadPlaylistId,
    this.videos = const [], // Initialize an empty list if no videos are provided
  });

  // Factory constructor to create Channel from a map
factory Channel.fromMap(Map<String, dynamic> map) {
  return Channel(
    id: map['id'] ?? '',
    title: map['snippet']?['title'] ?? '',
    // Add null check for profile picture URL
    profilePictureUrl: map['snippet']?['thumbnail']?['default']?['url'] ?? '',
    subscriberCount: map['statistics']?['subscriberCount'] ?? '0',
    videoCount: map['statistics']?['videoCount'] ?? '0',
    uploadPlaylistId: map['contentDetails']?['relatedPlaylists']?['uploads'] ?? '',
  );
}

}

// Assuming you have a Video class, this is an example implementation:
class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  // Constructor with required fields
  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
  });

  // Factory constructor to create Video from map
  factory Video.fromMap(Map<String, dynamic> snippet) {
    return Video(
      id: snippet['resourceId'] != null ? snippet['resourceId']['videoId'] ?? '' : '',
      title: snippet['title'] ?? 'No title',
      thumbnailUrl: snippet['thumbnails'] != null && snippet['thumbnails']['high'] != null
          ? snippet['thumbnails']['high']['url'] ?? ''
          : '',
      channelTitle: snippet['channelTitle'] ?? 'Unknown channel',
    );
  }
}

