//
//  SceneData.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 27/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PusherData.h"
#import "BlockData.h"

//=========================================================================================================================================
#define PATH_PNTS   50
#define GRID_XSIZE  30
#define GRID_YSIZE  30

//==============================================================================================================================================================
// Tipos de celdas que pueden haber
enum Cell
  {
  cPiso   = 0x00,
  cPared  = 0xA0,
  cBloque = 0x50,
  cTarget = 0x10,
  cPusher = 0xF0,
  };


//=========================================================================================================================================
// Clase para mantener y manejar los datos necesarios para dibujar una escena
@interface SceneBasicData : NSObject

+ (NSDictionary *)  OpenSceneFile: (NSString*) fName;
+ (SceneBasicData*) LoadName:(NSString*) fName;
+ (SceneBasicData*) LoadNum:(int) Num;
+ (BOOL)            DrawInContext:  (CGContextRef) ct Rect:(CGRect) rc Scene:(int) idx;
+ (void)            DrawImage:      (NSString*) sImage AtRect:(CGRect) rc;
+ (void)            DrawCacheImage: (NSString*) sImage AtRect:(CGRect) rc;

  @property int zCell;
  @property int Width;
  @property int Height;
  @property int xOff;
  @property int yOff;
  @property int Cols;
  @property int Rows;

  @property (copy,   nonatomic) NSString*   ImgFondo;
  @property (strong, nonatomic) PusherData* Pusher;

  @property (strong, nonatomic) NSMutableArray* Blocks;

// Funciones para convercion de coodenadas
  -(CGFloat) XCol: (int) col;
  -(CGFloat) YRow: (int) row;
  -(CGFloat) XMCol:(int) col;
  -(CGFloat) YMRow:(int) row;
  -(int)     ColX:(double) x;
  -(int)     RowY:(double) y;

  -(int)     DistCels:(double) pnts;
  -(CGFloat) DistPnts:(int)    cels;
  -(void)    OffsetsView:(UIView*) Zone;

@end

//=========================================================================================================================================
// Clase para mantener y manejar los datos de una escena
@interface SceneData : SceneBasicData

  @property int Moves;

  @property (copy,   nonatomic) NSString*   FileName;
  @property (copy,   nonatomic) NSString*   ImgFill;
  @property (weak,   nonatomic) UIView*     GameZone;

  +(BOOL) LoadName:(NSString*) fName Game:(UIView*) gZone Push:(UIImageView*) push;
  +(BOOL) LoadNum:(int) idxScene Game:(UIView*) gZone Push:(UIImageView*) push;

  -(BlockData*) BlockInCol:(int) col Row:(int) row;
  -(BOOL) AllBlockInTarget;
  -(BOOL) LoadSolution;  

// Funciones para manejo de las celdas
  -(BOOL) IsParedCol:(int) col Row:(int) row;
  -(BOOL) IsPisoCol: (int) col Row:(int) row;
  -(BOOL) IsBlockCol:(int) col Row:(int) row;
  -(BOOL) IsTagetCol:(int) col Row:(int) row;

  -(Byte) GetValCol: (int) col Row:(int) row;
  -(Byte) GetTipoCol:(int) col Row:(int) row;
  -(Byte) GetInfoCol:(int) col Row:(int) row;

  -(void) SetVal: (Byte) val Col:(int) col Row:(int) row;
//  -(void) SetInfo:(Byte) inf Col:(int) col Row:(int) row;

// Funciones para manejo de bloques
  -(int)         nBlocks;
  -(BlockData *) BlockAt:(int)Idx;

@end

//=========================================================================================================================================

extern SceneData* Scene;                 // Variable global, tener acceso a la escena actual desde cualquier lugar de la aplicacción

//=========================================================================================================================================
// Funciones para manejar de los valores de las celdas

#define IsValPared( v ) ((v)>=cPared)                       // Celdas que se comportan como pared   (no se puede pasar sobre ellas)
#define IsValPiso(  v ) ((v)<cBloque)                       // Celdas que se comportan como piso    (se puede pasar sobre ellas)
#define IsValBlock( v ) (!IsValPared(v) && !IsValPiso(v) )  // Celdas que se comportan como bloques (no se pueden pasar, pero se pueden mover)
#define IsValTaget( v ) (((v)&0xf0)==cTarget )              // Celdas que se comportan como Target  (Tipo especial de piso donde van los bloques) 

#define GetValTipo( v  ) ( (v)&0xf0 )                       // Obtiene el identificador del tipo de celda
#define GetValInfo( v  ) ( (v)&0x0f )                       // Obtiene el información asociado a un tipo celda determinado

#define SetValInfo( v,inf ) (( ((v)&0xf0) | ((Byte)(inf)) ))  // Obtiene el información asociado a un tipo celda determinado

//=========================================================================================================================================


