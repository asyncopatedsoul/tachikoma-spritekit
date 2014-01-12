//
//  CSCharacter.h
//  Quest
//
//  Created by Justin's Clone on 10/2/13.
//  Copyright (c) 2013 CartoonSmart. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@import CoreMotion;

@interface CSCharacter : SKNode



@property (nonatomic, assign) BOOL checkForDifferentPhoneLocations; 
@property (nonatomic, assign) int idealX;
@property (nonatomic, assign) int idealY;
@property (nonatomic, assign) BOOL theLeader;
@property (nonatomic, assign) BOOL followingEnabled;
@property (nonatomic, assign) float currentHealth;
@property (nonatomic, assign) float maxHealth;
@property (nonatomic, assign) BOOL hasOwnHealth;
@property (nonatomic, assign) BOOL isDying;
@property (nonatomic,assign) CGSize characterSize;

-(void)createWithDictionary: (NSDictionary*) charData;
-(void) update;
-(void) moveLeftWithPlace:(NSNumber*) place;
-(void) moveRightWithPlace:(NSNumber*) place;
-(void) moveDownWithPlace:(NSNumber*) place;
-(void) moveUpWithPlace:(NSNumber*) place;
-(void) makeLeader;
-(int) returnDirection;
-(void) stopMoving;
-(void) stopMovingFromWallHit;
-(void) attack;
-(void) doDamageWithAmount:(float)amount;
-(void) stopInFormation:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location;
-(void) followIntoPositionWithDirection:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location;

-(void) enterWindupMode;
-(void) exitWindUpMode;
-(void) executeOrders;

-(void) moveFromMotionManager: (CMAccelerometerData*) data;

@end