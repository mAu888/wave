/**
* CLBeacon+WVEBeaconAdditions.h
* wave
*
* Created by Maurício Hanika on 16.05.2014.
* Copyright (c) 2014 wave. All rights reserved.
*/

@import CoreLocation;

@interface CLBeacon (WVEBeaconAdditions)

@property(strong, nonatomic) NSDate *lastBeaconUpdateDate;

@end