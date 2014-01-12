//
//  CSCharacter.m
//  Quest
//
//  Created by Justin's Clone on 10/2/13.
//  Copyright (c) 2013 CartoonSmart. All rights reserved.
//

#import "CSCharacter.h"
#import "constants.h"

@import CoreMotion;

@interface CSCharacter() {
    
    NSDictionary* characterData;
    SKSpriteNode* character; // this will be the actual image you see of the character
    
    
    float collisionBodyCoversWhatPercent;
    float particleDelay;
    
    unsigned char collisionBodyType; //0 to 255
    float speed;
    unsigned char currentDirection; //0 to 255
    
    bool useForCollisions;
    bool useFrontViewFrames;
    bool useRestingFrames;
    bool useSideViewFrames;
    bool useBackViewFrames;
    bool useSideAttackFrames;
    bool useFrontAttackFrames;
    bool useBackAttackFrames;
    bool doesAttackWhenNotLeader;
    bool useAttackParticles;
    
    bool isAttachedToKey;
    
    SKAction* walkFrontAction;
    SKAction* walkBackAction;
    SKAction* walkSideAction;
    SKAction* repeatRest;
    SKAction* sideAttackAction;
    SKAction* frontAttackAction;
    SKAction* backAttackAction;
    
    int particlesToEmit;
    
    unsigned char fps; //the range is 0 to 255, but really you want this to be 1 to 60
    
}

@end


@implementation CSCharacter


-(void) executeOrders
{
    
}

-(id) init {
    
    if (self = [super init]) {
        
        // do initilization in here
      
        currentDirection = noDirection;
        
        
    }
    return self;
}

-(void) enterWindupMode
{
    //prevent camera movement
    //block accelerometer input
    
    //create/show WindUp overlay
}

-(void) exitWindUpMode
{
    
}

-(void)createWithDictionary: (NSDictionary*) charData {
    
    
    characterData = [NSDictionary dictionaryWithDictionary:charData];
    
    character = [SKSpriteNode spriteNodeWithImageNamed:[characterData objectForKey:@"BaseFrame"]];
    self.zPosition = 100;
    self.name = @"character";
    
    
    if (_checkForDifferentPhoneLocations == YES) {
        
        if([characterData objectForKey:@"StartLocationPhone"] != nil ) {
            NSLog(@"Yes, character has alternate phone location");
            self.position = CGPointFromString ( [characterData objectForKey:@"StartLocationPhone"] );
        } else {
            NSLog(@"NO, character does not have alternate phone location");
             self.position = CGPointFromString ( [characterData objectForKey:@"StartLocation"] );
        }
        
    } else {
        
         self.position = CGPointFromString ( [characterData objectForKey:@"StartLocation"] );
    }
    
   
    
    [self addChild:character];
    
    
    _followingEnabled = [[characterData objectForKey:@"FollowingEnabled"] boolValue];
    useForCollisions = [[characterData objectForKey:@"UseForCollisions"] boolValue];
    useAttackParticles = [[characterData objectForKey:@"UseAttackParticles"] boolValue];
    doesAttackWhenNotLeader = [[characterData objectForKey:@"DoesAttackWhenNotLeader"] boolValue];
    
    speed = [[characterData objectForKey:@"Speed"] floatValue];
    particleDelay = [[characterData objectForKey:@"ParticleDelay"] floatValue];
    particlesToEmit = [[characterData objectForKey:@"ParticlesToEmit"] intValue];
    
    //TEXTURES....
    
    fps = [[charData objectForKey:@"FPS"] integerValue];
    
    useBackViewFrames = [[charData objectForKey:@"UseBackViewFrames"] boolValue];
    useSideViewFrames = [[charData objectForKey:@"UseSideViewFrames"] boolValue];
    useFrontViewFrames = [[charData objectForKey:@"UseFrontViewFrames"] boolValue];
    useRestingFrames = [[charData objectForKey:@"UseRestingFrames"] boolValue];
    useSideAttackFrames = [[charData objectForKey:@"UseSideAttackFrames"] boolValue];
    useFrontAttackFrames = [[charData objectForKey:@"UseFrontAttackFrames"] boolValue];
    useBackAttackFrames = [[charData objectForKey:@"UseBackAttackFrames"] boolValue];
    
    _hasOwnHealth = [[characterData objectForKey:@"HasOwnHealth"] boolValue];
    
    if (_hasOwnHealth == YES) {
        
        [self setUpHealthMeter];
    }
    
    if (useRestingFrames == YES) {
        
        [self setUpRest];
    }
    if ( useSideViewFrames == YES) {
        
        [self setUpWalkSide];
        
    }
    if ( useBackViewFrames == YES) {
        
        [self setUpWalkBack];
        
    }
    if ( useFrontViewFrames == YES) {
        
        [self setUpWalkFront];
        
    }
    
    if (useBackAttackFrames == YES) {
        
        [self setUpBackAttackFrames];
        
    }
    if (useSideAttackFrames == YES) {
        
        [self setUpSideAttackFrames];
        
    }
    if (useFrontAttackFrames == YES) {
        
        [self setUpFrontAttackFrames];
    }
    
    
    if (useForCollisions == YES) {
        
        [self setUpPhysics];
    }
    
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        self.xScale = .75;
        self.yScale = .75;
    }
     */
    
}

