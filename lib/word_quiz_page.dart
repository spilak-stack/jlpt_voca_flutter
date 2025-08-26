import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jlpt241218/json_control.dart';
import 'package:jlpt241218/json_shuffle.dart';
import 'app_theme.dart';

class WordQuizPage extends StatefulWidget {
  final int n;
  const WordQuizPage({super.key, required this.n});

  @override
  State<WordQuizPage> createState() => _WordQuizPageState();
}

class _WordQuizPageState extends State<WordQuizPage> {
  bool showFurigana = false;
  bool showKorean = false;
  int index = 0;
  int solve = 0;
  int wrong = 0;
  int total = 0;
  int bookmark = 0;

  String furigana = '';
  String meaning = '';
  String word = '';
  List<Map<String, dynamic>> _wordData = [];
  List<Map<String, dynamic>> _totalData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _wordData = await readWordData(widget.n);
    _totalData = await readWordTotalData();

    setState(() {
      total = _wordData.length;
      index = _totalData[widget.n - 1]['Index'];
      solve = _totalData[widget.n - 1]['Solve'];
      wrong = _totalData[widget.n - 1]['Wrong'];

      furigana = _wordData[index]['Furigana'];
      meaning = _wordData[index]['Meaning'];
      word = _wordData[index]['Word'];
      bookmark = _wordData[index]['Bookmark'];
    });
  }

  Future<int> _findNextUnsolvedIndex(int currentIndex) async {
    _wordData = await readWordData(widget.n);
    for (int i = currentIndex + 1; i < total; i++) {
      if (_wordData[i]['Pass'] == 0) {
        print(i);
        return i;
      }
    }
    return -1; // No unsolved index found
  }

  Future<int> _findFirstUnsolvedIndex() async {
    _wordData = await readWordData(widget.n);
    for (int i = 0; i < total; i++) {
      if (_wordData[i]['Pass'] == 0) {
        return i;
      }
    }
    return -1; // No unsolved index found
  }

  void _toggleBookmark(int index) {
    setState(() {
      _wordData[index]['Bookmark'] = _wordData[index]['Bookmark'] == 1 ? 0 : 1;
      writeWordData(widget.n, _wordData);
      _loadData();
    });
  }

  void _showRetryDialog() {
    print("_showRetryDialog - called");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // StatefulBuilder 추가
          builder: (BuildContext context, StateSetter setState) {
            // StateSetter 추가
            return AlertDialog(
              title: Text("다시 풀기"),
              content: Text("현재 맞춘 단어 개수: $solve\n틀린 단어부터 다시 풀어보겠습니다."),
              actions: <Widget>[
                TextButton(
                  child: Text("확인"),
                  onPressed: () async {
                    Navigator.pop(context, true);
                    index = await _findFirstUnsolvedIndex();

                    setState(() {});

                    _totalData[widget.n - 1]['Index'] = index;
                    _totalData[widget.n - 1]['Wrong'] = 0;
                    writeWordData(widget.n, _wordData);
                    writeWordTotalData(_totalData);
                    _loadData(); // 변수 초기화
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Done!"),
              content: Text("모든 단어를 외우셨습니다."),
              actions: <Widget>[
                TextButton(
                  child: Text("확인"),
                  onPressed: () {
                    jsonWordTotalReset(widget.n);
                    jsonShuffle(widget.n);
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Quiz(${index + 1}/$total)"),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined),
            onPressed: appTheme.toggleTheme,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              Column(
                children: [
                  Visibility(
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    visible: showFurigana,
                    child: AutoSizeText(furigana,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 40, height: 1, fontFamily: 'JP')),
                  ),
                  AutoSizeText(word,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 100, height: 1, fontFamily: 'JP')),
                  SizedBox(height: 20),
                  Visibility(
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    visible: showKorean,
                    child: AutoSizeText(meaning,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 50,
                            height: 1,
                            fontFamily: 'KO',
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () => _toggleBookmark(index),
                        icon: Icon(
                            bookmark == 1 ? Icons.star : Icons.star_border)),
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnswerButton("日本語", () {
                    setState(() {
                      showFurigana = !showFurigana;
                    });
                  }, 'JP'),
                  Spacer(),
                  _buildAnswerButton("한국어", () {
                    setState(() {
                      showKorean = !showKorean;
                    });
                  }, 'KO'),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResultButton(false),
                  Spacer(),
                  _buildResultButton(true),
                ],
              ),
              SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(
      String label, VoidCallback onPressed, String fontFamily) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          fixedSize: Size(150, 100),
          textStyle: TextStyle(fontSize: 30),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          elevation: 5),
      child: Text(label, style: TextStyle(fontFamily: fontFamily)),
    );
  }

  Widget _buildResultButton(bool isCorrect) {
    return Row(
      children: [
        // 버튼을 숫자 왼쪽에 배치 (isCorrect가 false일 때, 즉 오답일 때)
        if (!isCorrect)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
              onPressed: () async {
                // 오답 처리 로직을 버튼을 누르자마자 실행
                _wordData[index]['Pass'] = 0;
                _totalData[widget.n - 1]['Wrong']++;
                writeWordData(widget.n, _wordData);
                writeWordTotalData(_totalData);

                // UI 업데이트를 위해 setState 호출
                setState(() {
                  showFurigana = false;
                  showKorean = false;
                  wrong =
                      _totalData[widget.n - 1]['Wrong']; // UI에 wrong 값 즉시 반영
                });

                // 다음 인덱스 찾기
                index = await _findNextUnsolvedIndex(index);

                if (index == -1) {
                  if (_totalData[widget.n - 1]['Solve'] == total) {
                    _showCompletionDialog();
                  } else {
                    _loadData();
                    _showRetryDialog();
                  }
                } else {
                  _totalData[widget.n - 1]['Index'] = index;
                  writeWordData(widget.n, _wordData);
                  writeWordTotalData(_totalData);
                  _loadData(); // 변수 초기화
                }

                // 나머지 UI 업데이트
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(100, 100),
                backgroundColor: const Color(0xFF914B43), // 빨간색
                foregroundColor: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(90))),
                elevation: 5,
              ),
              child: Icon(
                Icons.redo, // 오답 아이콘
                size: 40,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),

        // 숫자
        Text("${isCorrect ? solve : wrong}",
            style: TextStyle(
                fontSize: 40,
                fontFamily: 'KO',
                color: isCorrect
                    ? const Color(0xFF376A3E) // 초록색
                    : const Color(0xFF914B43) // 빨간색
                )),

        // 버튼을 숫자 오른쪽에 배치 (isCorrect가 true일 때, 즉 정답일 때)
        if (isCorrect)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ElevatedButton(
              onPressed: () async {
                // 정답 처리 로직을 버튼을 누르자마자 실행
                _wordData[index]['Pass'] = 1;
                _totalData[widget.n - 1]['Solve']++;
                writeWordData(widget.n, _wordData);
                writeWordTotalData(_totalData);

                // UI 업데이트를 위해 setState 호출
                setState(() {
                  showFurigana = false;
                  showKorean = false;
                  solve =
                      _totalData[widget.n - 1]['Solve']; // UI에 solve 값 즉시 반영
                });

                // 다음 인덱스 찾기
                index = await _findNextUnsolvedIndex(index);

                if (index == -1) {
                  if (_totalData[widget.n - 1]['Solve'] == total) {
                    _showCompletionDialog();
                  } else {
                    _loadData();
                    _showRetryDialog();
                  }
                } else {
                  _totalData[widget.n - 1]['Index'] = index;
                  writeWordData(widget.n, _wordData);
                  writeWordTotalData(_totalData);
                  _loadData(); // 변수 초기화
                }

                // 나머지 UI 업데이트
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(100, 100),
                backgroundColor: const Color(0xFF376A3E), // 초록색
                foregroundColor: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(90))),
                elevation: 5,
              ),
              child: Icon(
                Icons.check, // 정답 아이콘
                size: 40,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
      ],
    );
  }
}
