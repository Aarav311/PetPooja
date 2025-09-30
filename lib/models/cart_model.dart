import 'package:flutter/foundation.dart';

class CartModel extends ChangeNotifier {
  final List<Map<String,dynamic>> _items = [];
  List<Map<String,dynamic>> get items => List.unmodifiable(_items);
  void addItem(Map<String,dynamic>> item){ _items.add(item); notifyListeners(); }
  void removeItemById(dynamic id){ _items.removeWhere((it)=>it['id']==id); notifyListeners(); }
  bool contains(dynamic id)=> _items.any((it)=>it['id']==id);
  double get total => _items.fold(0.0, (s,it)=> s + (it['price'] as num).toDouble());
}