-(void) setUpHealthMeter {
    
    _maxHealth = [[characterData objectForKey:@"Health"] floatValue];
    _currentHealth = _maxHealth;
    
    SKSpriteNode* healthBar = [SKSpriteNode spriteNodeWithImageNamed:@"healthbar"];
    healthBar.zPosition = 200;
    healthBar.position = CGPointMake(0, (character.frame.size.height / 2)  );
    [self addChild:healthBar];
    
    SKSpriteNode* green = [SKSpriteNode spriteNodeWithImageNamed:@"green"];
    green.zPosition = 201;
    green.position = CGPointMake( - (green.frame.size.width / 2), (character.frame.size.height / 2)  );
    green.anchorPoint = CGPointMake(0.0, 0.5);
    green.name = @"green";
    [self addChild:green];
    
    
}

-(void) setUpPhysics {
    
    collisionBodyCoversWhatPercent = [[characterData objectForKey:@"CollisionBodyCoversWhatPercent"] floatValue];
    
    [self setCharacterSize:character.size];
    
    CGSize newSize = CGSizeMake( character.size.width * collisionBodyCoversWhatPercent, character.size.height * collisionBodyCoversWhatPercent);
    
    
    if (  [[characterData objectForKey:@"CollisionBodyType"] isEqualToString:@"square"]) {
        
        collisionBodyType = squareType;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newSize];
        
    } else {
        
        collisionBodyType = circleType;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:newSize.width / 2];
        
    }
    
    if ( [[characterData objectForKey:@"DebugBody"] boolValue] == YES ) {
        CGRect rect = CGRectMake( -( newSize.width / 2), -( newSize.height / 2), newSize.width, newSize.height);
        [self debugPath:rect bodyType:collisionBodyType];
    }
    
    self.physicsBody.dynamic = YES;
    self.physicsBody.restitution = 0.2;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.mass = 5;
    
    self.physicsBody.categoryBitMask = playerCategory;
    self.physicsBody.collisionBitMask = wallCategory | playerCategory | coinCategory;
    self.physicsBody.contactTestBitMask = wallCategory | playerCategory | coinCategory;//separate other categories with |
    
}

-(void) debugPath:(CGRect)theRect bodyType:(int)type {
    
    SKShapeNode*  pathShape = [[SKShapeNode alloc] init];
    CGPathRef thePath;
    
    if (type == squareType) {
    
        thePath = CGPathCreateWithRect( theRect, NULL);
        
    } else  {
        
        CGRect adjustedRect = CGRectMake(theRect.origin.x, theRect.origin.y, theRect.size.width, theRect.size.width);
        
        thePath = CGPathCreateWithEllipseInRect(adjustedRect, NULL);
        
    }
    
    
    pathShape.path = thePath;
    
    pathShape.lineWidth = 1;
    pathShape.strokeColor = [SKColor greenColor];
    pathShape.position = CGPointMake( 0, 0);
    
    [self addChild:pathShape];
    pathShape.zPosition = 1000;
    
}

#pragma mark Setup Rest / Walk Frames

-(void) setUpRest {
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"RestingAtlasFile"]];
    
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"RestingFrames"]];
    NSMutableArray* atlasTextures = [NSMutableArray arrayWithCapacity:[array count]];
    
    unsigned char count = 0;
    
    for (id object in array) {
        SKTexture *texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame: 1.0/ fps ];
    SKAction* wait = [SKAction waitForDuration:0.5];
    SKAction* sequence = [SKAction sequence:@[atlasAnimation, wait]];
    repeatRest = [SKAction repeatActionForever:sequence];
    

}

