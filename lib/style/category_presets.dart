import 'package:flutter/material.dart';

const categoryPresetColors = [
  '#F44336',
  '#FF9800',
  '#FFEB3B',
  '#4CAF50',
  '#2196F3',
  '#9C27B0',
  '#795548',
  '#607D8B',
];

const categoryIconMap = <String, IconData>{
  'local_grocery_store': Icons.local_grocery_store,
  'restaurant': Icons.restaurant,
  'kitchen': Icons.kitchen,
  'bakery_dining': Icons.bakery_dining,
  'egg': Icons.egg,
  'set_meal': Icons.set_meal,
  'local_drink': Icons.local_drink,
  'cleaning_services': Icons.cleaning_services,
  'pets': Icons.pets,
  'medical_services': Icons.medical_services,
  'checkroom': Icons.checkroom,
  'home': Icons.home,
};

IconData categoryIconFromName(String? iconName) {
  if (iconName == null) {
    return Icons.category;
  }
  return categoryIconMap[iconName] ?? Icons.category;
}
