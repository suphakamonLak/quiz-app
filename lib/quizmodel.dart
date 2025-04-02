import 'dart:convert';

List<QuizModel> quizModelFromJson(String str) => 
List<QuizModel>.from(json.decode(str).map((x) => QuizModel.fromJson(x)));

class QuizModel {
  String title;
  List<Choice> choice;
  String? img;
  int answerId;

  QuizModel({
    required this.title,
    required this.choice,
    required this.img,
    required this.answerId,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    title: json["title"],
    choice: List<Choice>.from(json["choice"].map((x) => Choice.fromJson(x))),
    img: json["img"],
    answerId: json["answerId"],
  );

  Map<String, dynamic> toJson() =>{
    "title" : title,
    "choice" : List<dynamic>.from(choice.map((x) => x.toJson())),
    "img" : img,
    "answerId" : answerId,
  };

}

class Choice{
  int id;
  String title;

  Choice({
    required this.id,
    required this.title,
  });

  factory Choice.fromJson(Map<String, dynamic> json) =>Choice(
    id: json["id"], 
    title: json["title"],
  );

  Map<String, dynamic> toJson()=>{
    "id" : id,
    "title" : title,
  };
}