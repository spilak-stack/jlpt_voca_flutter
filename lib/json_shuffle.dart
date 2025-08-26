import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

// JSON 데이터를 섞는 함수
Future<void> jsonShuffle(int n) async {
  String fileName = 'data_n$n.json';
  String directoryName = 'data'; // 데이터를 저장할 디렉토리 이름

  try {
    // 1. 애플리케이션 문서 디렉토리 경로를 가져옵니다.
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // 2. 데이터를 저장할 디렉토리 경로를 생성합니다.
    String dirPath = '$appDocPath/$directoryName';
    Directory dataDir = Directory(dirPath);

    // 3. 디렉토리가 존재하지 않으면 생성합니다.
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
      print('디렉토리를 생성했습니다: $dirPath');
    }

    // 4. 파일 경로를 생성합니다.
    String filePath = '$dirPath/$fileName';
    File file = File(filePath);

    // 5. 파일이 존재하지 않으면 경고 메시지를 출력하고 함수를 종료합니다.
    if (!await file.exists()) {
      print('파일이 존재하지 않아 복사를 시작합니다: $filePath');
      await copyAssetFileToDevice(fileName, filePath);
    }

    // 6. 파일에서 JSON 데이터를 읽습니다.
    String jsonString = await file.readAsString();
    List<dynamic> data = jsonDecode(jsonString);

    // 7. ID 섞기 (1부터 시작)
    final length = data.length;
    final numbers = List.generate(length, (index) => index + 1); // 1부터 시작하도록 수정
    numbers.shuffle(Random());

    // 8. 데이터에 섞인 ID 할당
    for (var i = 0; i < length; i++) {
      data[i]['ID2'] = numbers[i];
      data[i]['Pass'] = 0;
    }

    // 9. ID를 기준으로 데이터 정렬
    data.sort((a, b) {
      // ID가 int 또는 String 타입이 모두 가능하다고 가정
      int idA = (a['ID2'] is int) ? a['ID2'] : int.parse(a['ID2']);
      int idB = (b['ID2'] is int) ? b['ID2'] : int.parse(b['ID2']);
      return idA.compareTo(idB);
    });

    // 10. 정렬된 데이터를 JSON 문자열로 변환
    final shuffledJsonString = jsonEncode(data);

    // 11. 파일에 JSON 데이터 쓰기
    await file.writeAsString(shuffledJsonString);

    print('JSON 파일이 섞이고 저장되었습니다. 경로는: $filePath');
  } catch (e) {
    print('파일 처리 중 오류가 발생했습니다: $e');
  }
}

Future<void> jsonInitShuffle(int n) async {
  String fileName = 'data_n$n.json';
  String directoryName = 'data'; // 데이터를 저장할 디렉토리 이름

  try {
    // 1. 애플리케이션 문서 디렉토리 경로를 가져옵니다.
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // 2. 데이터를 저장할 디렉토리 경로를 생성합니다.
    String dirPath = '$appDocPath/$directoryName';
    Directory dataDir = Directory(dirPath);

    // 3. 디렉토리가 존재하지 않으면 생성합니다.
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
      print('디렉토리를 생성했습니다: $dirPath');

      // 4. 파일 경로를 생성합니다.
      String filePath = '$dirPath/$fileName';
      File file = File(filePath);

      // 5. 파일이 존재하지 않으면 경고 메시지를 출력하고 함수를 종료합니다.
      if (!await file.exists()) {
        print('파일이 존재하지 않아 복사를 시작합니다: $filePath');
        await copyAssetFileToDevice(fileName, filePath);
      }

      // 6. 파일에서 JSON 데이터를 읽습니다.
      String jsonString = await file.readAsString();
      List<dynamic> data = jsonDecode(jsonString);

      // 7. ID 섞기 (1부터 시작)
      final length = data.length;
      final numbers =
          List.generate(length, (index) => index + 1); // 1부터 시작하도록 수정
      numbers.shuffle(Random());

      // 8. 데이터에 섞인 ID 할당
      for (var i = 0; i < length; i++) {
        data[i]['ID2'] = numbers[i];
      }

      // 9. ID를 기준으로 데이터 정렬
      data.sort((a, b) {
        // ID가 int 또는 String 타입이 모두 가능하다고 가정
        int idA = (a['ID2'] is int) ? a['ID2'] : int.parse(a['ID2']);
        int idB = (b['ID2'] is int) ? b['ID2'] : int.parse(b['ID2']);
        return idA.compareTo(idB);
      });

      // 10. 정렬된 데이터를 JSON 문자열로 변환
      final shuffledJsonString = jsonEncode(data);

      // 11. 파일에 JSON 데이터 쓰기
      await file.writeAsString(shuffledJsonString);

      print('JSON 파일이 섞이고 저장되었습니다. 경로는: $filePath');
    }
  } catch (e) {
    print('파일 처리 중 오류가 발생했습니다: $e');
  }
}

Future<void> copyAssetFileToDevice(
    String assetFileName, String deviceFilePath) async {
  try {
    // assets에서 파일 로드
    final byteData = await rootBundle.load('assets/data/$assetFileName');
    final buffer = byteData.buffer;

    // 기기 저장소에 파일 쓰기
    await File(deviceFilePath).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    print('파일이 기기 저장소에 복사되었습니다: $deviceFilePath');
  } catch (e) {
    print('파일 복사 중 오류가 발생했습니다: $e');
  }
}

Future<void> jsonWordTotalReset(int n) async {
  String fileName = 'total_data.json';
  String directoryName = 'data'; // 데이터를 저장할 디렉토리 이름

  try {
    // 1. 애플리케이션 문서 디렉토리 경로를 가져옵니다.
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // 2. 데이터를 저장할 디렉토리 경로를 생성합니다.
    String dirPath = '$appDocPath/$directoryName';
    Directory dataDir = Directory(dirPath);

    // 3. 디렉토리가 존재하지 않으면 생성합니다.
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
      print('디렉토리를 생성했습니다: $dirPath');
    }

    // 4. 파일 경로를 생성합니다.
    String filePath = '$dirPath/$fileName';
    File file = File(filePath);

    // 5. 파일이 존재하지 않으면 경고 메시지를 출력하고 함수를 종료합니다.
    if (!await file.exists()) {
      print('파일이 존재하지 않아 복사를 시작합니다: $filePath');
      await copyAssetFileToDevice(fileName, filePath);
    }

    // 6. 파일에서 JSON 데이터를 읽습니다.
    String jsonString = await file.readAsString();
    List<dynamic> data = jsonDecode(jsonString);

    data[n - 1]['Solve'] = 0;
    data[n - 1]['Wrong'] = 0;
    data[n - 1]['Index'] = 0;
    data[n - 1]['Rest'] = data[n - 1]['Total'];

    // 10. 정렬된 데이터를 JSON 문자열로 변환
    final shuffledJsonString = jsonEncode(data);

    // 11. 파일에 JSON 데이터 쓰기
    await file.writeAsString(shuffledJsonString);

    print('JSON 파일 리셋. 경로는: $filePath');
  } catch (e) {
    print('파일 처리 중 오류가 발생했습니다: $e');
  }
}
