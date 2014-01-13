//
//  CSLevel.m
//  Quest
//
//  Created by Justin's Clone on 10/2/13.
//  Copyright (c) 2013 CartoonSmart. All rights reserved.
//

#import "CSLevel.h"
#import "constants.h"
#import "CSCharacter.h"
#import "CSStartMenu.h"
#import "CSCoin.h"

#import "TKMasterKey.h"
#import "TKToy.h"

@import AVFoundation;
@import CoreMotion;

static int levelCount = 0;

@interface CSLevel () {
    
    bool checkForDifferentPhoneLocations;
    bool isDevicePhone;
    UISwipeGestureRecognizer* swipeGestureLeft;
    UISwipeGestureRecognizer* swipeGestureRight;
    UISwipeGestureRecognizer* swipeGestureUp;
    UISwipeGestureRecognizer* swipeGestureDown;
    UITapGestureRecognizer* tapOnce;
    UITapGestureRecognizer* twoFingerTap;
    UITapGestureRecognizer* threeFingerTap;
    UIRotationGestureRecognizer* rotationGR;
    
    int levelBorderCausesDamageBy;
    int currentLevel;
    unsigned char charactersInWorld; // 0 to 255
    
    SKNode* myWorld;
    CSCharacter* leader;
    
    TKMasterKey* masterKey;
    SKSpriteNode *playerAbase;
    
    NSArray* characterArray;
    NSArray* playersArray;
    
    float followDelay;
    bool useDelayedFollow;
    bool gameHasBegun;
    
    int numberOfCoinsInLevel;
    int coinsCollected;
    int maxLevels;
    
    SKLabelNode *coinLabel;
    
    CMMotionManager *_motionManager;
    
    HUDWindUpViewController* windUpVC;
}

@end




@implementation CSLevel



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            isDevicePhone = YES;
        } else {
            
            isDevicePhone = NO;
        }
        
         NSLog(@"Scene Width %f", self.scene.size.width);
         NSLog(@"Scene Height %f", self.scene.size.height);
        
        checkForDifferentPhoneLocations = NO;
        gameHasBegun = NO;
        
        currentLevel = levelCount; // Later on, we will create a singleton to hold game data that is independent of this class.
        charactersInWorld = 0;
        coinsCollected = 0;
        
        NSLog(@"The level is %i", currentLevel);
        
        [self setUpScene];

        [self performSelector:@selector(setUpCharacters) withObject:nil afterDelay:0.5];
        
        
    }
    return self;
}

/*
//test the physics
-(void)moveCoinsWithImpulse {
    
    [myWorld enumerateChildNodesWithName:@"coin" usingBlock:^(SKNode *node, BOOL *stop) {
        
        [node.physicsBody applyImpulse: CGVectorMake(30, 30)];
        
    }];
    
    [self performSelector:@selector(moveCoinsWithImpulse) withObject:nil afterDelay:10.0];
}



-(void)moveCoinsWithForce {
    
     [myWorld enumerateChildNodesWithName:@"coin" usingBlock:^(SKNode *node, BOOL *stop) {
    
         [node.physicsBody applyForce: CGVectorMake(-1, -1)];
         
    }];
    
    [self performSelector:@selector(moveCoinsWithForce) withObject:nil afterDelay:1/60];
}
*/

-(void) pauseScene {
    self.paused = YES;
    
}
-(void) unPauseScene {
    
    self.paused = NO;
}


#pragma mark SetUp Scene

