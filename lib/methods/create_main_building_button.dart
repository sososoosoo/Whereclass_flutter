import 'package:flutter/material.dart';
import 'package:whc_proto/building_class.dart';

import 'package:whc_proto/widgets/floor_button.dart';

class CreateMainBuildingButton extends StatelessWidget {
  const CreateMainBuildingButton({super.key, required this.buildingId});

  final String buildingId;

  // 건물별 아이콘 반환
  IconData getBuildingIcon(String buildingId) {
    switch (buildingId) {
      case 'convergence_hall':
        return Icons.hub; // 컨버젼스 홀 - 연결/융합 의미
      case 'baekun_hall':
        return Icons.school; // 백운관 - 학교/교육 의미
      case 'changjo_hall':
        return Icons.lightbulb; // 창조관 - 창의/아이디어 의미
      case 'cheongsong_hall':
        return Icons.nature; // 청송관 - 자연/나무 의미
      case 'mirae_hall':
        return Icons.rocket_launch; // 미래관 - 미래/발전 의미
      case 'jeongui_hall':
        return Icons.balance; // 정의관 - 정의/균형 의미
      default:
        return Icons.business; // 기본 건물 아이콘
    }
  }

  // 건물별 배경색 반환
  Color getBuildingBackgroundColor(String buildingId) {
    switch (buildingId) {
      case 'convergence_hall':
        return Colors.blue[100]!; // 파란색 - 기술/융합
      case 'baekun_hall':
        return Colors.green[100]!; // 초록색 - 학습/성장
      case 'changjo_hall':
        return Colors.orange[100]!; // 주황색 - 창의/열정
      case 'cheongsong_hall':
        return Colors.teal[100]!; // 청록색 - 자연/평온
      case 'mirae_hall':
        return Colors.purple[100]!; // 보라색 - 미래/혁신
      case 'jeongui_hall':
        return Colors.amber[100]!; // 노란색 - 정의/지혜
      default:
        return Colors.blue[100]!; // 기본색
    }
  }

  // 건물별 아이콘 색상 반환
  Color getBuildingIconColor(String buildingId) {
    switch (buildingId) {
      case 'convergence_hall':
        return Colors.blue;
      case 'baekun_hall':
        return Colors.green;
      case 'changjo_hall':
        return Colors.orange;
      case 'cheongsong_hall':
        return Colors.teal;
      case 'mirae_hall':
        return Colors.purple;
      case 'jeongui_hall':
        return Colors.amber[700]!;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    String buildingName = getBuildingName(buildingId);
    String buildingInfo = getBuildingInfo(buildingId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: getBuildingBackgroundColor(buildingId),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getBuildingIcon(buildingId),
                  color: getBuildingIconColor(buildingId),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buildingName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333D4B),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      buildingInfo,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              for (int i = 0; i < getBuildingFloors(buildingId).length; i++) ...{
                Expanded(
                  child: FloorButton(
                    floorNum: getBuildingFloors(buildingId)[i], 
                    buildingId: buildingId,
                  ),
                ),
                if (i < getBuildingFloors(buildingId).length - 1)
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
              }
            ],
          ),
        ],
      ),
    );
  }
}
