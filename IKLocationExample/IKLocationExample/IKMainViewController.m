//
//  IKMainViewController.m
//  IKLocationExample
//
//  Created by Andres on 6/18/14.
//  Copyright (c) 2014 Inaka. All rights reserved.
//

#import "IKMainViewController.h"
#import "IKLocation.h"

@interface IKMainViewController () <IKLocationDelegate>
@property (strong, nonatomic) IBOutlet UILabel *geocodedLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;

@end

@implementation IKMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[IKLocation sharedLocation] setDelegate:self];
}

- (IBAction)pushAnOtherViewController:(id)sender {
    IKMainViewController *anOtherViewController = [[IKMainViewController alloc] init];
    [self.navigationController pushViewController:anOtherViewController
                                        animated:YES];
}

- (void)ikManagerDidFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}

- (void)ikManager:(id) manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    NSString *city = ((IKLocation *) manager).city;
    NSString *country = ((IKLocation *) manager).country;
    CGFloat latitude = ((IKLocation *) manager).latitude;
    CGFloat longitude = ((IKLocation *) manager).longitude;
    
    self.geocodedLocationLabel.text = [NSString stringWithFormat:@"Geocoded Location: %@ %@",city,country];
    self.latitudeLabel.text = [NSString stringWithFormat:@"Latitude: %f",latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"Latitude: %f",longitude];
}
@end
