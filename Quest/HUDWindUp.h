//
//  HUDWindUp.h
//  Quest
//
//  Created by Michael Garrido on 1/9/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HUDWindUp : SKSpriteNode

@property (nonatomic, assign) float actionRange;
@property (nonatomic, assign) NSString* actionType;
@property (nonatomic, assign) CGPoint actionTarget;
@property (nonatomic, assign) CGVector actionVector;

@property (nonatomic, assign) SKLabelNode* windUpCount;
@property (nonatomic, assign) UIColor* abilityColor;
@property (nonatomic, assign) UIColor* movementColor;

-(void) updateActionRange;
-(void) setActionPoint: (CGPoint)touchPoint;
-(void) changeActionType;
-(void) expandUI;
-(void) collapseUI;

@end
