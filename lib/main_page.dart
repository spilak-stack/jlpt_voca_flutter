import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'second_page.dart';
import 'json_shuffle.dart';

class MainPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MainPage({super.key, required this.toggleTheme});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isSettingsEnabled = true;
  List<bool> checkboxValues = [false, false, false, false, false]; // 여기에 추가

  void _showSettingsBottomSheet() {
    setState(() {
      _isSettingsEnabled = false;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Center(child: Text('Settings')),
              const Divider(),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: const Text('General Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh),
                title: const Text('Quiz Reset'),
                onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    // StatefulBuilder 내부로 이동
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          title: const Text('Quiz Reset'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(5, (index) {
                                return CheckboxListTile(
                                  title: Text('N${index + 1}'),
                                  value: checkboxValues[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkboxValues[index] = value!;
                                    });
                                  },
                                );
                              }),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                for (int i = 0;
                                    i < checkboxValues.length;
                                    i++) {
                                  if (checkboxValues[i] == true) {
                                    jsonShuffle(i + 1);
                                    jsonWordTotalReset(i + 1);
                                  }
                                }
                                // Fluttertoast.showToast(
                                //   msg: "Done",
                                //   toastLength: Toast.LENGTH_SHORT, // 표시 시간 (짧게)
                                //   gravity: ToastGravity.BOTTOM, // 하단에 표시
                                //   timeInSecForIosWeb: 1, // iOS 및 웹에서 표시 시간 (1초)
                                //   backgroundColor: Colors.grey,
                                //   textColor: Colors.white,
                                //   fontSize: 16.0,
                                // );

                                // AlertDialog를 닫을 때 상태 초기화
                                setState(() {
                                  for (int i = 0;
                                      i < checkboxValues.length;
                                      i++) {
                                    checkboxValues[i] = false;
                                  }
                                });
                                Navigator.pop(context, 'Cancel');
                              },
                              child: const Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _isSettingsEnabled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _isSettingsEnabled ? _showSettingsBottomSheet : null,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("JLPT",
                style: TextStyle(fontSize: 100, fontFamily: 'TITLE')),
            const Text("VOCA",
                style: TextStyle(fontSize: 100, fontFamily: 'TITLE')),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SecondPage(n: 1))),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 5,
              ),
              child: const Text("N1"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SecondPage(n: 2))),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 5,
              ),
              child: const Text("N2"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SecondPage(n: 3))),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 5,
              ),
              child: const Text("N3"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SecondPage(n: 4))),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 5,
              ),
              child: const Text("N4"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SecondPage(n: 5))),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 5,
              ),
              child: const Text("N5"),
            ),
          ],
        ),
      ),
    );
  }
}