-(void) setUpWalkFront {
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"WalkFrontAtlasFile"]];
    
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"WalkFrontFrames"]];
    NSMutableArray* atlasTextures = [NSMutableArray arrayWithCapacity:[array count]];
    
    unsigned char count = 0;
    
    for (id object in array) {
        SKTexture *texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame: 1.0/ fps ];
    walkFrontAction = [SKAction repeatActionForever:atlasAnimation];
    
}

-(void) setUpWalkBack {
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"WalkBackAtlasFile"]];
    
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"WalkBackFrames"]];
    NSMutableArray* atlasTextures = [NSMutableArray arrayWithCapacity:[array count]];
    
    unsigned char count = 0;
    
    for (id object in array) {
        SKTexture *texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame: 1.0/ fps ];
    walkBackAction = [SKAction repeatActionForever:atlasAnimation];
    
}

-(void) setUpWalkSide {
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"WalkSideAtlasFile"]];
    
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"WalkSideFrames"]];
    NSMutableArray* atlasTextures = [NSMutableArray arrayWithCapacity:[array count]];
    
    unsigned char count = 0;
    
    for (id object in array) {
        SKTexture *texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame: 1.0/ fps ];
    walkSideAction = [SKAction repeatActionForever:atlasAnimation];
    
}

#pragma mark Setup Attack Frames


-(void) setUpSideAttackFrames {
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"SideAttackAtlasFile"]];
    
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"SideAttackFrames"]];
    NSMutableArray* atlasTextures = [NSMutableArray arrayWithCapacity:[array count]];
    
    unsigned char count = 0;
    
    for (id object in array) {
        SKTexture *texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame: 1.0/ fps ];
    
    
    if (useSideViewFrames == YES) {
        
        SKAction* returnToWalking = [SKAction performSelector:@selector(runWalkSideTextures) onTarget:self];
        sideAttackAction = [SKAction sequence:@[atlasAnimation, returnToWalking]];
        
    } else {
        
        sideAttackAction = [SKAction repeatAction:atlasAnimation count:1];
    }

    
}

-(void) setUpBackAttackFrames {
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"BackAttackAtlasFile"]];
    
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"BackAttackFrames"]];
    NSMutableArray* atlasTextures = [NSMutableArray arrayWithCapacity:[array count]];
    
    unsigned char count = 0;
    
    for (id object in array) {
        SKTexture *texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame: 1.0/ fps ];
    
    
    if (useBackViewFrames == YES) {
        
        SKAction* returnToWalking = [SKAction performSelector:@selector(runWalkBackTextures) onTarget:self];
        backAttackAction = [SKAction sequence:@[atlasAnimation, returnToWalking]];
        
    } else {
        
        backAttackAction = [SKAction repeatAction:atlasAnimation count:1];
    }

    
}

-(void) setUpFrontAttackFrames {
    
    
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"FrontAttackAtlasFile"]];
    
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"FrontAttackFrames"]];
    NSMutableArray* atlasTextures = [NSMutableArray arrayWithCapacity:[array count]];
    
    unsigned char count = 0;
    
    for (id object in array) {
        SKTexture *texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame: 1.0/ fps ];
    
    
    if (useFrontViewFrames == YES) {
        
        SKAction* returnToWalking = [SKAction performSelector:@selector(runWalkFrontTextures) onTarget:self];
        frontAttackAction = [SKAction sequence:@[atlasAnimation, returnToWalking]];
        
    } else {
        
        frontAttackAction = [SKAction repeatAction:atlasAnimation count:1];
    }
    
    
}
#pragma mark Methods to RUN SKActions

-(void) runRestingTextures {
    
    if (repeatRest == nil ) {
        
        [self setUpRest];
        
    }
    if (character.hasActions == YES) {
        
        [character removeAllActions];
    }
    
    [character runAction:repeatRest];
    
}

-(void) runWalkFrontTextures {
    
    
    if ( walkFrontAction == nil ) {
        
        [self setUpWalkFront];
    }
    
    if (character.hasActions == YES) {
        [character removeAllActions];
    }
    
    [character runAction:walkFrontAction];
    
    
}

-(void) runWalkSideTextures {
    
    if ( walkSideAction == nil ) {
        
        [self setUpWalkSide];
        
    }
    
    if (currentDirection != left || currentDirection != right) {
        
        if (character.hasActions == YES) {
            [character removeAllActions];
        }
        [character runAction:walkSideAction];
        
    }
    
    
}

