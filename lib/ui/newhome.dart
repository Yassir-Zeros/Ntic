import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:ntic_app/services/notification_services.dart';
import 'package:ntic_app/services/theme_services.dart';
import 'package:http/http.dart' as http;
import 'package:ntic_app/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import '../main.dart';
import '../services/tanslateToJson_services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class nHomePage extends StatefulWidget {
  const nHomePage({Key? key}) : super(key: key);
  @override
  State<nHomePage> createState() => _nHomePageState();
}
class _nHomePageState extends State<nHomePage> {
  bool iscon = false;
  late  List<TimeTable> _times = [];
  final groupeName = groupName!.getString("gname");
  final lastUPTime = lastUpdate!.getString("LU");
  final notiGroupeName = notiGroupe!.getString("not");

  Future checknot() async {
    if (notiGroupe!.getString("not") == null) {
      notiGroupe!.setString(
          "not", groupName!.getString("gname")!);
      await FirebaseMessaging.instance.subscribeToTopic(
          notiGroupe!.getString("not")!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Help!',
          message:
          'This group will set the group receiving notifications, it can be changed in the settings!',
          contentType: ContentType.help,
        ),
      ));
    }
  }

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
          "https://nticrabat.com/emploi/timetable/index.php?version=2&groupe=$groupeName"));
      if (response.statusCode == 200) {
        APICacheDBModel cacheDBModel =
            APICacheDBModel(key: "API_TT", syncData: response.body);
        await APICacheManager().addCacheData(cacheDBModel);
        var tts = jsonDecode(response.body);
        setState(() {
          for (var tt in tts) {
            times.add(TimeTable.fromJson(tt));
          }
        });

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
    }
    return times;
  }
  var notifyHelper;
  @override
  void initState() {
    checknot();
    fetchTimeTable().then((value) {
      setState(() {
        _times.addAll(value!);
      });
    });
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    double contexHeight = MediaQuery.of(context).size.height;

    double highval = 0;
    if (contexHeight > 600 && contexHeight < 900) {
      highval = 8.0;
    }else if (contexHeight > 900) {
      highval = 15;
    } else if (contexHeight < 600) {
      highval = 0;
    }
    List allDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: UpgradeAlert(
        upgrader:Upgrader(
          showIgnore:false,
        showLater: false,
        dialogStyle: Platform.isAndroid? UpgradeDialogStyle.material : UpgradeDialogStyle.cupertino,
        ) ,
        child: Center(
            child: _times.isNotEmpty
                ? RefreshIndicator(
                    color: bluishClr,
                    onRefresh: () async{
                      setState(() {
                        _times = [];
                      });
                      fetchTimeTable().then((value) {
                        setState(() {
                          _times.addAll(value!);
                        });
                      });
                    },
                    child: ListView(
                      children: [
                    Row(
                      children: [
                        const SizedBox(
                        width: 10,
                      ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child:Container(
                            margin: const EdgeInsets.only(
                                left: 5, right: 5),
                            height: contexHeight * 0.05,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(
                                  4),
                              color: Get.isDarkMode
                                  ?secBlackmode : pinkClr,
                            ),
                            child: FittedBox(
                              child: Padding(
                                padding:
                                const EdgeInsets.all(
                                    5.0),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          children: [
                                            AutoSizeText(
                                                "08:30",
                                                maxLines:
                                                1,
                                                style: GoogleFonts
                                                    .openSans(
                                                  textStyle: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ), //BoxDecoration
                          ), //Container
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child:Container(
                            margin: const EdgeInsets.only(
                                left: 5, right: 5),
                            height: contexHeight * 0.05,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(
                                  4),
                              color: Get.isDarkMode
                                  ?secBlackmode : pinkClr,
                            ),
                            child: FittedBox(
                              child: Padding(
                                padding:
                                const EdgeInsets.all(
                                    5.0),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          children: [
                                            AutoSizeText(
                                                "11:00",
                                                maxLines:
                                                1,
                                                style: GoogleFonts
                                                    .openSans(
                                                  textStyle: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ), //BoxDecoration
                          ), //Container
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 5, right: 5),
                            height: contexHeight * 0.05,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(
                                  4),
                              color: Get.isDarkMode
                                  ?secBlackmode : pinkClr,
                            ),
                            child: FittedBox(
                              child: Padding(
                                padding:
                                const EdgeInsets.all(
                                    5.0),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          children: [
                                            AutoSizeText(
                                                "13:30",
                                                maxLines:
                                                1,
                                                style: GoogleFonts
                                                    .openSans(
                                                  textStyle: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ), //BoxDecoration
                          ), //Container
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 5, right: 5),
                            height: contexHeight * 0.05,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(
                                  4),
                              color: Get.isDarkMode
                                  ?secBlackmode : pinkClr,
                            ),
                            child: FittedBox(
                              child: Padding(
                                padding:
                                const EdgeInsets.all(
                                    5.0),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          children: [
                                            AutoSizeText(
                                                "16:00",
                                                maxLines:
                                                1,
                                                style: GoogleFonts
                                                    .openSans(
                                                  textStyle: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ), //BoxDecoration
                          ), //Container
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: allDays.length,
                        shrinkWrap: true,
                         itemBuilder: (context, index ) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: Padding(
                              padding: EdgeInsets.all(highval),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6, left: 20),
                                    child: Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: allDays[index] ,
                                            style: GoogleFonts.alegreyaSansSc(
                                                textStyle: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Get.isDarkMode
                                                        ? secBlackmode
                                                        : bluishClr)),
                                            children: <TextSpan>[
                                              for (var i = 0;
                                              i < _times.length;
                                              i++)
                                                if (_times[i].jour ==
                                                    allDays[index])
                                                  if(_times[i].tempuratureAvg != null && _times[i].tempuratureAvg!="")
                                                  TextSpan(text: "  ${_times[i].tempuratureAvg!}°C ",
                                                      style: GoogleFonts.quicksand(color: Get.isDarkMode? Colors.grey:Colors.black38 ,fontSize: 15),
                                                  ),

                                            ],
                                          ),
                                        ),
                                        for (var i = 0;
                                        i < _times.length;
                                        i++)
                                          if (_times[i].jour ==
                                              allDays[index])
                                            if(_times[i].tempuratureIcon != null && _times[i].tempuratureIcon!="" && iscon == true)
                                              Image.network(_times[i].tempuratureIcon!,
                                                width: 25,height: 25,)
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: <Widget>[
                                      for (var i = 0;
                                          i < _times.length;
                                          i++)
                                        if (_times[i].jour ==
                                            allDays[index])
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child:Container(
                                              margin: const EdgeInsets.only(left: 5, right: 5),
                                              height: contexHeight * 0.08,
                                              decoration: BoxDecoration(
                                                  boxShadow:[
                                                    BoxShadow(
                                                      color: _times[i].nums ==
                                                          "Free"? Colors.white.withOpacity(0):Colors.black,
                                                        blurStyle: BlurStyle.normal,
                                                        blurRadius:5,
                                                        offset:const Offset(3,4))
                                                  ],
                                                border: Border.all(
                                                    color: Get.isDarkMode
                                                        ? Colors.white
                                                        : bluishClr),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4),
                                                color: _times[i].etat ==
                                                        "Absent"
                                                    ? yellowClr
                                                    : _times[i].etat ==
                                                            "dist"
                                                        ? adistanceClr
                                                        : _times[i].nums ==
                                                                "Free"
                                                            ? Colors.white.withOpacity(0)
                                                            : bluishClr,
                                              ),
                                              child: FittedBox(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(
                                                          5.0),
                                                  child: Column(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          if (_times[i]
                                                                  .etat ==
                                                              "dist")
                                                            Column(
                                                              children: [
                                                                Text(
                                                                    "A distance",
                                                                    maxLines:
                                                                        1,
                                                                    style: GoogleFonts
                                                                        .openSans(
                                                                      textStyle: const TextStyle(
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.white),
                                                                    )),
                                                                Text(
                                                                    _times[i]
                                                                        .prof,
                                                                    maxLines:
                                                                        1,
                                                                    style: GoogleFonts
                                                                        .openSans(
                                                                      textStyle: const TextStyle(
                                                                          fontSize: 10,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.white),
                                                                    ))
                                                              ],
                                                            ),
                                                          if (_times[i]
                                                                  .etat ==
                                                              "Absent")
                                                            Column(
                                                              children: [

                                                                AutoSizeText(
                                                                    " Absent ",
                                                                    maxLines:
                                                                        1,
                                                                    style: GoogleFonts
                                                                        .openSans(
                                                                      textStyle: TextStyle(
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.bold,
                                                                          color:absentText),
                                                                    )),
                                                                Text(
                                                                    _times[i]
                                                                        .prof,
                                                                    style: GoogleFonts
                                                                        .openSans(
                                                                      textStyle: TextStyle(
                                                                          fontSize: 10,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: absentText),
                                                                    )),
                                                              ],
                                                            ),
                                                          if (_times[i]
                                                                      .etat !=
                                                                  "dist" &&
                                                              _times[i]
                                                                      .etat !=
                                                                  "Absent" &&
                                                              _times[i]
                                                                      .nums !=
                                                                  "Free")
                                                            Column(
                                                              children: [
                                                                Container(
                                                                  height: 5,
                                                                  color: Colors.transparent,
                                                                ),
                                                                Text(
                                                                    _times[i]
                                                                        .etat,
                                                                    maxLines: 1,
                                                                    style: GoogleFonts
                                                                        .openSans(
                                                                      textStyle: const TextStyle(
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.white),
                                                                    )),
                                                                Text(
                                                                    _times[i]
                                                                        .prof,
                                                                    maxLines: 1,
                                                                    style: GoogleFonts
                                                                        .openSans(
                                                                      textStyle: const TextStyle(

                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.white),
                                                                    )),
                                                                Container(
                                                                  height: 5,
                                                                  color: Colors.transparent,
                                                                ),
                                                              ],
                                                            ),
                                                          if (_times[i]
                                                                  .nums ==
                                                              "Free")
                                                            Column(
                                                              children: [
                                                                AutoSizeText(
                                                                    _times[i]
                                                                        .nums,
                                                                    maxLines:
                                                                        1,
                                                                    style: GoogleFonts
                                                                        .openSans(
                                                                      textStyle: TextStyle(
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.transparent),
                                                                    )),
                                                              ],
                                                            ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ), //BoxDecoration
                                            ), //Container
                                          ),

                                    ],
                                  )
                                ],
                              ), //Column
                            ),
                          ); //Container
                        })
                      ],
                    ))
                : Center(
                    child: Platform.isAndroid
                        ? const CircularProgressIndicator(
                            color: bluishClr,
                          )
                        : const CupertinoActivityIndicator())),
      ),
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
            ?  Icon(Icons.sunny, color: Get.isDarkMode
            ?secBlackmode : pinkClr, size: 25)
            :  Icon(Icons.nightlight_round, color: Get.isDarkMode
            ?secBlackmode : pinkClr, size: 25),
      ),
      title: Column(
        children: [
          Text(groupeName!,
              style: GoogleFonts.openSans(
                  color: Get.isDarkMode ? Colors.white : bluishClr,
                  fontWeight: FontWeight.bold)),
          iscon == false
              ? Text("Last Update: $lastUPTime",
                  style: GoogleFonts.quicksand(
                    textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: offlineClr),
                  ))
              : Container()
        ],
      ),
      centerTitle: true,
      actions: [
        iscon == true
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: PopupMenuButton(
                  iconSize: 30,
                  color: Get.isDarkMode
                      ?secBlackmode : Colors.white,
                  icon: Icon(
                    Icons.more_horiz_outlined,
                    color: Get.isDarkMode
                        ?secBlackmode : pinkClr,
                  ),
                  // add icon, by default "3 dot" icon

                   itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        onTap: () async {
                          SharedPreferences perfs =
                              await SharedPreferences.getInstance();
                          await perfs.remove("gname");
                          Get.offNamed("/");
                        },
                        child: Row(
                          mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Change Groupe "),
                         Icon(Icons.change_circle_outlined,
                           color: Get.isDarkMode
                           ?Colors.white : pinkClr,),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          print(notiGroupe!.getString("not"));
                          if (notiGroupe!.getString("not") == null) {
                            notiGroupe!.setString(
                                "not", groupName!.getString("gname")!);
                            await FirebaseMessaging.instance.subscribeToTopic(
                                notiGroupe!.getString("not")!);
                          } else {
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic(
                                    notiGroupe!.getString("not")!);
                            SharedPreferences perfs =
                                await SharedPreferences.getInstance();
                            await perfs.remove("not");
                            notiGroupe!.setString(
                                "not", groupName!.getString("gname")!);
                            await FirebaseMessaging.instance.subscribeToTopic(
                                notiGroupe!.getString("not")!);
                          }

                          if (notiGroupe!.getString("not") == groupeName) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Success!',
                                message:
                                    'Settings have been changed successfully!',
                                contentType: ContentType.success,
                              ),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Error!',
                                message:
                                    'A problem has been occurred while submitting your data!',
                                contentType: ContentType.warning,
                              ),
                            ));
                          }

                          print(notiGroupe!.getString("not"));
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Set as default "),
                            Icon(Icons.notifications_active_outlined,color: Get.isDarkMode
                                ?Colors.white : pinkClr,)
                          ],
                        ),
                      )
                    ];
                  },
                ),
              )
            : Container()
      ], // like this!
    );
  }
}
