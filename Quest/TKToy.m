//
//  TKToy.m
//  Quest
//
//  Created by Michael Garrido on 1/11/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import "TKToy.h"
#import "constants.h"
#import <TransitionKit.h>

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

-(void) setupStateMachine
{
    TKStateMachine *inboxStateMachine = [TKStateMachine new];
    
    TKState *unread = [TKState stateWithName:@"Unread"];
    [unread setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        //[self incrementUnreadCount];
    }];
    TKState *read = [TKState stateWithName:@"Read"];
    [read setDidExitStateBlock:^(TKState *state, TKTransition *transition) {
        //[self decrementUnreadCount];
    }];
    TKState *deleted = [TKState stateWithName:@"Deleted"];
    [deleted setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        //[self moveMessageToTrash];
    }];
    
    [inboxStateMachine addStates:@[ unread, read, deleted ]];
    inboxStateMachine.initialState = unread;
    
    TKEvent *viewMessage = [TKEvent eventWithName:@"View Message" transitioningFromStates:@[ unread ] toState:read];
    TKEvent *deleteMessage = [TKEvent eventWithName:@"Delete Message" transitioningFromStates:@[ read, unread ] toState:deleted];
    TKEvent *markAsUnread = [TKEvent eventWithName:@"Mark as Unread" transitioningFromStates:@[ read, deleted ] toState:unread];
    
    [inboxStateMachine addEvents:@[ viewMessage, deleteMessage, markAsUnread ]];
    
    // Activate the state machine
    [inboxStateMachine activate];
    
    [inboxStateMachine isInState:@"Unread"]; // YES, the initial state
    
    // Fire some events
    NSDictionary *userInfo = nil;
    NSError *error = nil;
    BOOL success = [inboxStateMachine fireEvent:@"View Message" userInfo:userInfo error:&error]; // YES
    success = [inboxStateMachine fireEvent:@"Delete Message" userInfo:userInfo error:&error]; // YES
    success = [inboxStateMachine fireEvent:@"Mark as Unread" userInfo:userInfo error:&error]; // YES
    
    success = [inboxStateMachine canFireEvent:@"Mark as Unread"]; // NO
    
    // Error. Cannot mark an Unread message as Unread
    success = [inboxStateMachine fireEvent:@"Mark as Unread" userInfo:nil error:&error]; // NO
    
    // error is an TKInvalidTransitionError with a descriptive error message and failure reason
}

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
    int roundedRotations = (int)floorf(fabs(_rotations));
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
    
    //TODO set default from dictionary/plist
    _maxWindUpRotations = 2;
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
    _actionRange.hidden = YES;
    _actionRange.zPosition = 1000;
    
    [self updateActionRange];
    
    [self addChild:_actionRange];
    
}

-(void) setupAutoActions: (NSArray*)actionsArray
{
    //TODO set actions from dictionary/plist
    
    //setup auto attack
    float actionRange = 200.0;
    float actionObjectMovementSpeed = 800.0;
    float actionMinimumRepeatInterval = 0.4;
    CGPoint actionOrigin = CGPointMake(0.0, 0.0);
    NSString *actionType = @"physical";
    float actionObjectMass = 1.0;
    
    //TODO set eligible targets that trigger action
    
    //float actionObject
    //size
    //asset
    //particles
    
    SKSpriteNode *actionRangeNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(actionRange*2, actionRange*2)];
    SKSpriteNode *actionObject = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(30.0, 30.0)];
    
    actionRangeNode.name = @"actionRange";
    actionRangeNode.zPosition = 1;
    actionRangeNode.position = CGPointMake(0.0, 0.0);
    
    actionObject.name = @"actionObject";
    actionObject.zPosition = 2;
    actionObject.position = actionOrigin;
    actionObject.hidden = YES;
    
    if ([actionType isEqualToString:@"physical"])
    {
        actionObject.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: 30.0/2];
        actionObject.physicsBody.dynamic = YES;
        actionObject.physicsBody.restitution = 0.2;
        actionObject.physicsBody.allowsRotation = NO;
        actionObject.physicsBody.mass = actionObjectMass;
        
        actionObject.physicsBody.categoryBitMask = attackCategory;
        actionObject.physicsBody.collisionBitMask = wallCategory | keyCategory | toyCategory;
        actionObject.physicsBody.contactTestBitMask = wallCategory | keyCategory | toyCategory;
    }

    [actionRangeNode addChild:actionObject];
    [self addChild:actionRangeNode];
    
    //encode action nodes with behavior data
    actionRangeNode.userData = [[NSMutableDictionary alloc] init];
    [actionRangeNode.userData setValue:[NSNumber numberWithFloat:0.0] forKey:@"nextActionTime"];
    [actionRangeNode.userData setValue:[NSNumber numberWithFloat:actionMinimumRepeatInterval] forKey:@"minimumRepeatInterval"];
    
    actionObject.userData = [[NSMutableDictionary alloc] init];
    [actionObject.userData setValue:[NSString stringWithFormat:@"%@",actionType] forKey:@"type"];
    [actionObject.userData setValue:[NSNumber numberWithFloat:actionObjectMovementSpeed] forKey:@"movementSpeed"];
    
    [actionObject.userData setValue:[NSNumber numberWithFloat:actionOrigin.x] forKey:@"originX"];
    [actionObject.userData setValue:[NSNumber numberWithFloat:actionOrigin.y] forKey:@"originY"];
}

