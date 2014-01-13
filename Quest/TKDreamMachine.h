//
//  TKDreamMachine.h
//  Quest
//
//  Created by Michael Garrido on 1/12/14.
//  Copyright (c) 2014 CartoonSmart. All rights reserved.
//

#import "TKToy.h"

@interface TKDreamMachine : TKToy

@property (nonatomic,assign) int selectedToyId;
@property  (nonatomic,assign) CGPoint spawnPoint;

- (void) setSpawnTimer;
- (void) spawnToy;
- (void) updateSpawnPoint: (CGPoint)newSpawnPoint;
- (void) selectToyToSpawn: (int)toyId;

@end
