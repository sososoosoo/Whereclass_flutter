
import 'package:flutter/material.dart';

// Universal variable to store the searched room unique ID with notifier
class SearchedRoomIdHolder {
  static final ValueNotifier<String?> searchedRoomId = ValueNotifier<String?>(null);
}

// Usage example:
// SearchedRoomIdHolder.searchedRoomId.value = 'room123';
// print(SearchedRoomIdHolder.searchedRoomId.value);



