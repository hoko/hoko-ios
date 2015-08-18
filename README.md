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

This document is a quick start introduction to the HOKO framework for iOS (only <u>iOS 5 and higher</u>). You can read the full documentation at [http://hokolinks.com/documentation#ios](http://support.hokolinks.com/ios/ios-setup/).

To integrate HOKO in your app, simply follow the 3 simple steps below after adding it to your project.

## Install HOKO in your project

### Cocoapods

1. Install [CocoaPods](http://cocoapods.org/) in your system
2. Open your Xcode project folder and create a file called `Podfile` with the following content:

    ```ruby
    pod 'Hoko', '~> 2.2'
    ```

3. Run `pod install` and wait for CocoaPod to install HOKO SDK. From this moment on, instead of using `.xcodeproj` file, you should start using `.xcworkspace`.

### Framework

1. Download the [Hoko SDK](https://github.com/hokolinks/hoko-ios/archive/master.zip).
2. Drag the `Hoko` folder to your project.
3. Be sure to also add `SystemConfiguration.framework` and `libz.dylib` in case your project does not include it already.

### Integrating the SDK with your Swift project

Because the HOKO SDK is written in `Objective-C`, you'll have to manually add a `Bridging Header file` into your project in order to use it with your Swift code:

* `File` > `New` > `File...` > `iOS` > `Source` > `Header File`

* Name that header file `YourAppName-Bridging-Header.h`

* Inside that header file, import `#import <Hoko/Hoko.h>`

* Go to your project > `Build Settings` > `Objective-C Bridging Header` > add the path to your bridging header file, from your root folder (e.g. `MyApp/MyApp-Bridging-Header.h`)

* Get Swifty!

## SDK Setup

Add the following line to your `applicationDidFinishLaunching` method in your `AppDelegate` class (don't forget to import the HOKO class by using `#import <Hoko/Hoko.h>` if you're working with `Objective-C`).

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
[[Hoko deeplinking] mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
	BLKProductViewController *productViewController = [[BLKProductViewController alloc] initWithProductId:deeplink.routeParameters[@"product_id"]];
	productViewController.referrer = deeplink.queryParameters[@"referrer"];
	[HOKNavigation pushViewController:productViewController animated:YES];
}];
```

Swift

```swift
Hoko.deeplinking().mapRoute("product/:product_id", toTarget: { (deeplink: HKDeeplink!) -> Void in
	let productViewController = BLKPRoductViewController(productId: deeplink.routeParameters["product_id"])
	productViewController.referrer = deeplink.queryParameters["referrer"]
	HOKNavigation.pushViewController(productViewController, animated: true)
})
```

In order to perform certain tasks whenever a deep link enters the application, a `Handler` may be added to the `Deeplinking` module. This makes it easier to track deep links to analytics platforms, log entries or update your database.

Objective-C

```objective-c
[[Hoko deeplinking] addHandlerBlock:^(HOKDeeplink *deeplink) {
	[[Analytics sharedInstance] track:"deeplink" parameters:@{@"route": deeplink.route}];
}];
```

Swift

```swift
Hoko.deeplinking().addHandlerBlock { (deeplink: HOKDeeplink!) -> Void in
	Analytics.sharedInstance().track("deeplink", parameters: ["route": deeplink.route])
}
```


### Full documentation

We recommend you to read the full documentation at [http://support.hokolinks.com/quickstart/ios/](http://support.hokolinks.com/quickstart/ios/).
