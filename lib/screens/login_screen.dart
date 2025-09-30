import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '+91');
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _loading = false;
  bool _codeSent = false;

  void _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() { _loading = true; });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacementNamed(context, '/home');
        },
        verificationFailed: (e) {
          setState(() { _loading = false; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Verification failed')));
        },
        codeSent: (id, token) {
          setState(() { _verificationId = id; _codeSent = true; _loading = false; });
        },
        codeAutoRetrievalTimeout: (id) { _verificationId = id; },
      );
    } catch (e) {
      setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _verificationId == null) return;
    setState(() { _loading = true; });
    try {
      final cred = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: code);
      await FirebaseAuth.instance.signInWithCredential(cred);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid code')));
    } finally { setState(() { _loading = false; }); }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(20), child: _loading ? CircularProgressIndicator() : Column(mainAxisSize: MainAxisSize.min, children: [
      Text('PetPooja', style: TextStyle(fontSize:32, fontWeight: FontWeight.bold)),
      SizedBox(height:12),
      if (!_codeSent) TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Phone (+countrycode...)')),
      if (_codeSent) TextField(controller: _codeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'OTP')),
      SizedBox(height:12),
      ElevatedButton(onPressed: _codeSent ? _verifyCode : _sendCode, child: Text(_codeSent ? 'Verify' : 'Send OTP')),
      SizedBox(height:12),
      Text('Tip: Use Firebase test numbers if SMS delivery is blocked during development.', style: TextStyle(fontSize:12), textAlign: TextAlign.center)
    ],))))); }
}
