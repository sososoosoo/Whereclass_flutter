import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // 토스트 메시지 표시 함수
  void _showToastMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 제보하기 구글폼 열기
  Future<void> _openReportForm(BuildContext context) async {
    const String url = 'https://docs.google.com/forms/d/e/1FAIpQLScQyzMfIqaVqv84Y2R-FG0ZAaehuhQQTYMoXW0RaANzSx7kAg/viewform?usp=dialog';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('의견 보내기'),
          content: const Text('여러분의 소중한 의견은 정확도를 높이는 데 큰 도움이 됩니다.'),
          actions: [
            TextButton(
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    _showToastMessage(context, '링크를 열 수 없습니다');
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  _showToastMessage(context, '브라우저를 열 수 없습니다. 나중에 다시 시도해주세요.');
                }
              },
              child: const Text('의견 보내기'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '닫기',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  // 지도 가이드 열기
  void _openMapGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const MapGuideDialog();
      },
    );
  }

  // 출시 알림 신청 구글폼 열기
  Future<void> _openReleaseNotification(BuildContext context) async {
    const String url = 'https://docs.google.com/forms/d/e/1FAIpQLSdF0xs7hcQKQ6JGNsbvVIYoCwMukh0u4O8GxAcpp9WjJWx24Q/viewform?usp=dialog';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('출시 알림'),
          content: const Text('신청폼을 작성하면 앱 출시 소식을 미리 알려드릴게요.'),
          actions: [
            TextButton(
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    _showToastMessage(context, '링크를 열 수 없습니다');
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  _showToastMessage(context, '브라우저를 열 수 없습니다. 나중에 다시 시도해주세요.');
                }
              },
              child: const Text('알림 신청하기'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '닫기',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 문의하기 메뉴
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMenuItem(
                context,
                icon: Icons.contact_support,
                title: '의견 보내기',
                subtitle: '잘못된 정보가 보이나요?',
                onTap: () => _openReportForm(context),
              ),
            ),
            
            // 지도 가이드 메뉴
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMenuItem(
                context,
                icon: Icons.map,
                title: '지도 가이드',
                subtitle: '지도 요소 확인하기',
                onTap: () => _openMapGuide(context),
              ),
            ),
            
            // 출시 알림 메뉴
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMenuItem(
                context,
                icon: Icons.notifications_active,
                title: '출시 알림 받기',
                subtitle: '앱이 출시하면 가장 먼저 알려드려요',
                onTap: () => _openReleaseNotification(context),
              ),
            ),
            
            // 스페이서를 추가하여 푸터를 하단에 고정
            const SizedBox(height: 200),
            
            // 향후 추가될 메뉴들을 위한 예시 (주석처리)
            /*
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    title: '알림 설정',
                    subtitle: '푸시 알림을 관리하세요',
                    onTap: () => _showToastMessage(context, '알림 설정 기능 준비중입니다'),
                  ),
                  
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.info,
                    title: '앱 정보',
                    subtitle: '버전 및 앱 정보를 확인하세요',
                    onTap: () => _showToastMessage(context, '앱 정보 기능 준비중입니다'),
                  ),
                ],
              ),
            ),
            */
          ],
        ),
      ),
      // 푸터
      bottomSheet: _buildFooter(),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 영역 - SVG 파일 사용
          Container(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'assets/logos/futurevel_logo_black.svg',
              width: 80,
              height: 28,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                width: 80,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'WhereClass',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 주소 정보
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              '강원특별자치도 원주시 연세대길1 컨버젼스 홀 201-5호',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 10),
          
          // 이메일 정보
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'futurevel.kr@gmail.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 20),
          
          // 저작권 정보
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              '© 2025 WhereClass. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

// 지도 가이드 다이얼로그 위젯
class MapGuideDialog extends StatelessWidget {
  const MapGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '지도 가이드',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            
            // SVG 가이드 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset(
                  'assets/guides/map_guide.svg',
                  fit: BoxFit.contain,
                  placeholderBuilder: (BuildContext context) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '지도 가이드 파일을 찾을 수 없습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
