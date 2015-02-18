//
//  WGLocation.m
//  WannaGo
//
//  Created by Andres on 5/22/14.
//  Copyright (c) 2014 Inaka Networks. All rights reserved.
//

#import "IKLocation.h"


@interface IKLocation ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSPointerArray *delegates;
@property (nonatomic, strong) NSError *error;
@end

@implementation IKLocation
+ (instancetype)sharedLocation {
    static IKLocation *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[IKLocation alloc] init];
    });
    
    return _sharedClient;
}

- (id)init {
    if (self = [super init]) {
        self.cacheTimeout=5.0;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        CLAuthorizationStatus locationAuthStatus = [CLLocationManager authorizationStatus];
        if ((locationAuthStatus == kCLAuthorizationStatusNotDetermined) && (NSFoundationVersionNumber<=NSFoundationVersionNumber_iOS_7_1)) {
            [self.locationManager startUpdatingLocation];
        } else if (locationAuthStatus == kCLAuthorizationStatusAuthorizedWhenInUse || locationAuthStatus == kCLAuthorizationStatusAuthorized) {
            [self.locationManager startUpdatingLocation];
        }
        
        self.locationAvailable = NO;
        self.error = nil;
        self.delegates = [NSPointerArray weakObjectsPointerArray];
        [self isLocationServicesAuthorized];
    }
    return self;
}

- (void) refreshLocation{
    self.locationAvailable = NO;
    self.error = nil;
    _oldLocation = nil;
    _location = nil;
    _city = nil;
    _state = nil;
    _country = nil;
    
    [self.locationManager startUpdatingLocation];
}

- (void) setDelegate:(id)delegate{
    BOOL delegateAlreadySet=NO;
    void * delegatePtr = (__bridge void *)delegate;
    for (NSUInteger i = 0; i < [self.delegates count]; i++) {
        void * ptr = [self.delegates pointerAtIndex:i];
        
        if (ptr == delegatePtr) {
            delegateAlreadySet=YES;
        }
    }
    
    if (delegateAlreadySet==NO) {
        [self.delegates addPointer:delegatePtr];
    }
    
    if (_locationAvailable) {
        if ([delegate respondsToSelector:@selector(ikManager:didUpdateToLocation:fromLocation:)]) {
            [delegate ikManager:self didUpdateToLocation:_location fromLocation:_oldLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        self.locationServicesAuthorized=NO;
    } else if ((status == kCLAuthorizationStatusAuthorized) || (status == kCLAuthorizationStatusAuthorizedWhenInUse) || (status == kCLAuthorizationStatusAuthorizedAlways)) {
		self.locationServicesAuthorized=YES;
        [self notifyDelegatesDidRecieveUserAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count>1) {
        [self locationManager:manager didUpdateToLocation:[locations lastObject] fromLocation:[locations objectAtIndex:1]];
    } else {
        [self locationManager:manager didUpdateToLocation:[locations lastObject] fromLocation:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (oldLocation) {
        _oldLocation = oldLocation;
    }
    _location = newLocation;
    _latitude = newLocation.coordinate.latitude;
    _longitude = newLocation.coordinate.longitude;
    
    [self.locationManager stopUpdatingLocation];
 
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:_location  completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            NSDictionary *place = [[placemarks lastObject] addressDictionary];
            _city = place[@"City"];
            _state = place[@"State"];
            _country = place[@"Country"];
            
            _locationAvailable = YES;
            
            [self notifyDelegatesLocationSuccessful];
            
            NSLog(@"Location: %@ %@ %@",_city, _state, _country);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    self.error = error;
    [self notifyDelegatesLocationFailed];
    
    NSLog(@"IKLocation: Failed To Update Location. %@", error);
}

- (void) notifyDelegatesLocationSuccessful {
    for (int i = 0; i < self.delegates.count; i++) {
        id delegate = [self.delegates pointerAtIndex:i];
        
        if ([delegate respondsToSelector:@selector(ikManager:didUpdateToLocation:fromLocation:)]) {
            [delegate ikManager:self didUpdateToLocation:_location fromLocation:_oldLocation];
        }else{
            [self.delegates replacePointerAtIndex:i withPointer:NULL];
        }
    }
    [self.delegates compact];
}

- (void) notifyDelegatesLocationFailed {
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(ikManagerDidFailWithError:)]) {
            [delegate ikManagerDidFailWithError:self.error];
        }
    }
}

- (void) notifyDelegatesDidRecieveUserAuthorization {
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(ikManagerDidRecieveUserAuthorization)]) {
            [delegate ikManagerDidRecieveUserAuthorization];
        }
    }
}

- (BOOL)isLocationAvailable {
    if (self.locationAvailable) {
        NSTimeInterval locationAge = [_location.timestamp timeIntervalSinceNow];
        if (abs(locationAge) > self.cacheTimeout) {
            [self refreshLocation];
        }
    }

    return self.locationAvailable;
}

- (BOOL)isLocationServicesAuthorized {
    if (!self.locationServicesAuthorized) {
        CLAuthorizationStatus locationAuthStatus = [CLLocationManager authorizationStatus];
        if (locationAuthStatus == kCLAuthorizationStatusAuthorizedWhenInUse || locationAuthStatus == kCLAuthorizationStatusAuthorizedAlways || locationAuthStatus == kCLAuthorizationStatusAuthorized) {
			self.locationServicesAuthorized=YES;
		}
    }

    return self.locationServicesAuthorized;
}

@end
