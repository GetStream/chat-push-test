import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Set these values with your own ones
  const apiKey = '<API-KEY>';
  const userToken = '<USER-TOKEN>';
  const userId = '<USER-ID>';

  /// Create a new instance of [StreamChatClient] passing the apikey obtained from your
  /// project dashboard.
  final client = StreamChatClient(
    apiKey,
    logLevel: Level.SEVERE,
  );

  /// Set the current user and connect the websocket. In a production scenario, this should be done using
  /// a backend to generate a user token using our server SDK.
  /// Please see the following for more information:
  /// https://getstream.io/chat/docs/ios_user_setup_and_tokens/
  await client.connectUser(
    User(id: userId),
    userToken,
  );

  runApp(MyApp(client));
}

/// Example application using Stream Chat Flutter widgets.
/// Stream Chat Flutter is a set of Flutter widgets which provide full chat functionalities
/// for building Flutter applications using Stream.
/// If you'd prefer using minimal wrapper widgets for your app, please see our other
/// package, `stream_chat_flutter_core`.
class MyApp extends StatelessWidget {
  /// Instance of Stream Client.
  /// Stream's [StreamChatClient] can be used to connect to our servers and set the default
  /// user for the application. Performing these actions trigger a websocket connection
  /// allowing for real-time updates.
  final StreamChatClient client;

  /// Example using Stream's Flutter package.
  /// If you'd prefer using minimal wrapper widgets for your app, please see our other
  /// package, `stream_chat_flutter_core`.
  MyApp(this.client);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      builder: (context, widget) {
        return StreamChat(
          child: widget,
          client: client,
        );
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text('User ID'),
            subtitle: Text(StreamChat.of(context).user.id),
          ),
          ListTile(
            title: Text('Device ID'),
            subtitle: GestureDetector(
              child: Text(token ?? ''),
              onTap: () {
                Clipboard.setData(ClipboardData(
                  text: token,
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Token copied to the clipboard'),
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: Text(
              'Please send the app to background and run the stream-cli command that you can find in the README of this project',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    setupNotifications();
    super.initState();
  }

  void setupNotifications() async {
    final firebaseMessaging = FirebaseMessaging();
    final res = await firebaseMessaging.requestNotificationPermissions();
    if (res == false) {
      throw ArgumentError(
          'You must allow notification permissions in order to receive push notifications');
    }

    firebaseMessaging.configure();
    firebaseMessaging.onTokenRefresh.listen((token) {
      StreamChat.of(context).client.addDevice(token, PushProvider.firebase);
      setState(() {
        this.token = token;
      });
    });
  }
}
