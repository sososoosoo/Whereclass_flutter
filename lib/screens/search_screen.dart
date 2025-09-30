import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whc_proto/building_class.dart';
import 'package:whc_proto/methods/current_location.dart';
import 'package:whc_proto/methods/room_search_enum.dart';
import 'package:whc_proto/methods/screen_controller.dart';
import 'package:whc_proto/screens/interactive_svg_screen.dart';
import 'package:whc_proto/widgets/search_history_button.dart';
import 'package:whc_proto/data/search_data/search_history.dart';
import 'package:whc_proto/data/search_data/search_corpus.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _suggestions = const [];
  Timer? _debounce;
  bool _suppressSuggestions = false;
  RoomData? _searchResult; // 검색 결과 저장
  void _onQueryChanged(String input) {
    _debounce?.cancel();
    // If user types, allow suggestions again
    if (_suppressSuggestions) {
      _suppressSuggestions = false;
    }
    
    // 검색 중에는 검색 결과 숨기기
    if (_searchResult != null) {
      setState(() {
        _searchResult = null;
      });
    }
    
    _debounce = Timer(const Duration(milliseconds: 160), () {
      if (!_suppressSuggestions) {
        setState(() => _suggestions = _buildSuggestions(input));
      }
    });
  }

  List<String> _buildSuggestions(String input) {
    final q = input.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <String>[];
    final seen = <String>{};
    void addAll(Iterable<String> items) {
      for (final s in items) {
        final key = s.toLowerCase();
        if (seen.add(key)) out.add(s);
      }
    }

    final history = searchHistoryNotifier.value;
    addAll(history.where((s) => s.toLowerCase().startsWith(q)));
    addAll(searchCorpus.where((s) => s.toLowerCase().startsWith(q)));
    addAll(searchCorpus.where(
        (s) => s.toLowerCase().contains(q) && !s.toLowerCase().startsWith(q)));
    addAll(searchCorpus.where((term) => term.toLowerCase().contains(q)));
    return out.take(10).toList();
  }

  Future<void> _runSearch(String query, bool clearField) async {
  // Convert all alphabetic characters to uppercase
  query = query.replaceAllMapped(RegExp(r'[a-zA-Z]'), (m) => m.group(0)!.toUpperCase());
  addSearchTerm(query); // record history
    setState(() {
      if (clearField) {
        _controller.clear();
        _focusNode.unfocus();
        _suggestions = [];
        _suppressSuggestions = true;
      }
    });
    // Special case: Korean prefix + floor/room (e.g., '컨B107', '백B101', '미4F201')
    final prefixMap = {
      '컨버전스홀': 'convergence_hall',
      '컨버젼스홀': 'convergence_hall',
      '컨버젼스': 'convergence_hall',
      '컨버전스': 'convergence_hall',
      '컨버': 'convergence_hall',
      '컨홀': 'convergence_hall',
      '컨': 'convergence_hall',
      'ㅋㅂㅈㅅㅎ': 'convergence_hall',
      'ㅋㅂㅈㅅ': 'convergence_hall',
      'ㅋㅂㅈ': 'convergence_hall',
      'ㅋㅂ': 'convergence_hall',
      'ㅋㅎ': 'convergence_hall',
      'ㅋ': 'convergence_hall',
      '백운관': 'baekun_hall',
      '백운': 'baekun_hall',
      '백': 'baekun_hall',
      'ㅂㅇㄱ': 'baekun_hall',
      'ㅂㅇ': 'baekun_hall',
      'ㅂ': 'baekun_hall',
      '창조관': 'changjo_hall',
      '창조': 'changjo_hall',
      '창': 'changjo_hall',
      'ㅊㅈㄱ': 'changjo_hall',
      'ㅊㅈ': 'changjo_hall',
      '청송관': 'cheongsong_hall',
      '청송': 'cheongsong_hall',
      '청': 'cheongsong_hall',
      'ㅊㅅㄱ': 'cheongsong_hall',
      'ㅊㅅ': 'cheongsong_hall',
      '정의관': 'jeongui_hall',
      '정의': 'jeongui_hall',
      '정': 'jeongui_hall',
      'ㅈㅇㄱ': 'jeongui_hall',
      'ㅈㅇ': 'jeongui_hall',
      'ㅈ': 'jeongui_hall',
      '미래관': 'mirae_hall',
      '미래': 'mirae_hall',
      '미': 'mirae_hall',
      'ㅁㄹㄱ': 'mirae_hall',
      'ㅁㄺ': 'mirae_hall',
      'ㅁㄹ': 'mirae_hall',
      'ㅁ': 'mirae_hall',
    };
    final input = query.replaceAll(' ', '');

    String? foundPrefix;
    String? roomPart;
    // Try to find the longest matching prefix
    for (final k in prefixMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length))) {
      if (input.startsWith(k)) {
        foundPrefix = k;
        // Only take the trailing alphanumeric part (e.g., B107, 107, 4F201)
        final match =
            RegExp(r'([A-Za-z]?[0-9]+)$').firstMatch(input.substring(k.length));
        if (match != null) {
          roomPart = match.group(1);
        }
        debugPrint(
            'Detected prefix: $k -> ${prefixMap[k]}, roomPart: $roomPart');
        break;
      }
    }
    if (foundPrefix != null && roomPart != null && roomPart.isNotEmpty) {
      final collection = prefixMap[foundPrefix];
      final uniqueId = '${collection}_$roomPart';
      final doc = null; // 임시 처리
      if (doc != null && doc.docs.isNotEmpty) {
        final data = doc.docs.first.data();
        final room = RoomData.fromFirestore(data);
        setState(() {
          _searchResult = room;
          _suggestions = [];
          _suppressSuggestions = true;
        });
      } else {
        setState(() {
          _searchResult = null;
        });
      }

      return;
    }
    // ...existing code for other searches (if any)...
    if (prefixMap.keys.contains(input)) {
      debugPrint('Input matches prefixMap key: $input');
      String asdf = getBuildingName(prefixMap[input]!);
      debugPrint('Navigating to building: $asdf');
      currentLocation.value = CurrentLocation(
        curBuildingName: asdf == '컨버젼스홀' ? '컨버젼스 홀' : asdf,
        curFloorNum: '1',
      );
      ScreenController.current.value = AppScreen.map;
    }
  }

  void _applyTerm(String term) {
    _controller.text = term;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: term.length));
    _runSearch(term, false);
    _focusNode.unfocus();
    setState(() => _suggestions = []);
    _suppressSuggestions = true;
  }

  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 48,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: '강의실 호수, 이름으로 검색',
              hintStyle: TextStyle(color: Color(0xFF96A7AF), fontSize: 16),
              prefixIcon: Icon(Icons.search, color: Color(0xFF96A7AF), size: 20),
              filled: true,
              fillColor: Color.fromRGBO(229, 232, 236, 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: false,
            ),
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            onChanged: _onQueryChanged,
            onSubmitted: (query) {
              if (query.trim().isEmpty) return;
              _runSearch(query, false);
            },
          ),
        ),
        titleSpacing: 16,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 결과 표시 영역 (검색된 방 정보)
            if (_searchResult != null) _buildSearchResult(_searchResult!),
            
            // 기존 검색 기록 위치 - 고정 높이 설정
            SizedBox(
              height: 80, // 검색 기록 영역 고정 높이
              child: ValueListenableBuilder(
                valueListenable: searchHistoryNotifier,
                builder: (context, history, child) {
                  if (history.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...history.map((term) {
                              return SearchHistoryButton(
                                searchTerm: term,
                                onTap: () => _applyTerm(term),
                                onDelete: () => removeSearchTerm(term),
                              );
                            }),
                            TextButton.icon(
                                onPressed: clearSearchHistory,
                                icon: const Icon(Icons.delete_sweep),
                                label: const Text('Clear All'))
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  );
                },
              ),
            ),
            
            // 검색 가이드 - 항상 표시
            const Text(
              '이렇게 검색해 보세요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            // 검색 제안사항 - 항상 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuggestionItem('건물명 + 호수 (컨201)'),
                _buildSuggestionItem('건물초성 + 호수 (ㅋㅂㅈㅅㅎ201)'),
                // _buildSuggestionItem('장소명 (세미나실)'),
              ],
            ),
            
            // Suggestions panel (shows while typing and no search result)
            // if (_suggestions.isNotEmpty && _searchResult == null) ...[
            //   const SizedBox(height: 16),
            //   Expanded(
            //     child: Material(
            //       elevation: 2,
            //       borderRadius: BorderRadius.circular(12),
            //       child: ListView.separated(
            //         padding: const EdgeInsets.all(8),
            //         itemCount: _suggestions.length,
            //         separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
            //         itemBuilder: (_, i) {
            //           final s = _suggestions[i];
            //           return ListTile(
            //             dense: true,
            //             leading: const Icon(Icons.search, size: 18, color: Colors.grey),
            //             title: Text(
            //               s,
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //               style: const TextStyle(fontSize: 16),
            //             ),
            //             onTap: () => _applyTerm(s),
            //           );
            //         },
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResult(RoomData room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToMap(room),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // 중간 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${room.buildingNameKo} ${room.roomNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ' ${room.roomNameKo}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        ' ${room.floor == '-1' ? 'B1' : room.floor}층',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                // 오른쪽 X 버튼
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _searchResult = null;
                        _controller.clear();
                        _focusNode.unfocus();
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMap(RoomData room) {
    debugPrint(
        'Navigating to map for room: ${room.uniqueId}, ${room.buildingNameKo}, ${room.floor == '-1' ? 'B1' : room.floor}');
    currentLocation.value = CurrentLocation(
      curBuildingName: room.buildingNameKo == '컨버젼스홀'
          ? '컨버젼스 홀'
          : room.buildingNameKo,
      curFloorNum: room.floor == '-1' ? 'B1' : room.floor,
    );
    ScreenController.current.value = AppScreen.map;
    SearchedRoomIdHolder.searchedRoomId.value = room.uniqueId;
    debugPrint('🔔 1검색된 방 ID 설정: ${SearchedRoomIdHolder.searchedRoomId.value}');
  }
}
