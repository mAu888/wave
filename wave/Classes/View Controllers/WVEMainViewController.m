/**
* WVEMainViewController.m
* wave
*
* Created by Maurício Hanika on 16.05.2014.
* Copyright (c) 2014 wave. All rights reserved.
*/

#import "WVEMainViewController.h"
#import "WVEBeaconHandler.h"

@import CoreBluetooth;
@import CoreLocation;


////////////////////////////////////////////////////////////////////////////////
@interface WVEMainViewController () <WVEBeaconHandlerDelegate>

@property(weak, nonatomic) IBOutlet UIButton *startWavingButton;
@property(weak, nonatomic) IBOutlet UIButton *stopWavingButton;
@property(weak, nonatomic) IBOutlet UITextView *logTextView;
@property(strong, nonatomic) WVEBeaconHandler *beaconHandler;

@end


////////////////////////////////////////////////////////////////////////////////
@implementation WVEMainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self name:WVEDidReceiveLocalNotification object:nil];
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if ( self )
    {
        _beaconHandler = [WVEBeaconHandler handler];
        _beaconHandler.delegate = self;
        _beaconHandler.beaconValidityTimeInterval = 10;

        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(didReceiveLocalNotification:)
                   name:WVEDidReceiveLocalNotification
                 object:nil];
    }

    return self;
}

# pragma mark - UI

- (void)viewDidLoad
{
    [self updateUI];
}

- (void)updateUI
{
    BOOL isActive = [self.beaconHandler isRunning];

    if ( isActive )
    {
        self.startWavingButton.hidden = YES;
        self.stopWavingButton.hidden = NO;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"berlinON.png"]];
    }
    else
    {
        self.startWavingButton.hidden = NO;
        self.stopWavingButton.hidden = YES;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"berlinOFF.png"]];
    }
}


#pragma mark - Wave

- (IBAction)startWaving:(UIButton *)button
{
    [self.beaconHandler start];
    [self updateUI];
}

- (IBAction)stopWaving:(UIButton *)button
{
    [self.beaconHandler stop];
    [self updateUI];
}


#pragma mark - WVEBeaconHandlerDelegate

- (void)beaconHandler:(WVEBeaconHandler *)handler didRecognizeNewBeacons:(NSSet *)beacons
{
    [self triggerLocalNotification];
    [beacons enumerateObjectsUsingBlock:^void(CLBeacon *beacon, BOOL *stop) {
        NSString *distanceString = nil;
        switch ( beacon.proximity )
        {
            case CLProximityUnknown:
                distanceString = @"unknown";
                break;
            case CLProximityImmediate:
                distanceString = @"immediate";
                break;
            case CLProximityNear:
                distanceString = @"near";
                break;
            case CLProximityFar:
                distanceString = @"far";
                break;
        }
        NSString *logString = [NSString stringWithFormat:@"New beacon (%d.%d) is %@\n",
                                                         [beacon.major intValue],
                                                         [beacon.minor intValue],
                                                         distanceString];
        self.logTextView.text = [logString stringByAppendingString:self.logTextView.text];
    }];
}


#pragma mark - Notifications

- (void)triggerLocalNotification
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = NSLocalizedString(@"There's somebody near you", nil);
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)didReceiveLocalNotification:(NSNotification *)note
{
    UIAlertView *alertView = [[UIAlertView alloc]
        initWithTitle:NSLocalizedString(@"Hey", nil)
              message:NSLocalizedString(@"There's someone near you!", nil)
             delegate:nil
    cancelButtonTitle:NSLocalizedString(@"Ok, thanks!", nil)
    otherButtonTitles:nil];
    [alertView show];
}

@end