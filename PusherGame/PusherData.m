//
//  PusherData.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 29/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "PusherData.h"
#import "SceneData.h"
#import "Sound.h"

@interface PusherData()
  {
  float Angulo;
  }
@end

//=========================================================================================================================================
@implementation PusherData
@synthesize Col, Row, On, Ctl, Name;

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos del pusher desde una cadena en el formato col,row,namebase y la asocia a un ImageView
- (void) AssociteView:(UIImageView*) view
  { 
  view.image = [UIImage imageNamed:Name];                           // Carga la imagen en el image view
  
  view.transform = CGAffineTransformMakeRotation( Angulo );         // Rota la imagen
    
  Ctl = view;                                                       // Asigna la imagen al control
    
  [self MoveCol:Col Row:Row];                                       // Mueve el pusher
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos del pusher desde una cadena en el formato col,row,namebase
+ (PusherData *) FromString: (NSString *) sData
  { 
  NSArray *tokens = [ sData componentsSeparatedByString:@"," ];       // Divide la cadena en tokens
  if( tokens.count < 3 ) return nil;                                  // Si menos de 3 tokens la cadena es incorrecta
  
  PusherData* obj = [PusherData alloc];                               // Crea el objeto pusher
    
  obj.Col  = ((NSString *)tokens[0]).intValue;                        // Obtiene la columna donde posicionarlo
  obj.Row  = ((NSString *)tokens[1]).intValue;                        // Obtiene la fila donde posicionarlo
  
  obj.Name = tokens[2];                                               // Obtiene nombre de la imagen del pusher
  
  if( tokens.count > 3 )                                              // Hay un cuarto parametro  (hay que rotarlo)
    {
    float angGrd = ((NSString *)tokens[3]).floatValue;                // Obtiene el angulo en grados
    obj->Angulo = (angGrd * M_PI) / 180.0 ;                           // Lo convierte a radianes
    }

  return obj;                                                         // Retorna el pusher creado
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Mueve el pusher a una posición determinada
- (void) MoveCol:(int) col Row:(int) row 
  {
  Col = col;
  Row = row;

  CGRect rc = Ctl.bounds;
  rc.origin = CGPointMake([Scene XCol:col], [Scene YRow:row]);
  
  Ctl.frame = rc;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Arreglo de imagenes para la animación del pusher
NSMutableArray* imgs;
NSString* nameBase;

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga la secuencia de imagenes de pusher para aparentar que esta caminando
- (void) LoadAnimateImages
  {
  NSString* nBase = [Name stringByDeletingPathExtension];
  
  if( imgs != nil && [nBase isEqualToString:nameBase] ) return;
  
  nameBase = nBase;
  
  imgs = [NSMutableArray new];
    
  [imgs addObject:[UIImage imageNamed:nameBase] ];
    
  for( int i=1;; ++i )
    {
      NSString* name = [nameBase stringByAppendingFormat:@"%d", i ];
      UIImage*  Img  = [UIImage imageNamed:name];
      
      if( Img==nil ) break;
      
      [imgs addObject:Img ];
    }
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga la secuencia de imagenes de pusher para aparentar que esta caminando
- (void) StartAnimate
  {
  [self LoadAnimateImages];
  
  double tm = 0.3;
  if( [Scene.ImgFill isEqualToString:@"Water.jpg"] ) tm = 0.1;
  if( [Scene.ImgFill isEqualToString:@"Sky.jpg"  ] ) tm = 0.1;
  
  Ctl.animationImages = imgs;
  Ctl.animationDuration = tm;
  [Ctl startAnimating];
  
  [Sound PlayWalking];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muesta el pusher estatico
- (void) EndAnimate
  {
  [Ctl stopAnimating];
  [Sound StopWalking];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el arreglo de imagenes usadas para animar el pusher
- (NSMutableArray*) GetAnimImgs
	{
  [self LoadAnimateImages];
  
  return imgs;
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Rota el pusher al angulo 'ang'
- (void) setAngle:(float) ang
  {
  [UIView animateWithDuration: 0.2  
                     animations:^{
                                 Ctl.transform = CGAffineTransformMakeRotation(ang);
                                 } ];
  Angulo = ang;  
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Retorna el angulo que esta rotado el pusher
- (float) Angle
  {
  return Angulo;  
  }


//-----------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================
