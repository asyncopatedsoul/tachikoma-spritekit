//
//  TKMasterKey.m
//  Quest
//
//  Created by Michael Garrido on 1/11/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import "TKMasterKey.h"

#import "TKToy.h"
#import "constants.h"

@interface TKMasterKey()
{
    NSDictionary* objectData;
    
    float collisionBodyCoversWhatPercent;
    float particleDelay;
    
    unsigned char collisionBodyType; //0 to 255
    unsigned char currentDirection; //0 to 255
    
}

@end

@implementation TKMasterKey

-(void) attachToToy:(TKToy *)toyNode
{
    NSLog(@"attachToToy");
    _linkedToy = toyNode;
    self.physicsBody.dynamic = NO;
    self.isAttachedToToy = YES;
    [toyNode attachToKey:self];
    
    self.hidden = YES;
    self.position = toyNode.position;
}

-(BOOL) setBasePointAtTarget: (SKNode*)targetNode
{
    _basePoint = targetNode.position;
    
    if ([targetNode.parent isEqual:self.parent])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
-(void) triggerKeyWasHitWithNode: (SKSpriteNode*)contactNode;
{
    //immune if attached to toy
    if (_isAttachedToToy)
        return;
    
    if ([contactNode.name isEqualToString:@"actionObject"])
        [self returnToBasePoint];
}
-(void) returnToBasePoint
{
    self.position = _basePoint;
    
    //TODO animate teleportation
    
    NSLog(@"returnToBasePoint: %f,%f",_basePoint.x,_basePoint.y);
}

-(void) detachFromToyAtPoint:(CGPoint)touchPoint
{
    NSLog(@"detachFromToyAtPoint: %f,%f",touchPoint.x,touchPoint.y);
    NSLog(@"current location: %f,%f",self.position.x,self.position.y);
    [_linkedToy detachFromKey:self];
    
    //immediately unwind once detached
    [_linkedToy startUnwind];
    
    //if ipad
    float centeredX = touchPoint.x-768/2;
    float centeredY = touchPoint.y-1024/2;
    
    NSLog(@"centered location: %f, %f",centeredX,centeredY);
    
    float constrainedX;
    float constrainedY;

    
    float magnitude = sqrtf(centeredX*centeredX+centeredY*centeredY);
    float angle = atan2(centeredY, centeredX);
    
    NSLog(@"magnitude: %f",magnitude);
    NSLog(@"angle: %f",angle);
    
    if (magnitude>_detachRange){
        magnitude = _detachRange;
        constrainedX = self.position.x+cosf(angle)*_detachRange;
        constrainedY = self.position.y-sinf(angle)*_detachRange;
    } else {
        constrainedX = self.position.x+centeredX;
        constrainedY = self.position.y-centeredY;
    }
    
    //set key position at touchPoint if within drop radius
    //otherwise, set key position at drop radius max along vector to touch point
    //self.position = CGPointMake(constrainedX, constrainedY);
    CGPoint detachLocation = CGPointMake(constrainedX, constrainedY);
    
    self.hidden = NO;
    self.physicsBody.dynamic = YES;
    
    SKAction *detachAction = [SKAction moveTo:detachLocation duration:magnitude/_movementSpeed];
    SKAction *detachDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Detach Completed");
        self.isAttachedToToy = NO;
        _linkedToy = NULL;
    }];
    
    SKAction *moveLaserActionWithDone = [SKAction sequence:@[detachAction,detachDoneAction]];
    [self runAction:moveLaserActionWithDone withKey:@"isDetaching"];
    
    
    
}

-(void) update
{
    
}

-(void) createWithDictionary:(NSDictionary *)charData
{
    objectData = [NSDictionary dictionaryWithDictionary:charData];
    
    //_keySprite = [SKSpriteNode spriteNodeWithImageNamed:[objectData objectForKey:@"BaseFrame"]];
    _keySprite = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(40.0,40.0)];
    _keySprite.zPosition = 2;
    
    _detachRange = 200.0;
    _movementSpeed = 400.0;
    
    _toyContactRange = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(60.0, 60.0)];
    _toyContactRange.zPosition = 1;
    
    self.zPosition = 100;
    self.name = @"masterKey";
    
    
    if (_checkForDifferentPhoneLocations == YES) {
        
        if([objectData objectForKey:@"StartLocationPhone"] != nil ) {
            NSLog(@"Yes, character has alternate phone location");
            self.position = CGPointFromString ( [objectData objectForKey:@"StartLocationPhone"] );
        } else {
            NSLog(@"NO, character does not have alternate phone location");
            self.position = CGPointFromString ( [objectData objectForKey:@"StartLocation"] );
        }
        
    } else {
        
        self.position = CGPointFromString ( [objectData objectForKey:@"StartLocation"] );
    }
    
    self.isAttachedToToy = NO;
    
    [self addChild:_toyContactRange];
    [self addChild:_keySprite];
    
    [self setUpPhysics];

}

