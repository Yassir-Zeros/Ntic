import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../main.dart';
class AuthMiddleware extends GetMiddleware{
  @override
  RouteSettings? redirect(String? route){
    if(groupName!.getString("gname") != null)
      return const RouteSettings(name: "/home");
  }
}