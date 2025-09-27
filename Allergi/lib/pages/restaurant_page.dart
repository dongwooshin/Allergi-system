import 'package:flutter/material.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

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
              // 지도에서 찾기
              const Text(
                "지도에서 찾기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                        "https://developers.google.com/maps/documentation/maps-static/images/error-image-generic.png"), // 더미 지도
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "지도 뷰 (구글맵/카카오맵 연동 가능)",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 범례
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Legend(color: Colors.green, label: "안전"),
                  SizedBox(width: 16),
                  _Legend(color: Colors.orange, label: "주의"),
                  SizedBox(width: 16),
                  _Legend(color: Colors.red, label: "위험"),
                ],
              ),

              const SizedBox(height: 24),

              // 목록에서 찾기
              const Text(
                "목록에서 찾기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _RestaurantItem(
                name: "비건 키친 (Vegan Kitchen)",
                category: "퓨전 비건",
                rating: 4.9,
                statusColor: Colors.green,
              ),
              _RestaurantItem(
                name: "해물명가",
                category: "한식 해물",
                rating: 4.5,
                statusColor: Colors.orange,
              ),
              _RestaurantItem(
                name: "안돈 송도직영점",
                category: "일식 돈가츠",
                rating: 4.8,
                statusColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 범례 위젯
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// 식당 아이템 위젯
class _RestaurantItem extends StatelessWidget {
  final String name;
  final String category;
  final double rating;
  final Color statusColor;

  const _RestaurantItem({
    required this.name,
    required this.category,
    required this.rating,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(category, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Row(
            children: [
              Text(rating.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
