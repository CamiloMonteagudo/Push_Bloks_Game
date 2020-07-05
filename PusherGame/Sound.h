//
//  Player.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 06/06/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sound : NSObject

+(void) PrepareSoundsScene;
+(void) SoundsOn:(int) on;

+(void) PlayEndScene;
+(void) PlayOnTarget;
+(void) PlayWalking;
+(void) StopWalking;
+(void) PlayAddPathPoint;
+(void) PlayUndo;
+(void) PlayPushBlock;
+(void) StopPushBlock;

+(void) PlayBackground1;
+(void) PlayBackground2;
+(void) StopBackground1;
+(void) StopBackground2;

@end
