<p align="center" >
<img src="https://s3-eu-west-1.amazonaws.com/hokoassets/hoko_logo.png" alt="Hoko" title="Hoko">
</p>

[![Build Status](https://travis-ci.org/hokolinks/hoko-ios.svg?branch=master)](https://travis-ci.org/hokolinks/hoko-ios)

# What's HOKO?

The HOKO framework is an easy to use deep linking framework that enables an app to map deep linking routes to actual behavior in the app. This behavior can include showing a particular screen or performing a certain action. HOKO also allows users to be redirected to your app regardless of the platform they are on.

After integrating HOKO, you will be able to open your app by using URI links such as...

```
your.app.scheme://<mapped_route>/<route_param>?<query_params>
```

# Quick Start - HOKO framework for iOS

This document is a quick start introduction to the HOKO framework for iOS. You can read the full documentation at [http://hokolinks.com/documentation#ios](http://hokolinks.com/documentation#ios).

To integrate HOKO in your app, simply follow the 3 simple steps below after adding it to your project.

## Install HOKO in your project

### Cocoapods

1. Install [CocoaPods](http://cocoapods.org/) in your system
2. Open your Xcode project folder and create a file called `Podfile` with the following content:

    ```ruby
    pod 'Hoko', :git => 'https://github.com/hokolinks/hoko-ios.git', :branch => 'push_notifications'
    ```

3. Run `pod install` and wait for CocoaPod to install HOKO SDK. From this moment on, instead of using `.xcodeproj` file, you should start using `.xcworkspace`.

### Framework

1. Download the [Hoko SDK](https://github.com/hokolinks/hoko-ios/archive/master.zip).
2. Drag the `Hoko` folder to your project.
3. Be sure to also add `SystemConfiguration.framework` and `zlib.dylib` in case your project does not include it already.

## SDK Setup

Add the following line to your `applicationDidFinishLaunching` method in your `AppDelegate` class.

Objective-C

```objective-c
#import <Hoko/Hoko.h>

- (BOOL)application:(UIApplication *)application 
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[Hoko setupWithToken:@"YOUR-APP-TOKEN"];
	// The rest of your code goes here...
}
```

Swift

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	Hoko.setupWithToken("YOUR-APP-TOKEN")
	// The rest of your code goes here...
}
```

### 1. Add a URL Scheme to your App

To register a URL scheme you should navigate to your project's application **target**, select the **info** tab, and under **URL Types** click the **plus** sign.
Once there you should assign a custom (and unique) URL scheme. Following Apple's guidelines is should be in **reverse DNS notation** (e.g. *com.hoko.hokotestbed*).

![URL Scheme](https://s3-eu-west-1.amazonaws.com/hokoassets/urlschemes-ios.png)

### 2. Deeplinking

To map routes to your View Controllers all you have to do is map them in the **deeplinking** module on your `applicationDidFinishLaunching` method in your `AppDelegate` class. 

Objective-C

```objective-c
[HokoDeeplinking mapRoute:@"product/:product_id" toTarget:^(HKDeeplink *deeplink) {
	BLKProductViewController *productViewController = [[BLKProductViewController alloc] initWithProductId:deeplink.routeParameters[@"product_id"]];
	productViewController.referrer = deeplink.queryParameters[@"referrer"];
	[HKNavigation pushViewController:productViewController animated:YES];
}];
```

Swift

```swift
Hoko.deeplinking().mapRoute("product/:product_id", toTarget: { (deeplink: HKDeeplink!) -> Void in
	let productViewController = BLKPRoductViewController(productId: deeplink.routeParameters["product_id"])
	productViewController.referrer = deeplink.queryParameters["referrer"]
	HKNavigation.pushViewController(productViewController, animated: true)
})
```

In order to perform certain tasks whenever a deep link enters the application, a `Handler` may be added to the `Deeplinking` module. This makes it easier to track deep links to analytics platforms, log entries or update your database.

Objective-C

```objective-c
[HokoDeeplinking addHandlerBlock:^(HKDeeplink *deeplink) {
	[[Analytics sharedInstance] track:"deeplink" parameters:@{@"route": deeplink.route}];
}];
```

Swift

```swift
Hoko.deeplinking().addHandlerBlock { (deeplink: HKDeeplink!) -> Void in
	Analytics.sharedInstance().track("deeplink", parameters: ["route": deeplink.route])
}
```


### 3. Analytics


If your app identifies its users to the HOKO SDK, the HOKO platform will be able to provide you with better usage metrics and better user targeting when creating Hokolinks or push notification campaigns. To identify users the app needs to provide a few user details, namely an identifier, which can be an e-mail, an integer or even a username and the login methodology (e.g. Facebook, Twitter or GitHub login).

Objective-C

```objective-c
[[Hoko analytics] identifyUserWithIdentifier:@"johnappleseed"
                                 accountType:HKUserAccountTypeGithub];
```

Swift

```swift
Hoko.analytics().identifyUserWithIdentifier("johnappleseed",
    accountType: .Github)
```

To complement the automatically gathered information from **sessions** the app should manually track the key events associated of which to measure the success or failure of a push notification campaign session. You can track events with or without associated monetary value.

Objective-C

```objective-c
[[Hoko analytics] trackKeyEvent:@"facebook_share"];
[[Hoko analytics] trackKeyEvent:@"dress_purchase" amount:@(29.99)];
```

Swift

```swift
Hoko.analytics().trackKeyEvent("facebook_share")
Hoko.analytics().trackKeyEvent("dress_purchase", amount:29.99)
```

### Full documentation

We recommend you to read the full documentation at [http://hokolinks.com/documentation#ios](http://hokolinks.com/documentation#ios).


# Author

HOKO, S.A.

# License

HOKO is available under the Apache license. See the LICENSE file for more info.

