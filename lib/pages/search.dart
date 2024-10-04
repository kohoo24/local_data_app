import 'package:flutter/material.dart';
import 'package:localdata_app01/services/api_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<String, dynamic>? regionData;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;
  String? _selectedEndYear;
  String? _selectedEndMonth;
  String? _selectedEndDay;

  List<String> years = ['2023', '2024'];
  List<String> months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadRegionData(); // Load region data when the screen initializes
  }

  Future<void> _loadRegionData() async {
    final jsonString =
        await rootBundle.loadString('assets/intuitive_region_codes.json');
    setState(() {
      regionData = json.decode(jsonString);
    });
  }

  Future<void> _search() async {
    if (_selectedCity == null ||
        _selectedDistrict == null ||
        _selectedYear == null ||
        _selectedMonth == null ||
        _selectedDay == null ||
        _selectedEndYear == null ||
        _selectedEndMonth == null ||
        _selectedEndDay == null) {
      print('모든 항목을 선택해 주세요.');
      return;
    }

    final cityCode = regionData!['cities'][_selectedCity]['code'];
    final districtCode = regionData!['cities'][_selectedCity]['districts']
        .firstWhere((element) => element['name'] == _selectedDistrict)['code'];

    final selectedLocalCode = districtCode;
    final startDate = _selectedYear! + _selectedMonth! + _selectedDay!;
    final endDate = _selectedEndYear! + _selectedEndMonth! + _selectedEndDay!;

    try {
      final results = await fetchApiData(selectedLocalCode, startDate, endDate);
      setState(() {
        _searchResults = results;
      });
      print('검색 결과: $_searchResults');
    } catch (e) {
      print('검색 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final double horizontalSpacing = screenWidth * 0.02; // 너비의 2%를 간격으로 설정
    final double verticalSpacing = mediaQuery.size.height * 0.02;

    return Scaffold(
      appBar: AppBar(title: const Text('기간별 지역 신규 업장 검색')),
      body: regionData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(horizontalSpacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Column 크기를 자식에 맞게 조정
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCity,
                            hint: const Text('시 선택'),
                            items: regionData!['cities']
                                .keys
                                .map<DropdownMenuItem<String>>((city) {
                              return DropdownMenuItem<String>(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                                _selectedDistrict = null;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: horizontalSpacing),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDistrict,
                            hint: const Text('구 선택'),
                            items: _selectedCity == null
                                ? []
                                : regionData!['cities'][_selectedCity]
                                        ['districts']
                                    .map<DropdownMenuItem<String>>((district) {
                                    return DropdownMenuItem<String>(
                                      value: district['name'],
                                      child: Text(district['name']),
                                    );
                                  }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDistrict = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),

                    // 시작 날짜와 종료 날짜 선택을 세로로 배치
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('시작 날짜'),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedYear,
                                hint: const Text('년'),
                                items: years.map((year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: horizontalSpacing),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedMonth,
                                hint: const Text('월'),
                                items: months.map((month) {
                                  return DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(month),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonth = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: horizontalSpacing),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedDay,
                                hint: const Text('일'),
                                items: days.map((day) {
                                  return DropdownMenuItem<String>(
                                    value: day,
                                    child: Text(day),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDay = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('종료 날짜'),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedEndYear,
                                hint: const Text('년'),
                                items: years.map((year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEndYear = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: horizontalSpacing),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedEndMonth,
                                hint: const Text('월'),
                                items: months.map((month) {
                                  return DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(month),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEndMonth = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: horizontalSpacing),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedEndDay,
                                hint: const Text('일'),
                                items: days.map((day) {
                                  return DropdownMenuItem<String>(
                                    value: day,
                                    child: Text(day),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEndDay = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),

                    ElevatedButton(
                      onPressed: _search,
                      child: const Text('검색'),
                    ),

                    SizedBox(height: verticalSpacing),

                    _searchResults.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              return ListTile(
                                title: Text(item['opnSvcNm']), // 개방 서비스명
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('사업장명: ${item['bplcNm']}'),
                                    Text('주소: ${item['siteWhlAddr']}'),
                                    Text('영업 상태: ${item['trdStateNm']}'),
                                  ],
                                ),
                              );
                            },
                          )
                        : const Center(child: Text('검색 결과가 없습니다')),
                  ],
                ),
              ),
            ),
    );
  }
}
