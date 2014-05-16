/**
* WVEBeaconHandler.m
* wave
*
* Created by Maurício Hanika on 16.05.2014.
* Copyright (c) 2014 wave. All rights reserved.
*/

@import CoreBluetooth;
@import CoreLocation;

#import "WVEBeaconHandler.h"
#import "CLBeacon+WVEBeaconAdditions.h"

NSString *const WVEBeaconUUIDString = @"39583CB2-5EB0-4BE7-9BCC-B7156E32F14E";
NSString *const WVEBeaconIdentifierString = @"io.waveapp.ios.wave";

////////////////////////////////////////////////////////////////////////////////
@interface WVEBeaconHandler () <CLLocationManagerDelegate>

@property(strong, nonatomic) CBPeripheralManager *peripheralManager;
@property(strong, nonatomic) CLLocationManager *locationManager;

@end


////////////////////////////////////////////////////////////////////////////////
@implementation WVEBeaconHandler
{
    CLBeaconRegion *_beaconRegion;
    CLBeaconRegion *_beaconAdvertisingRegion;
    BOOL _running;
}

- (id)init
{
    self = [super init];

    if ( self )
    {
        _beaconsNearby = [NSSet set];
        _beaconValidityTimeInterval = 300;
    }

    return self;
}

+ (instancetype)handler
{
    return [[self alloc] init];
}

- (void)start
{
    if ( self.isRunning )
    {
        return;
    }

    _running = YES;

    [self startBeaconAdvertising];
    [self startListeningForBeacons];
}

- (void)stop
{
    if ( !self.isRunning )
    {
        return;
    }

    _running = NO;

    [self stopBeaconAdvertising];
    [self stopListeningForBeacons];
}


#pragma mark - Beacon advertising and listening

- (void)startBeaconAdvertising
{
    NSMutableDictionary *peripheralData = [[self beaconAdvertisingRegion] peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc]
        initWithDelegate:nil queue:dispatch_get_main_queue()];

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


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    NSMutableSet *newBeacons = [NSMutableSet set];
    [beacons enumerateObjectsUsingBlock:^(CLBeacon *beacon, NSUInteger idx, BOOL *stop) {
        __block BOOL isKnownBeacon = NO;
        [self.beaconsNearby enumerateObjectsUsingBlock:^(CLBeacon *knownBeacon, BOOL *innerStop) {
            if ( [knownBeacon.major isEqualToNumber:beacon.major]
                && [knownBeacon.minor isEqualToNumber:beacon.minor]
                && [knownBeacon.proximityUUID isEqual:beacon.proximityUUID] )
            {
                isKnownBeacon = YES;
                *innerStop = YES;
            }
        }];

        if ( !isKnownBeacon && beacon.proximity != CLProximityUnknown )
        {
            [beacon setLastBeaconUpdateDate:[NSDate date]];
            [newBeacons addObject:beacon];
        }
    }];

    self.beaconsNearby = [self.beaconsNearby setByAddingObjectsFromSet:newBeacons];
    self.beaconsNearby = [self.beaconsNearby filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CLBeacon *beacon, NSDictionary *bindings) {
        // Consider beacons with unknown distance as not reachable
        return beacon.proximity != CLProximityUnknown
            && [[NSDate date] timeIntervalSinceDate:beacon.lastBeaconUpdateDate] < self.beaconValidityTimeInterval;
    }]];

    if ( newBeacons.count > 0
        && [self.delegate respondsToSelector:@selector(beaconHandler:didRecognizeNewBeacons:)] )
    {
        [self.delegate beaconHandler:self didRecognizeNewBeacons:[NSSet setWithSet:newBeacons]];
    }
}

- (void)       locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
                     withError:(NSError *)error
{
    if ( [self.delegate respondsToSelector:@selector(beaconHandler:didFailWithError:)] )
    {
        [self.delegate beaconHandler:self didFailWithError:error];
    }
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

- (BOOL)isRunning
{
    return _running;
}

@end