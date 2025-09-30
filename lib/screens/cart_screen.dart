import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatelessWidget {
  Future<void> _placeOrder(BuildContext context, List<Map<String,dynamic>> items) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please sign in'))); return; }
    final order = {'userId': user.uid, 'phone': user.phoneNumber, 'items': items, 'total': items.fold(0.0,(s,it)=>s+(it['price'] as num).toDouble()), 'status':'placed', 'createdAt': FieldValue.serverTimestamp() };
    await FirebaseFirestore.instance.collection('orders').add(order);
    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Order placed'), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text('OK'))]));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    return Scaffold(appBar: AppBar(title: Text('Cart')), body: cart.items.isEmpty?Center(child: Text('Empty')):Column(children:[ Expanded(child: ListView.builder(itemCount: cart.items.length,itemBuilder:(c,i){ final it=cart.items[i]; return ListTile(title: Text(it['name']), subtitle: Text('₹'+it['price'].toString()), trailing: IconButton(icon: Icon(Icons.delete), onPressed: ()=>cart.removeItemById(it['id'])));})), Padding(padding: EdgeInsets.all(12), child: ElevatedButton(onPressed: ()=>_placeOrder(context, cart.items), child: Text('Checkout')) ) ])); }
}
