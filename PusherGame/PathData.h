//
//  PathData.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 30/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockData.h"

//=========================================================================================================================================
// Sentido de los segmentos de restas usados en PusherPath
enum SegmSent
  {
  Indef = 0,
  Horz  = 1,
  Vert  = 2,
  };

@class PathPnt;

//=========================================================================================================================================

@interface PathData : NSObject

  @property int idxAnim;
  @property CGPoint Delta;

  +(void) Start;
  
  -(void) Clear;
  -(int) nPoints;
  -(PathPnt*) PointAt:(int) idx;
  -(PathPnt*) LastPnt;
  -(void) SetRefPnt:(CGPoint) pnt;
  -(BOOL) AddPnt:(CGPoint) pnt;
  -(BlockData *) BlockAt:(int) idx;
  -(BOOL) AddPathPnt:(PathPnt *) pnt;

@end

//=========================================================================================================================================

extern PathData* Path;                                  // Variable global, al camino por donde se desplaza el pusher
extern double    PathSpeed;

//=========================================================================================================================================
// Almacena los datos asociados a un punto del camino del pusher
@interface PathPnt : NSObject

  @property CGPoint pnt;                                                 // Posición en coordenadas graficas
  @property int     Sent;                                                // Sentido del segmento Horizontal, Vertical e Indefinido
  @property int     Sgn;                                                 // Signo del recorrido (1) Abajo/Derecha (-1) Arriba/Izquierda  
  @property int     Col;                                                 // Posición en coordenadas de escena (fila/columna)
  @property int     Row;
  @property bool    Bck;                                                 // Indica si se empuja un bloque o no
    
  +(PathPnt*) PntWithCol:(int) col Row:(int) row Sent:(int) sent Sign:(int) sgn Bck:(bool) bck;
  +(PathPnt*) FromString:(NSString*) sData;

  -(BOOL) ChangeCol:(int) col;
  -(BOOL) ChangeRow:(int) row;

  -(bool) IsVert;
  -(bool) IsHorz;
    
@end

//=========================================================================================================================================
