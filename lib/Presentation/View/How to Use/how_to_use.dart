import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../Core/Utils/colors.dart';


class HowToUse extends StatefulWidget {
  const HowToUse({super.key});

  @override
  State<HowToUse> createState() => _HowToUseState();
}

class _HowToUseState extends State<HowToUse> {


  String videoUrl = 'https://youtu.be/VN9JJDGg1MU?si=UhYQh9_YSDuHdyN-';
  YoutubePlayerController ? _youtubePlayerController;
  @override
  void initState() {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        isLive: true,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("How to Use",style: TextStyle(color: Colors.white),),
        backgroundColor: TizaraaColors.Tizara,
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          children: [
            YoutubePlayer(
              controller: _youtubePlayerController!,
              liveUIColor: Colors.amber,
            ),

          ],
        ),
      ),
    );
  }
}




