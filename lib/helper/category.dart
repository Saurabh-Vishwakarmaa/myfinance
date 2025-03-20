import 'package:flutter/material.dart';

class Category {
  String id;
  String name;
  Color color;
  IconData icon;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      color: Color(int.parse(json['color'] ?? '0xFF9E9E9E')),
      icon: IconData(int.parse(json['icon'] ?? '0xe318'), fontFamily: 'MaterialIcons'),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value.toString(),
      'icon': icon.codePoint.toString(),
    };
  }
}