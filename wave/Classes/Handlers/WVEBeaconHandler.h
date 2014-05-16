/**
* WVEBeaconHandler.h
* wave
*
* Created by Maurício Hanika on 16.05.2014.
* Copyright (c) 2014 wave. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class WVEBeaconHandler;

////////////////////////////////////////////////////////////////////////////////
@protocol WVEBeaconHandlerDelegate <NSObject>

@optional
- (void)beaconHandler:(WVEBeaconHandler *)handler didRecognizeNewBeacons:(NSSet *)beacons;
- (void)beaconHandler:(WVEBeaconHandler *)handler didFailWithError:(NSError *)error;

@end


////////////////////////////////////////////////////////////////////////////////
@interface WVEBeaconHandler : NSObject

+ (instancetype)handler;

/** The time interval in seconds after which a beacon is not recognized as known beacon anymore */
@property(assign, nonatomic) NSTimeInterval beaconValidityTimeInterval;
@property(weak, nonatomic) id <WVEBeaconHandlerDelegate> delegate;
@property(strong, nonatomic) NSSet *beaconsNearby;

- (void)start;
- (void)stop;
- (BOOL)isRunning;

@end