import 'package:flutter/material.dart';

class NavigationManager {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();
  
  BuildContext? _context;
  
  void setContext(BuildContext context) {
    _context = context;
  }
  
  BuildContext get context {
    if (_context == null) {
      throw Exception('NavigationManager context not set. Call setContext() first.');
    }
    return _context!;
  }
}