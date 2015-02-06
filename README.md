<p align="center" >
<img src="https://s3-eu-west-1.amazonaws.com/hokoassets/hoko_logo.png" alt="Hoko" title="Hoko">
</p>

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
    pod 'Hoko', '~> 1.0.2'
    ```

3. Run `pod install` and wait for CocoaPod to install HOKO SDK. From this moment on, instead of using `.xcodeproj` file, you should start using `.xcworkspace`.

### Framework

1. Download the [Hoko SDK](https://github.com/hokolinks/hoko-ios/archive/master.zip).
2. Drag the `Hoko.framework` file to your project's `Target Dependencies`.
3. Be sure to also add `SystemConfiguration.framework` and `zlib.dylib` in case your project does not include it already.

## SDK Setup

Add the following line to your `applicationDidFinishLaunching` method in your `AppDelegate` class.

```objective-c
#import <Hoko/Hoko.h>

- (BOOL)application:(UIApplication *)application 
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[Hoko setupWithToken:@"YOUR-APP-TOKEN"];
	// The rest of your code goes here...
}
```

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	Hoko.setupWithToken("YOUR-APP-TOKEN")
	// The rest of your code goes here...
}
```

### 2. Add a URL Scheme to your App

To register a URL scheme you should navigate to your project's application **target**, select the **info** tab, and under **URL Types** click the **plus** sign.
Once there you should assign a custom (and unique) URL scheme. Following Apple's guidelines is should be in **reverse DNS notation** (e.g. *com.hoko.hokotestbed*).

![URL Scheme](https://s3-eu-west-1.amazonaws.com/hokoassets/urlschemes-ios.png)

### 2. Deeplinking

To map routes to your View Controllers all you have to do is map them in the **deeplinking** module on your `applicationDidFinishLaunching` method in your `AppDelegate` class. 

```objective-c
[[Hoko deeplinking] mapRoute:@"product/:product_id" toTarget:^(HKDeeplink *deeplink) {
    HKTBDetailViewController *tableViewController = [[HKTBDetailViewController alloc]init];
    tableViewController.productId = deeplink.routeParameters[@"product_id"];
    tableViewController.productPrice = deeplink.queryParameters[@"product_price"];
    [HKNavigation pushViewController:tableViewController animated:YES];
  }];
```


### 3. Push Notifications

To allow your app to receive push notifications, simply add the following piece of code to wherever you want to ask your user to allow push notifications. By default, added it to your `AppDelegate` as well.

```objective-c
[[Hoko pushNotifications] registerForRemoteNotificationTypes:HKRemoteNotificationTypeAlert|HKRemoteNotificationTypeBadge|HKRemoteNotificationTypeSound];
```

### 4. Analytics

In order to provide metrics on push notifications and deeplinking campaigns, it is advised to delegate key events to the Analytics module (e.g. in-app purchases, referals, etc).

All you have to do is:

```objective-c
[[Hoko analytics] trackKeyEvent:@"dress_purchase" amount:@(29.99)];
```

You can also identify your users to create targeted campaigns on HOKO.

```objective-c
[[Hoko analytics] identifyUserWithIdentifier:@"johndoe"
                       accountType:HKUserAccountTypeGitHub
                              name:@"John Doe"
                             email:@"johndoe@hoko.com"
                         birthDate:[NSDate date]
                            gender:HKUserGenderMale];
```

### Full documentation

We recommend you to read the full documentation at [http://hokolinks.com/documentation#ios](http://hokolinks.com/documentation#ios).


# Author

HOKO, S.A.

# License

HOKO is available under the Apache license. See the LICENSE file for more info.

