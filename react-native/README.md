# Stream Chat Push Notification Test Application

- Clone our repo for push testing.

  ```sh

  # Clone the repository
  git clone git@github.com:GetStream/chat-push-test.git

  # Go to react-native project directory
  cd chat-push-test/react-native

  # Install yarn dependencies
  yarn && npx pod-install

  # Create environment file
  mv .env.template .env
  ```

- Set the API_KEY, USER_ID and USER_TOKEN inside chat-push-test/react-native/.env file

- Configure bundle identifier:
  - iOS
    - Open the project (chat-push-test/react-native/ios/ChatPushTest.xcworkspace) in xcode, and update the bundle identifier, which you registered on firebase.

      ![115986575-1e3c6100-a5b1-11eb-9](https://user-images.githubusercontent.com/11586388/116699541-f93b5a00-a9c5-11eb-881a-b0fac18b87ce.png)


    - Add your GoogleService-info.plist file as mentioned in [React Native Firebase docs](https://rnfirebase.io/#generating-ios-credentials)
    - Clean and re-build the project

  - Android
    - Add your google-services.json file as mentioned in [React Native Firebase docs](https://rnfirebase.io/#2-android-setup).
    - Use the following command to change the applicationId to the one which you registered on firebase.

      ![Webp net-resizeimage](https://user-images.githubusercontent.com/11586388/116699686-28ea6200-a9c6-11eb-971f-bae4db7bf174.png)

      ```sh
      npx react-native-rename -b <APPLICATION_ID>
      ```
    - Clean and re-build the project
- Run the app on device (NOT SIMULATOR).
- Accept push notification permission.
- Send the app to background.
- Install and Configure stream-cli.
- After configuring stream-cli paste the following command on command line using your user ID.
  ```sh
  stream chat:push:test -u <USER-ID>
  ```
- You should receive a test push notification. If you do, that means push related config is correct.