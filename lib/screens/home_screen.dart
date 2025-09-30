import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'restaurant_screen.dart';

class HomeScreen extends StatelessWidget {
  final CollectionReference restaurantsRef = FirebaseFirestore.instance.collection('restaurants');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PetPooja'), actions: [IconButton(icon: Icon(Icons.logout), onPressed: () async { await FirebaseAuth.instance.signOut(); Navigator.pushReplacementNamed(context, '/login'); })]),
      body: StreamBuilder<QuerySnapshot>(stream: restaurantsRef.snapshots(), builder: (context,snap){
        if(!snap.hasData) return Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return Center(child: Text('No restaurants yet.'));
        return ListView.builder(itemCount: docs.length,itemBuilder: (ctx,i){
          final data = docs[i].data() as Map<String,dynamic>;
          return ListTile(leading: data['banner']!=null?Image.network(data['banner'],width:50,height:50,fit:BoxFit.cover):null, title: Text(data['name']??''), subtitle: Text(data['desc']??''), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantScreen(restaurantDoc: docs[i]))));
        });
      }),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.shopping_cart), onPressed: () => Navigator.pushNamed(context, '/cart')),
    );
  }
}
