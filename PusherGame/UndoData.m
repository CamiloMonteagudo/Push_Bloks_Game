//
//  UndoData.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 31/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "UndoData.h"
#import "SceneData.h"
#import "Sound.h"

UndoData* Undo;                                  // Variable global, que contiene la lista de operaciones a deshacer

//=========================================================================================================================================
// Variables locales de PathData
@interface UndoData()
  @property (strong, nonatomic) NSMutableArray* Ops;
@end

//=========================================================================================================================================
// Maneja los puntos del camino que deber recorrer el pusher
@implementation UndoData
@synthesize Ops, Moves;

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicia por primera ves o limpia la lista de undo
+(void) Start
  {
  Undo = [UndoData alloc];                                           // Crea una lista vacia
  
  Undo.Ops   = [NSMutableArray array];                               // Le asocia un arreglo de operaciones vacias
  Undo.Moves = 0;                                                    // Pone la cantidad de movimientos a cero 
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Adiciona un nuevo punto a la lista de undo
-(void) AddPnt:(PathPnt *)pnt Block:(BlockData *) bck
  {
  UndoPnt* obj = [UndoPnt UndoWithPnt:pnt Block:bck];      
  [Ops addObject: obj ];
  
  int idx = (int)Ops.count-1;                                             // Optiene el ultimo elemento de la lista de undo
  if( idx > 0 )                                                           // Si no es el primer punto, calcula los movimientos
    {
    PathPnt* pt1 = ((UndoPnt*) Ops[idx  ]).Pnt;                           // Obtiene el punto inicial (el ultimo)
    PathPnt* pt2 = ((UndoPnt*) Ops[idx-1]).Pnt;                           // Obtiene el punto final   (el penultimo)
    
    int dx = pt2.Col-pt1.Col;                                             // Calcula desplazamiento hoizontal
    int dy = pt2.Row-pt1.Row;                                             // Calcula desplazamiento vertical   
    
    Moves += abs(dx) + abs(dy);                                           // Suma celdas recorridas
    }
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Deshace la ultima operacion registrada en le lista de undo
-(void) DoUndo
  {
  int idx = (int)Ops.count-1;                                             // Optiene el ultimo elemento de la lista de undo
  if( idx < 1 ) return;                                                   // No hace nada por no haber operaciones en la lista
  
  [Sound PlayUndo];
  PathPnt* pt1 = ((UndoPnt*) Ops[idx  ]).Pnt;                             // Obtiene el punto inicial (el ultimo)
  PathPnt* pt2 = ((UndoPnt*) Ops[idx-1]).Pnt;                             // Obtiene el punto final   (el penultimo)
    
  int dx = pt2.Col-pt1.Col;                                               // Calcula desplazamiento hoizontal
  int dy = pt2.Row-pt1.Row;                                               // Calcula desplazamiento vertical   
    
  float ang = [self GetAngleDx: dx Dy: dy ];                              // Calcula el angulo de rotación del pusher
  Scene.Pusher.Angle = ang;                                               // Rota el pusher al angulo indicado
    
  BlockData *Bck = ((UndoPnt*) Ops[idx]).Bck;                             // Obtiene bloque que se esta empujando
    
 [UIView animateWithDuration: abs(dx+dy)/PathSpeed                        // Determina tiempo de la inimación
                  animations:^{
                              if( Bck!=nil )                                      // Si se esta empujando un bloque
                                [Bck MoveCol: Bck.Col+dx Row: Bck.Row+dy];        // Realiza movimiento del bloque
                       
                              [Scene.Pusher MoveCol:pt2.Col Row:pt2.Row];         // Realiza movimiento del pusher
                              }
  ];
  
  [Ops removeLastObject];                                                 // Quita la operación de la lista de undo
  Moves -= (abs(dx) + abs(dy));                                           // Resta las celdas recorridas
  }

//---------------------------------------------------------------------------------------------------------------------------
-(float) GetAngleDx:(int) dx Dy:(int) dy
  {
  if( dy==0 ) return (dx>0)?   M_PI   : 0  ;
  else        return (dy>0)? 3*M_PI/2 : M_PI/2 ;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
@end

//=========================================================================================================================================
@implementation UndoPnt

//-----------------------------------------------------------------------------------------------------------------------------------------
+(UndoPnt*) UndoWithPnt:(PathPnt *)pnt Block:(BlockData *) bck
  {
  UndoPnt* obj = [UndoPnt alloc];
    
  obj.Pnt = pnt;
  obj.Bck = bck;  
  
  return obj;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
@end

//=========================================================================================================================================
