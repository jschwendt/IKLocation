//
//  WGLocation.m
//  WannaGo
//
//  Created by Andres on 5/22/14.
//  Copyright (c) 2014 Inaka Networks. All rights reserved.
//

#import "WGLocation.h"


@interface WGLocation ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSError *error;
@end

@implementation WGLocation
+ (instancetype)sharedLocation {
    static WGLocation *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[WGLocation alloc] init];
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
        self.delegates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) setDelegate:(id)delegate{
    [self.delegates addObject:delegate];
    
    if (_locationAvailable) {
        if (!self.error) {
            if ([delegate respondsToSelector:@selector(wgManager:didUpdateToLocation:fromLocation:)]) {
                [delegate wgManager:self didUpdateToLocation:_location fromLocation:_oldLocation];
            }
        }else{
            if ([delegate respondsToSelector:@selector(wgManagerDidFailWithError:)]) {
                [delegate wgManagerDidFailWithError:self.error];
            }
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
            
            NSLog(@"WLLocation: %@ %@ %@",_city, _state, _country);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    self.error = error;
    [self notifyDelegatesLocationFailed];
    
    NSLog(@"WLLocation: Failed To Update Location. %@", error);
}

- (void) notifyDelegatesLocationSuccessful{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(wgManager:didUpdateToLocation:fromLocation:)]) {
            [delegate wgManager:self didUpdateToLocation:_location fromLocation:_oldLocation];
        }
    }
}

- (void) notifyDelegatesLocationFailed{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(wgManagerDidFailWithError:)]) {
            [delegate wgManagerDidFailWithError:self.error];
        }
    }
}

- (BOOL) isLocationAbailable{
    return self.locationAvailable;
}

@end
