import 'package:flutter/material.dart';

class PostCustomObject {
  final Icon icon;
  final String name;
  final String description;
  final Function apiCall;

  PostCustomObject({
    required this.icon,
    required this.name,
    required this.description,
    required this.apiCall,
  });
}