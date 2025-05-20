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
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.yellow[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                child: Image.asset('assets/img/garfield.png'),
                              ),
                              Text("Let's start Quiz!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ),
                      ),
                      Text("Welcome to Quiz App. Don't worry if you don't know everything - just try your best and enjoy the process. Good luck!"),
                      SizedBox(height: 10,),
                      Text("Amount did quiz: $currentView", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,))
                    ]
                  ),
                )
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.all(2),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      )
                    ),
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (BuildContext context) => Page1())
                      ).then((_) {
                        loadView();
                      });
                    }, 
                    child: Text("Start to quiz", style: TextStyle(fontSize: 16),)
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}