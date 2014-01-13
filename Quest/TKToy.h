//
//  TKToy.h
//  Quest
//
//  Created by Michael Garrido on 1/11/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TKMasterKey.h"
#import "CSCharacter.h"

@interface TKToy : CSCharacter

@property (nonatomic, assign) SKSpriteNode* keyContactRange;
@property (nonatomic, retain) SKShapeNode* actionRange;
@property (nonatomic, assign) CGPoint actionPoint;
@property (nonatomic,assign) float rotations;
@property (nonatomic,assign) float actionRangeMultiplier;
@property (nonatomic,assign) float movementSpeed;
@property (nonatomic,assign) float actionMagnitude;
@property (nonatomic,assign) float maxActionMagnitude;


@property (nonatomic,assign) int maxWindUpRotations;

-(void) setupPhysics;
-(void) setupKeyInterface;
-(int) setWindUpRotations:(float) rotations;
-(int) compoundWindUpRotations:(float) rotations;
-(void) attachToKey:(TKMasterKey*)masterKey;
-(void) detachFromKey:(TKMasterKey*)masterKey;
- (void) startUnwind;
- (void) stopUnwind;

- (void) setActionVectorToPoint:(CGPoint)actionPoint;
- (void) setupAutoActions: (NSArray*)actionsArray;
- (void) triggerPhysicalAttackToTarget: (SKSpriteNode*)attackTarget WithNode: (SKSpriteNode*)attackNode;

@end