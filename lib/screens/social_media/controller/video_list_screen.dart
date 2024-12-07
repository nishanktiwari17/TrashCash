import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For caching images
import 'package:waste_management_app/screens/social_media/models/channel.dart';
import 'package:waste_management_app/screens/social_media/controller/video_screen.dart';
import 'package:waste_management_app/screens/social_media/views/components/youtube_service.dart';

class VideoList extends StatefulWidget {
  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  Channel? _channel;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  _initChannel() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      Channel channel = await APIService.instance.fetchChannel(channelId: 'UClUC_8c_F3aBmwME-dNfvKg');
      setState(() {
        _channel = channel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error fetching channel data: $e');
    }
  }

  _buildProfileInfo() {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      height: 120.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: _channel!.profilePictureUrl,
              width: 70.0,
              height: 70.0,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _channel!.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_channel!.subscriberCount} subscribers',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildVideo(Video video) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(id: video.id),
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 5.0,
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                width: 150.0,
                height: 100.0,
                imageUrl: video.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                video.title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadMoreVideos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Video> moreVideos = await APIService.instance.fetchVideosFromPlaylist(playlistId: _channel!.uploadPlaylistId);
      List<Video> allVideos = _channel!.videos..addAll(moreVideos);
      setState(() {
        _channel!.videos = allVideos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error loading more videos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Channel'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            )
          : _hasError
              ? Center(child: Text('Error loading content. Please try again later.'))
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollDetails) {
                    if (!_isLoading &&
                        _channel!.videos.length != int.parse(_channel!.videoCount) &&
                        scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent) {
                      _loadMoreVideos();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: 1 + _channel!.videos.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return _buildProfileInfo();
                      }
                      Video video = _channel!.videos[index - 1];
                      return _buildVideo(video);
                    },
                  ),
                ),
    );
  }
}
