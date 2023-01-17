import 'dart:convert';
import 'dart:io' show Platform;
import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:ntic_app/services/notification_services.dart';
import 'package:ntic_app/services/theme_services.dart';
import 'package:http/http.dart' as http;
import 'package:ntic_app/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/tanslateToJson_services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool iscon = false;
  final List<TimeTable> _times = [];
  final groupeName = groupName!.getString("gname");
  final lastUPTime = lastUpdate!.getString("LU");

  Future<List<TimeTable>?> fetchTimeTable() async {
    List<TimeTable> times = [];
    bool resultCon = await InternetConnectionChecker().hasConnection;
    if (resultCon == true) {
      setState(() {
        iscon = true;
      });
      String DNow = DateFormat('dd/MM kk:mm a').format(DateTime.now());
      lastUpdate!.setString("LU", DNow);
      var response = await http.get(Uri.parse(
          "https://nticrabat.com/emploi/timetable/index.php?groupe=$groupeName"));
      if (response.statusCode == 200) {
        APICacheDBModel cacheDBModel =
            new APICacheDBModel(key: "API_TT", syncData: response.body);
        await APICacheManager().addCacheData(cacheDBModel);
        var tts = jsonDecode(response.body);
        for (var tt in tts) {
          times.add(TimeTable.fromJson(tt));
        }
        print("from api");
      }
    } else {
      setState(() {
        iscon = false;
      });
      var cachData = await APICacheManager().getCacheData("API_TT");
      var tts = jsonDecode(cachData.syncData);
      for (var tt in tts) {
        times.add(TimeTable.fromJson(tt));
      }
      print("from cache");
    }
    return times;
  }

  var notifyHelper;

  @override
  Future noti() async {
    await FirebaseMessaging.instance.subscribeToTopic(groupeName!);
  }

  void initState() {
    fetchTimeTable().then((value) {
      setState(() {
        _times.addAll(value!);
      });
    });
    super.initState();
    noti();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    List allDays = ["Mon.", "Tues.", "Wed.", "Thurs.", "Fri.", "Sat."];
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Center(
          child: _times.isNotEmpty
              ? RefreshIndicator(
                  color: bluishClr,
                  onRefresh: () async {
                    await fetchTimeTable();
                  },
                  child: ListView(
                    children: [
                      ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: allDays.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            alignment: Alignment.center,
                            child: AnimationConfiguration.staggeredList(
                                position: index,
                                child: SlideAnimation(
                                  child: FadeInAnimation(
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.all(10),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          blurRadius: 5.0,
                                                          offset: Offset(5, 5))
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    color: bluishClr,
                                                  ),
                                                  child: SingleChildScrollView(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(children: [
                                                        RotatedBox(
                                                            quarterTurns: 3,
                                                            child: AutoSizeText(
                                                                allDays[index],
                                                                maxLines: 1,
                                                                style:
                                                                    GoogleFonts
                                                                        .lato(
                                                                  textStyle: const TextStyle(
                                                                      fontSize:
                                                                          23,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                ))),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          height: 80,
                                                          width: 0.5,
                                                          color:
                                                              Colors.grey[100]!,
                                                        ),
                                                        for (var i = 0;
                                                            i < _times.length;
                                                            i++)
                                                          if (_times[i].jour ==
                                                              allDays[index])
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  width: 68,
                                                                  child: Column(
                                                                    children: [
                                                                      if (_times[i]
                                                                              .etat ==
                                                                          "dist")
                                                                        Column(
                                                                          children: [
                                                                            AutoSizeText(_times[i].nums,
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.cyan.shade300),
                                                                                )),
                                                                            Text("A distance",
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.cyan.shade100),
                                                                                )),
                                                                            Text(_times[i].prof,
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                ))
                                                                          ],
                                                                        ),
                                                                      if (_times[i]
                                                                              .etat ==
                                                                          "Absent")
                                                                        Column(
                                                                          children: [
                                                                            AutoSizeText(_times[i].nums,
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.yellow),
                                                                                )),
                                                                            AutoSizeText(_times[i].etat,
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
                                                                                )),
                                                                            Text(_times[i].prof,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                ))
                                                                          ],
                                                                        ),
                                                                      if (_times[i].etat != "dist" &&
                                                                          _times[i].etat !=
                                                                              "Absent" &&
                                                                          _times[i].nums !=
                                                                              "Libre")
                                                                        Column(
                                                                          children: [
                                                                            AutoSizeText(_times[i].nums,
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                )),
                                                                            AutoSizeText(_times[i].etat,
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                )),
                                                                            Text(_times[i].prof,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                ))
                                                                          ],
                                                                        ),
                                                                      if (_times[i]
                                                                              .nums ==
                                                                          "Libre")
                                                                        Column(
                                                                          children: [
                                                                            AutoSizeText(_times[i].nums,
                                                                                maxLines: 1,
                                                                                style: GoogleFonts.lato(
                                                                                  textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.grey),
                                                                                )),
                                                                          ],
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  height: 70,
                                                                  width: 0.8,
                                                                  color: Colors
                                                                          .grey[
                                                                      100]!,
                                                                )
                                                              ],
                                                            ),
                                                      ])))),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                          );
                        },
                      ),
                    ],
                  ))
              : Center(
                  child: Platform.isAndroid
                      ? CircularProgressIndicator(
                          color: bluishClr,
                        )
                      : CupertinoActivityIndicator())),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
        },
        child: Get.isDarkMode
            ? const Icon(Icons.sunny, color: bluishClr, size: 25)
            : const Icon(Icons.nightlight_round, color: bluishClr, size: 25),
      ),
      title: Column(
        children: [
          Text(groupeName!,
              style:
                  TextStyle(color: Get.isDarkMode ? Colors.white : bluishClr)),
          iscon == false
              ? Text(
                  "Last Update: $lastUPTime",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                  ),
                )
              : Container()
        ],
      ),
      centerTitle: true,
      actions: [
        iscon == true
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: PopupMenuButton(
                  iconSize: 30,
                  color: Get.isDarkMode ? bluishClr : Colors.white,
                  icon: Icon(
                    Icons.more_horiz_outlined,
                    color: bluishClr,
                  ),
                  // add icon, by default "3 dot" icon

                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<int>(
                        onTap: () async {
                          SharedPreferences perfs =
                              await SharedPreferences.getInstance();
                          await perfs.clear();
                          await FirebaseMessaging.instance
                              .unsubscribeFromTopic(groupeName!);
                          print(groupeName);
                          Get.offNamed("/");
                        },
                        child: Text("Change Groupe"),
                      ),
                    ];
                  },
                ),
              )
            : Container()
      ], // like this!
    );
  }
}
