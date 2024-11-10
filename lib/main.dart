import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:ntic_app/Middleware/AuthMiddleWarePages.dart';
import 'package:ntic_app/services/theme_services.dart';
import 'package:ntic_app/shared/constants.dart';
import 'package:ntic_app/ui/get_start.dart';
import 'package:ntic_app/ui/newhome.dart';
import 'package:ntic_app/ui/theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notiGroupeName = notiGroupe!.getString("not");
SharedPreferences? groupName;
SharedPreferences? lastUpdate;
SharedPreferences? notiGroupe;
final groupeName = groupName!.getString("gname");
Future noti() async {
  if (notiGroupeName != null)
    await FirebaseMessaging.instance.subscribeToTopic(notiGroupe!.getString("not")!);
  print("main $notiGroupeName");
}
late final FirebaseMessaging _messaging;
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
void requestAndRegisterNotification() async {
  // 1. Initialize the Firebase app
  await Firebase.initializeApp();

  // 2. Instantiate Firebase Messaging
  _messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. On iOS, this helps to take the user permissions
  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  }
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  }

  else{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    lastUpdate = await SharedPreferences.getInstance();
    groupName = await SharedPreferences.getInstance();
    notiGroupe = await SharedPreferences.getInstance();
    await GetStorage.init();
    noti();
    runApp(const MyApp());
  }}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: GetMaterialApp(
        title: 'NTIC Notify',
        debugShowCheckedModeBanner: false,
        theme: Themes.dark,
        darkTheme: Themes.light,
        themeMode: ThemeService().theme,
        initialRoute: "/",
        getPages: [
          GetPage(
              name: "/", page: () => const GetStart(), middlewares: [AuthMiddleware()]),
          GetPage(name: "/home", page: () => const nHomePage())
        ],
        //home: GetStart(),
      ),
    );
  }
}