-(void) runWalkBackTextures {
    
    if ( walkBackAction == nil ) {
        
        [self setUpWalkBack];
        
    }
    
    if (character.hasActions == YES) {
        [character removeAllActions];
    }
    
    [character runAction:walkBackAction];
    
    
}


#pragma mark UPDATE method

-(void) update {
    
    
    if (_followingEnabled == YES || _theLeader == YES) {
    
    switch (currentDirection) {
        case up:
            self.position = CGPointMake (self.position.x, self.position.y + speed);
            
            if (self.position.x < _idealX && _theLeader == NO) {
                self.position = CGPointMake(self.position.x + 1, self.position.y);
            } else if (self.position.x > _idealX && _theLeader == NO) {
                self.position = CGPointMake(self.position.x - 1, self.position.y);
            }
            
            break;
        case down:
            self.position = CGPointMake (self.position.x, self.position.y - speed);
            
            if (self.position.x < _idealX && _theLeader == NO) {
                self.position = CGPointMake(self.position.x + 1, self.position.y);
            } else if (self.position.x > _idealX && _theLeader == NO) {
                self.position = CGPointMake(self.position.x - 1, self.position.y);
            }
            
            break;
        case left:
            self.position = CGPointMake (self.position.x - speed, self.position.y  );
            
            if (self.position.y < _idealY && _theLeader == NO) {
                self.position = CGPointMake(self.position.x , self.position.y + 1);
            } else if (self.position.y > _idealY && _theLeader == NO) {
                self.position = CGPointMake(self.position.x, self.position.y - 1);
            }
            
            break;
        case right:
            self.position = CGPointMake (self.position.x + speed, self.position.y );
            
            if (self.position.y < _idealY && _theLeader == NO) {
                self.position = CGPointMake(self.position.x , self.position.y + 1);
            } else if (self.position.y > _idealY && _theLeader == NO) {
                self.position = CGPointMake(self.position.x, self.position.y - 1);
            }
            
            break;
        case noDirection:
           // in case you do want to do something for noDirection
            
            break;
            
        default:
            break;
    }
    
        
    } // if (_followingEnabled == YES && _theLeader == YES) {
    
}

#pragma mark Handle Movement 

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};


-(void) moveLeftWithPlace:(NSNumber*) place {
    
    if (_followingEnabled == YES || _theLeader == YES) {
    
        self.zPosition = 100 - [place integerValue]; // converts NSNumber to int
        
        if (useSideViewFrames == YES){
            
            character.zRotation = DegreesToRadians(0);
            character.xScale = -1; // flip 100% on the X axis
            [self runWalkSideTextures];
            
        } else if (useFrontViewFrames == YES) {
            character.zRotation = DegreesToRadians(-90);
            [self runWalkFrontTextures];
            
        } else {
        
            character.zRotation = DegreesToRadians(-90);
        
        }
            currentDirection = left;
        
    }
    
}

-(void) moveRightWithPlace:(NSNumber*) place{
    
     if (_followingEnabled == YES || _theLeader == YES) {
    
         self.zPosition = 100 - [place integerValue]; // converts NSNumber to int
         character.xScale = 1; // flip 100% on the X axis
         
         if (useSideViewFrames == YES){
             
             character.zRotation = DegreesToRadians(0);
             [self runWalkSideTextures];
             
         } else if (useFrontViewFrames == YES) {
             character.zRotation = DegreesToRadians(90);
             [self runWalkFrontTextures];
             
         } else {
             
             character.zRotation = DegreesToRadians(90);
             
         }
         currentDirection = right;

         
     }
}

-(void) moveDownWithPlace:(NSNumber*) place{
    
    if (_followingEnabled == YES || _theLeader == YES) {
        
        self.zPosition = 100 - [place integerValue]; // converts NSNumber to int
        character.xScale = 1; // flip 100% on the X axis
         character.zRotation = DegreesToRadians(0);
        
        if (useFrontViewFrames == YES) {
            
            [self runWalkFrontTextures];
           
        }
        
         currentDirection = down;
     }
}

-(void) moveUpWithPlace:(NSNumber*) place{
    
     if (_followingEnabled == YES || _theLeader == YES) {
         
         self.zPosition = 100 + [place integerValue]; // converts NSNumber to int
         character.xScale = 1; // flip 100% on the X axis

         if (useBackViewFrames == YES){
             
             [self runWalkBackTextures];
             character.zRotation = DegreesToRadians(0);
         }
         else if (useFrontViewFrames == YES) {
             
             character.zRotation = DegreesToRadians(180);
             [self runWalkFrontTextures];
             
         } else {
             
             character.zRotation = DegreesToRadians(180);
             
         }
         
         currentDirection = up;
     }
    
}

