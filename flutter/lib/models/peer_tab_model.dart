import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/models/platform_model.dart';

import '../common.dart';
import 'model.dart';

// 只保留 Address book 一个标签
enum PeerTabIndex {
  ab,
}

class PeerTabModel with ChangeNotifier {
  WeakReference<FFI> parent;

  static const int maxTabCount = 1;
  static const List<String> tabNames = [
    'Address book',
  ];
  static const List<IconData> icons = [
    IconFont.addressBook,
  ];

  // 只需要一个标签，始终启用且可见
  List<bool> isEnabled = [true];
  final List<bool> _isVisible = [true];
  List<bool> get isVisibleEnabled => [true];
  final List<int> orders = [0];
  List<int> get visibleEnabledOrderedIndexs => [0];

  int get currentTab => 0;
  int _currentTab = 0;
  List<Peer> _selectedPeers = List.empty(growable: true);
  List<Peer> get selectedPeers => _selectedPeers;
  bool _multiSelectionMode = false;
  bool get multiSelectionMode => _multiSelectionMode;
  List<Peer> _currentTabCachedPeers = List.empty(growable: true);
  List<Peer> get currentTabCachedPeers => _currentTabCachedPeers;
  bool _isShiftDown = false;
  bool get isShiftDown => _isShiftDown;
  String _lastId = '';
  String get lastId => _lastId;

  PeerTabModel(this.parent);

  // 当前Tab始终是0
  setCurrentTab(int index) {
    if (_currentTab != index) {
      _currentTab = index;
      notifyListeners();
    }
  }

  String tabTooltip(int index) {
    if (index == 0) {
      return 'Address book';
    }
    return index.toString();
  }

  IconData tabIcon(int index) {
    if (index == 0) {
      return IconFont.addressBook;
    }
    return Icons.help;
  }

  setMultiSelectionMode(bool mode) {
    _multiSelectionMode = mode;
    if (!mode) {
      _selectedPeers.clear();
      _lastId = '';
    }
    notifyListeners();
  }

  select(Peer peer) {
    if (!_multiSelectionMode) {
      if (isDesktop || isWebDesktop) return;
      _multiSelectionMode = true;
    }
    final cached = _currentTabCachedPeers.map((e) => e.id).toList();
    int thisIndex = cached.indexOf(peer.id);
    int lastIndex = cached.indexOf(_lastId);
    if (_isShiftDown && thisIndex >= 0 && lastIndex >= 0) {
      int start = thisIndex < lastIndex ? thisIndex : lastIndex;
      int end = thisIndex > lastIndex ? thisIndex : lastIndex;
      bool remove = isPeerSelected(peer.id);
      for (var i = start; i <= end; i++) {
        if (remove) {
          if (isPeerSelected(cached[i])) {
            _selectedPeers.removeWhere((p) => p.id == cached[i]);
          }
        } else {
          if (!isPeerSelected(cached[i])) {
            _selectedPeers.add(_currentTabCachedPeers[i]);
          }
        }
      }
    } else {
      if (isPeerSelected(peer.id)) {
        _selectedPeers.removeWhere((p) => p.id == peer.id);
      } else {
        _selectedPeers.add(peer);
      }
    }
    _lastId = peer.id;
    notifyListeners();
  }

  setCurrentTabCachedPeers(List<Peer> peers) {
    Future.delayed(Duration.zero, () {
      final isPreEmpty = _currentTabCachedPeers.isEmpty;
      _currentTabCachedPeers = peers;
      final isNowEmpty = _currentTabCachedPeers.isEmpty;
      if (isPreEmpty != isNowEmpty) {
        notifyListeners();
      }
    });
  }

  selectAll() {
    _selectedPeers = _currentTabCachedPeers.toList();
    notifyListeners();
  }

  bool isPeerSelected(String id) {
    return selectedPeers.firstWhereOrNull((p) => p.id == id) != null;
  }

  setShiftDown(bool v) {
    if (_isShiftDown != v) {
      _isShiftDown = v;
      if (_multiSelectionMode) {
        notifyListeners();
      }
    }
  }

  setTabVisible(int index, bool visible) {
    // 只有一个标签，什么也不用做
  }

  _trySetCurrentTabToFirstVisibleEnabled() {
    // 只有一个标签什么都不用做
  }

  reorder(int oldIndex, int newIndex) {
    // 只有一个标签，不需要排序
  }
}
