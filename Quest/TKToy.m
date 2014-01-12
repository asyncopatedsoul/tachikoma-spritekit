//
//  TKToy.m
//  Quest
//
//  Created by Michael Garrido on 1/11/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import "TKToy.h"

@interface TKToy()
{
    SKLabelNode* rotationsLabel;
    NSTimer* actionTimer;
    float unwindAmount;
    float unwindInterval;
}
@end

@implementation TKToy

-(int) compoundWindUpRotations:(float) rotations
{
    [self updateRotations];
    
    if (fabs(rotations)>_maxWindUpRotations)
    {
        int rotationCap = (rotations>0)?_maxWindUpRotations:_maxWindUpRotations*-1;
        _rotations = rotationCap;
        return rotationCap;
    }
    else
    {
        _rotations+=rotations;
        return 0;
    }
}
-(int) setWindUpRotations:(float) rotations
{
    [self updateRotations];
    
    if (fabs(rotations)>_maxWindUpRotations)
    {
        int rotationCap = (rotations>0)?_maxWindUpRotations:_maxWindUpRotations*-1;
        _rotations = rotationCap;
        return rotationCap;
    }
    else
    {
        _rotations=rotations;
        return 0;
    }
}

-(void) updateRotations
{
    [self updateActionRange];
    [self updateRotationsLabel];
}

-(void) updateRotationsLabel
{
    int roundedRotations = (int)floorf(_rotations);
    rotationsLabel.text = [NSString stringWithFormat:@"%i",roundedRotations];
}
- (void) updateActionRange
{
    //grow/shrink with rotations
    
    //for this unit, action is movement
    //TODO set actions from dictionary/plist
    float totalUnwindTime = (fabs(_rotations)/unwindInterval)/(1.0/unwindInterval);
    float maxMovementRange = _movementSpeed*totalUnwindTime;
    
    NSLog(@"action range: %f",maxMovementRange);
    
    
    //CGRect rect = CGRectMake( -( self.characterSize.width / 2), -( self.characterSize.height / 2), newSize.width, newSize.height);

    CGRect sourceRect = CGRectMake( -( 2*maxMovementRange / 2), -( 2*maxMovementRange / 2), 2*maxMovementRange, 2*maxMovementRange);
    _actionRange.position = CGPointMake( 0, 0);

    CGPathRef circlePath = CGPathCreateWithEllipseInRect(sourceRect, NULL);
    
    _actionRange.path = circlePath;
}


-(void) setupKeyInterface
{
    _rotations = 0;
    
    //TODO set actions from dictionary/plist
    _maxWindUpRotations = 3;
    _movementSpeed = 200.0; //per second
    unwindInterval = 0.1;
    unwindAmount = 0.05;
   
    rotationsLabel = [SKLabelNode node];
    rotationsLabel.position = CGPointMake(0.0,40.0);
    rotationsLabel.color = [UIColor redColor];
    rotationsLabel.fontSize = 40.0;
    rotationsLabel.zPosition = 1000;
    
    [self addChild:rotationsLabel];
    
    _keyContactRange = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size: CGSizeMake(90.0, 90.0)];
    _keyContactRange.zPosition = 1;
    
    [self addChild:_keyContactRange];
    
    _actionRange = [SKShapeNode node];
    
    _actionRange.lineWidth = 1;
    _actionRange.strokeColor = [SKColor greenColor];
    //_actionRange.hidden = YES;
    _actionRange.zPosition = 1000;
    
    [self updateActionRange];
    
    [self addChild:_actionRange];
    
}

-(void) attachToKey: (TKMasterKey*)masterKey
{
    //_actionRange.hidden = NO;
    
    [self stopUnwind];
    
    //self.physicsBody.dynamic = NO;
    //change to illustration with attached key
    
}

-(void) detachFromKey:(TKMasterKey *)masterKey
{
    //_actionRange.hidden = YES;
    
    //self.physicsBody.dynamic = YES;
    //revert to default illustration
}

- (void) unwind
{
    if (_rotations>0)
        _rotations-=unwindAmount;
    else
        _rotations+=unwindAmount;
    
    [self updateRotations];
    
    if (fabs(_rotations)-unwindAmount<=0)
        [self stopUnwind];
    
}

- (void) startUnwind
{
    actionTimer = [NSTimer scheduledTimerWithTimeInterval:unwindInterval
                                                   target:self
                                                 selector:@selector(unwind)
                                                 userInfo:nil
                                                  repeats:YES];
}
- (void) stopUnwind
{
    [actionTimer invalidate];
    actionTimer = nil;
}

@end