-(void) setUpScene {
    // take care of setting up the world and bring in the property list
    
    #pragma mark - Setup the Accelerometer to move the character
    _motionManager = [[CMMotionManager alloc] init];
    
    
    NSString* path = [[ NSBundle mainBundle] bundlePath];
    NSString* finalPath = [ path stringByAppendingPathComponent:@"GameData.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
     //NSLog(@"The Property List contains: %@", plistData);
    
    
    NSMutableArray* levelArray = [NSMutableArray arrayWithArray:[plistData objectForKey:@"Levels"]];
    NSDictionary* levelDict = [NSDictionary dictionaryWithDictionary:[levelArray objectAtIndex:currentLevel]];
    characterArray = [NSArray arrayWithArray:[levelDict objectForKey:@"Characters"]];
    
    playersArray = [NSArray arrayWithArray:[levelDict objectForKey:@"Players"]];
    
    maxLevels = [levelArray count];
    
    //NSLog(@"The Property List contains: %@", characterArray);
    
    checkForDifferentPhoneLocations = [[levelDict objectForKey:@"CheckForDifferentPhoneLocations"] boolValue];
    
    if ( isDevicePhone == NO){
        
        checkForDifferentPhoneLocations = NO;
    }
    
    
    levelBorderCausesDamageBy = [[levelDict objectForKey:@"LevelBorderCausesDamageBy"] intValue];
    followDelay = [[levelDict objectForKey:@"FollowDelay"] floatValue];
    useDelayedFollow = [[levelDict objectForKey:@"UseDelayedFollow"] boolValue];
    
    self.anchorPoint = CGPointMake(0.5, 0.5); //0,0 to 1,1
    myWorld = [SKNode node];
    [self addChild:myWorld];
    
    
    SKNode* instructionNode = [SKNode node];
    instructionNode.name = @"instructions";
    [myWorld addChild:instructionNode];
    instructionNode.position = CGPointMake(0, 0);
    instructionNode.zPosition = 50;
    
    SKLabelNode *label1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label1.text = @"Swipe to Move, Rotate to Stop";
    label1.fontSize = 22;
    label1.position = CGPointMake(0 , 50);
    
    SKLabelNode *label2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label2.text = @"Touch with 2 or 3 Fingers to Swap Leaders";
    label2.fontSize = 22;
    label2.position = CGPointMake(0 , -50);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        label1.fontSize = 15;
        label2.fontSize = 15;
    }
    
    
    [instructionNode addChild:label1];
    [instructionNode addChild:label2];
    
    coinLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    coinLabel.text = @"Coins:";
    coinLabel.fontSize = 22;
    coinLabel.zPosition = 1001;
    coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [myWorld addChild:coinLabel];
    
    
    
    
    SKSpriteNode* map = [SKSpriteNode spriteNodeWithImageNamed:[levelDict objectForKey:@"Background"]];
    map.position = CGPointMake(0, 0.0);
    [myWorld addChild:map];
    
    // Setup Physics
    
    float shrinkage = [[ levelDict objectForKey:@"ShrinkBackgroundBoundaryBy"]floatValue ];
    
    int offsetX = (map.frame.size.width - (map.frame.size.width * shrinkage)) / 2;
    int offsetY = (map.frame.size.height - (map.frame.size.height * shrinkage)) / 2;
    
    CGRect mapWithSmallerRect = CGRectMake(map.frame.origin.x + offsetX, map.frame.origin.y + offsetY, map.frame.size.width * shrinkage, map.frame.size.height * shrinkage);
    
    
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    myWorld.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:mapWithSmallerRect];
    myWorld.physicsBody.categoryBitMask = wallCategory;
    
    if ( [[levelDict objectForKey:@"DebugBorder"] boolValue]  == YES) {
        
        [self debugPath:mapWithSmallerRect];
        
        
    }
    

    NSArray* coinArray = [NSArray arrayWithArray:[levelDict objectForKey:@"Coins"]];
    [self setUpCoins:coinArray];
    
    [self setupTerrain];
    [self setupInterestPoints];
    
    //setup to handle accelerometer readings using CoreMotion Framework
    [self startMonitoringAcceleration];
}


-(void) debugPath:(CGRect)theRect {
    
    SKShapeNode*  pathShape = [[SKShapeNode alloc] init];
    CGPathRef thePath = CGPathCreateWithRect( theRect, NULL);
    pathShape.path = thePath;
    
    pathShape.lineWidth = 1;
    pathShape.strokeColor = [SKColor greenColor];
    pathShape.position = CGPointMake( 0, 0);
    
    [myWorld addChild:pathShape];
    pathShape.zPosition = 1000;
    
}



-(void) fadeToDeath:(SKNode*) node {
    
    SKAction* fade = [SKAction fadeAlphaTo:0 duration:10];
    SKAction* remove = [SKAction performSelector:@selector(removeFromParent) onTarget:node];
    SKAction* sequence = [SKAction sequence:@[ fade, remove ]];
    [node runAction:sequence];
    
}

