import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:letshang/main.dart';
import 'package:letshang/screens/events/event_details_screen.dart';
import 'package:letshang/screens/invitations/event_invitation_notification_screen.dart';
import 'package:letshang/utils/router.dart';

class PushNotificationService {
  static final FirebaseMessaging firebaseMessageService =
      FirebaseMessaging.instance;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static late AndroidNotificationChannel androidChannel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Define a top-level named handler which background/terminated messages will
  /// call.
  ///
  /// To verify things are working, check out the native platform logs.
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
  }

  static void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    final dataMap = message.data;
    final entityType =
        dataMap.containsKey("entityType") ? dataMap["entityType"] : null;
    final notificationType = dataMap.containsKey("notificationType")
        ? dataMap["notificationType"]
        : null;
    if (notificationType != null) {
      if (notificationType == "Invitation") {
        if (entityType != null) {
          if (entityType == "Event") {
            AppRouter.lhRouterConfig.go(
                "/eventInvitationNotification/${dataMap["userId"]}/${dataMap["entityId"]}/${dataMap["notificationId"]}");
          }
          if (entityType == "Group") {
            AppRouter.lhRouterConfig.go(
                "/groupInvitationNotification/${dataMap["userId"]}/${dataMap["entityId"]}/${dataMap["notificationId"]}");
          }
        }
      } else if (notificationType == "Announcement") {
        if (entityType != null) {
          if (entityType == "Event") {
            AppRouter.lhRouterConfig.go("/eventDetails/${dataMap["entityId"]}");
          }
          // if (entityType == "Group") {
          //   navigatorKey.currentState?.push(MaterialPageRoute(
          //     builder: (context) => EventInvitationNotificationScreen(
          //       userId: dataMap["userId"],
          //       eventId: dataMap["entityId"],
          //       notificationId: dataMap["notificationId"],
          //     ),
          //   ));
          // }
        }
      } else if (notificationType == "NewPoll") {
        if (entityType != null) {
          if (entityType == "Event") {
            AppRouter.lhRouterConfig.go(
                "/eventPollNotification/${dataMap["entityId"]}/${dataMap["eventPollId"]}");
          }
          // if (entityType == "Group") {
          //   navigatorKey.currentState?.push(MaterialPageRoute(
          //     builder: (context) => EventInvitationNotificationScreen(
          //       userId: dataMap["userId"],
          //       eventId: dataMap["entityId"],
          //       notificationId: dataMap["notificationId"],
          //     ),
          //   ));
          // }
        }
      }
    }
  }

  static Future initializeLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings("@drawable/lets_hang_logo");
    const settings = InitializationSettings(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
      handleMessage(message);
    });
    final platform =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(androidChannel);
  }

  static Future initializePushNotifications() async {
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                androidChannel.id,
                androidChannel.name,
                channelDescription: androidChannel.description,
                icon: '@drawable/lets_hang_logo',
              ),
            ),
            payload: jsonEncode(message.toMap()));
      }
    });
  }

  static Future initialize() async {
    await firebaseMessageService.requestPermission(
        alert: true, badge: true, provisional: false, sound: true);
    initializePushNotifications();
    initializeLocalNotifications();
  }
}
