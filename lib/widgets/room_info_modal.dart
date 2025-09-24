import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whc_proto/screens/interactive_svg_screen.dart'; // RoomData를 위해 임시 import

/// 하단 정보 모달 위젯
class RoomInfoModal extends StatelessWidget {
  final RoomData? roomData;
  final bool isVisible;
  final VoidCallback onHide;
  final VoidCallback onClose;

  const RoomInfoModal({
    Key? key,
    required this.roomData,
    required this.isVisible,
    required this.onHide,
    required this.onClose,
  }) : super(key: key);

  // 제보하기 구글폼 열기
  Future<void> _openReportForm(BuildContext context) async {
    final Uri url = Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLScQyzMfIqaVqv84Y2R-FG0ZAaehuhQQTYMoXW0RaANzSx7kAg/viewform?usp=dialog');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showToastMessage(context, '링크를 열 수 없습니다');
      }
    } catch (e) {
      _showToastMessage(context, '브라우저를 열 수 없습니다. 나중에 다시 시도해주세요.');
    }
  }

  // 토스트 메시지 표시
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

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: roomData != null && isVisible ? 0 : -400, // 충분히 큰 값으로 완전 숨김
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: roomData != null ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 행
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomData!.roomNameKo.isNotEmpty
                          ? roomData!.roomNameKo
                          : '방 정보',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${roomData!.buildingNameKo}${roomData!.roomNumber.isNotEmpty ? ' ${roomData!.roomNumber}호' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 숨기기 버튼과 닫기 버튼
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 숨기기 버튼
                    IconButton(
                      onPressed: onHide,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: '모달 숨기기',
                    ),
                    const SizedBox(width: 4),
                    // 닫기 버튼
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: '선택 해제',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 방 유형 정보 (있는 경우에만 표시)
            if (roomData!.roomType.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    roomData!.roomType,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 4),

            // 버튼들
            Row(
              children: [
                // 상세정보 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showToastMessage(context, '상세정보 기능은 준비중이에요'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('상세정보'),
                  ),
                ),
                const SizedBox(width: 8),
                // 제보하기 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openReportForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 242, 249, 252),
                      foregroundColor: const Color(0xFF00AEFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('제보하기'),
                  ),
                ),
              ],
            ),
          ],
        ) : const SizedBox.shrink(),
      ),
    );
  }
}