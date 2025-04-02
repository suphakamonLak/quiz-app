import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_midterm/pagemain.dart';
import 'package:test_midterm/quizmodel.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  late List<QuizModel> quiz = [];
  List<int> multichoice = [];
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> allScores = [];
  String text = "";
  String grade = "";
  String percentScore = "";
  int view = 0; //จำนวนการทำ quiz ซ้ำ
  int correct = 0;
  int incorrect = 0;
  int bestScore = 0;
  int worstScore = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener((){
      int pos = ((_scrollController.position.pixels/
        _scrollController.position.maxScrollExtent)*100).toInt();
      setState(() {
        text = "$multichoice Pos: $pos";
      });
    });
    loadjson(); 
    loadScores(); // โหลดค่า bestScore และ worstScore จาก SharedPreferences
    calGrade();
  }

  void loadjson() async{ //โหลด data
    final String response = await rootBundle.loadString('assets/json/data.json');
    final jsdata = quizModelFromJson(response);

    setState(() {
      quiz = jsdata;
      shuffle(quiz); //เรียกใช้ method shuffle เพื่อสลับข้อ
      if (multichoice.length != quiz.length) {
        multichoice = List.filled(quiz.length, 0); // ปรับขนาด multichoice ให้ตรงกับ quiz
      }
    });
  }

  List shuffle(List items){ //สลับข้อ
    var random = Random();
    for(var i = items.length-1; i>0; i--){
      var n = random.nextInt(i+1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  void resetRadio() async{ //reset radio กลับไปค่าเริ่มต้นเมื่อกดปุ่มย้อนกลับมาทำซ้ำ
    setState(() {
      multichoice = List.filled(quiz.length, 0);
      correct = 0;
      incorrect = 0;
    });
  }

  Future<void> quizView() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
      view = (pref.getInt("view") ?? 0) + 1;
      pref.setInt('view', view);
    });
  }

  bool checkSubmit(){
    int unAns = multichoice.indexWhere((choice)=>choice==0); //หาข้อที่ยังไม่ได้ตอบ

    if(unAns != -1){
      double position = ((unAns / 4) * 
      _scrollController.position.maxScrollExtent)+200;
      _scrollController.animateTo(
        position,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {
        text = "Please answer all quiz. Missing quiz : ${unAns + 1}, position: $position";
      });
      return false;
    }else{
      setState(() {
        text = "Thanks for submitting";
      });
      return true;
    }
  } 

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
      worstScore = prefs.getInt('worstScore') ?? 0;
    });
  }

  Future<void> saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (correct > bestScore) {// เก็บค่าถูกที่มากที่สุด
        bestScore = correct;
        prefs.setInt('bestScore', bestScore);
      }
      if (worstScore < incorrect) {// เก็บค่าผิดที่มากที่สุด
        worstScore = incorrect;
        prefs.setInt('worstScore', worstScore);
      }
    });
  }

  void calculateScores() {
    correct = 0;
    incorrect = 0;

    for (int i = 0; i < quiz.length; i++) {
      if (multichoice[i] != 0) {
        if (multichoice[i] == quiz[i].answerId) {
          correct++;
        } else {
          incorrect++;
        }
      }
    }
  }

  void calGrade() {
    int maxScore = 4;
    double percent = (correct / maxScore) * 100;
    String formatPercent = percent.toStringAsFixed(2);
    String calGrade;

    if (percent >= 80) {
      calGrade = "A";
    } else if (percent >= 70) {
      calGrade = "B";
    } else if (percent >= 60) {
      calGrade = "C";
    } else if (percent >= 50) {
      calGrade = "D";
    } else {
      calGrade = "F";
    }

    setState(() {
      grade = calGrade;
      percentScore = formatPercent;
    });
  }

  void saveScoresAndGrade() {
    calculateScores(); // คำนวณคะแนนก่อนบันทึก
    calGrade(); // คำนวณเกรด
    saveScores(); // บันทึกคะแนนใน SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          quiz.isNotEmpty ? Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: quiz.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (quiz[index].img != null)
                        Image.asset(
                          quiz[index].img!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8,),
                        Text(
                          "${index+1}. ${quiz[index].title}",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        ListView.builder(// choice
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: quiz[index].choice.length,
                          itemBuilder: (context, idx) {
                            return ListTile(
                              leading: Radio(
                                value: quiz[index].choice[idx].id, 
                                groupValue: multichoice[index], 
                                onChanged: (int ? value) {
                                  setState(() {
                                    multichoice[index] = value!;
                                    text = "$multichoice Pos: ${((_scrollController.position.pixels/
                                      _scrollController.position.maxScrollExtent)*100).toInt()}";                 
                                  });
                                }
                              ),
                              title: Text(quiz[index].choice[idx].title, style: TextStyle(fontSize: 18),),
                            );
                          }
                        ),
                        if (index == quiz.length-1) // display button submit
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (checkSubmit()) {
                                      // บันทึกข้อมูลคะแนนมากสุดต่ำสุดใน shared_preferences
                                      saveScoresAndGrade();
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Row(
                                              children: [
                                                Text(
                                                  "Score",
                                                  style: TextStyle(fontSize: 20,
                                                  fontWeight: FontWeight.bold)
                                                )
                                              ],
                                            ),
                                            content: Column(
                                              children: [
                                                Text(
                                                  'Grade $grade',
                                                  style: TextStyle(fontSize: 25),
                                                  maxLines: 3,
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 10,),
                                                Text(
                                                  'Percentage $percentScore %',
                                                  style: TextStyle(fontSize: 25),
                                                  maxLines: 3,
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 10,),
                                                Text(
                                                  'Correct: ${correct} , Incorrect: ${incorrect}',
                                                  style: TextStyle(fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 10,),
                                                Text(
                                                  'worst score: $worstScore',
                                                  style: TextStyle(fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 10,),
                                                Text(
                                                  'best score: $bestScore',
                                                  style: TextStyle(fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () async{
                                                  await quizView();
                                                  Navigator.push(
                                                    context, 
                                                    MaterialPageRoute(
                                                      builder: (context) => Pagemain()
                                                    )
                                                  );
                                                }, 
                                                child: Text("Ok"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }, 
                                  child: Text("Submit")
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white
                                  ),
                                  onPressed: () {
                                    resetRadio();
                                  }, 
                                  child: Text("Clear")
                                )
                              ],
                            ),
                          )
                    ],
                  ),
                );
              }
            )
          ) : Text("NoData")
        ],
      ),
    );
  }
}