import 'package:emushaf/widgets/read_quran_card.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran/quran.dart' as quran;
import 'package:vibration/vibration.dart';

class ReadPage extends StatefulWidget {
  final int chapter;
  const ReadPage({super.key, required this.chapter});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  late int _currentVerse;
  late Box _bookmarks;
  late int _currentChapter;
  late ScrollController _scrollController;
  late int _totalVerses;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _bookmarks = Hive.box("bookmarks");
    _currentChapter = widget.chapter;
    _currentVerse = _bookmarks.get(_currentChapter) ?? 1;
    _getTotalVerses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(quran.getSurahName(_currentChapter)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ReadQuranCard(
                    currentChapter: _currentChapter,
                    currentVerse: _currentVerse,
                    totalVerses: _totalVerses,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(bottom: 15, right: 18, left: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Distribute buttons horizontally
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle left button action
                    _vibrate();
                    if (_currentVerse != 1) {
                      _decrement();
                      _bookmarks.put(_currentChapter, _currentVerse);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 30,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _vibrate();
                    _scrollUp();
                    if (_currentVerse != _totalVerses) {
                      _increment();
                      _bookmarks.put(_currentChapter, _currentVerse);
                    } else {
                      // New Chapter
                      _bookmarks.delete(_currentChapter);
                      _reset();
                      if (_currentChapter != 114) {
                        _incrementChapter();
                      } else {
                        _resetChapter();
                      }
                      _getTotalVerses();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _increment() {
    setState(() {
      _currentVerse++;
    });
  }

  void _decrement() {
    setState(() {
      _currentVerse--;
    });
  }

  void _reset() {
    setState(() {
      _currentVerse = 1;
    });
  }

  void _getTotalVerses() {
    setState(() {
      _totalVerses = quran.getVerseCount(_currentChapter);
    });
  }

  void _incrementChapter() {
    setState(() {
      _currentChapter++;
    });
  }

  void _resetChapter() {
    setState(() {
      _currentChapter = 1;
    });
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator() != null) {
      Vibration.vibrate(duration: 25);
    }
  }

  void _scrollUp() {
    _scrollController.jumpTo(_scrollController.position.minScrollExtent);
  }
}
