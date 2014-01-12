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
    SKSpriteNode* actionTargetIndicator;
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
    _maxActionMagnitude = _movementSpeed*totalUnwindTime;
    
    NSLog(@"action range: %f",_maxActionMagnitude);
    
    
    //CGRect rect = CGRectMake( -( self.characterSize.width / 2), -( self.characterSize.height / 2), newSize.width, newSize.height);

    CGRect sourceRect = CGRectMake( -( 2*_maxActionMagnitude / 2), -( 2*_maxActionMagnitude / 2), 2*_maxActionMagnitude, 2*_maxActionMagnitude);
    _actionRange.position = CGPointMake( 0, 0);

    CGPathRef circlePath = CGPathCreateWithEllipseInRect(sourceRect, NULL);
    
    _actionRange.path = circlePath;
    
    [self validateActionPoint];
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
    
    actionTargetIndicator = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(20.0, 20.0)];
    actionTargetIndicator.position = CGPointMake(0.0, 0.0);
    
    [self addChild:actionTargetIndicator];
    
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
    actionTargetIndicator.position = CGPointMake(0.0, 0.0);
    
    _actionRange.hidden = NO;
    actionTargetIndicator.hidden = NO;
   
    [self stopUnwind];
    
    //self.physicsBody.dynamic = NO;
    //change to illustration with attached key
    
}

-(void) detachFromKey:(TKMasterKey *)masterKey
{
    _actionRange.hidden = YES;
    actionTargetIndicator.hidden = YES;
    
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

- (void) setActionVectorToPoint:(CGPoint)actionPoint
{
    CGPoint centeredActionPoint = CGPointMake(actionPoint.x-768/2, -1*(actionPoint.y-1024/2) );
    
    _actionMagnitude = sqrtf(centeredActionPoint.x*centeredActionPoint.x+centeredActionPoint.y*centeredActionPoint.y);
    
    NSLog(@"toy position: %f,%f", self.position.x, self.position.y);
    NSLog(@"raw action point: %f,%f", actionPoint.x, actionPoint.y);
    NSLog(@"centered action point: %f, %f", centeredActionPoint.x, centeredActionPoint.y);
    NSLog(@"action vector magnitude: %f",_actionMagnitude);
    
    actionTargetIndicator.position = centeredActionPoint;
    
    [self validateActionPoint];
}

- (void) validateActionPoint
{
    if (_actionMagnitude>_maxActionMagnitude)
    {
        [actionTargetIndicator setColor:[UIColor redColor]];
        [self setActionPoint:CGPointMake(0.0, 0.0)];
    }
    else
    {
        [actionTargetIndicator setColor:[UIColor greenColor]];
        [self setActionPoint:actionTargetIndicator.position];
    }
}

- (void) executeOrders
{
    //TODO detect action type
    [self executeMovement];
}

- (void) executeMovement
{
    
    NSLog(@"executeMovement toy position: %f,%f", self.position.x, self.position.y);
    
    if (_actionPoint.x==0.0 && _actionPoint.y==0.0)
        return;
    
    CGPoint movementTarget = CGPointMake(self.position.x+_actionPoint.x, self.position.y+_actionPoint.y);
    SKAction *movementAction = [SKAction moveTo:movementTarget duration:_actionMagnitude/_movementSpeed];
    SKAction *movementDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Movement Completed");
    }];
    
    
    
    SKAction *moveActionWithDone = [SKAction sequence:@[movementAction,movementDoneAction]];
    [self runAction:moveActionWithDone withKey:@"isMoving"];
}

- (void) startUnwind
{
    actionTimer = [NSTimer scheduledTimerWithTimeInterval:unwindInterval
                                                   target:self
                                                 selector:@selector(unwind)
                                                 userInfo:nil
                                                  repeats:YES];
    
    [self executeOrders];
    
}
- (void) stopUnwind
{
    [actionTimer invalidate];
    actionTimer = nil;
}

@end
