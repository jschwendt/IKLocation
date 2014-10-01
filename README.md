IKLocation
==============

If you need to get the device location in multiple sections of the app `CLLocationManager` may be a solution. `CLLocationManager` is a wrapper to avoid using multiple `CLLocationManager` across an application. All delegates added to IKLocation are notified when the location is available or when the `refresh` method is called. `IKLocation` automatically removes object when those are deallocated.

Contact Us
----------------------
For **questions** or **general comments** regarding the use of this library, please use our public
[hipchat room](https://www.hipchat.com/gpBpW3SsT).

If you find any **bugs** or have a **problem** while using this library, please [open an issue](https://github.com/inaka/IKLocation/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at [inaka.github.io](http://inaka.github.io)

Installation and usage
----------------------
1. Copy `IKLocation.h` and `IKLocation.m` to your project. (or you can just add it as a pod. `pod 'IKLocation'`)
2. Call `[IKLocation sharedClient]` when you want your app to prompt the user to allow access location.
3. Implement `IKLocationDelegate`
4. Add all the objects that implements the delegate. `[[IKLocation sharedLocation] setDelegate:self];`
5. Implement `ikManager:didUpdateToLocation:fromLocation:` and if you want `ikManagerDidFailWithError:`

You can add as many delegates as you want. The wrapper is using a `NSPointerArray` to avoid reference cycles.

The app also exposes the following properties: 
    
- __location__: `(CLLocation *)` Current location 
- __oldLocation__: `(CLLocation *)` Previous location 
- __latitude__: `(CGFloat)` Current latitude 
- __longitude__: `(CGFloat)` Current longitude 
- __city__: `(NSString *)` Current city 
- __state__: `(NSString *)` Current state
- __country__: `(NSString *)` Current country

The app also exposes the following methods:

- __isLocationAvailable__: Returns true if a location is available.  
- __refresh__: Updates the location.  
