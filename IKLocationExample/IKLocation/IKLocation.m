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
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        self.locationAvailable = NO;
        self.error = nil;
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void) setDelegate:(id)delegate{
    [self.delegates addPointer:(__bridge void *)delegate];
    
    if (_locationAvailable) {
        if ([delegate respondsToSelector:@selector(ikManager:didUpdateToLocation:fromLocation:)]) {
            [delegate ikManager:self didUpdateToLocation:_location fromLocation:_oldLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    _oldLocation = oldLocation;
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
            
            NSLog(@"IKLocation: %@ %@ %@",_city, _state, _country);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    self.error = error;
    [self notifyDelegatesLocationFailed];
    
    NSLog(@"IKLocation: Failed To Update Location. %@", error);
}

- (void) notifyDelegatesLocationSuccessful{
    for (int i = 0; i < self.delegates.count; i++) {
        id delegate = [self.delegates pointerAtIndex:i];
        
        if ([delegate respondsToSelector:@selector(ikManager:didUpdateToLocation:fromLocation:)]) {
            [delegate ikManager:self didUpdateToLocation:_location fromLocation:_oldLocation];
        }else{
            [self.delegates removePointerAtIndex:i];
        }
    }
}

- (void) notifyDelegatesLocationFailed{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(ikManagerDidFailWithError:)]) {
            [delegate ikManagerDidFailWithError:self.error];
        }
    }
}

- (BOOL) isLocationAbailable{
    return self.locationAvailable;
}

@end
