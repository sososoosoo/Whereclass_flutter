import 'package:flutter/material.dart';

class FavoritesPopup extends StatelessWidget {
  const FavoritesPopup({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onDismiss();
            },
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 1,
            child: GestureDetector(
              onTap: () {
                onDismiss();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    // X button in the top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {
                          onDismiss();
                        },
                        icon: Icon(Icons.close_rounded, color: Colors.grey),
                      ),
                    ),
                    // Centered text
                    Center(
                      child: Text(
                        '즐겨찾기 기능 추가 예정',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
