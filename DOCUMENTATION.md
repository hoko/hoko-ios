# iOS Guide

If you haven’t installed the SDK yet, please [head over to the QuickStart guide](http://hokolinks.com/quickstart/ios) to get our SDK up and running in Xcode. Note that we support iOS 5.0 and higher. You can also check out our API Reference for more detailed information about our SDK.

## Introduction

HOKO takes all that’s great about deeplinking and gives it to you as a simple SDK - ready to integrate into your app. You can also setup HOKO's analytics to track user behaviour, or have HOKO work in parallel with existing analytics suites.

The platform provides an easy method of linking a unique URL to an action within an app. It is based on the way we use the web, but customised for mobile frameworks. Existing solutions for deeplinking are complex and over-engineered, requiring huge amounts of time and knowledge to implement - Let HOKO do the hard work!

### Apps

With HOKO, you can aggregate all the platforms where your App is available. Each App has its own application id and each platform has its own client key that you apply to your SDK install. Your account on HOKO can accommodate multiple Apps. 

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

## Deeplinking

Deep linking is a link that redirects/links the users to a specific view inside your mobile application. Since handling advanced deep linking is complex, HOKO provides an easy-to-use API to map content to URLs within the App.

### URL Scheme

The first step to make your App deep-linkable is to register for a `URL Scheme`. To register a URL Scheme you should navigate to your project's application **target**, select the **info** tab, and under **URL Types** click the **plus** sign. This `URL Scheme` should be in **reverse DNS notation** (e.g. *com.hoko.Black*).

![URL Scheme](https://s3-eu-west-1.amazonaws.com/hokoassets/urlschemes-ios.png)

### Route Mapping

In order to map content to URLs, HOKO provides you with a few ways to do so. 

To map a certain `UIViewController` to a URL, the app just needs to set a **route format** ("wishlist") and a target, where the target should contain the code to show a certain `UIViewController` or perform a certain action:

```objective-c
[[Hoko deeplinking] mapRoute:@"wishlist" toTarget:^(HKDeeplink *deeplink) {
	BLKWishListViewController *wishListViewController = [BLKWishListViewController new];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:wishListViewController];
	[HKNavigation setRootViewController:navController];
}];
```

```swift
Hoko.deeplinking().mapRoute("wishlist", toTarget: { (deeplink: HKDeeplink!) -> Void in
	let wishListViewController = BLKWishListViewController()
	let navController = UINavigationController(rootViewController: wishListViewController)  
	HKNavigation.setRootViewController(navController)
})
```

Note: It is recommended that deep linking routes are mapped right after the HOKO SDK setup on your `applicationDidFinishLaunching` method in your `AppDelegate` class.

HOKO also allows mapping routes with **route parameters** and **query parameters**, where route parameters are required and query parameters are optional. This route will be triggered when, for example, a deep link such as `black://product/3`, is opened in the device.

```objective-c
[[Hoko deeplinking] mapRoute:@"product/:product_id" toTarget:^(HKDeeplink *deeplink) {
	BLKProductViewController *productViewController = [[BLKProductViewController alloc] initWithProductId:deeplink.routeParameters[@"product_id"]]; // always exists
	productViewController.referrer = deeplink.queryParameters[@"referrer"]; // might not exist
	[HKNavigation pushViewController:productViewController animated:YES];
}];
```

```swift
Hoko.deeplinking().mapRoute("product/:product_id", toTarget: { (deeplink: HKDeeplink!) -> Void in
	let productViewController = BLKPRoductViewController(productId: deeplink.routeParameters["product_id"]) // always exists
	productViewController.referrer = deeplink.queryParameters["referrer"] // might not exist
	HKNavigation.pushViewController(productViewController, animated: true)
})
```

HOKO also provides an easy way to redirect non-mapped routes to a default target. (e.g. a landing screen or an error dialog).

```objective-c
[[Hoko deeplinking] mapDefaultRouteToTarget:^(HKDeeplink *deeplink) {
	BLKLandingViewController *landingViewController = [BLKProductViewController new];
	[HKNavigation setRootViewController:landingViewController];
}];
```

```swift
Hoko.deeplinking().mapDefaultRouteToTarget { (deeplink: HKDeeplink!) -> Void in
	let landingViewController = BLKLandingViewController()
	HKNavigation.setRootViewController(landingViewController)
}
```

### Handlers

In order to perform certain tasks whenever a deep link enters the application a `Handler` may be added to the `Deeplinking` module. This makes it easier to track deep links to analytics platforms, log entries or update your database.

```objective-c
[[Hoko deeplinking] addHandlerBlock:^(HKDeeplink *deeplink) {
	[[Analytics sharedInstance] track:"deeplink" parameters:@{@"route": deeplink.route}];
}];
```

```swift
Hoko.deeplinking().addHandlerBlock { (deeplink: HKDeeplink!) -> Void in
	Analytics.sharedInstance().track("deeplink", parameters: ["route": deeplink.route])
}
```

Handlers can also be added by implementing the `HKHandlerProtocol` in any object. All that is needed for implementation is a `handleDeeplink` function and be added to the `Deeplinking` module.

```objective-c
// Analytics.h
@interface Analytics: NSObject <HKHandlerProtocol>
...
@end
// Analytics.m
@implementation Analytics
...
- (void)handleDeeplink:(HKDeeplink *)deeplink
{
	[self track:"deeplink" parameters:@{@"route": deeplink.route}];
}
// AppDelegate.m
...
[[Hoko deeplinking] addHandler:[Analytics sharedInstance]];
```

```swift
// Analytics.swift
class Analytics: HKHandlerProtocol {
...
func handleDeeplink(deeplink: HKDeeplink!) {
	track("deeplink", parameters: ["route": deeplink.route])
}
// AppDelegate.swift
...
Hoko.deeplinking().addHandler(Analytics.sharedInstance())
```

Note: It is recommended that handlers are added right after the HOKO SDK setup and the route maps on your `AppDelegate` class.

### Deep link Delegation

To save time integrating HOKO in an application, HOKO does not require delegation of the `openURL` from the `AppDelegate`.  Should you choose to delegate manually, you must make sure to return `YES` or `true` in case the deep link was handled, by either Hoko or other deep link frameworks and `NO`or `false`otherwise.

```objective-c
// AppDelegate.m
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if ([FBSession.activeSession handleOpenURL:url])
		return YES;
	return [[Hoko deeplinking] openURL:url sourceApplication:sourceApplication annotation:annotation];
}
```

```swift
// AppDelegate.swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
	if FBSession.activeSession().handleOpenUrl(url) {
		return true
	}
	return Hoko.deeplinking().openURL(url, sourceApplication:sourceApplication, annotation: annotation)
}
```

### Hokolink Generation

HOKO isn't just a deep linking SDK, it also provides ways for inter-platform communication through deep links. HOKO allows the creation of **Hokolinks** which are URLs that redirect the user to a deep link depending the platform where the user is opening that particular Hokolink, be it either **iOS**, **Android** or the **Web**.

These Hokolinks may be created on **Hokolinks.com** or through the Hoko SDK, to allow users to share platform independent links direct to the relevant content.

To generate Hokolinks through the application it needs a **route format**, the corresponding **route parameters** and optional **query parameters**.

```objective-c
HKDeeplink *deeplink = [HKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id":@(self.product.identifier)} queryParameters:@{@"referrer": self.user.name}];
[[Hoko deeplinking] generateHokolinkForDeeplink:deeplink success:^(NSString *hokolink) {
	[[Social sharedInstance] shareProduct:self.product link:hokolink];
} failure:^(NSError *error) {
	[ErrorDialog show:error];
}];
```

```swift
let deeplink = HKDeeplink("product/:product_id", routeParameters: ["product_id": product.identifier], queryParameters:["referrer": user.name])        Hoko.deeplinking().generateHokolinkForDeeplink(deeplink, success: { (hokolink: String!) -> Void in
	Social.sharedInstance().shareProduct(product, link: hokolink)
}) { (error: NSError!) -> Void in
	ErrorDialog.show(error)
}
```

## Analytics

To allow the creation of Hokolinks with associated user targets HOKO implements a simple form of **Analytics**. It only tracks **users**, their **devices**, **deep linking sessions** and associated **key events**. This also provides a better result analysis, with a breakdown of Hokolinks.

### Users

In HOKO there are two kinds of users, the **identified** and the **anonymous** users. Every user is an anonymous user until it is identified, and it will stay identified until the app is uninstalled or it is identified as an anonymous user once again.

#### Anonymous Users

To identify a user as an anonymous user the app should identify the user without an identifier. Should the app identify two anonymous users in sequence, they will be considered the same anonymous user to avoid replication whereas it is not necessary.

```objective-c
[[Hoko analytics] identifyUser];
```

```swift
Hoko.analytics().identifyUser()
```

#### Identified Users

If your app identifies its users to the HOKO SDK, the HOKO platform will be able to provide you with better usage metrics and better user targeting when creating Hokolinks. To identify users the app needs to provide a few user details, namely an identifier, which can be an e-mail, an integer or even a username and the login methodology (e.g. Facebook, Twitter or GitHub login).

```objective-c
[[Hoko analytics] identifyUserWithIdentifier:@"johnappleseed"
                                 accountType:HKUserAccountTypeGithub];
```

```swift
Hoko.analytics().identifyUserWithIdentifier("johnappleseed",
    accountType: .Github)
```

The app may also provide a few optional parameters to provide finer control over the user targeting mechanics in the HOKO platform.

```objective-c
[[Hoko analytics] identifyUserWithIdentifier:@"johnappleseed"
                                 accountType:HKUserAccountTypeGithub
                                        name:@"John Appleseed"
                                       email:@"john.appleseed@hokolinks.com"
                                   birthDate:[NSDate date]
                                      gender:HKUserGenderMale];
```

```swift
Hoko.analytics().identifyUserWithIdentifier("johnappleseed",
    accountType: .Github,
    name: "John Appleseed",
    email: "john.appleseed@hokolinks.com",
    birthDate: NSDate(),
    gender: .Male)
```

### Sessions

In HOKO, sessions have a different meaning when compared to common analytics platforms. HOKO only creates a session if the app was opened or resumed from a Hokolink. The deep linking session serves the purpose of tracking app usage **after** a user opens a deep link, namely, how much time the user spent on the app and if the user performed certain key events (e.g. purchasing a product or sharing it on a social network).

Note: Sessions are tracked automatically and there is no code required to implement sessions with the HOKO SDK.

### Events

To complement the automatically gathered information from **sessions** the app should manually track the key events associated of which to measure the success or failure of a deeplink session. You can track events with or without associated monetary value.

```objective-c
[[Hoko analytics] trackKeyEvent:@"facebook_share"];
[[Hoko analytics] trackKeyEvent:@"dress_purchase" amount:@(29.99)];
```

```swift
Hoko.analytics().trackKeyEvent("facebook_share")
Hoko.analytics().trackKeyEvent("dress_purchase", amount:29.99)
```

## Utilities

To help your app becoming deep-linkable we provide a **non-mandatory** utility class to handle navigation.

### HKNavigation

`HKNavigation` serves the purpose of easing the pushing, presenting and setting of `UIViewControllers` to whatever may be the current state of your application. This class handles all the logic of finding your current view controller and performing the chosen action over that view controller. This should work on most apps that rely only on `UINavigationControllers`, `UITabBarControllers` and modal view controllers to handle navigation.

#### Setting the Root View Controller

To completely replace the current view controller on your application just call the `setRootViewController` method with a given view controller.

```objective-c
[HKNavigation setRootViewController:[BLKLandingViewController new]];
```

```swift
HKNavigation.setRootViewController(BLKLandingViewController())
```

#### Presenting a View Controller

To present a view controller modally your app can call the `presentViewController` method with a given view controller.

```objective-c
[HKNavigation presentViewController:[BLKLandingViewController new] animated:YES];
```

```swift
HKNavigation.presentViewController(BLKLandingViewController(), animated: true)
```

#### Pushing a View Controller

If your view controller is a navigation controller it replaces the root view controller, otherwise it tries to push the view controller  if the current view controller is a `UINavigationController`, otherwise it creates it before pushing. The replace parameter locates the current view controller and replaces it if it is of the same class as the view controller parameter being passed, this exists to avoid two of the same view controller in a row.

```objective-c
[HKNavigation pushViewController:[BLKLandingViewController new] animated:YES replace:YES];
```

```swift
HKNavigation.pushViewController(BLKLandingViewController(), animated: true, replace: true)
```

#### Need more help?

We think HOKO is super simple to setup - but if you have any questions and can’t find answers in these pages - feel free to reach out directly at email@hokolinks.com
