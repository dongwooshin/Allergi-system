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
        final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
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
    });

    try {
      // 🔑 API 기본정보
      const String baseUrl = "https://api.foodsafetykorea.go.kr/api";
      const String apiKey = "AAABmYnjBKr+VWpHU6KCcYu00I7fiN0waXKHuw==";

      // URL 생성
      final String url;
      if (barcode != null) {
        url = "$baseUrl/$apiKey/PRODUCT01/json/1/5?BAR_CD=$barcode";
      } else {
        url = "$baseUrl/$apiKey/PRODUCT01/json/1/5?PRDLST_NM=$name";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // TODO: data['row'][0]['PRDLST_NM'] 등 실제 값 추출해서 카드에 뿌리기
          _result = const JsonEncoder.withIndent("  ").convert(data);
        });
      } else {
        setState(() {
          _result = "API 호출 실패 (status: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _result = "에러 발생: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
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
                          final input = _inputController.text.trim();
                          if (input.isEmpty) return;
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
                          setState(() {
                            _inputController.text = scanned; // ✅ 입력창에 자동 세팅
                          });
                          _searchProduct(barcode: scanned); // ✅ 자동으로 제품 확인 실행
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "제품 바코드 또는 제품명을 입력하고 '제품 확인' 버튼을 누르세요.\n\n"
                          "예시: 8801007830607 (바코드) 또는 새우깡 (제품명)",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 결과 출력
              if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
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
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
