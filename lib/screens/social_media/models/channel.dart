class Channel {
  final String id;
  final String title;
  final String profilePictureUrl;
  final String subscriberCount;
  final String videoCount;
  final String uploadPlaylistId;
  List<Video> videos;

  Channel({
    required this.id,
    required this.title,
    required this.profilePictureUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.uploadPlaylistId,
    this.videos = const [],
  });

factory Channel.fromMap(Map<String, dynamic> map) {
  return Channel(
    id: map['id'] ?? '',
    title: map['snippet']?['title'] ?? '',
    profilePictureUrl: map['snippet']?['thumbnail']?['default']?['url'] ?? '',
    subscriberCount: map['statistics']?['subscriberCount'] ?? '0',
    videoCount: map['statistics']?['videoCount'] ?? '0',
    uploadPlaylistId: map['contentDetails']?['relatedPlaylists']?['uploads'] ?? '',
  );
}

}

class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
  });

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

