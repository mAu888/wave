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

@property(weak, nonatomic) IBOutlet UIButton *startWavingButton;
@property(weak, nonatomic) IBOutlet UIButton *stopWavingButton;
@property(weak, nonatomic) IBOutlet UITextView *logTextView;
@property(strong, nonatomic) CBPeripheralManager *peripheralManager;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) NSSet *knownBeacons;

@end


////////////////////////////////////////////////////////////////////////////////
@implementation WVEMainViewController
{
    CLBeaconRegion *_beaconRegion;
    CLBeaconRegion *_beaconAdvertisingRegion;
}

- (id)init
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];

    if ( self )
    {
        _knownBeacons = [NSSet set];
    }

    return self;
}

# pragma mark - UI

-(void) viewDidLoad
{
    [self updateUI];
}

-(void) updateUI
{
    BOOL isActive = (self.peripheralManager != nil);
    
    if (isActive) {
        self.startWavingButton.hidden = YES;
        self.stopWavingButton.hidden = NO;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"berlinON.png"]];
    } else {
        self.startWavingButton.hidden = NO;
        self.stopWavingButton.hidden = YES;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"berlinOFF.png"]];
    }
}


#pragma mark - Wave

- (IBAction)startWaving:(UIButton *)button
{
    [self startBeaconAdvertising];
    [self startListeningForBeacons];

    [self updateUI];
}

- (IBAction)stopWaving:(UIButton *)button
{
    [self stopBeaconAdvertising];
    [self stopListeningForBeacons];

    [self updateUI];
}

- (void)startBeaconAdvertising
{
    NSMutableDictionary *peripheralData = [[self beaconAdvertisingRegion] peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc]
        initWithDelegate:self queue:dispatch_get_main_queue()];

    [self.peripheralManager startAdvertising:peripheralData];
}

- (void)stopBeaconAdvertising
{
    [self.peripheralManager stopAdvertising];
    self.peripheralManager = nil;
}

- (void)startListeningForBeacons
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self.locationManager startMonitoringForRegion:[self beaconRegion]];
    [self.locationManager startRangingBeaconsInRegion:[self beaconRegion]];
}

- (void)stopListeningForBeacons
{
    [self.locationManager stopMonitoringForRegion:[self beaconRegion]];
    [self.locationManager stopRangingBeaconsInRegion:[self beaconRegion]];
    self.locationManager = nil;
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
        __block BOOL isKnownBeacon = NO;
        [self.knownBeacons enumerateObjectsUsingBlock:^(CLBeacon *knownBeacon, BOOL *innerStop) {
            if ( [knownBeacon.major isEqualToNumber:beacon.major]
                && [knownBeacon.minor isEqualToNumber:beacon.minor]
                && [knownBeacon.proximityUUID isEqual:beacon.proximityUUID] )
            {
                isKnownBeacon = YES;
                *innerStop = YES;
            }
        }];

        if ( !isKnownBeacon )
        {
            self.knownBeacons = [self.knownBeacons setByAddingObject:beacon];
            self.logTextView.text = [NSString stringWithFormat:@"New beacon: %d.%d\n%@", [beacon.major intValue], [beacon.minor intValue], self.logTextView.text];

            [self triggerLocalNotification];
        }


        ////////////////////////////////////////
        switch ( beacon.proximity )
        {
            case CLProximityUnknown:
                logString = [@"unknown\n" stringByAppendingString:logString];
                break;
            case CLProximityImmediate:
                logString = [@"immediate\n" stringByAppendingString:logString];
                break;
            case CLProximityNear:
                logString = [@"near\n" stringByAppendingString:logString];
                break;
            case CLProximityFar:
                logString = [@"far\n" stringByAppendingString:logString];
                break;
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


#pragma mark - Private methods

- (CLBeaconRegion *)beaconRegion
{
    if ( !_beaconRegion )
    {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:WVEBeaconUUIDString];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                           identifier:WVEBeaconIdentifierString];
    }

    return _beaconRegion;
}

- (CLBeaconRegion *)beaconAdvertisingRegion
{
    if ( !_beaconAdvertisingRegion )
    {
        CLBeaconMajorValue majorBeaconValue = ( CLBeaconMajorValue ) (arc4random() % UINT16_MAX);
        CLBeaconMinorValue minorBeaconValue = ( CLBeaconMinorValue ) (arc4random() % UINT16_MAX);

        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:WVEBeaconUUIDString];
        _beaconAdvertisingRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:majorBeaconValue
                                                                minor:minorBeaconValue
                                                           identifier:WVEBeaconIdentifierString];
    }

    return _beaconAdvertisingRegion;
}

- (void)triggerLocalNotification
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = NSLocalizedString(@"There's somebody near you", nil);
    notification.fireDate = [NSDate date];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end