import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/fractal_params.dart';

class ShaderService {
  bool _initialized = false;

  Future<void> initialize(dynamic flutterGl) async {
    // Simplified shader service for demo purposes
    _initialized = true;
  }

  void useProgram() {
    // Simplified for demo
  }

  void setUniforms(FractalParams params, Size size, double time) {
    // Simplified for demo
  }

  void dispose() {
    _initialized = false;
  }
  
  bool get initialized => _initialized;
}