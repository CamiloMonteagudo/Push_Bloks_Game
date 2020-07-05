//
//  CronoTime.m
//  PusherGame
//
//  Created by Camilo Monteagudo Pena on 20/08/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "CronoTime.h"

@implementation CronoTime

//---------------------------------------------------------------------------------------------------------------------------------------------
// Inicia el conteo de tiempo de la escena y activa la actualización del tiempo trascurrido
- (void) SetUpdateSel:(SEL) uptFunc Class:(id) class
	{
  UpdateFunc = uptFunc;
  UpdateObj  = class;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Inicia el conteo de tiempo de la escena y activa la actualización del tiempo trascurrido
- (void) Start
	{
  if( ClockTimer!=nil ) [ClockTimer invalidate];
  
  ClockTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:UpdateObj selector:UpdateFunc userInfo:nil repeats:YES];
  TimeRef = [NSDate date];                                                            // Marca tiempo de inicio de la escena
  TimeSave = -1;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el tiempo trascurrido desde el inicio de la escena
- (double) GetTime
  {
  return -[TimeRef timeIntervalSinceNow ];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Para el conteo de tiempo
- (void) Stop
  {
  if( ClockTimer!=nil )
    {
    [ClockTimer invalidate];
    ClockTimer = nil;
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Detiene momentaneamente el conteo del tiempo
- (void) Pause
  {
  if( ClockTimer!=nil && TimeSave==-1 )
    {
    TimeSave = [self GetTime];
    [ClockTimer invalidate];
    ClockTimer = nil;
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Continua contando el tiempo a partir de momento que se llamo Pause
- (void) Restore
  {
  if( TimeSave == -1 ) return;
  
  double tmp = TimeSave;
  [self Start];
  
  TimeRef = [TimeRef dateByAddingTimeInterval:-tmp];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------

@end
