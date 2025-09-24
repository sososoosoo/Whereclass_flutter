import 'package:flutter/material.dart';
import 'package:whc_proto/methods/screen_controller.dart';
import 'package:whc_proto/widgets/appBar/appBarRouter.dart';
import 'package:whc_proto/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whereclass',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0; // 선택된 탭 인덱스 추적

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppScreen>(
      valueListenable: ScreenController.current,
      builder: (context, currentScreen, child) {
        // 현재 화면에 따라 선택된 인덱스 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          int newIndex = switch (currentScreen) {
            AppScreen.main => 0,
            AppScreen.more => 2,
            _ => 0, // 검색, 지도 등은 홈으로 간주
          };
          if (_selectedIndex != newIndex) {
            setState(() {
              _selectedIndex = newIndex;
            });
          }
        });

        return Scaffold(
          appBar: AppBarRouter.current as PreferredSizeWidget?,
          body: SafeArea(
            child: const ScreenRouter(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: Colors.transparent, // 기본 인디케이터 제거
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0 ? const Color(0xFF00AEFF) : Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.home,
                  color: const Color(0xFF00AEFF),
                ),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.star,
                  color: _selectedIndex == 1 ? const Color(0xFF00AEFF) : Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.star,
                  color: const Color(0xFF00AEFF),
                ),
                label: '즐겨찾기',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.menu,
                  color: _selectedIndex == 2 ? const Color(0xFF00AEFF) : Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.menu,
                  color: const Color(0xFF00AEFF),
                ),
                label: '더보기',
              ),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // 라벨 항상 표시
            onDestinationSelected: (i) {
              setState(() {
                _selectedIndex = i;
              });
              
              if (i == 0) {
                // 홈
                ScreenController.current.value = AppScreen.main;
              } else if (i == 1) {
                // 즐겨찾기 토스트 메시지 표시 (선택 상태는 유지하지 않음)
                setState(() {
                  _selectedIndex = 0; // 홈으로 되돌리기
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('즐겨찾기 기능은 준비중이에요'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.black87,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.all(16),
                  ),
                );
              } else if (i == 2) {
                // 더보기 화면으로 이동
                ScreenController.current.value = AppScreen.more;
              }
            },
          ),
        );
      },
    );
  }
}
