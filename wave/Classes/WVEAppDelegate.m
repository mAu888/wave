//
//  WVEAppDelegate.m
//  wave
//
//  Created by Maurício Hanika on 16.05.14.
//  Copyright (c) 2014 wave. All rights reserved.
//

#import "WVEAppDelegate.h"
#import "WVEMainViewController.h"
#import "APLCompositeBehaviorViewController.h"

@implementation WVEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[WVEMainViewController alloc] init];
//    self.window.rootViewController = [[APLCompositeBehaviorViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
