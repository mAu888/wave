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
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property(strong, nonatomic) WVEBeaconHandler *beaconHandler;
@property (weak, nonatomic) IBOutlet UIView *peersNearbyView;
@property (weak, nonatomic) IBOutlet UILabel *peersNearbyLabel;

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
        self.backgroundImageView.highlighted = YES;
    }
    else
    {
        self.startWavingButton.hidden = NO;
        self.stopWavingButton.hidden = YES;
        self.backgroundImageView.highlighted = NO;
    }

    NSString *text = nil;
    if ( self.beaconHandler.beaconsNearby.count == 1 )
    {
        text = NSLocalizedString(@"One person nearby", nil);
    }
    else
    {
        text = [NSString stringWithFormat:NSLocalizedString(@"%d people nearby", nil), self.beaconHandler.beaconsNearby.count];
    }

    self.peersNearbyLabel.text = text;
    self.peersNearbyView.hidden = self.beaconHandler.beaconsNearby.count == 0;
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