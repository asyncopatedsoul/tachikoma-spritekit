//
//  TKDreamMachine.m
//  Quest
//
//  Created by Michael Garrido on 1/12/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import "TKDreamMachine.h"
#import "CSLevel.h"

@implementation TKDreamMachine


- (void) setSpawnTimer
{
    
    
}
- (void) spawnToy
{
    //deduct selected toy windUp cost from rotations
    self.rotations-=self.selectedToyCost;
    
    //create toy
    TKToy* newToy = [TKToy node];
    [newToy setupKeyInterface];
    //[newToy setupAutoActions:nil];
    //newToy.checkForDifferentPhoneLocations = checkForDifferentPhoneLocations;
    [newToy createWithDictionary:self.selectedToyTemplate ];
    
    CSLevel* parentScene = (CSLevel*) self.scene;
    [parentScene addToy:newToy];
    
    //animate spawning
    
    //if ground unit, spawn with gravity
}
- (void) selectToyToSpawn: (int)toyId
{
    NSString* path = [[ NSBundle mainBundle] bundlePath];
    NSString* finalPath = [ path stringByAppendingPathComponent:@"GameData.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    //update UI state to show toy is selected
    
    //set template
    self.selectedToyTemplate = [(NSArray*)[plistData objectForKey:@"toyTemplates"] objectAtIndex:toyId];
    
    //set spawn point
    self.spawnPoint = CGPointMake(0.0, -100.0);
    [self.selectedToyTemplate setValue:[NSString stringWithFormat:@"{ %f,%f }",self.spawnPoint.x,self.spawnPoint.y] forKey:@"StartLocation"];
    
    //set cost
    self.selectedToyCost = [[self.selectedToyTemplate objectForKey:@"SpawnCost"] floatValue];
}

@end
