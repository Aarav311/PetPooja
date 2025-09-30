import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class RestaurantScreen extends StatelessWidget {
  final QueryDocumentSnapshot restaurantDoc;
  RestaurantScreen({required this.restaurantDoc});

  @override
  Widget build(BuildContext context) {
    final data = restaurantDoc.data() as Map<String,dynamic>;
    final menu = List<Map<String,dynamic>>.from(data['menu'] ?? []);
    final cart = Provider.of<CartModel>(context);
    return Scaffold(appBar: AppBar(title: Text(data['name'] ?? 'Restaurant')), body: Column(children: [
      if(data['banner']!=null) Image.network(data['banner'], height: 180, width: double.infinity, fit: BoxFit.cover),
      Expanded(child: ListView.builder(itemCount: menu.length,itemBuilder:(c,i){ final it = menu[i]; return ListTile(title: Text(it['name']), subtitle: Text('₹'+it['price'].toString()), trailing: ElevatedButton(onPressed: (){ if(!cart.contains(it['id'])) cart.addItem({...it,'restaurantId':restaurantDoc.id}); }, child: Text('Add')); }))
    ])); }
}
