//
//  CSLevel.h
//  Quest
//
//  Created by Justin's Clone on 10/2/13.
//  Copyright (c) 2013 CartoonSmart. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "HUDWindUpViewController.h"

@class TKToy;

@interface CSLevel : SKScene <SKPhysicsContactDelegate>

-(void) showWindUpInterfaceOverToy:(TKToy*)toyNode;
-(void) hideWindUpInterface;

-(void) setupTerrain;
-(void) setupInterestPoints;

@end
