//
//  HUDWindUpViewController.h
//  Quest
//
//  Created by Michael Garrido on 1/9/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SpriteKit/SpriteKit.h>
#import "DPCircularGestureRecognizer.h"

@class TKToy;
@class TKMasterKey;

@interface HUDWindUpViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic,assign) float windUpRadians;
@property (nonatomic,assign) float windUpRotations;
@property (nonatomic,assign) float windUpProgression;
@property (nonatomic,retain) UILabel* windUpTotalLabel;
@property (nonatomic,retain) TKToy* linkedToy;
@property (nonatomic,retain) TKMasterKey* linkedKey;

- (void) setActionPoint;
- (void) linkToy: (TKToy*)toyNode andKey: (TKMasterKey*)keyNode;
- (void) releaseLinkedNodes;
- (void) handleMovingInCircle:(DPCircularGestureRecognizer *)recognizer;
- (void) drawRadiusFromCenter: (CGPoint)centerPoint ThroughPoint: (CGPoint)touchPoint;

- (void) handleTouchUpInside:(UIGestureRecognizer*) recognizer;

- (void) teardown;

@end
