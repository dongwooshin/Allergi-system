import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _customAllergyController = TextEditingController();

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

  bool _loading = false;

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
    final text = _customAllergyController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _customAllergies.add(text);
        _customAllergyController.clear();
      });
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("필수 항목을 모두 입력해주세요.")),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      // Firebase Authentication
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore User Document
      await FirebaseFirestore.instance.collection("users").doc(cred.user!.uid).set({
        "email": email,
        "nickname": nickname,
        "allergies": _selectedAllergies,
        "customAllergies": _customAllergies,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 성공!")),
        );
        Navigator.pop(context); // 로그인 화면으로 이동
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 실패: ${e.message}")),
      );
    } finally {
      setState(() => _loading = false);
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
              const Center(
                child: Text(
                  "회원가입",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // 이메일
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "이메일 *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 비밀번호
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "비밀번호 * (6자 이상)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 비밀번호 확인
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "비밀번호 확인 *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 닉네임
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: "닉네임 *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 주요 알레르기 선택
              const Text("주요 알레르기 선택"),
              const SizedBox(height: 8),
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
                      controller: _customAllergyController,
                      decoration: const InputDecoration(
                        hintText: "예: 복숭아, 토마토 등",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addCustomAllergy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
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

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("회원가입"),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "이미 계정이 있으신가요? 로그인",
                    style: TextStyle(color: Color(0xFF2F80ED)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
