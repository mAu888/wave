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

#import "WVEAnimationViewController.h"

@interface WVEAnimationViewController ()
@end

#define squareWidth 52
#define spacing 1

@implementation WVEAnimationViewController
{
    NSMutableArray *_viewsArray;
    UIColor *_color;
}

- (id)initWithColor:(UIColor *)color
{
    self = [super init];
    if ( self )
    {
        _color = color;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _viewsArray = [NSMutableArray new];
    [self setupView];
}

- (void)setupView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    int rows = CGRectGetHeight([self.view bounds]) / (squareWidth + spacing);
    int columns = CGRectGetHeight([self.view bounds]) / (squareWidth + spacing);
    for(int i = 0; i < rows; i++)
    {
        for(int j = 0; j <= columns; j++)
        {
            UIView *tmpView = [[UIView alloc] initWithFrame:
                                                  CGRectMake(spacing + j*(squareWidth+ spacing),
                                                      spacing + i*(squareWidth+ spacing),
                                                      squareWidth,
                                                      squareWidth)];
            [tmpView setBackgroundColor:[UIColor blueColor]];

            [_viewsArray addObject:tmpView];
            [self.view addSubview:tmpView];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [self animateColor];
}

- (void)animateColor
{
    [_viewsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1*idx
                            options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut
                         animations:^
                         {
                             [obj setBackgroundColor:_color];
                         }
                         completion:^(BOOL finished)
                         {
                             if ( finished )
                             {
                                 [obj setBackgroundColor:[UIColor blueColor]];
                             }
                         }];

    }];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self dismissViewControllerAnimated:YES completion:^
        {
            if ( [_delegate respondsToSelector:@selector(viewIsDismissed)] )
            {
                [_delegate performSelector:@selector(viewIsDismissed)];
            }
        }];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end