import {API_KEY, USER_ID, USER_TOKEN} from '@env';
import messaging from '@react-native-firebase/messaging';
import Clipboard from '@react-native-community/clipboard';

import React, {useEffect, useRef, useState} from 'react';
import {AppState, StyleSheet, Text, View} from 'react-native';

import {StreamChat} from 'stream-chat';

const client = StreamChat.getInstance(API_KEY);

/** You may also request permissions in root entry file of your application - index.js */
const requestPermission = async () => {
  const authStatus = await messaging().requestPermission({
    badge: true,
  });
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL;

  if (enabled) {
    console.log('Authorization status:', authStatus);
  }
};

const App = () => {
  const [isReady, setIsReady] = useState(false);
  const appState = useRef('');

  useEffect(() => {
    let unsubscribeTokenRefreshListener;
    // Register FCM token with stream chat server.
    const registerPushToken = async () => {
      const token = await messaging().getToken();
      await client.addDevice(token, 'firebase');

      unsubscribeTokenRefreshListener = messaging().onTokenRefresh(
        async newToken => {
          await client.addDevice(newToken, 'firebase');
        },
      );
    };

    const init = async () => {
      await client.connectUser({id: USER_ID}, USER_TOKEN);

      await requestPermission();
      await registerPushToken();

      setIsReady(true);
    };

    init();

    return async () => {
      await client?.disconnectUser();
      unsubscribeTokenRefreshListener?.();
    };
  }, []);

  useEffect(() => {
    const handleRemoteMessage = remoteMessage => {
      try {
        const channel = JSON.parse(remoteMessage.data.channel);
        console.log('This message belongs to channel with id - ', channel.id);
      } catch (_) {
        // channel doesn't exist in data template
      }

      const message = remoteMessage.data?.message;

      if (message) {
        console.log('Message id is', message);
      }

      // You will add your navigation logic, to navigate to relevant channel screen.
    };

    // `onNotificationOpenedApp` gets called when app is in background, and you press
    // the push notification.
    //
    // Here its assumed a message-notification contains a "channel" property in the data payload.
    //
    // Please check the docs on push template:
    // https://getstream.io/chat/docs/javascript/push_template/?language=javascript
    messaging().onNotificationOpenedApp(remoteMessage => {
      console.log(
        'Notification caused app to open from BACKGROUND state:',
        remoteMessage,
      );

      handleRemoteMessage(remoteMessage);
    });

    // `getInitialNotification` gets called when app is in quit state, and you press
    // the push notification.
    //
    //
    // Here its assumed that a message-notification contains a "channel" property in the data payload.
    // Please check the docs on push template:
    // https://getstream.io/chat/docs/javascript/push_template/?language=javascript
    messaging()
      .getInitialNotification()
      .then(remoteMessage => {
        if (remoteMessage) {
          console.log(
            'Notification caused app to open from QUIT state:',
            remoteMessage,
          );

          handleRemoteMessage(remoteMessage);
        }
      });
  }, []);

  useEffect(() => {
    const _handleAppStateChange = async nextAppState => {
      if (appState.current === 'background' && nextAppState === 'active') {
        await client.openConnection();
      } else if (
        appState.current.match(/active|inactive/) &&
        nextAppState === 'background'
      ) {
        await client.closeConnection();
      }

      appState.current = nextAppState;
    };

    AppState.addEventListener('change', _handleAppStateChange);

    return () => {
      AppState.removeEventListener('change', _handleAppStateChange);
    };
  }, []);

  const command = `stream chat:push:test --user_id ${USER_ID}`;
  const copyCommand = () => {
    Clipboard.setString(command);
  };

  if (!isReady) {
    return null;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Push Test</Text>
      <View style={styles.pushCommandContainer}>
        <Text style={styles.pushCommandText} onPress={copyCommand}>
          {command}
        </Text>
      </View>
      <Text>(Paste this command in your terminal ☝️)</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 25,
    fontWeight: '700',
  },
  pushCommandContainer: {
    backgroundColor: '#ececec',
    borderRadius: 10,
    paddingVertical: 10,
    paddingHorizontal: 20,
    marginVertical: 20,
  },
  pushCommandText: {
    fontSize: 18,
  },
});

export default App;
