import 'package:flutter/material.dart';
import 'package:monday/common/api_com.dart';
import 'package:http/src/response.dart';
import 'package:monday/common/shared_prefs.dart';
import 'package:monday/common/utils.dart';
import 'package:monday/ui/login.dart';
import 'package:monday/model/light_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:monday/common/server_response.dart';
import 'package:monday/common/r.dart';

class LightController {

  /*
  This method is used to get light devices from Monday
   */
  static Future<List<LightModel>> getLightsFromMonday(BuildContext context) async {
    String hostname = await SharedPrefs.getMondayHostname();
    String sessionToken = await SharedPrefs.getSessionToken();
    String clientId = await SharedPrefs.getClientId();
    Map data = {
      "clientId":clientId,
      "sessionToken": sessionToken,
    };
    ServerResponse response = await ApiCom.sendRequestToMondayAPI(context, data, hostname,
        "light/read.php");
    if (response.statusCode == 200) {//lights found
      var lightsMap = jsonDecode(response.body);
      var lightListModel = LightListModel.fromJson(lightsMap);
      return lightListModel.records;
    }
    if (response.statusCode == 201){//no lights found
      List<LightModel> records = List(0);
      return records;
    }
    if (response.statusCode == 400){//bad request
      Utils.showDialogPanel(
        R.of(context).warningMsg, R.of(context).controllerSysError, context);
      return null;
    }
    if (response.statusCode == 402){//token not valid
      Utils.showDialogPanel(
        R.of(context).warningMsg, R.of(context).controllerTokenError, context);
      return null;
    }
    else {//internal error, data incomplete
      Utils.showDialogPanel(
        R.of(context).warningMsg, R.of(context).controllerSysError, context);
      return null;
    }
  }

  /*
  This method is used for switching device on/off on Monday
   */
  static Future<String> updateSwitchOnMonday (BuildContext context,
      String deviceId) async {
    String clientId = await SharedPrefs.getClientId();
    String hostname = await SharedPrefs.getMondayHostname();
    String sessionToken = await SharedPrefs.getSessionToken();
    Map data = {
      "clientId":clientId,
      "sessionToken":sessionToken,
      "id": deviceId
    };
    ServerResponse response = await ApiCom.sendRequestToMondayAPI(context, data, hostname,
        "light/switch.php");
    Map lightMap = jsonDecode(response.body);
    var light = LightModel.fromJson(lightMap);
    if (response.statusCode == 200) {//Response correctly received
      return light.switchStatus;
    }
    if (response.statusCode == 402) {//session token expired, require new login
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login(false)));
      return null;
    }
    if (response.statusCode == 503) { //error on Shelly side
      Utils.showDialogPanel(
          R.of(context).warningMsg, R.of(context).controllerDevNotReachableError, context);
      return null;
    }
    else {//internal error
      Utils.showDialogPanel(
          R.of(context).warningMsg, R.of(context).controllerSysError, context);
      return null;
    }
  }

  /*
  This method is used to get light switch status from Monday
   */
  static Future<String> getSwitchStatusFromMonday(BuildContext context,
      String deviceId) async {
    String hostname = await SharedPrefs.getMondayHostname();
    String sessionToken = await SharedPrefs.getSessionToken();
    String clientId = await SharedPrefs.getClientId();
    Map data = {
      "clientId":clientId,
      "sessionToken": sessionToken,
      "deviceId" : deviceId
    };
    ServerResponse response = await ApiCom.sendRequestToMondayAPI(context, data, hostname,
        "light/read_switch_status.php");
    if (response.statusCode == 200) {//light found
      var lightMap = jsonDecode(response.body);
      var lightModel = LightModel.fromJson(lightMap);
      return lightModel.switchStatus;
    }
    if (response.statusCode == 201){//no light found
      return "";
    }
    if (response.statusCode == 400){//bad request
      Utils.showDialogPanel(
        R.of(context).warningMsg, R.of(context).controllerSysError, context);
      return null;
    }
    if (response.statusCode == 402){//token not valid
      Utils.showDialogPanel(
        R.of(context).warningMsg, R.of(context).controllerTokenError, context);
      return null;
    }
    else {//internal error, data incomplete
      Utils.showDialogPanel(
        R.of(context).warningMsg, R.of(context).controllerSysError, context);
      return null;
    }
  }
}