//
//  AppDelegate.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 18/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalData.h"
#import "Sound.h"
#import "Purchases.h"

int LastSound = -1;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
  {
#ifdef FREE_TO_PLAY
  [Purchases CreateAppPurshases];
#endif
  return YES;
  }
							
- (void)applicationWillResignActive:(UIApplication *)application
  {
  if( SceneCrono ) [SceneCrono Pause];
  [AppData Save];
  
  LastSound = AppData.Sound;
  [Sound SoundsOn: 0];
  }

- (void)applicationDidEnterBackground:(UIApplication *)application
  {
  }

- (void)applicationWillEnterForeground:(UIApplication *)application
  {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

- (void)applicationDidBecomeActive:(UIApplication *)application
  {
  if( SceneCrono ) [SceneCrono Restore];
  
  if( LastSound == -1 ) LastSound = AppData.Sound;
  
  [Sound SoundsOn: LastSound];
  }

- (void)applicationWillTerminate:(UIApplication *)application
  {
  [AppData Save];
  }

@end
