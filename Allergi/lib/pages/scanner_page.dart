import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("바코드 스캔")),
      body: Stack(
        children: [
          // 카메라 프리뷰
          MobileScanner(
            onDetect: (capture) {
              if (_scanned) return;
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _scanned = true;
                  Navigator.pop(context, code); // 결과 반환
                }
              }
            },
          ),

          // 중앙 네모 박스 오버레이
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.redAccent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 반투명 검정 배경 (네모박스 바깥)
          Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxSize = 250.0;
                final horizontal = (constraints.maxWidth - boxSize) / 2;
                final vertical = (constraints.maxHeight - boxSize) / 2;

                return Stack(
                  children: [
                    // 위
                    Positioned.fill(
                      child: Column(
                        children: [
                          Container(height: vertical, color: Colors.black38),
                          Row(
                            children: [
                              Container(width: horizontal, height: boxSize, color: Colors.black38),
                              const Spacer(),
                              Container(width: horizontal, height: boxSize, color: Colors.black38),
                            ],
                          ),
                          Expanded(child: Container(color: Colors.black38)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 안내 문구
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "바코드를 네모 안에 맞춰주세요",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
