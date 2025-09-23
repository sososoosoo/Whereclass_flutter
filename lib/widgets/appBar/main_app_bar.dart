import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize {
    // Use a default value, but this will be overridden in build
    return const Size.fromHeight(kToolbarHeight);
  }

  void _showToastNotification(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastNotification(
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // AppBar height: 10% of screen height, min 56, max 120
    final double appBarHeight = screenHeight * 0.10;
    final double clampedHeight = appBarHeight.clamp(56.0, 120.0);
    return SizedBox(
      height: clampedHeight,
      child: AppBar(
        centerTitle: false,
        toolbarHeight: clampedHeight,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: SvgPicture.asset(
            'assets/logos/whereclass_logo_black.svg',
            width: 100,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.grey,
                size: 28, // 아이콘 크기도 함께 증가
              ),
              onPressed: () {
                _showToastNotification(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToastNotification extends StatefulWidget {
  final VoidCallback onDismiss;
  
  const _ToastNotification({required this.onDismiss});

  @override
  State<_ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<_ToastNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 애니메이션 시작
    _controller.forward();

    // 2초 후 사라지기 시작
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 60 + _slideAnimation.value,
          left: 16,
          right: 16,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '알림 기능은 준비중이에요',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}