-(void) showWindUpInterfaceOverToy:(TKToy *)toyNode
{
    windUpVC = [[HUDWindUpViewController alloc] init];
    [windUpVC linkToy:toyNode andKey:masterKey];
    [self.view addSubview:windUpVC.view];
    [windUpVC setWindUpRadians:toyNode.rotations*(M_PI*2)];
}
-(void) hideWindUpInterface
{
    
}


-(void) setupTerrain
{
    
}
-(void) setupInterestPoints
{
    //setup player bases
    playerAbase = [SKSpriteNode spriteNodeWithColor:[UIColor lightGrayColor] size:CGSizeMake(100.0, 100.0)];
    playerAbase.position = CGPointMake(400.0, 800.0);
    [myWorld addChild:playerAbase];
}


#pragma mark SetUp Characters

-(void) setUpCharacters {
    

    
    [self fadeToDeath:[myWorld childNodeWithName:@"instructions"]];
    
    /*
    leader = [CSCharacter node];
    leader.checkForDifferentPhoneLocations = checkForDifferentPhoneLocations;
    [leader createWithDictionary:[characterArray objectAtIndex:0] ];
    [leader makeLeader];
    
    [myWorld addChild:leader];
     */
    
    masterKey = [TKMasterKey node];
    masterKey.checkForDifferentPhoneLocations = checkForDifferentPhoneLocations;
    [masterKey createWithDictionary:[playersArray objectAtIndex:0] ];
    [masterKey setBasePointAtTarget:playerAbase];
    masterKey.position = masterKey.basePoint;
    [myWorld addChild:masterKey];
    
    int c = 0;
    
    while (c < [characterArray count] ){
        [self createAnotherCharacter];
        //[self performSelector:@selector(createAnotherCharacter) withObject:nil afterDelay:(0.5 * c)];
        c++;
    }
    
 
}

-(void) createAnotherCharacter {
    
    
    TKToy* character = [TKToy node];
    [character setupKeyInterface];
    [character setupAutoActions:nil];
    
    character.checkForDifferentPhoneLocations = checkForDifferentPhoneLocations;
    [character createWithDictionary:[characterArray objectAtIndex:charactersInWorld] ];
    [myWorld addChild:character];
    
    charactersInWorld ++;
    
    character.zPosition = character.zPosition - charactersInWorld;
    
    
    
}

#pragma mark SetUp Characters

-(void) setUpCoins:(NSArray*)theArray {

    
    numberOfCoinsInLevel = [theArray count];
    
    NSLog(@"Number of coins to collect this level %i", numberOfCoinsInLevel);
    
    int c = 0;
    
    while ( c < [theArray count] ) {
        
        NSDictionary* coinDict = [NSDictionary dictionaryWithDictionary:[theArray objectAtIndex:c]];
        NSString* baseString = [NSString stringWithString:[coinDict objectForKey:@"BaseFrame"]];
        CGPoint coinLocation;
        
        if ( checkForDifferentPhoneLocations == YES) {
            
            if ( [coinDict objectForKey:@"StartLocationPhone"] != nil ) {
                NSLog(@" YES, alternate location for coin");
               coinLocation = CGPointFromString( [coinDict objectForKey:@"StartLocationPhone"]  );
                
            } else {
                NSLog(@" NO alternate location for coin");
                 coinLocation = CGPointFromString( [coinDict objectForKey:@"StartLocation"]  );
            }
            
        } else {
             coinLocation = CGPointFromString( [coinDict objectForKey:@"StartLocation"]  );
            
        }
        
        
        CSCoin* newCoin = [CSCoin node];
        [newCoin createWithBaseImage:baseString andLocation:coinLocation ];
        [myWorld addChild:newCoin];
        
        c++;
    }
    
    
}
    
