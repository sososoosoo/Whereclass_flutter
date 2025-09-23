import 'package:flutter/material.dart';

class MoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MoreAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 백버튼 자동 생성 비활성화
      title: const Text('더보기'),
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
    );
  }
}
