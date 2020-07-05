//
//  UndoData.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 31/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "PathData.h"

@class UndoPnt;

//=========================================================================================================================================
// Maneja la lista de movimientos del pusher que pueden deshacerse
@interface UndoData: NSObject

@property int Moves;

+(void) Start;
-(void) AddPnt:(PathPnt *)Pnt Block:(BlockData *) bck;
-(void) DoUndo;

@end

//=========================================================================================================================================

extern UndoData* Undo;                                  // Variable global, que contiene la lista de operaciones a deshacer

//=========================================================================================================================================
// Almacena los datos de un punto de undo
@interface UndoPnt : NSObject

@property (strong, nonatomic) PathPnt*   Pnt;
@property (strong, nonatomic) BlockData* Bck;

+(UndoPnt*) UndoWithPnt:(PathPnt *)pnt Block:(BlockData *) bck;

@end

//=========================================================================================================================================