- (BOOL) triggerPhysicalAttackToTarget: (SKNode*)attackTarget WithNode: (SKSpriteNode*)attackNode atTime:(double)currentTime
{
    /*
    NSLog(@"attacker: %@",self);
    NSLog(@"attack node: %@", attackNode);
    NSLog(@"attack target: %@",attackTarget);
     */
    //preserving its movement relative to player, like a kick or punch
    //not like a free projectile

    float nextAttackTime = [[attackNode.parent.userData valueForKey:@"nextActionTime"] floatValue];
    float minimumRepeatInterval = [[attackNode.parent.userData valueForKey:@"minimumRepeatInterval"] floatValue];
    
    float deltaTime = currentTime-nextAttackTime;
    
    //NSLog(@"next attack time: %f",nextAttackTime);
    //NSLog(@"current time: %f",currentTime);
    //NSLog(@"detla time: %f",deltaTime);
    //NSLog(@"min interval: %f",minimumRepeatInterval);
    
    if (deltaTime < minimumRepeatInterval)
        return NO;
    
    if ([attackNode actionForKey:@"isAttacking"])
        return NO;
    
    //do not attack a dead toy
    if ([attackTarget isMemberOfClass:[TKToy class]])
    {
        CSCharacter* toyTarget = (CSCharacter*)attackTarget;
        if (toyTarget.isDying)
            return NO;
    }
    
    [attackNode.parent.userData setValue:[NSNumber numberWithFloat:currentTime+minimumRepeatInterval] forKey:@"nextActionTime"];
    
    CGPoint attackOrigin = attackNode.position;
    //attackNode.parent is the actionRangeNode
    //if attackTarget is masterKey, attackTarget.parent is myWorld
    CGPoint attackPoint = [attackNode.parent convertPoint:attackTarget.position fromNode:attackTarget.parent];

    
    NSLog(@"toy position: %f, %f",self.position.x,self.position.y);
    NSLog(@"attack node position: %f,%f",attackNode.position.x, attackNode.position.y);
    NSLog(@"attack start: %f,%f",attackOrigin.x,attackOrigin.y);
    NSLog(@"attack end: %f,%f",attackPoint.x,attackPoint.y);
    
    
    float deltaX = attackOrigin.x-attackPoint.x;
    float deltaY = attackOrigin.y-attackPoint.y;
    float attackMagnitude = sqrtf(powf(deltaX,2)+pow(deltaY,2));
    float attackDuration = attackMagnitude/[[attackNode.userData valueForKey:@"movementSpeed"] floatValue];
    
    NSLog(@"attack magnitude: %f", attackMagnitude);
    NSLog(@"attack duration: %f", attackDuration);
    
    //attackNode.hidden = NO;
    //[attackNode removeAllActions];
    
    //TODO
    //change player sprite to attack animation
    
    attackNode.hidden = NO;
    
    SKAction *attackAction = [SKAction moveTo:attackPoint duration:attackDuration];
    SKAction *attackDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Attack Completed");
        attackNode.hidden = YES;
        attackNode.position = CGPointMake(0.0, 0.0);
    }];
    
    SKAction *attackActionWithDone = [SKAction sequence:@[attackAction,attackDoneAction]];
    
    [attackNode runAction:attackActionWithDone withKey:@"isAttacking"];
    
    return YES;
}


-(void) attachToKey: (TKMasterKey*)masterKey
{
    actionTargetIndicator.position = CGPointMake(0.0, 0.0);
    
    _actionRange.hidden = NO;
    actionTargetIndicator.hidden = NO;
   
    [self stopUnwind];
    
    //TODO change to illustration with attached key
    
}

-(void) detachFromKey:(TKMasterKey *)masterKey
{
    _actionRange.hidden = YES;
    actionTargetIndicator.hidden = YES;
    
    //TODO revert to default illustration
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
