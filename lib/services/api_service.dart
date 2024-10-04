import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<List<Map<String, dynamic>>> fetchApiData(
    String localcode, String bgnYmd, String endYmd) async {
  // Firebase Functions에서 설정한 프록시 API 엔드포인트
  const String firebaseFunctionsUrl =
      'https://localdataapp.cloudfunctions.net/apiProxy'; // 여기에 Firebase 프로젝트 ID를 입력

  // URL 파라미터를 추가하여 Firebase Functions로 전달
  String urlWithParams =
      '$firebaseFunctionsUrl?localCode=$localcode&startDate=$bgnYmd&endDate=$endYmd';

  // 디버깅 로그 추가
  print('Firebase Functions API 호출 URL: $urlWithParams');

  try {
    final response = await http.get(Uri.parse(urlWithParams));

    // 응답 상태 코드와 본문 로그 추가
    print('Firebase Functions 응답 상태 코드: ${response.statusCode}');
    print('Firebase Functions 응답 본문: ${response.body}');

    if (response.statusCode == 200) {
      // Firebase Functions에서 받은 XML 데이터 파싱
      final document = xml.XmlDocument.parse(response.body);
      final rows = document.findAllElements('row');
      if (rows.isEmpty) {
        print('데이터가 없습니다.');
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
      print('Firebase Functions 호출 실패 - 상태 코드: ${response.statusCode}');
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Firebase Functions 호출 중 오류 발생: $e');
    rethrow;
  }
}
