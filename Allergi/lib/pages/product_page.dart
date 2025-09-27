import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Danger 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Danger",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // 제품 이미지
              Center(
                child: Image.network(
                  "https://shopping-phinf.pstatic.net/main_8231249/82312499764.2.jpg?type=f640", // 새우깡 예시 이미지
                  height: 150,
                ),
              ),
              const SizedBox(height: 16),

              // 제품명 / 제조사 / 바코드
              const Text(
                "새우깡 (Shrimp Crackers)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("농심 (Nongshim)",
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              const Text("바코드: 8801007830607",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),

              // 알레르기 경고
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "주의! 감지된 알레르기 유발 성분:\n- 갑각류 (Crustaceans)",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),

              // 원재료명
              const Text(
                "원재료명:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "소맥분(밀: 미국산, 호주산), 전분(태국산), 미강유, 새우(국산), 팜유, 새우풍미유, 탈지대두(대두), 유청(우유)",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 28),

              // 대체 식품 추천 안내
              const Text(
                "대체 식품 추천",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                "나의 알레르기 정보를 바탕으로 안전한 대체 식품을 추천받을 수 있습니다.\n"
                    "우선적으로 유사한 종류의 제품을 데이터베이스에서 검색하며,\n정보가 없을 경우 AI가 추천합니다.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 대체 식품 추천 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text("대체 식품 추천받기"),
                ),
              ),
              const SizedBox(height: 24),

              // 추천 식품 리스트
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("꼬깔콘 고소한맛 (Kkokkal Corn Original)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F80ED))),
                    SizedBox(height: 4),
                    Text("제조사: 롯데웰푸드 (Lotte Wellfood)",
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("포카칩 (Pocachip)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F80ED))),
                    SizedBox(height: 4),
                    Text("제조사: 오리온 (Orion)",
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "추천 정보는 참고용이며, 구매 전 반드시 제품 라벨을 다시 확인해주세요.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
