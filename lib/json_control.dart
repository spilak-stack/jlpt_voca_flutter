import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

// 공통 함수: 에셋에서 파일 복사 (비동기 처리)
Future<void> _copyFileFromAssets(File file, String assetPath) async {
  try {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await file.writeAsBytes(bytes, flush: true);
  } catch (e) {
    print('Error copying file from assets: $e');
    // 사용자에게 에러 알림 (예: AlertDialog)
    // ...
  }
}

// JSON 형식 검증 함수
bool _isValidJson(String jsonString, {bool isArray = false}) {
  final trimmedJsonString = jsonString.trim();
  return trimmedJsonString.isNotEmpty &&
      (isArray
          ? trimmedJsonString.startsWith('[')
          : (trimmedJsonString.startsWith('{') ||
              trimmedJsonString.startsWith('[')));
}

// JSON 데이터를 읽고 List<dynamic> 형태로 반환하는 함수 (기기 저장소 파일 사용)
Future<List<Map<String, dynamic>>> _readJsonFile(
    String fileName, String directoryName, bool isArray) async {
  try {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    String dirPath = '$appDocPath/$directoryName';
    Directory dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    String filePath = '$dirPath/$fileName';
    File file = File(filePath);

    // 파일이 없으면 에셋에서 복사
    if (!await file.exists()) {
      await _copyFileFromAssets(file, 'assets/data/$fileName');
    }

    // 파일에서 JSON 데이터 읽기
    if (await file.exists()) {
      String jsonString = await file.readAsString();

      // 빈 문자열인 경우 빈 리스트 반환
      if (jsonString.isEmpty) {
        return [];
      }

      // JSON 형식 검증
      if (!_isValidJson(jsonString, isArray: isArray)) {
        print(
            'Error: Invalid JSON format or empty string after trim in $fileName.');
        print('File path: $filePath');
        print('File content: $jsonString');
        // 사용자에게 에러 알림 (예: AlertDialog)
        // ...
        return [];
      }

      return List<Map<String, dynamic>>.from(jsonDecode(jsonString)); // 수정된 부분
    } else {
      print('Error: File does not exist after copying from assets: $filePath');
      // 사용자에게 에러 알림 (예: AlertDialog)
      // ...
      return [];
    }
  } catch (e) {
    print('파일 처리 중 오류가 발생했습니다: $e');
    // 사용자에게 에러 알림 (예: AlertDialog)
    // ...
    return [];
  }
}

// Word 데이터 읽기
Future<List<Map<String, dynamic>>> readWordData(int n) async {
  String fileName = 'data_n$n.json';
  String directoryName = 'data';
  return _readJsonFile(fileName, directoryName, false);
}

// Total 데이터 읽기
Future<List<Map<String, dynamic>>> readWordTotalData() async {
  String fileName = 'total_data.json';
  String directoryName = 'data';
  return _readJsonFile(fileName, directoryName, true);
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<void> _writeJsonFile(
    List<Map<String, dynamic>> jsonList, String filePath) async {
  try {
    // 1. JSON 리스트를 JSON 문자열로 인코딩
    final jsonString = jsonEncode(jsonList);

    // 2. 파일 생성 및 쓰기
    final path = await _localPath;
    final file = File('$path/$filePath');
    await file.writeAsString(jsonString);
  } catch (e) {
    print('Error saving JSON list to file: $e');
  }
}

Future<void> writeWordData(int n, List<Map<String, dynamic>> jsonList) async {
  String filePath = 'data/data_n$n.json';
  _writeJsonFile(jsonList, filePath);
}

Future<void> writeWordTotalData(List<Map<String, dynamic>> jsonList) async {
  String filePath = 'data/total_data.json';
  _writeJsonFile(jsonList, filePath);
}
