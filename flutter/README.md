# Flutter Push Test Application

## Usage
1. Clone the repo `git clone git@github.com:GetStream/chat-push-test.git`
2. `cd flutter`
3. In folder `flutter pub get`
4. Input your api key and secret in `lib/main.dart`
5. Change the bundle identifier/application ID and development team/user so you can run the app in your device (**do not** run on iOS simulator, Android emulator is fine)
6. Add your google-services.json/GoogleService-Info.plist 
7. Run the app
8. Accept push notification permission (iOS only)
9. Tap on `Device ID` and copy it
10. Send the app to background
11. After configuring [stream-cli](https://github.com/GetStream/stream-cli) paste the following command on command line using your user ID
```
stream chat:push:test -u <USER-ID>
```

You should get a test push notification
