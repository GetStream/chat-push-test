# iOS Push Test Application

## Usage
1. Clone the repo
1. In folder `pod install`
1. Input your api key and secret in `AppDelegate.swift:L25`
1. Change the bundle identifier and development team/user so you can run the app in your device (**do not** run on simulator)
1. Run the app on real device
1. Accept push notification permission
1. Long touch on `stream-cli Command` and copy it
1. Send the app to background
1. [After configuring `stream-cli`] Paste the command on command line

You should get a test push notification
