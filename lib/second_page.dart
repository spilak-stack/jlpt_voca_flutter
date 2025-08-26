import 'package:flutter/material.dart';
import 'package:jlpt241218/word_list_page.dart';
import 'app_theme.dart';
import 'package:jlpt241218/word_quiz_page.dart';
import 'json_control.dart';

class SecondPage extends StatefulWidget {
  final int n;
  const SecondPage({super.key, required this.n});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with RouteAware {
  List<Map<String, dynamic>> _totalData = [];
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData(); // 초기 데이터 로드
  }

  Future<void> _loadData() async {
    _totalData = await readWordTotalData();
    _progress = await _loadProgress();
    if (mounted) {
      setState(() {});
    }
  }

  Future<double> _loadProgress() async {
    if (_totalData.isEmpty || widget.n - 1 >= _totalData.length) {
      return 0.0;
    }
    final data = _totalData[widget.n - 1];
    double progress;

    final total = data['Total'] ?? 0;
    final solve = data['Solve'] ?? 0;
    final wrong = data['Wrong'] ?? 0;
    final pass = solve + wrong;

    if (total == 0) {
      progress = 0.0;
    } else {
      progress = pass / total;
    }

    return progress;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("N${widget.n}"),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Navigator.push()에서 await를 사용하여 WordQuizPage의 결과를 기다립니다.
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordQuizPage(n: widget.n)));

                // WordQuizPage에서 pop(context, true)로 돌아온 경우, result는 true가 됩니다.
                if (result == true) {
                  _loadData(); // 데이터 다시 로드 및 상태 업데이트
                }
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 100),
                  textStyle: TextStyle(fontSize: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5),
              child: const Text("단어 퀴즈"),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordListPage(n: widget.n)));

                if (result == true) {
                  // _loadData(); // 데이터 다시 로드 및 상태 업데이트
                }
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 100),
                  textStyle: TextStyle(fontSize: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5),
              child: const Text("단어장"),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('준비중입니다.'),
                  content: const Text('조금만 기다려주세요!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 100),
                  textStyle: TextStyle(fontSize: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5),
              child: const Text("상용한자"),
            ),
          ],
        ),
      ),
    );
  }
}