-(void) setUpPhysics {
    
    collisionBodyCoversWhatPercent = [[objectData objectForKey:@"CollisionBodyCoversWhatPercent"] floatValue];
    CGSize newSize = CGSizeMake( _keySprite.size.width * collisionBodyCoversWhatPercent, _keySprite.size.height * collisionBodyCoversWhatPercent);
    
    
    if (  [[objectData objectForKey:@"CollisionBodyType"] isEqualToString:@"square"]) {
        
        collisionBodyType = squareType;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newSize];
        
    } else {
        
        collisionBodyType = circleType;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:newSize.width / 2];
        
    }
    /*
    if ( [[objectData objectForKey:@"DebugBody"] boolValue] == YES ) {
        CGRect rect = CGRectMake( -( newSize.width / 2), -( newSize.height / 2), newSize.width, newSize.height);
        [self debugPath:rect bodyType:collisionBodyType];
    }
    */
    self.physicsBody.dynamic = YES;
    self.physicsBody.restitution = 0.2;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.mass = 5;
    
    /*
    self.physicsBody.categoryBitMask = playerCategory;
    self.physicsBody.collisionBitMask = wallCategory | playerCategory | coinCategory;
    self.physicsBody.contactTestBitMask = wallCategory | playerCategory | coinCategory; // seperate other categories with |
    */
}

- (void) moveFromMotionManager: (CMAccelerometerData*) data
{
    //NSLog(@"acceleration value x,y:\n %f, %f",data.acceleration.x,data.acceleration.y);
    
    // NSLog(@"velocity = %f, %f",_playerSprite.physicsBody.velocity.dx,_playerSprite.physicsBody.velocity.dy);
    
    float speedMultiplierX;
    float speedMultiplierY;
    
    float yInput;
    float xInput;
    
    float absoluteInputX = (data.acceleration.x>0)?data.acceleration.x:data.acceleration.x*-1.0;
    float absoluteInputY = (data.acceleration.y>0)?data.acceleration.y:data.acceleration.y*-1.0;
    
    
    speedMultiplierY = _movementSpeed;
    speedMultiplierX = _movementSpeed;
    
    float yInputLowerLimit = 0.03;
    float xInputLowerLimit = 0.03;
    
    //_playerSprite.physicsBody.linearDamping = 1.0;
    
    //how to stop on a dime?
    //when input direction is opposite of velocity direction, set velocity to 0
    
    //NSLog(@"horizontal velocity vs input: \n %f, %f",_playerSprite.physicsBody.velocity.dx,data.acceleration.y);
    if ( (self.physicsBody.velocity.dx>0.0 && data.acceleration.y<0.0) || (self.physicsBody.velocity.dx<0.0 && data.acceleration.y>0.0) )
    {
        self.physicsBody.velocity = CGVectorMake(self.physicsBody.velocity.dy,0.0);
    }
    
    //NSLog(@"vertical velocity vs input: \n %f, %f",_playerSprite.physicsBody.velocity.dy,data.acceleration.x);
    
    if ( (self.physicsBody.velocity.dy<0.0 && data.acceleration.x<0.0) || (self.physicsBody.velocity.dy>0.0 && data.acceleration.x>0.0) )
    {
        self.physicsBody.velocity = CGVectorMake(0.0,self.physicsBody.velocity.dx);
        
    }
    
    
    if (absoluteInputY<yInputLowerLimit)
    {
        yInput = 0.0;
        
    }
    else
    {
        if (data.acceleration.y>0.0)
        {
            yInput = 1.0;
            //_playerFacingRight = YES;
        }
        else
        {
            yInput =  -1.0;
            //_playerFacingRight = NO;
        }
    }
    
    if (absoluteInputX<xInputLowerLimit){
        xInput = 0.0;
    } else {
        xInput = (data.acceleration.x>0.0) ? 1.0 : -1.0;
    }
    
    //make fixed-speed movement like input from arcade joystick, jerky and precise
    self.physicsBody.velocity = CGVectorMake(xInput*speedMultiplierX,yInput*speedMultiplierY);
    //[_playerSprite.physicsBody applyForce:CGVectorMake(data.acceleration.y*speedMultiplierY, -1.0*data.acceleration.x*speedMultiplierX)];
    
    
    //if ( (_playerFacingRight && _playerRoot.xScale<0) || (!_playerFacingRight && _playerRoot.xScale>0))
    //    _playerRoot.xScale = _playerRoot.xScale*-1.0;
    
    //camera.position = _playerRoot.position;
}

@end
