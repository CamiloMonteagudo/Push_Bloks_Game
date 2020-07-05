//
//  GlobalData.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 18/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//
#ifdef DEBUG
//#define SIMULATE_INTERNET    1
#endif

#import <Foundation/Foundation.h>
#import "CronoTime.h"
#import "ScenePages.h"

//=========================================================================================================================================
// Maneja los datos globales de la aplicación, las escenas, las propagandas, las compras, etc.
@interface GlobalData : NSObject <NSCoding>

#ifdef FREE_TO_PLAY
  @property (nonatomic) BOOL PurchaseNoAds;
  @property (nonatomic) BOOL PurchaseUnlock;
  @property (nonatomic) BOOL PurchaseSolLavel1;
  @property (nonatomic) BOOL PurchaseSolLavel2;
  @property (nonatomic) BOOL PurchaseSolLavel3;

  @property (nonatomic) BOOL ProcessNoAds;
  @property (nonatomic) BOOL ProcessUnlock;
  @property (nonatomic) BOOL ProcessSolLavel1;
  @property (nonatomic) BOOL ProcessSolLavel2;
  @property (nonatomic) BOOL ProcessSolLavel3;
#endif

  @property (nonatomic) int IdxScene;
  @property (nonatomic) int Zoom;
  @property (nonatomic) int Sound;
  @property (nonatomic) ScenePages* Pages;

+ (GlobalData *) Default;

- (BOOL) Save;

- (int) nScenes;

- (NSString*) NowPath;
- (NSString*) NowFondo;
- (int)       NowPuntos;

- (NSString*) PathAt:(int) idx;
- (NSString*) FondoAt:(int) idx;
- (int)       PuntosAt:(int) idx;
- (int)       StarsAt:(int) idx;
- (int)       GetStars:(int) puntos;

- (BOOL) isLockAt:(int) idx;
- (void) UnLockAll;

- (void) setNowPuntos:(int) puntos;
- (long) getTotalPnts;
- (NSString*) GetFullPath:(NSString*) fName;

@end

//=========================================================================================================================================

extern GlobalData* AppData;                 // Variable global, para tener acceso a los datos de la aplicación desde cualquier lugar
extern CronoTime*  SceneCrono;              // Variable global, para controlar el tiempo de juego por escena

//=========================================================================================================================================
