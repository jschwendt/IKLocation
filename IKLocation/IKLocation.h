//
//  WGLocation.h
//  WannaGo
//
//  Created by Andres on 5/22/14.
//  Copyright (c) 2014 Inaka Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol IKLocationDelegate <NSObject>
- (void)ikManagerDidFailWithError:(NSError *)error;
- (void)ikManager:(id) manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
@end

@interface IKLocation : NSObject <CLLocationManagerDelegate>
@property (readonly) CLLocation* location;
@property (readonly) CLLocation* oldLocation;

@property (readonly) CGFloat latitude;
@property (readonly) CGFloat longitude;
@property (nonatomic) BOOL locationAvailable;

@property (nonatomic,readonly) NSString *city;
@property (nonatomic,readonly) NSString *state;
@property (nonatomic,readonly) NSString *country;

@property (nonatomic) NSTimeInterval cacheTimeout;

+ (instancetype)sharedLocation;
- (void) setDelegate:(id)delegate;
- (void) refreshLocation;
- (BOOL)isLocationAvailable;

@end
