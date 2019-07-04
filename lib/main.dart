import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() => runApp(new ListApp());

class ListApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ListAppState();
  }
}

class ListAppState extends State<ListApp> {
  var _isLoading = true;
  var videos;
  
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    final url = 'https://api.letsbuildthatapp.com/youtube/home_feed';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final map = json.decode(response.body);
      final videosJson = map["videos"];

      setState(() {
        _isLoading = false;
        this.videos = videosJson;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.red,
      ),
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text("Sample List and video "),
            ),
            body: new Center(
                child: _isLoading
                    ? new CircularProgressIndicator()
                    : new ListView.builder(
                        itemCount: this.videos.length,
                        itemBuilder: (context, i) {
                          final video = this.videos[i];
                          return new FlatButton(
                            padding: EdgeInsets.all(0.0),
                          child: new Column(
                            children: <Widget>[
                              new Container(
                                padding: new EdgeInsets.all(16.0),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                  new Image.network(video["imageUrl"]),
                                  new Container(height: 8.0),
                                  new Text(video["name"],
                                    style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)
                                  ),
                                  ]
                                ),
                              ),
                              new Divider()
                            ],
                          ),
                          onPressed: () {
                           print('$i Pressed');
                           Navigator.push(context, 
                           new MaterialPageRoute(
                             builder: (context) => VideoPlayerScreen()
                           ));
                          },
                          );
                        }))));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
     super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: new Center (child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          print(snapshot.connectionState);
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ), 
    );
  }
}
