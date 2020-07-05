//
//  BlockData.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 29/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "BlockData.h"
#import "SceneData.h"

//=========================================================================================================================================
@implementation BlockData
@synthesize Row, Col, Id, On, Ctl, Tipo, Name;

//----------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos de un bloque, desde una cadena de caracteres
+(BlockData*) FromString:(NSString*) sData
  { 
  NSArray *tokens = [ sData componentsSeparatedByString:@"," ];
  if( tokens.count < 5 ) return nil;
    
  BlockData* obj = [BlockData alloc];                               // Crea objeto bloque y le pone todos sus datos
  obj.Tipo = ((NSString *)tokens[0]).intValue;                      // Primer elemnto como tipo del bloque
  obj.Col  = ((NSString *)tokens[1]).intValue;                      // Segundo elemnto columna donde esta el bloque
  obj.Row  = ((NSString *)tokens[2]).intValue;                      // Tercera elemento columna fila donde esta el bloque
  obj.Id   = ((NSString *)tokens[3]).intValue;                      // Cuarto elemento identificador del bloque
  obj.Name = tokens[4];                                             // Quito elemento, nombre de la imagen que representa al bloque
  
  return obj;                                                       // Retorna el bloque creado
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona el bloque a la vista del juego y pone una referncia en la escena al indice en el arreglo de bloques
- (void) AddToGame:(UIView*) Zone At:(int) idx
  { 
  UIImage*      img = [UIImage imageNamed: Name];                   // Lee imagen del quito elemento y la carga a memoria
  UIImageView* Ctrl = [[UIImageView alloc] initWithImage:img ];     // Crea control con la imagen cargada
  
  [Zone insertSubview:Ctrl atIndex:0];                              // Adiciona el control a la zona de juego
    
  Ctl = Ctrl;
  On  = [Scene GetValCol:Col Row:Row];

  Byte Val = SetValInfo(cBloque, idx);                              // Crea valor que representa al bloque en la escena 
  [Scene SetVal:Val Col:Col Row:Row];                               // Pone valor identifica el bloque en la celda
  
  CGFloat x = [Scene XCol:Col ];                                    // Determina la posicion en la pantalla
  CGFloat y = [Scene YRow:Row ];
    
  Ctrl.frame = CGRectMake(x, y, Scene.zCell, Scene.zCell );         // Posiciona el control en la zona de juego
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------
// Mueve el bloque de una posición a otra
-(void) MoveCol:(int) col Row:(int) row
  { 
  Byte Val = [Scene GetValCol:Col Row:Row];                       // Información del bloque de la celda donde esta
  Byte tmp = [Scene GetValCol:col Row:row];                       // Guarda contenido de la celda hacia donde se va a mover
  
  [Scene SetVal:On  Col:Col Row:Row];                             // Restaura el contenido de la celda donde esta
  [Scene SetVal:Val Col:col Row:row];                             // Actualiza la celda hacia donde va, con información del bloque
  
  On  = tmp;                                                      // Guarda contenido de la celda sobre la que esta el bloque
  Row = row ;                                                     // Actualiza fila 
  Col = col ;                                                     // Actualiza columna
  
  CGFloat x = [Scene XCol:col ];                                  // Determina la posicion en la pantalla
  CGFloat y = [Scene YRow:row ];
  
  CGRect rc = CGRectMake(x, y, Scene.zCell, Scene.zCell );        // Crea marco donde se va a posicionar el control
  Ctl.frame = rc;                                                 // Posiciona el control en la zona de juego
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si el bloque esta sobre un target valido o no
-(BOOL) InTarget
  {
  if( GetValTipo(On) != cTarget )  return FALSE;                  // No esta sobre un target
  
  Byte OnId = GetValInfo(On);                                     // Obtiene ID del target

  return ( Id==OnId );                                            // Verdadero si coinciden los IDs
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================