-(void) followIntoPositionWithDirection:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location {
    
    
    if (_followingEnabled == YES) {
    
    int paddingX = character.frame.size.width / 1.5;
    int paddingY = character.frame.size.height / 1.5;
    
    CGPoint newPosition;
    
    if (direction == up) {
        
        newPosition = CGPointMake(location.x , location.y - ( paddingY * place) );
        [self moveUpWithPlace:[NSNumber numberWithInt:place] ];
        
    } else if (direction == down) {
        
        newPosition = CGPointMake(location.x , location.y + ( paddingY * place) );
        [self moveDownWithPlace:[NSNumber numberWithInt:place] ];
        
    } else if (direction == right) {
        
        newPosition = CGPointMake(location.x - ( paddingX * place)  , location.y );
        [self moveRightWithPlace:[NSNumber numberWithInt:place] ];
        
    } else if (direction == left) {
        
        newPosition = CGPointMake(location.x + ( paddingX * place)  , location.y );
        [self moveLeftWithPlace:[NSNumber numberWithInt:place] ];
    }

    SKAction* moveIntoLine = [SKAction moveTo:newPosition duration:0.2];
    [self runAction:moveIntoLine];
    
    
    }
    
    
    
}

- (void)moveFromMotionManager: (CMAccelerometerData*) data
{
    //NSLog(@"acceleration value x,y:\n %f, %f",data.acceleration.x,data.acceleration.y);
    
    // NSLog(@"velocity = %f, %f",_playerSprite.physicsBody.velocity.dx,_playerSprite.physicsBody.velocity.dy);
    
    float speedMultiplierX;
    float speedMultiplierY;
    
    float yInput;
    float xInput;
    
    float absoluteInputX = (data.acceleration.x>0)?data.acceleration.x:data.acceleration.x*-1.0;
    float absoluteInputY = (data.acceleration.y>0)?data.acceleration.y:data.acceleration.y*-1.0;
    
    
    speedMultiplierY = 400.0;
    speedMultiplierX = 400.0;
    
    float yInputLowerLimit = 0.1;
    float xInputLowerLimit = 0.1;
    
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


#pragma mark STOP Moving

-(void) stopMoving {
    
    currentDirection = noDirection;
    
    [character removeAllActions];
    
}

-(void) stopMovingFromWallHit {
    

    [character removeAllActions];
    
}

-(void) stopInFormation:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location {
    
    
     if (_followingEnabled == YES && currentDirection != noDirection) {
    
    int paddingX = character.frame.size.width / 2;
    int paddingY = character.frame.size.height / 2;
    
         
         
    CGPoint newPosition = CGPointMake(self.position.x, self.position.y);
    
         
    if (direction == up) {
        
        newPosition = CGPointMake(location.x , location.y - ( paddingY * place) );
        
    } else if (direction == down) {
        
        newPosition = CGPointMake(location.x , location.y + ( paddingY * place) );
   
        
    } else if (direction == right) {
        
        newPosition = CGPointMake(location.x - ( paddingX * place)  , location.y );
        
        
    } else if (direction == left) {
        
        newPosition = CGPointMake(location.x + ( paddingX * place)  , location.y );
        
    }
    
    SKAction* moveIntoLine = [SKAction moveTo:newPosition duration:0.5f];
    SKAction* stop = [SKAction performSelector:@selector(stopMoving) onTarget:self];
    SKAction* sequence = [SKAction sequence:@[ moveIntoLine, stop] ];
    [self runAction:sequence];
    
         
     }
    
}



#pragma mark LEADER stuff

-(void) makeLeader{
    
    currentDirection = noDirection;
    _theLeader = YES;
    
    if ( useForCollisions == NO ) {
        
        //NSLog(@"Leader must use physics");
        [self setUpPhysics];
        
    }
    
}

-(int) returnDirection {
    
    return currentDirection;
}

#pragma mark Attack

-(void) attack {
    
    if (_theLeader == YES || doesAttackWhenNotLeader == YES) {
        
    
        if (currentDirection == down && useFrontAttackFrames == YES) {
            
            [character removeAllActions];
            
            if (frontAttackAction == nil) {
                
                [self setUpFrontAttackFrames];
            }
            
            [character runAction:frontAttackAction];
            
            
        } else if ( currentDirection == left || currentDirection == right ) {
            
             [character removeAllActions];
            
            if (useSideAttackFrames == YES) {
                
                 // if side view attack frames are  enabled....
                
                if (sideAttackAction == nil) {
                    
                    [self setUpSideAttackFrames];
                }
                [character runAction:sideAttackAction];
                
                
            } else if (useFrontAttackFrames == YES) {
                
                // if side view attack frames are not enabled, but front attack are, we run this...
                if (frontAttackAction == nil) {
                    
                    [self setUpFrontAttackFrames];
                }
                
                [character runAction:frontAttackAction];
                
            }
            
            
            
        } else if (currentDirection == up) {
            
            [character removeAllActions];
            
            if (useBackAttackFrames == YES) {
                
                if (backAttackAction == nil) {
                    
                    [self setUpBackAttackFrames];
                }
                [character runAction:backAttackAction];
                
                
            } else if (useFrontAttackFrames == YES) {
                
                // if side view attack frames are not enabled, but front attack are, we run this...
                if (frontAttackAction == nil) {
                    
                    [self setUpFrontAttackFrames];
                }
                
                [character runAction:frontAttackAction];
                
            }
            
        }
        
        
        if (useAttackParticles == YES && currentDirection != noDirection) {
            
            [self performSelector:@selector(addEmitter) withObject:nil afterDelay:particleDelay];
            
        }
        
       
        
        
    }
    
}


-(void) addEmitter {
    
    NSString* emitterPath = [[NSBundle mainBundle] pathForResource:[characterData objectForKey:@"AttackParticleFile"] ofType:@"sks"];
    SKEmitterNode* emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    emitter.zPosition = 150;
    
    switch (currentDirection) {
        case up:
            emitter.position = CGPointMake(0, character.frame.size.height / 2 );
            break;
        case down:
            emitter.position = CGPointMake(0, -(character.frame.size.height / 2) );
            break;
        case right:
            emitter.position = CGPointMake((character.frame.size.height / 2), 0 );
            break;
        case left:
            emitter.position = CGPointMake( -(character.frame.size.height / 2), 0 );
            break;
        default:
            emitter.position = CGPointMake(0, 0 );
            break;
    }
    
    emitter.numParticlesToEmit = particlesToEmit;
    [self addChild:emitter];
    
    
}

#pragma mark Damage

-(void) doDamageWithAmount:(float)amount {
    
    _currentHealth = _currentHealth - amount;
    [self childNodeWithName:@"green"].xScale = _currentHealth / _maxHealth;
    
    
    // just to prevent the green health bar from being inverted.
    if (_currentHealth <= 0) {
     
        _currentHealth = 0;
        [self childNodeWithName:@"green"].xScale = _currentHealth / _maxHealth;
    }
    
    [self performSelector:@selector(damageActions) withObject:nil afterDelay:0.05];
    
}

-(void) damageActions {
    
    SKAction* push;
    
    if (currentDirection == left){
        
        push = [SKAction moveByX:100 y:0 duration:0.2];
    } else if (currentDirection == right){
        
        push = [SKAction moveByX:-100 y:0 duration:0.2];
    } else if (currentDirection == up){
        
        push = [SKAction moveByX:0 y:-100 duration:0.2];
    } else if (currentDirection == down){
        
        push = [SKAction moveByX:0 y:100 duration:0.2];
    }
    
    [self runAction:push];
    
    SKAction* pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.2],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.2],
                                              ]];
    [character runAction:pulseRed];
    
    
    [self performSelector:@selector(damageDone) withObject:nil afterDelay:0.21];
    
    
}
-(void) damageDone {
    
    currentDirection = noDirection;
    
    if (_currentHealth <= 0) {

        [self enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
            
            [node removeFromParent];
            
        }];
        
        [self deathEmitter];
       
        _isDying = YES;
        self.physicsBody.dynamic = NO;
        self.physicsBody = nil;
        
        [self performSelector:@selector(removeFromParent) withObject:nil afterDelay:1.0];
    }

    
    
}


-(void) deathEmitter {
    
    NSString* emitterPath = [[NSBundle mainBundle] pathForResource:@"DeathFire" ofType:@"sks"];
    SKEmitterNode* emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    emitter.zPosition = 150;
    emitter.position = CGPointMake(0, - (character.frame.size.height / 2)+10 );
    emitter.numParticlesToEmit = 150;
    [self addChild:emitter];
    
}



@end







