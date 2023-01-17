// class TimeTable {
//   late String jour;
//   late String prof;
//   late String nums;
//
//   TimeTable();
//
//   TimeTable.fromJson(Map<String, dynamic> json){
//     jour = json['jour'];
//     prof = json['prof'];
//     nums = json['nums'];
//   }
//
// }
import 'dart:convert';

TimeTable timeTableFromJson(String str) => TimeTable.fromJson(json.decode(str));

String timeTableToJson(TimeTable data) => json.encode(data.toJson());

class TimeTable {


  TimeTable({
    required this.id,
    required this.jour,
    required this.prof,
    required this.nums,
    required this.tempuratureAvg,
    required this.tempuratureIcon,
    required this.etat,
  });

  int id;
  String jour;
  String prof;
  String nums;
  final String? tempuratureAvg;
  final String? tempuratureIcon;
  String etat;


  factory TimeTable.fromJson(Map<String, dynamic> json) => TimeTable(
    id: json["id"],
    jour: json["jour"],
    prof: json["prof"],
    nums: json["nums"],
    tempuratureAvg: json["tempuratureAvg"],
    tempuratureIcon: json["tempuratureIcon"],
    etat: json["etat"],



  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "jour": jour,
    "prof": prof,
    "nums": nums,
    "tempuratureAvg":tempuratureAvg,
    "tempuratureIcon":tempuratureIcon,
    "etat":etat,

  };
}

GroupsList groupsListFromJson(String str) => GroupsList.fromJson(json.decode(str));

String groupsListToJson(GroupsList data) => json.encode(data.toJson());

class GroupsList {
  GroupsList({
    required this.id,
    required this.name,
  });

  String id;
  String name;

  factory GroupsList.fromJson(Map<String, dynamic> json) => GroupsList(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}