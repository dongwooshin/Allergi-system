import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scanner_page.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key});

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = "";

  String? _nickname;
  bool _loadingUser = true;

  List<String> _algList = []; // ✅ 알레르기 성분 목록 state

  String _productName = "";
  String _productBarcode = "";

  String _userInput = ""; // 사용자가 입력한 값 저장

  bool _productExists = false;

  bool _isSearching = false; // 제품 검색 로딩 상태

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Firestore에서 사용자 닉네임 가져오기
  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection("users").doc(
            uid).get();
        if (doc.exists) {
          setState(() {
            _nickname = doc["nickname"] ?? "사용자";
          });
        }
      }
    } catch (e) {
      debugPrint("유저 데이터 로드 에러: $e");
    } finally {
      setState(() {
        _loadingUser = false;
      });
    }
  }

  /// 공공 API - 제품 검색 (바코드번호 또는 제품명)
  Future<void> _searchProduct({String? barcode, String? name}) async {
    setState(() {
      _result = "조회 중...";
      _algList = []; // ✅ 새 조회 시작 시 기존 목록 비우기
      _productExists = false; // ← ❗ 반드시 false로 초기화
      _isSearching = true;
    });

    try {
      // 🔑 API 기본정보
      // 푸드QR기본정도
      const String baseUrl = "https://foodqr.kr/openapi/service/qr1003/F003?accessKey=AAABmg9sLG1939prXwQU/1NiLadMnpv7s9M9Mw==";

      // URL 생성
      final String url;
      if (barcode != null) {
        url = "$baseUrl&_type=json&brcdNo=$barcode";
      } else {
        url = "$baseUrl&_type=json&prdctNm=$name";
      }

      // 🔥 URL 로그 찍기
      print("🔍 API Request URL: $url");

      final response = await http.get(Uri.parse(url));

      // 🔥 상태코드 로그
      print("📡 Status Code: ${response.statusCode}");

      // 🔥 Raw Body 로그
      print("📦 Raw Response Body:");
      print(response.body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final bodyItems = json['response']?['body']?['items'];

        if (bodyItems == null || bodyItems is String || bodyItems == "") {
          bool ok = await _fallbackProductLookup(_userInput);

          if (!ok) {
            setState(() {
              _productExists = false;
              _result = "‘$_userInput’ 에 해당하는 제품을 찾을 수 없습니다.";
            });
          }
          return;
        }

        // JSON 안전하게 접근
        final item = json['response']?['body']?['items']?['item'];

        if (item == null) {
          setState(() {
            _productName = "";
            _productBarcode = "";
            _algList = [];
            _productExists = false; // ❗중요
            _result = "‘$_userInput’ 에 해당하는 제품을 찾을 수 없습니다.";
          });
          return;
        }

        // 개별 필드 추출
        final brcdNo = item['brcdNo'] ?? "";
        final prdctNm = item['prdctNm'] ?? "";

        print("📄 Parsed JSON:");
        print("prdctNm: $prdctNm");
        print("brcdNo: $brcdNo");

        setState(() {
          _productName = prdctNm;
          _productBarcode = brcdNo;
        });

        // 푸드QR 알레르기정보
        const String baseUrl = "https://foodqr.kr/openapi/service/qr1009/F009?accessKey=AAABmg9sLG1939prXwQU/1NiLadMnpv7s9M9Mw==";

        // URL 생성
        final String url;
        url = "$baseUrl&_type=json&brcdNo=$brcdNo";

        // 🔥 URL 로그 찍기
        print("🔍 API Request URL: $url");

        final response2 = await http.get(Uri.parse(url));

        // 🔥 상태코드 로그
        print("📡 Status Code: ${response2.statusCode}");

        // 🔥 Raw Body 로그
        print("📦 Raw Response Body2:");
        print(response2.body);


        if (response2.statusCode == 200) {
          final json = jsonDecode(response2.body);

          // JSON 안전하게 접근
          final items = json['response']?['body']?['items']?['item'];

          if (items == null) {
            bool ok = await _fallbackProductLookup(brcdNo);
            if (!ok) {
              setState(() {
                _productName = "";
                _productBarcode = "";
                _algList = [];
                _productExists = false;
                _result = "‘$_userInput’ 에 해당하는 제품을 찾을 수 없습니다.";
              });
            }
            return;
          }

          List<String> algList = [];

          if (items is List) {
            algList = items
                .map<String>((e) => e['algCsgMtrNm']?.toString() ?? "")
                .where((s) => s.isNotEmpty)
                .toList();
          } else if (items is Map) {
            final algName = items['algCsgMtrNm']?.toString() ?? "";
            if (algName.isNotEmpty) {
              algList = [algName];
            }
          }

          print("📄 algCsgMtrNm 목록: $algList");

          // ✅ 여기서 state에 저장
          setState(() {
            _algList = algList;
            _result = "알레르기 유발 물질: ${algList.join(', ')}";
            _productExists = true; // ❗ 이 시점에서만 설정
          });
        }

        setState(() {
          // TODO: data['row'][0]['PRDLST_NM'] 등 실제 값 추출해서 카드에 뿌리기
          // _result = const JsonEncoder.withIndent("  ").convert(data);
        });
      } else {
        setState(() {
          _result = "API 호출 실패 (status: ${response.statusCode})";
          _algList = []; // ✅ 실패 시도 초기화
        });
      }
    } catch (e) {
      setState(() {
        _result = "에러 발생: $e";
        _productExists = false;
      });
    } finally {
      // 🔥 무조건 마지막에 로딩 종료
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<bool> _fallbackProductLookup(String barcode) async {
    final url = "https://upsertproduct-jtz6deupta-du.a.run.app/?barcode=$barcode";

    print("🔍 Fallback API Request: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body);

      if (json["ok"] != true) return false;
      if (json["data"] == null) return false;

      final data = json["data"];
      final display = data["display"];

      // 제품명 & 바코드
      final name = data["name"] ?? "";
      final code = data["barcode"] ?? "";

      // 알레르기 목록 (warnings → labelKo)
      List<String> warnings = [];
      if (display != null &&
          display["warnings"] != null &&
          display["warnings"] is List) {
        warnings = (display["warnings"] as List)
            .map((e) => e["labelKo"]?.toString() ?? "")
            .where((e) => e.isNotEmpty)
            .toList();
      }

      setState(() {
        _productName = name;
        _productBarcode = code;
        _algList = warnings;
        _productExists = true;
        _result = warnings.isEmpty
            ? "알레르기 정보가 없습니다."
            : "알레르기: ${warnings.join(', ')}";
      });

      return true; // Fallback 성공
    } catch (e) {
      print("Fallback API error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          SafeArea(
            child: _loadingUser
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 로고 + 닉네임
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ALLERGI",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F80ED),
                        ),
                      ),
                      Text(
                        "안녕하세요, ${_nickname ?? "사용자"}!",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 카드 1 : 제품 정보 검색
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "제품 정보 검색",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "제품의 바코드 또는 이름으로 알레르기 위험도를 확인하세요.",
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // 입력창
                        TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: "바코드 번호 또는 제품명 입력",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 제품 확인 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();

                              final input = _inputController.text.trim();
                              if (input.isEmpty) return;

                              setState(() {
                                _userInput = input; // 🔥 사용자 입력값 기억해두기
                              });

                              if (RegExp(r'^[0-9]+$').hasMatch(input)) {
                                _searchProduct(barcode: input); // 숫자 → 바코드
                              } else {
                                _searchProduct(name: input); // 문자 → 제품명
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F80ED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("제품 확인"),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 카메라 버튼
                        OutlinedButton.icon(
                          onPressed: () async {
                            final scanned = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ScannerPage()),
                            );

                            if (scanned != null && scanned is String) {
                              FocusScope.of(context).unfocus();  // 🔥 키보드 강제 닫기
                              setState(() {
                                _inputController.text = scanned; // ✅ 입력창에 자동 세팅
                                _userInput = scanned; // 🔥 사용자 입력값 기억해두기
                              });
                              _searchProduct(
                                  barcode: scanned); // ✅ 자동으로 제품 확인 실행
                            }
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text("카메라로 스캔"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 카드 2 : 안내문
                  // 카드 2 : 안내문 / 알레르기 목록
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.grey),
                        const SizedBox(height: 8),
                        if (_isSearching) ...[
                          // 🔥 로딩 중일 때: 안내문 대신 로딩 메시지
                          const Text(
                            "제품 정보를 불러오는 중입니다...",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (!_productExists && _algList.isEmpty) ...[
                          // 제품 없음 케이스
                          if (_result.contains("해당하는 제품을 찾을 수 없습니다")) ...[
                            Text(
                              _result,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else
                            ...[
                              const Text(
                                "제품 바코드 또는 제품명을 입력하고 '제품 확인' 버튼을 누르세요.\n\n"
                                    "예시: 08801045121086 (바코드) 또는 오늘밥상 바로 무쳐먹는 파채양념 (제품명)",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                        ] else
                          ...[
                            // 🔥 제품 있음 → 제품명 + 바코드 + 알레르기 표시
                            Text(
                              _productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "바코드: $_productBarcode",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              "알레르기 유발 물질",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _algList.join(', '),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 🔥 검색 중일 때 전체 화면 오버레이
          if (_isSearching)
            Positioned.fill(
              child: Container(
                // color: Colors.black.withOpacity(0.2), // 반투명 배경
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
