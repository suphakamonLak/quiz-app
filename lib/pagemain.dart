import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_midterm/page1.dart';

class Pagemain extends StatefulWidget {
  const Pagemain({super.key});

  @override
  State<Pagemain> createState() => _PagemainState();
}

class _PagemainState extends State<Pagemain> {
  late int currentView = 0; //จำนวนที่ทำแบบทดสอบ
  

  @override
  void initState() {
    super.initState();
    loadView();
  }

  Future<void> loadView() async { //จำนวนที่ทำแบบทดสอบ
    final pref = await SharedPreferences.getInstance();
    final int? view = pref.getInt('view');
    setState(() {
      currentView = view ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Welcome to Quiz App!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10,),
            Text("Amount did quiz: $currentView"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => Page1())
                ).then((_) {
                  loadView();
                });
              }, 
              child: Text("Start to quiz")
            ),
            
          ],
        ),
      ),
    );
  }
}