import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:topografia/Aulas/tts.dart';

class TextSpeechController extends StatefulWidget {
  TextSpeechController({
    required this.text,
  });

  final String text;

  _TextSpeechController textSpeech = _TextSpeechController();

  bool isOpen = false;

  void open() async {
    textSpeech.open();
    isOpen = true;
  }

  void close() async {
    textSpeech.close();
    isOpen = false;
  }

  @override
  _TextSpeechController createState() => textSpeech;
}

class _TextSpeechController extends State<TextSpeechController> {
  bool _open = false;

  TtsState _playPause = TtsState.stopped;
  double _playbackSpeed = 1;

  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    iniciar();
  }

  void iniciar() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.awaitSynthCompletion(true);
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      setState(() {
        _playPause = TtsState.stopped;
      });
    });

    flutterTts.setStartHandler(() {
      setState(() {
        _playPause = TtsState.playing;
      });
    });
  }

  void open() {
    _open = true;
    if (mounted) {
      setState(() {});
    } else {
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {});
      });
    }
  }

  void close() {
    _open = false;
    _playPause = TtsState.stopped;
    _playbackSpeed = 1;
    if (mounted) {
      setState(() {
        flutterTts.stop();
      });
    } else {
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          flutterTts.stop();
        });
      });
    }
  }

  void onReturn5Seconds() async {}

  void onPlayPause() async {
    if (_playPause == TtsState.paused || _playPause == TtsState.stopped) {
      var result = await flutterTts.speak(widget.text);
      if (result == 1) setState(() => _playPause = TtsState.playing);
    } else if (_playPause == TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) setState(() => _playPause = TtsState.stopped);
    }

    setState(() {});
  }

  Widget build(BuildContext context) {
    return Row(
      children: textSpeechWidget(),
    );
  }

  List<Widget> textSpeechWidget() {
    List<Widget> audioList = [];

    IconData playPauseButton =
        _playPause == TtsState.playing ? Icons.pause : Icons.play_arrow;

    if (_open) {
      if (_playPause == TtsState.playing) {
        IconData speed = Icons.fast_forward;
        IconData replay5 = Icons.replay_5;

        if (_playbackSpeed != 1) {
          audioList.add(
            SizedBox(
              height: 50,
              width: 50,
              child: InkWell(
                onTap: () {
                  _playbackSpeed += 0.25;

                  if (_playbackSpeed > 2) {
                    _playbackSpeed = 1;
                  }
                  flutterTts.setSpeechRate(_playbackSpeed).then((val) async {
                    var result = await flutterTts.stop();
                    if (result == 1)
                      setState(() => _playPause = TtsState.stopped);
                  });
                },
                child: Stack(
                  children: [
                    Center(child: Icon(speed)),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Text(
                        "x$_playbackSpeed",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          audioList.add(
            SizedBox(
              height: 50,
              width: 50,
              child: InkWell(
                onTap: () {
                  _playbackSpeed += 0.5;

                  if (_playbackSpeed > 2) {
                    _playbackSpeed = 1;
                  }
                  setState(() {});
                },
                child: Icon(speed),
              ),
            ),
          );
        }

        audioList.add(
          SizedBox(
            height: 50,
            width: 50,
            child: InkWell(
              onTap: () {
                onReturn5Seconds();
              },
              child: Icon(replay5),
            ),
          ),
        );
      }
      audioList.add(
        SizedBox(
          height: 50,
          width: 50,
          child: InkWell(
            onTap: () {
              onPlayPause();
            },
            child: Icon(playPauseButton),
          ),
        ),
      );
    }
    return audioList;
  }
}