#pragma mark Update


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    __block bool anyNonLeaderFoundInPlay = NO;
    __block bool leaderFound = NO;
    
    if (!masterKey.isAttachedToToy) {
        [masterKey moveFromMotionManager:_motionManager.accelerometerData];
    }
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        // do something if we find a character inside of myWorld
        TKToy* toy = (TKToy*)node;
        
        //TODO trigger actions on eligible targets
        //TODO trigger actions by type
        
        SKSpriteNode *triggerObject = (SKSpriteNode*)masterKey;
        SKSpriteNode *actionRange = (SKSpriteNode *)[toy childNodeWithName:@"actionRange"];
        SKSpriteNode *actionObject = (SKSpriteNode *)[actionRange childNodeWithName:@"actionObject"];
        
        if ([actionRange intersectsNode:triggerObject]){
            double now = CACurrentMediaTime();
            [toy triggerPhysicalAttackToTarget:triggerObject WithNode:actionObject atTime:now];
        }
        
        //[toy enumerateChildNodesWithName:@"actionRange" usingBlock:^(SKNode *node, BOOL *stop) {}];
        
        //if toy is within contact range of master key, attach them
        if ([masterKey.toyContactRange intersectsNode:toy.keyContactRange] && !masterKey.isAttachedToToy)
        {
            [masterKey attachToToy:(TKToy*)node];
            [self showWindUpInterfaceOverToy:(TKToy*)node];
        }
        
        /*
        if (self.paused == NO) {
        
            if (character == leader) {

                if (leader.isDying == NO){
                    leaderFound = YES;
                }
                
                
            } else if (character.followingEnabled == YES) {
                
                anyNonLeaderFoundInPlay = YES;
                character.idealX = leader.position.x;
                character.idealY = leader.position.y;
                
            }
            
        
            [character update];
            
        }
        */
        
    }];
    
    
    [myWorld enumerateChildNodesWithName:@"//actionObject" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node intersectsNode:masterKey.toyContactRange])
             {
                 [masterKey triggerKeyWasHitWithNode:(SKSpriteNode*)node];
             }
    }];
    
    
    //outside of the enumeration block, we then test for a leader or follower being found....
    
    if ( leaderFound == NO && gameHasBegun == YES) {
        
        
        
        if (anyNonLeaderFoundInPlay == YES) {
        
            NSLog(@"Leader not found, assigning new one");
            
             [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
                 CSCharacter* character = (CSCharacter*)node;
                 if (character.followingEnabled == YES) {
                     leader = character;
                     [leader makeLeader];
                     [myWorld insertChild:leader atIndex:0];
                 }
        
            }];
        } else {
            
            NSLog(@"game over");
            gameHasBegun = NO;
            [self gameOver];
            
        }
        
    }
    
    
}


#pragma mark Contact Listener

-(void) didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody, *secondBody;
    
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    
    ////WALLS
    
    if (firstBody.categoryBitMask == wallCategory || secondBody.categoryBitMask == wallCategory ) {
        
        if (firstBody.categoryBitMask == playerCategory) {
            CSCharacter* character = (CSCharacter*) firstBody.node;
            
            [self stopAllPlayersFromCollision:character];
            [character doDamageWithAmount:levelBorderCausesDamageBy];
            
        } else if (secondBody.categoryBitMask == playerCategory) {
            CSCharacter* character = (CSCharacter*) secondBody.node;
            
            [self stopAllPlayersFromCollision:character];
            [character doDamageWithAmount:levelBorderCausesDamageBy];
        }
        
        
    }
    
    
    if (firstBody.categoryBitMask == coinCategory || secondBody.categoryBitMask == coinCategory ) {
        
        if (firstBody.categoryBitMask == coinCategory) {
            CSCoin* coin = (CSCoin*) firstBody.node;
           
            [self testCoinCount];
            [coin removeFromParent];
            
            
        } else if (secondBody.categoryBitMask == coinCategory) {
            CSCoin* coin = (CSCoin*) secondBody.node;
           
           [self testCoinCount];
           [coin removeFromParent];
        }
        
        
    }
    
    //OTHER PLAYERS
    
     if (firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == playerCategory ) {
         
         CSCharacter* character = (CSCharacter*) firstBody.node;
         CSCharacter* character2 = (CSCharacter*) secondBody.node;
         
         if (character == leader) {
             NSLog(@"character is leader");
             
             
             
         } else if (character2 == leader) {
             NSLog(@"character2 is leader");
         }
         
         /*
         if (character == leader) {
             
             if (character2.followingEnabled == NO) {
                 
                 character2.followingEnabled = YES;
                 [character2 followIntoPositionWithDirection:[leader returnDirection] andPlaceInLine:1 leaderLocation:leader.position];
                 
             }
             
             
         } else if ( character2 == leader) {
             
             if (character.followingEnabled == NO) {
                 
                 character.followingEnabled = YES;
                 [character followIntoPositionWithDirection:[leader returnDirection] andPlaceInLine:1 leaderLocation:leader.position];
                 
             }
             
         }
         */
         
     }
    
    
}


