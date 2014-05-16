/**
* CLBeacon+WVEBeaconAdditions.m
* wave
*
* Created by Maurício Hanika on 16.05.2014.
* Copyright (c) 2014 wave. All rights reserved.
*/

#import "CLBeacon+WVEBeaconAdditions.h"
#import <objc/runtime.h>

void const *WVEBeaconLastUpdateDateKey = "WVEBeaconLastUpdateDateKey";

////////////////////////////////////////////////////////////////////////////////
@implementation CLBeacon (WVEBeaconAdditions)

- (NSDate *)lastBeaconUpdateDate
{
    return objc_getAssociatedObject(self, WVEBeaconLastUpdateDateKey);
}

- (void)setLastBeaconUpdateDate:(NSDate *)lastBeaconUpdateDate
{
    objc_setAssociatedObject(self, WVEBeaconLastUpdateDateKey, lastBeaconUpdateDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end