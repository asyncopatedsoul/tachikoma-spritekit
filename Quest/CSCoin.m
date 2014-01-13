//
//  CSCoin.m
//  Quest
//
//  Created by Justin's Clone on 10/9/13.
//  Copyright (c) 2013 CartoonSmart. All rights reserved.
//

#import "CSCoin.h"
#import "constants.h"

@interface CSCoin() {
    
    SKSpriteNode* coin;
    
    
}

@end


@implementation CSCoin


-(id) init {
    
    if (self = [super init]) {
        
        // do initilization in here
        
    }
    return self;
}


-(void)createWithBaseImage:(NSString*)baseString andLocation:(CGPoint)coinLocation {
    
    coin = [SKSpriteNode spriteNodeWithImageNamed:baseString];
    [self addChild:coin];
    
    self.zPosition = 25;
    self.name = @"coin";
    
    self.position = coinLocation;
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:coin.frame.size.width / 2];
    self.physicsBody.dynamic = YES;
    self.physicsBody.restitution = 1.0;
    self.physicsBody.allowsRotation = YES;
   
    //self.physicsBody.categoryBitMask = coinCategory;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    
}

@end
