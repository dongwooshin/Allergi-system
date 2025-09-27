import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllergyPage extends StatefulWidget {
  const AllergyPage({super.key});

  @override
  State<AllergyPage> createState() => _AllergyPageState();
}

class _AllergyPageState extends State<AllergyPage> {
  final List<String> _mainAllergies = [
    "갑각류 (Crustaceans)",
    "견과류 (Tree Nuts)",
    "땅콩 (Peanuts)",
    "유제품 (Dairy)",
    "밀 (Wheat)",
    "대두 (Soy)",
    "계란 (Eggs)",
    "생선 (Fish)",
    "참깨 (Sesame)",
    "아황산염 (Sulfites)"
  ];

  List<String> _selectedAllergies = [];
  List<String> _customAllergies = [];
  final TextEditingController _customController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
        if (doc.exists) {
          setState(() {
            _selectedAllergies = List<String>.from(doc["allergies"] ?? []);
            _customAllergies = List<String>.from(doc["customAllergies"] ?? []);
          });
        }
      }
    } catch (e) {
      debugPrint("알레르기 데이터 불러오기 에러: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection("users").doc(uid).update({
          "allergies": _selectedAllergies,
          "customAllergies": _customAllergies,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("알레르기 정보가 저장되었습니다.")),
        );
      }
    } catch (e) {
      debugPrint("알레르기 데이터 저장 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("저장 실패. 다시 시도해주세요.")),
      );
    }
  }

  void _toggleAllergy(String allergy) {
    setState(() {
      if (_selectedAllergies.contains(allergy)) {
        _selectedAllergies.remove(allergy);
      } else {
        _selectedAllergies.add(allergy);
      }
    });
  }

  void _addCustomAllergy() {
    final text = _customController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _customAllergies.add(text);
        _customController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "내 알레르기 정보 수정",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 주요 알레르기 선택
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _mainAllergies.map((allergy) {
                  final isSelected = _selectedAllergies.contains(allergy);
                  return ChoiceChip(
                    label: Text(allergy),
                    selected: isSelected,
                    onSelected: (_) => _toggleAllergy(allergy),
                    selectedColor: const Color(0xFF2F80ED),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 기타 알레르기 직접 입력
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      decoration: InputDecoration(
                        hintText: "예: 복숭아, 토마토 등",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addCustomAllergy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      minimumSize: const Size(60, 48),
                    ),
                    child: const Text("추가"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 추가된 customAllergies 표시
              Wrap(
                spacing: 8,
                children: _customAllergies.map((item) {
                  return Chip(
                    label: Text(item),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _customAllergies.remove(item);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("알레르기 정보 저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
