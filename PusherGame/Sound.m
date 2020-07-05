//
//  Player.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 06/06/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "Sound.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import "GlobalData.h"
#import "PathData.h"

AVAudioPlayer* playerEnScene;
AVAudioPlayer* playerOnTarget;
AVAudioPlayer* playerWalking;
AVAudioPlayer* playerPathPnt;
AVAudioPlayer* playerUndo;
AVAudioPlayer* playerPushBlock;
AVAudioPlayer* playerBackground1;
AVAudioPlayer* playerBackground2;

int BackGrndSnd = 0;                            // Dice cual de los background esta activo

AVAudioSession* Session;

//=========================================================================================================================================
@implementation Sound

//-----------------------------------------------------------------------------------------------------------------------------------------
// Prepra los sonidos para cuando se vayan a utilizar, la carga sea mas rápida
+(void) PrepareSoundsScene
  {
  if( playerOnTarget  == nil ) playerOnTarget  = [Sound FromFile:@"_OnTarget"];
  if( playerPathPnt   == nil ) playerPathPnt   = [Sound FromFile:@"_PathPnt"];
  if( playerUndo      == nil ) playerUndo      = [Sound FromFile:@"_OnUndo"];
  if( playerPushBlock == nil ) playerPushBlock = [Sound FromFile:@"_MoveBlock"];
  
  if( playerOnTarget  != nil ) [playerOnTarget  prepareToPlay];
  if( playerPathPnt   != nil ) [playerPathPnt   prepareToPlay]; 
  if( playerUndo      != nil ) [playerUndo      prepareToPlay];
  if( playerPushBlock != nil ) [playerPushBlock prepareToPlay];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Activa o desactiva el audio para todo la apiacación
+(void) SoundsOn:(int) on
  {
  if( !Session )
    {
    Session = [AVAudioSession sharedInstance];
    [Session setCategory: AVAudioSessionCategoryAmbient error: nil];
    }
	
  if( on )
    {
    AppData.Sound = 1;
  
    if( BackGrndSnd==1 ) [Sound PlayBackground1];
    if( BackGrndSnd==2 ) [Sound PlayBackground2];
    }
  else
    {
    if( playerEnScene     != nil ) [playerEnScene     pause];
    if( playerOnTarget    != nil ) [playerOnTarget    pause];
    if( playerWalking     != nil ) [playerWalking     pause];
    if( playerPathPnt     != nil ) [playerPathPnt     pause];
    if( playerUndo        != nil ) [playerUndo        pause];
    if( playerPushBlock   != nil ) [playerPushBlock   pause];
    if( playerBackground1 != nil ) [playerBackground1 pause];
    if( playerBackground2 != nil ) [playerBackground2 pause];
    
    AppData.Sound = 0;
    }
  
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Toca el sonido del final de la escena
+(void) PlayEndScene
  {
  if( AppData.Sound == 0 ) return;
  
  [Sound StopBackground2];
  if( playerEnScene == nil )	
    playerEnScene = [Sound FromFile:@"_EndScene"];
    
  [playerEnScene play];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Toca el sonido cuando un bloque llega a su target
+(void) PlayOnTarget
  {
  if( AppData.Sound == 0 || Session.otherAudioPlaying ) return;
  
  if( playerOnTarget == nil )
    playerOnTarget = [Sound FromFile:@"_OnTarget"];
  
  [playerOnTarget play];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Toca el sonido cuando se agrega un punto al camino
+(void) PlayAddPathPoint
  {
  if( AppData.Sound == 0 || Session.otherAudioPlaying ) return;
  
  if( playerPathPnt == nil )
    playerPathPnt = [Sound FromFile:@"_PathPant"];
  
  playerPathPnt.volume = 0.5;
  [playerPathPnt play];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Toca el sonido cuando se deshace un movimiento
+(void) PlayUndo
  {
  if( AppData.Sound == 0 || Session.otherAudioPlaying ) return;
  
  if( playerUndo == nil )
    playerUndo = [Sound FromFile:@"_OnUndo"];
  
  playerUndo.volume = 0.5;
  [playerUndo play];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Toca el sonido cuando se arrastra un bloque
+(void) PlayPushBlock
  {
  if( AppData.Sound == 0 || Session.otherAudioPlaying ) return;
  
  //[Sound StopWalking];
  if( playerPushBlock == nil )
    playerPushBlock = [Sound FromFile:@"_MoveBlock"];
  
  playerPushBlock.numberOfLoops = -100;
  [playerPushBlock play];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Para el sonido de arrastre del bloque
+(void) StopPushBlock
  {
  if( playerPushBlock != nil )
    [playerPushBlock pause];
  }

//--- --------------------------------------------------------------------------------------------------------------------------------------
// Comienza a tocar el sonido de cuando el pusher esta caminando
+(void) PlayWalking
  {
  if( AppData.Sound == 0 || Session.otherAudioPlaying ) return;
  
  if( playerWalking == nil )
    playerWalking = [Sound FromFile:@"_Pasos"];
  
  playerWalking.numberOfLoops = -1;
  [playerWalking play];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Termina el sonido del pusher cminando
+(void) StopWalking
  {
  if( playerWalking != nil ) [playerWalking pause];
  }

//--- --------------------------------------------------------------------------------------------------------------------------------------
// Comienza a tocar el sonido de fondo para las selección de las escenas
+(void) PlayBackground1
  {
  BackGrndSnd = 1;
  
  if( AppData.Sound == 0 || Session.otherAudioPlaying ) return;
  
  [Sound StopBackground2];
  if( playerBackground1 == nil )  
    playerBackground1 = [Sound FromFile:@"_Background1"];
  
  playerBackground1.numberOfLoops = -1;
  [playerBackground1 play];
  playerBackground1.volume = 0.5;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Termina el sonido de fondo para la selección de las escenas
+(void) StopBackground1
  {
  if( playerBackground1 != nil ) [playerBackground1 pause];
  }

//--- --------------------------------------------------------------------------------------------------------------------------------------
// Comienza a tocar el sonido de fondo para las selección de las escenas
+(void) PlayBackground2
  {
  BackGrndSnd = 2;
  if( AppData.Sound == 0 || Session.otherAudioPlaying ) return;
  
  [Sound StopBackground1];
  if( playerBackground2 == nil )  
    playerBackground2 = [Sound FromFile:@"_Background2"];
    
  playerBackground2.numberOfLoops = -1;
  [playerBackground2 play];
  playerBackground2.volume = 0.5;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Termina el sonido de fondo para la selección de las escenas
+(void) StopBackground2
  {
  if( playerBackground2 != nil ) [playerBackground2 pause];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga un fichero de audio, dado el nombre del fichero
+(AVAudioPlayer*) FromFile:(NSString*) Name
  {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:Name ofType:@"m4a"]];
    
  return [[AVAudioPlayer alloc] initWithContentsOfURL:url error: nil];
  }

@end

//=========================================================================================================================================
