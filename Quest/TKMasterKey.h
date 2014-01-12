//
//  TKMasterKey.h
//  Quest
//
//  Created by Michael Garrido on 1/11/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class TKToy;

@import CoreMotion;

@interface TKMasterKey : SKNode

@property (nonatomic, assign) float detachRange;
@property (nonatomic, assign) float movementSpeed;
@property (nonatomic, assign) SKSpriteNode* keySprite;
@property (nonatomic, assign) SKSpriteNode* toyContactRange;
@property (nonatomic,assign) bool isAttachedToToy;
@property (nonatomic,assign) TKToy* linkedToy;
@property (nonatomic, assign) BOOL checkForDifferentPhoneLocations;



-(void) createWithDictionary: (NSDictionary*)charData;
-(void) update;
-(void) moveFromMotionManager: (CMAccelerometerData*)data;
-(void) attachToToy: (TKToy*)toyNode;
-(void) detachFromToyAtPoint: (CGPoint)touchPoint;

@end
