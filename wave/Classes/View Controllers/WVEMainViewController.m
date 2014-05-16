/**
* WVEMainViewController.m
* wave
*
* Created by Maurício Hanika on 16.05.2014.
* Copyright (c) 2014 wave. All rights reserved.
*/

#import "WVEMainViewController.h"
#import "WVEBeaconHandler.h"
#import "WVEAnimationViewController.h"

@import CoreBluetooth;
@import CoreLocation;


////////////////////////////////////////////////////////////////////////////////
@interface WVEMainViewController () <WVEBeaconHandlerDelegate>

@property(weak, nonatomic) IBOutlet UIButton *startWavingButton;
@property(weak, nonatomic) IBOutlet UIButton *stopWavingButton;
@property(weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property(strong, nonatomic) WVEBeaconHandler *beaconHandler;
@property(weak, nonatomic) IBOutlet UIView *peersNearbyView;
@property(weak, nonatomic) IBOutlet UILabel *peersNearbyLabel;

@end


////////////////////////////////////////////////////////////////////////////////
@implementation WVEMainViewController
{
    BOOL _shakeViewVisible;
    NSArray *_colorsArray;
    NSUInteger _nextColorIndex;
}

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

        _colorsArray = @[[UIColor yellowColor], [UIColor redColor], [UIColor greenColor]];
        _nextColorIndex = 0;
    }

    return self;
}

# pragma mark - UI

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
    [self becomeFirstResponder];
}

- (void)updateUI
{
    BOOL isActive = [self.beaconHandler isRunning];

    if ( isActive )
    {
        self.startWavingButton.hidden = YES;
        self.stopWavingButton.hidden = NO;
//        self.backgroundImageView.highlighted = YES;
        [self toggleBackgroundImage:YES];
    }
    else
    {
        self.startWavingButton.hidden = NO;
        self.stopWavingButton.hidden = YES;
//        self.backgroundImageView.highlighted = NO;
        [self toggleBackgroundImage:NO];
    }

    NSString *text = nil;
    if ( self.beaconHandler.beaconsNearby.count == 1 )
    {
        text = NSLocalizedString(@"One person nearby", nil);
    }
    else
    {
        text = [NSString stringWithFormat:NSLocalizedString(@"%d people nearby", nil),
                                          self.beaconHandler.beaconsNearby.count];
    }

    self.peersNearbyLabel.text = text;
    self.peersNearbyView.hidden = self.beaconHandler.beaconsNearby.count == 0 || !isActive;
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

-(void)toggleBackgroundImage:(BOOL)on
{
    _backgroundImageView.image = [UIImage imageNamed:on ? @"berlinON.jpg" : @"berlinOFF.jpg"];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFromBottom;

    [_backgroundImageView.layer addAnimation:transition forKey:nil];
}

#pragma mark - WVEBeaconHandlerDelegate

- (void)beaconHandler:(WVEBeaconHandler *)handler didUpdateBeaconsWithNewBeacons:(NSSet *)newBeacons
{
    if ( newBeacons.count > 0 )
    {
        [self triggerLocalNotification];
    }

    [self updateUI];
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


#pragma mark - Shake detector
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake && !_shakeViewVisible )
    {
        _shakeViewVisible = YES;
        WVEAnimationViewController *vc = [[WVEAnimationViewController alloc] initWithColor:_colorsArray[_nextColorIndex]];
        [vc setDelegate:self];
        [self presentViewController:vc
                           animated:YES
                         completion:nil];
        _nextColorIndex = _nextColorIndex + 1 >= [_colorsArray count] ? 0 : _nextColorIndex + 1;
    }
}

- (void)viewIsDismissed
{
    _shakeViewVisible = NO;
    [self becomeFirstResponder];
}

#pragma
@end