#pragma mark Gestures

-(void) didMoveToView:(SKView *)view {
    
    /*
    swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer:swipeGestureLeft];
    
    
    swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer:swipeGestureRight];
    
    
    swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
    [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [view addGestureRecognizer:swipeGestureUp];
    
    
    swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [view addGestureRecognizer:swipeGestureDown];
    
    tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnce:)];
    tapOnce.numberOfTapsRequired = 1;
    tapOnce.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:tapOnce];
    
    twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSwitchToSecond:)];
    twoFingerTap.numberOfTapsRequired = 1;
    twoFingerTap.numberOfTouchesRequired = 2;
    [view addGestureRecognizer:twoFingerTap];
    
    threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSwitchToThird:)];
    threeFingerTap.numberOfTapsRequired = 1;
    threeFingerTap.numberOfTouchesRequired = 3;
    [view addGestureRecognizer:threeFingerTap];
    
    
    rotationGR = [[ UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [view  addGestureRecognizer:rotationGR];
    */

    
}

-(void) handleSwipeLeft:(UISwipeGestureRecognizer *) recognizer {
    
   
    
    __block unsigned char place = 0;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        gameHasBegun = YES;
        
        CSCharacter* character = (CSCharacter*)node;
        
        if (character == leader) {
            [character moveLeftWithPlace: [NSNumber numberWithInt:0] ];
        } else {
           if (useDelayedFollow == YES) {
               
            [character performSelector:@selector(moveLeftWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:place * followDelay];
        
           } else {
               
               [character followIntoPositionWithDirection:left andPlaceInLine:place leaderLocation:leader.position];
           }
        }
        
        place ++;
        
    }];
    
    
}

-(void) handleSwipeRight:(UISwipeGestureRecognizer *) recognizer {
    
   
    __block unsigned char place = 0;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        gameHasBegun = YES;
        
        CSCharacter* character = (CSCharacter*)node;
        
        if (character == leader) {
            [character moveRightWithPlace: [NSNumber numberWithInt:0] ];
        } else {
            
             if (useDelayedFollow == YES) {
            
            [character performSelector:@selector(moveRightWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:place * followDelay];
             
             }else {
                 
                  [character followIntoPositionWithDirection:right andPlaceInLine:place leaderLocation:leader.position];
             }
        }
        
        place ++;
        
    }];
    
}


-(void) handleSwipeUp:(UISwipeGestureRecognizer *) recognizer {
    
   
    
    
    __block unsigned char place = 0;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        gameHasBegun = YES;
        
        CSCharacter* character = (CSCharacter*)node;
        
        if (character == leader) {
            [character moveUpWithPlace: [NSNumber numberWithInt:0] ];
        } else {
           
             if (useDelayedFollow == YES) {
             [character performSelector:@selector(moveUpWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:place * followDelay];
             } else {
                 
                  [character followIntoPositionWithDirection:up andPlaceInLine:place leaderLocation:leader.position];
             }
        }
        
        place ++;
        
    }];
    
}


-(void) handleSwipeDown:(UISwipeGestureRecognizer *) recognizer {
    
    
    __block unsigned char place = 0;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        gameHasBegun = YES;

        
        CSCharacter* character = (CSCharacter*)node;
        
        if (character == leader) {
            [character moveDownWithPlace: [NSNumber numberWithInt:0] ];
        } else {
            
            if (useDelayedFollow == YES) {
            
            [character performSelector:@selector(moveDownWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:place * followDelay];
           
            } else {
                
                 [character followIntoPositionWithDirection:down andPlaceInLine:place leaderLocation:leader.position];
            }
        }
        
        place ++;
        
    }];
}




-(void) tappedOnce:(UITapGestureRecognizer *) recognizer {
    
   // NSLog(@"one finger tap");
    
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        CSCharacter* character = (CSCharacter*)node;
        [character attack];
       
        
    }];
    
}

-(void) tapToSwitchToSecond:(UITapGestureRecognizer *) recognizer {
    
    NSLog(@"two finger tap");
    [self switchOrder:2];
    
}



