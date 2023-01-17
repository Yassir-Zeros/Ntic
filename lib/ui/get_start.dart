import 'dart:convert';
import 'package:footer/footer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ntic_app/services/notification_services.dart';
import '../main.dart';
import '../services/tanslateToJson_services.dart';

class GetStart extends StatefulWidget {
  const GetStart({Key? key}) : super(key: key);

  @override
  State<GetStart> createState() => _GetStartState();
}

late String groupNameValue;

class _GetStartState extends State<GetStart> {
  var notifyHelper;
  @override
  void initState() {

    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit.fill
                      )
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child:Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/light-1.png')
                              )
                          ),
                        ),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child:Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/light-2.png')
                              )
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/clock.png')
                              )
                          ),
                        ),
                      ),
                      Positioned(
                        left: 30,
                        top: 190,
                        width: 80,
                        height: 150,
                        child: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/timetable.png')
                              )
                          ),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 280,
                        width: 80,
                        height: 150,
                        child: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/notif.png')
                              )
                          ),
                        ),
                      ),
                      Positioned(
                        child:Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text("Welcome",style: GoogleFonts.openSans(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    children: <Widget>[Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color.fromRGBO(143, 148, 251,0.7),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromRGBO(143, 148, 251, .2),
                                blurRadius: 20,
                                offset: Offset(0, 10)
                            )
                          ]
                      ),
                      child: Container(
                        child: DropdownButtonExample(),
                      ),
                    ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Footer(backgroundColor: Colors.transparent,
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Created by : ",
                      style: GoogleFonts.quicksand(color: Colors.grey),
                      children: <TextSpan>[
                        TextSpan(text: 'Yassir Rifi', style: GoogleFonts.quicksand(color: Get.isDarkMode? Colors.white:Colors.black87)),
                      ],
                    ),
                  ),
                  Text("“ DEVOWFS203 „",style: GoogleFonts.quicksand(color: Get.isDarkMode? Colors.white70:Colors.black87 , fontSize: 12))
                ],
              )
          )
        ],
      ),

    );
  }


}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  @override
  void initState() {
    fetchGroupsList().then((value) {
      setState(() {
        _groups.addAll(value);
      });
    });
    super.initState();
  }

  final List<GroupsList> _groups = [];

  Future<List<GroupsList>> fetchGroupsList() async {
    //var response = await http.get(Uri.parse("http://127.0.0.1:8000/api/group-list"));
    var response = await http
        .get(Uri.parse("https://nticrabat.com/emploi/timetable/list.php"));
    List<GroupsList> groups = [];

    if (response.statusCode == 200) {
      var tts = jsonDecode(response.body);
      for (var tt in tts) {
        groups.add(GroupsList.fromJson(tt));
      }
    }
    return groups;
  }

  String dropdownValue = "INFO201";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
            value: dropdownValue,
            dropdownColor:Color.fromRGBO(143, 148, 251, 1),
            icon: const Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.white70,),
            elevation: 16,
            underline: Container(
              height: 4,
              color:
              Colors.white70,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
                groupNameValue = value;
              });
              groupName!.setString("gname", groupNameValue);
              Get.offNamed("/home");
            },
            items: _groups.map((value) {
              return DropdownMenuItem(
                value: value.name,
                child: Center(child:
                Text(value.name.toString(),style: GoogleFonts
                    .openSans(
                  textStyle: TextStyle(

                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ))),
              );
            }).toList(),
            hint: Text("Groupe Name")),
      ],
    );
  }
}