/**
* WVEMainViewController.m
* wave
*
* Created by Maurício Hanika on 16.05.2014.
* Copyright (c) 2014 wave. All rights reserved.
*/

#import "WVEMainViewController.h"

@import CoreBluetooth;
@import CoreLocation;

NSString *const WVEBeaconUUIDString = @"39583CB2-5EB0-4BE7-9BCC-B7156E32F14E";
NSString *const WVEBeaconIdentifierString = @"io.waveapp.ios.wave";

////////////////////////////////////////////////////////////////////////////////
@interface WVEMainViewController () <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property(weak, nonatomic) IBOutlet UITextView *logTextView;
@property(strong, nonatomic) CBPeripheralManager *peripheralManager;
@property(strong, nonatomic) CLLocationManager *locationManager;

@end


////////////////////////////////////////////////////////////////////////////////
@implementation WVEMainViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];

    if ( self )
    {

    }

    return self;
}


#pragma mark - Wave

- (IBAction)startTheWave:(id)sender
{
    [self startBeaconAdvertising];
    [self startListeningForBeacons];
}

- (void)startListeningForBeacons
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:WVEBeaconUUIDString];
    CLBeaconRegion *region = [[CLBeaconRegion alloc]
        initWithProximityUUID:uuid identifier:WVEBeaconIdentifierString];
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager startRangingBeaconsInRegion:region];
}

- (void)startBeaconAdvertising
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:WVEBeaconUUIDString];
    CLBeaconRegion *region = [[CLBeaconRegion alloc]
        initWithProximityUUID:uuid identifier:WVEBeaconIdentifierString];

    NSMutableDictionary *peripheralData = [region peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc]
        initWithDelegate:self queue:dispatch_get_main_queue()];

    [self.peripheralManager startAdvertising:peripheralData];
}


#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{

}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    __block NSString *logString = @"";
    [beacons enumerateObjectsUsingBlock:^(CLBeacon *beacon, NSUInteger idx, BOOL *stop) {
        switch ( beacon.proximity )
        {
            case CLProximityUnknown: logString = [@"unknown\n" stringByAppendingString:logString]; break;
            case CLProximityImmediate: logString = [@"immediate\n" stringByAppendingString:logString]; break;
            case CLProximityNear: logString = [@"near\n" stringByAppendingString:logString]; break;
            case CLProximityFar: logString = [@"far\n" stringByAppendingString:logString]; break;
        }
    }];

    self.logTextView.text = [logString stringByAppendingString:self.logTextView.text];
}

- (void)       locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
                     withError:(NSError *)error
{
    self.logTextView.text = [NSString stringWithFormat:@"Error: %@\n%@", error, self.logTextView.text];
}

@end