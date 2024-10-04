import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<List<Map<String, dynamic>>> fetchApiData(
    String localcode, String bgnYmd, String endYmd) async {
  // API URL 구성
  const String apiUrl =
      'http://www.localdata.go.kr/platform/rest/TO0/openDataApi?authKey=tgexWmZK0NOb1z8CYwiq9QI5DrGPHtUm7ZjAAPKO0CY=';
  String urlWithParams =
      '$apiUrl&localCode=$localcode&bgnYmd=$bgnYmd&endYmd=$endYmd';

  // 디버깅 로그 추가
  print('API 호출 URL: $urlWithParams');

  try {
    final response = await http.get(Uri.parse(urlWithParams));

    // 응답 상태 코드와 본문 로그 추가
    print('API 응답 상태 코드: ${response.statusCode}');
    print('API 응답 본문: ${response.body}');

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final rows = document.findAllElements('row');
      if (rows.isEmpty) {
        print('데이터가 없습니다.'); // 데이터가 없을 경우에 대한 처리 추가
        return [];
      }

      List<Map<String, dynamic>> results = [];
      for (var element in rows) {
        results.add({
          'rowNum': element.findElements('rowNum').single.text,
          'opnSvcNm': element.findElements('opnSvcNm').single.text,
          'bplcNm': element.findElements('bplcNm').single.text,
          'siteWhlAddr': element.findElements('siteWhlAddr').single.text,
          'trdStateNm': element.findElements('trdStateNm').single.text,
        });
      }

      // 파싱된 데이터 확인을 위한 로그
      print('파싱된 데이터: $results');
      return results;
    } else {
      print('API 호출 실패 - 상태 코드: ${response.statusCode}');
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('API 호출 중 오류 발생: $e');
    rethrow;
  }
}
