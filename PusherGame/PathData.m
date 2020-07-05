//
//  PathData.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 30/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "PathData.h"
#import "SceneData.h"
#import "Sound.h"

PathData* Path;                                  // Variable global, al camino por donde se desplaza el pusher
double    PathSpeed = 3;                          // Velocidad que se recorre el camino en Celdas/segundo

//=========================================================================================================================================
// Variables locales de PathData
@interface PathData()
  {
  PathPnt* Last;
  }
  
  @property (strong, nonatomic) NSMutableArray* Points;
@end

//=========================================================================================================================================
// Maneja los puntos del camino que deber recorrer el pusher
@implementation PathData
@synthesize Points, idxAnim, Delta;

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicializa el trabajo con un camino para el pusher
+(void) Start
  {
  Path = [PathData alloc];                                              // Crea un camino vacio
    
  Path.Points  = [NSMutableArray array];                                // Crea un arreglo para los puntos
  
  int col = [Scene Pusher].Col;
  int row = [Scene Pusher].Row;
  
  PathPnt* p = [PathPnt PntWithCol:col Row:row Sent:Indef Sign:0 Bck:false];
  
  [Path.Points addObject:p];
  Path->Last  = p;
  Path->Delta = CGPointMake(0, 0);
  
  Path.idxAnim = 0;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Borra todos los puntos del camino
-(void) Clear
  { 
  [Points removeAllObjects];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el bloque asociado al punto 'idx' del perfil
-(BlockData *) BlockAt:(int) idx
  { 
  if( idx<1 || idx>=Points.count ) return nil;

  PathPnt* p1 = Points[idx-1];  
  PathPnt* p2 = Points[idx  ];  
  
  int col, row;
  if( p2.Sent == Horz )
    {
    col = p1.Col + p2.Sgn;
    row = p2.Row; 
    }
  else
    {
    col = p2.Col;
    row = p1.Row + p2.Sgn; 
    }  
  
  return [Scene BlockInCol:col Row:row];    
  }

//-----------------------------------------------------------------------------------------------------------------------------------------

-(int)      nPoints           { return (int)Points.count;     }         // Retorna el número de puntos del camino
-(PathPnt*) PointAt:(int) idx { return (PathPnt*)Points[idx]; }         // Retorna el punto con indice 'idx' del camino
-(PathPnt*) LastPnt           { return Last;                  }         // Retorna el ultimo punto del camino

//-----------------------------------------------------------------------------------------------------------------------------------------
// Establece un punto de referencia de comienzo de moviento del dedo, con repecto al ultimo punto del camino
-(void) SetRefPnt:(CGPoint) pnt 
  { 
  Delta = CGPointMake( pnt.x-Last.pnt.x, pnt.y-Last.pnt.y ); 
  } 

//-----------------------------------------------------------------------------------------------------------------------------------------
// Adiciona un nuevo punto al camino
-(BOOL) AddPathPnt:(PathPnt *) pnt
  {
  if( pnt.Row<0 || pnt.Row>=Scene.Rows  ) return false;               // Celda fuera del area de la escena por la vertical
  if( pnt.Col<0  || pnt.Col>=Scene.Cols ) return false;               // Celda fuera del area de la escena por la horizontal
  
  Byte Val = [Scene GetValCol:pnt.Col Row:pnt.Row];                   // Obtiene el contenido de la celda
  
  if( IsValPared(Val) ) return false;                                 // Si es una pared, no es valido el movimiento

  [Points addObject: pnt ];
  
  return TRUE;
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Adiciona un nuevo punto al camino, es tomado como desplazamiento respecto al punto de referencia y su valides de acuerdo a la celda
-(BOOL) AddPnt:(CGPoint) pnt
  { 
  if( Points.count < 1 ) return false;
  
  float x  = pnt.x - Delta.x;                                           // Pone coordenadas relativas al camino
  float y  = pnt.y - Delta.y;
  
  float dx = x-Last.pnt.x;                                              // Desplazamiento respeto al último punto analizado
  float dy = y-Last.pnt.y;
    
  int Sent = (fabsf(dx)>fabsf(dy))? Horz : Vert;                        // Determina la orientación del desplazamiento
  
  int col = [Scene ColX:x];                                             // Determina la celda
  int row = [Scene RowY:y];    
    
  if( col==Last.Col && row==Last.Row ) return false;                    // No se movio respecto a la ultima celda analizada
    
  bool ret;
  if( Sent == Vert )                                                    // Si la sentido es Vertical
    {
    int sgn = (dy<0)? -1 : 1;                                           // Signo del desplazamiento en la vertical
    
    if( Last.IsVert ) ret = [self ChangeRow:row Sgn:sgn];               // Ultimo segmento era vertical, lo cambia
    else              ret = [self AddNewRow:row Sgn:sgn];               // Ultimo segmento era horizontal, adiciona uno nuevo vertical
    }
  else                                                                  // La dirección es Horizontal
    {
    int sgn = (dx<0)? -1 : 1;                                           // Signo del desplazamiento en la horizontal
      
    if( Last.IsHorz ) ret = [self ChangeCol:col Sgn:sgn];               // Ultimo segmento era horizontal, lo cambia 
    else              ret = [self AddNewCol:col Sgn:sgn];               // Ultimo segmento era vertical, adiciona uno nuevo horizontal
    }
  
  if( ret ) [Sound PlayAddPathPoint];
  return ret;
  }
 
//-----------------------------------------------------------------------------------------------------------------------------------------
// Se adiciona un nuevo segmento Vertical
-(bool) AddNewRow:(int)rowEnd Sgn:(int) sgn
  {
  if( Last.Bck ) return false;                                        // Si se esta empujando, no se admiten nuevos segmentos
  
  int   row = Last.Row + sgn;                                         // Obtiene la fila, relativo al ultimo punto
  bool  bck = false;                                                  // Asume que no es esta empujando un bloque
  if( ![self VerifyRow:row Sgn:sgn Bck:&bck] ) return false;          // Verifica si la celda es valida
  
  Last = [PathPnt PntWithCol:Last.Col Row:row Sent:Vert Sign:sgn Bck:bck];      // Crea un nuevo punto para el perfil
  if( ![self AddPathPnt:Last] ) return false;

  if( row!=rowEnd ) [self ChangeRow:rowEnd Sgn:sgn];                   // Si es de mas de una celda, alarga el segmento
  return true;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Realiza un cambio en el desplazamiento Vertical (Acorta, Alarga o Elimina el ultimo segmento)
-(bool) ChangeRow:(int)rowEnd Sgn:(int) sgn
  {
  int len = (int)Points.count;
  if( len>1 && [self PointAt:len-2].Row==rowEnd )                     // Si el segmento se hace de logitud 0
    {
    [Points removeLastObject];                                        // Borra el ultimo punto
    Last = [Points lastObject];                                       // Actualiza el ultimo punto
    
    return true;                                                      // Retorna OK
    }
    
  bool ret = false;
  for(;;)
    {
    int  row = Last.Row + sgn;                                        // Incrementa/decrementa fila, según el signo
    bool bck = Last.Bck;                                              // Si se esta empujando un bloque
  
    if( (Last.Sgn==sgn || Last.Sgn==0) &&                             // Si se esta alargando el segmento
       ![self VerifyRow:row Sgn:sgn Bck:&bck ] ) return ret;          // Verifica que la nueva celda sea valida
  
    if( bck && !Last.Bck )                                            // Si se comenzo a empujar un bloque
      {
      Last = [PathPnt PntWithCol:Last.Col Row:row Sent:Vert Sign:sgn Bck:bck];      // Crea un nuevo punto para el perfil
      if( ![self AddPathPnt:Last] ) return false;
      }
    else
      if( ![Last ChangeRow:row] ) return false;                       // Cambia la fila del ultimo segmento
    
    ret = true;                                                       // Si al menos se alargo una fila, retorna verdadero
    if( row == rowEnd ) break;                                        // Si se llego a la ultima fila, termina
    }
  
  return ret;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Verifica que el desplazamiento Vertical se realice hacia una celda valida
-(bool) VerifyRow:(int)row Sgn:(int)sgn Bck:(bool *)bck
  {
  if( *bck ) row += sgn;                                              // Si esta empujando un bloque, se chequea una celda por delante
  
  if( row<0 || row>=Scene.Rows ) return false;                        // La celda esta fuera del area de la escena
  
  Byte Val = [Scene GetValCol:Last.Col Row:row];                      // Obtiene el contenido de la celda
  
  if( IsValPared(Val) ) return false;                                 // Si es una pared, no es valido el movimiento
  
  if( IsValBlock(Val) )                                               // Es un bloque
   { 
   if( *bck ) return false;                                           // Ya se estaba empujando, no valido mas de un bloque a la vez
    
   *bck = true;                                                       // Retorna que se comenzo a empujar un bloque
   return [self VerifyRow:row Sgn:sgn Bck:bck];                       // Chequea un punto por adelantado, para ver si es valido
   }
  
  return true;                                                        // Retorna que es valido el movimiento
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se adiciona un nuevo segmento Horizontal
-(bool) AddNewCol:(int)colEnd Sgn:(int) sgn
{
  if( Last.Bck ) return false;                                        // Si se esta empujando, no se admiten nuevos segmentos
  
  int   col = Last.Col + sgn;                                         // Obtiene la fila, relativo al ultimo punto
  bool  bck = false;                                                  // Asume que no es esta empujando un bloque
  if( ![self VerifyCol:col Sgn:sgn Bck:&bck] ) return false;          // Verifica si la celda es valida
  
  Last = [PathPnt PntWithCol:col Row:Last.Row Sent:Horz Sign:sgn Bck:bck];      // Crea un nuevo punto para el perfil
  if( ![self AddPathPnt:Last] ) return false;
  
  if( col!=colEnd ) [self ChangeCol:colEnd Sgn:sgn];                   // Si es de mas de una celda, alarga el segmento
  return true;
}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Realiza un cambio en el desplazamiento Horizontal (Acorta, Alarga o Elimina el ultimo segmento)
-(bool) ChangeCol:(int)colEnd Sgn:(int) sgn
  {
  int len = (int)Points.count;
  if( len>1 && [self PointAt:len-2].Col==colEnd )                     // Si el segmento se hace de logitud 0
    {
    [Points removeLastObject];                                        // Borra el ultimo punto
    Last = [Points lastObject];                                       // Actualiza el ultimo punto
    
    return true;                                                      // Retorna OK
    }
  
  bool ret = false;
  for(;;)
    {
    int  col = Last.Col + sgn;                                        // Incrementa/decrementa fila, según el signo
    bool bck = Last.Bck;                                              // Si se esta empujando un bloque
    
    if( (Last.Sgn==sgn || Last.Sgn==0) &&                             // Si se esta alargando el segmento
       ![self VerifyCol:col Sgn:sgn Bck:&bck ] ) return ret;          // Verifica que la nueva celda sea valida
    
    if( bck && !Last.Bck )                                            // Si se comenzo a empujar un bloque
      {
      Last = [PathPnt PntWithCol:col Row:Last.Row Sent:Horz Sign:sgn Bck:bck];      // Crea un nuevo punto para el perfil
      if( ![self AddPathPnt:Last] ) return false;
      }
    else
      if( ![Last ChangeCol:col] ) return false;                       // Cambia la fila del ultimo segmento
    
    ret = true;                                                       // Si al menos se alargo una fila, retorna verdadero
    if( col == colEnd ) break;                                        // Si se llego a la ultima fila, termina
    }
  
  return ret;
}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Verifica que el desplazamiento Vertical se realice hacia una celda valida
-(bool) VerifyCol:(int)col Sgn:(int)sgn Bck:(bool *)bck
  {
  if( *bck ) col += sgn;                                              // Si esta empujando un bloque, se chequea una celda por delante
  
  if( col<0 || col>=Scene.Cols ) return false;                        // La celda esta fuera del area de la escena
  
  Byte Val = [Scene GetValCol:col Row:Last.Row];                      // Obtiene el contenido de la celda
  
  if( IsValPared(Val) ) return false;                                 // Si es una pared, no es valido el movimiento
  
  if( IsValBlock(Val) )                                               // Es un bloque
    { 
    if( *bck ) return false;                                           // Ya se estaba empujando, no valido mas de un bloque a la vez
    
    *bck = true;                                                       // Retorna que se comenzo a empujar un bloque
    return [self VerifyCol:col Sgn:sgn Bck:bck];                       // Chequea un punto por adelantado, para ver si es valido
    }
  
  return true;                                                        // Retorna que es valido el movimiento
  }
 
@end

//=========================================================================================================================================
// Almacena los datos asociados a un punto del camino del pusher
@implementation PathPnt
@synthesize pnt, Sent, Sgn, Col, Row, Bck;

//-----------------------------------------------------------------------------------------------------------------------------------------
// Establece todos los datos del punto
+(PathPnt*) PntWithCol:(int) col Row:(int) row Sent:(int) sent Sign:(int) sgn Bck:(bool) bck
  {
  PathPnt* p = [PathPnt alloc];
  
  p.pnt = CGPointMake( [Scene XMCol:col], [Scene YMRow:row] );
      
  p.Col = col;
  p.Row = row;
      
  p.Sent = sent;
  p.Sgn  = sgn;
  p.Bck  = bck;
  
  return p;
  }
    
//-----------------------------------------------------------------------------------------------------------------------------------------
// Cambia la columna del donde esta el punto
-(BOOL) ChangeCol:(int) col
  {
  if( Row<0 || Row>=Scene.Rows  ) return false;               // Celda fuera del area de la escena por la vertical
  if( col<0 || col>=Scene.Cols  ) return false;               // Celda fuera del area de la escena por la horizontal
  
  Byte Val = [Scene GetValCol:col Row:Row];                   // Obtiene el contenido de la celda
  
  if( IsValPared(Val) ) return false;                                 // Si es una pared, no es valido el movimiento

  Col   = col;
  pnt.x = [Scene XMCol:col];
  
  return true;
  }
    
//-----------------------------------------------------------------------------------------------------------------------------------------
// Cambia la fila del donde esta el punto
-(BOOL) ChangeRow:(int) row
 {
 if( row<0 || Row>=Scene.Rows  ) return false;               // Celda fuera del area de la escena por la vertical
 if( Col<0 || Col>=Scene.Cols  ) return false;               // Celda fuera del area de la escena por la horizontal
  
 Byte Val = [Scene GetValCol:Col Row:row];                   // Obtiene el contenido de la celda
  
  if( IsValPared(Val) ) return false;                                 // Si es una pared, no es valido el movimiento

 Row   = row;
 pnt.y = [Scene YMRow:row ];
  
 return true;
 }

//-----------------------------------------------------------------------------------------------------------------------------------------
-(bool) IsVert { return (Sent==Vert); }
-(bool) IsHorz { return (Sent==Horz); }
    
//-----------------------------------------------------------------------------------------------------------------------------------------
// Lee desde una cadena de caracteres los datos del punto
+(PathPnt*) FromString:(NSString*) sData
  {
  NSArray *tokens = [ sData componentsSeparatedByString:@"," ];
  if( tokens.count < 3 ) return nil;
    
  int col = ((NSString *)tokens[0]).intValue; 
  int row = ((NSString *)tokens[1]).intValue;
  int Bck = ((NSString *)tokens[2]).boolValue;
  
  return [PathPnt PntWithCol:col Row:row Sent:1 Sign:1 Bck:Bck];
  }
    
//-----------------------------------------------------------------------------------------------------------------------------------------
@end
    
//=========================================================================================================================================
