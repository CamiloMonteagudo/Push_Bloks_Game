//
//  SocialData.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 09/07/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

//=========================================================================================================================================

@protocol FacebookErrorMsg
- (void) ShowMsg:(NSString*)Msg;
@end

//=========================================================================================================================================

@interface SocialData : NSObject <GKLeaderboardViewControllerDelegate>

+ (SocialData *) Default;

- (void) ShowTwitterUI:(UIViewController*) parent;
- (BOOL) IsTwitter;

- (void) FacebookLoginBtn:(UIView *) BtnFB Notify:(BOOL)notify;
- (void) ScoreNotifyFB:(UIView *) BtnFB GC:(UIView *) BtnGC;

- (void) initGameCenter:(UIViewController*) parent;
- (BOOL) IsGameCenter;
- (void) ShowLeaderBoard:(UIViewController*) parent;
- (void) NotifyAchievements:(long) Pnts;

@end

//=========================================================================================================================================

extern SocialData* Social;                  // Variable global, para tener acceso a la clase de social de la aplicación

//=========================================================================================================================================