-(void) tapToSwitchToThird:(UITapGestureRecognizer *) recognizer {
    
    NSLog(@"three finger tap");
    [self switchOrder:3];
    
}

#pragma mark Switch Leaders

-(void) switchOrder:(int) cycle {
    
    __block unsigned char i = 1;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        CSCharacter* character = (CSCharacter*)node;
        [character stopMoving];
        if (character != leader && i < cycle) {
            
            if (character.followingEnabled == YES) {
                
                NSLog(@"switch occuring");
                i++;
                leader.theLeader = NO;
                leader.followingEnabled = YES; 
                leader = nil;
                leader = character;
                leader.theLeader = YES;
                [leader makeLeader];
                [myWorld insertChild:leader atIndex:0];
                
            }
    
        }
        
    }];
    
}



#pragma mark STOP ALL CHARACTERS

-(void) handleRotation:(UIRotationGestureRecognizer *) recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"Rotation ended");
        [self stopAllPlayersAndPutIntoLine];
        
    }
    
    
}


-(void) stopAllPlayersAndPutIntoLine {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
   
    __block unsigned char leaderDirection;
    __block unsigned char place = 0;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        CSCharacter* character = (CSCharacter*)node;
        
        if (character == leader) {
          
            leaderDirection = [leader returnDirection];
            
            [leader stopMoving];
          
        } else if (character.followingEnabled == YES) {
           
            [character stopInFormation:leaderDirection andPlaceInLine:place leaderLocation:leader.position];
            
            // for place in line, 1 is the first follower, 2 is the second follower (0 is the leader)
            
        }
        
        place ++;
        
    }];

    
    
}

-(void) stopAllPlayersFromCollision:(SKNode*) damagedNode {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        
        CSCharacter* character = (CSCharacter*)node;
        
        if (character == damagedNode) {
            
            [character stopMovingFromWallHit];
            
        } else {
            
            [character stopMoving];
        }
    
        

    }];
    
}

#pragma mark Scene moved from view


-(void) willMoveFromView:(SKView *)view {
    
    NSLog(@"Scene moved from view");
    
    [view removeGestureRecognizer: swipeGestureLeft ];
    [view removeGestureRecognizer: swipeGestureRight];
    [view removeGestureRecognizer: swipeGestureUp];
    [view removeGestureRecognizer: swipeGestureDown];
    [view removeGestureRecognizer: tapOnce];
    [view removeGestureRecognizer: twoFingerTap];
    [view removeGestureRecognizer: threeFingerTap];
    [view removeGestureRecognizer: rotationGR];
}


#pragma mark Camera Centering

- (void)didSimulatePhysics
{
    
    [self centerOnNode: masterKey];
    
}

- (void) centerOnNode: (SKNode *) node
{
    
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y);
    
   
    
     //coinLabel.position = CGPointMake( (leader.position.x - (self.scene.size.width / 2)) + 40, leader.position.y + (self.scene.size.height /2) -30);
}

#pragma mark GAME OVER MAN

-(void) gameOver {
    
    [self stopMonitoringAcceleration];
    [myWorld enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        
        [node removeFromParent];
        
    }];
    
    [myWorld removeFromParent];
    
    
    SKScene *nextScene = [[CSStartMenu alloc ] initWithSize:self.size ];
    SKTransition *fade = [SKTransition fadeWithColor:[SKColor blackColor] duration:1.5];
    [self.view presentScene:nextScene transition:fade]; 
    
}

#pragma mark ADVANCE LEVEL 

-(void)testCoinCount{
    
     coinsCollected ++;
    
    coinLabel.text = [NSString stringWithFormat:@"Coins: %i", coinsCollected];
    
    if (coinsCollected == numberOfCoinsInLevel){

        [self advanceLevel];
    }
    
}

-(void) advanceLevel {
    
    levelCount ++;
    
    if(levelCount >= maxLevels) {
        NSLog(@"resetting levels to 0");
        levelCount = 0;
    }
    
    self.paused = YES;
    gameHasBegun = NO;
    SKScene *nextScene = [[CSLevel alloc] initWithSize:self.size ];
    SKTransition *fade = [SKTransition fadeWithColor:[SKColor blackColor] duration:1.5];
    [self.view presentScene:nextScene transition:fade];
    
}

#pragma mark accelerometer input

- (void)startMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}



@end
