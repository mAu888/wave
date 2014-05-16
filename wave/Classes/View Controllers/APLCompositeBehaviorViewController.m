/*
     File: APLCompositeBehaviorViewController.m
 Abstract: Provides the "Pendulum (Composite Behavior)" demonstration.
 
  Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "APLCompositeBehaviorViewController.h"
#import "APLPendulumBehavior.H"
#import <CoreMotion/CoreMotion.h>


@interface APLCompositeBehaviorViewController ()
@property (nonatomic, strong) UIView *square;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) APLPendulumBehavior *pendulumBehavior;
@end

#define accelerationThreshold  0.30 // or whatever is appropriate - play around with different values

@implementation APLCompositeBehaviorViewController
{
}
//| ----------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];


    _square = [[UIView alloc] initWithFrame:CGRectMake(
        CGRectGetWidth([[self view] bounds]) / 2.f,
        200.f ,
        50.f,
        50.f)];
    [_square setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:_square];

    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    CGPoint pendulumAttachmentPoint = CGPointMake(CGRectGetMidX(_square.frame), 50.f);

    // An example of a high-level behavior simulating a simple pendulum.
    APLPendulumBehavior *pendulumBehavior = [[APLPendulumBehavior alloc] initWithWeight:_square suspendedFromPoint:pendulumAttachmentPoint];
    [animator addBehavior:pendulumBehavior];
    self.pendulumBehavior = pendulumBehavior;
    
    self.animator = animator;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //Motion detected, handle it with method calls or additional
    //logic here.
    if (motion == UIEventSubtypeMotionShake)
    {
        [self.pendulumBehavior dragWeightToPoint:CGPointMake(CGRectGetMaxX(_square.frame) + 50.f, CGRectGetMinY(_square.frame))];
    }

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self.pendulumBehavior endDraggingWeightWithVelocity:CGPointMake(200, 200)];
    }
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

//| ----------------------------------------------------------------------------
//  IBAction for the Pan Gesture Recognizer that has been configured to track
//  touches in self.view.
//
- (IBAction)dragWeight:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
        [self.pendulumBehavior beginDraggingWeightAtPoint:[gesture locationInView:self.view]];
    else if (gesture.state == UIGestureRecognizerStateEnded)
        [self.pendulumBehavior endDraggingWeightWithVelocity:[gesture velocityInView:self.view]];
    else if (gesture.state == UIGestureRecognizerStateCancelled)
    {
        gesture.enabled = YES;
        [self.pendulumBehavior endDraggingWeightWithVelocity:[gesture velocityInView:self.view]];
    }
    else if (!CGRectContainsPoint(self.square.bounds, [gesture locationInView:self.square]))
        // End the gesture if the user's finger moved outside square1's bounds.
        // This causes the gesture to transition to the cencelled state.
        gesture.enabled = NO;
    else
        [self.pendulumBehavior dragWeightToPoint:[gesture locationInView:self.view]];
}

@end