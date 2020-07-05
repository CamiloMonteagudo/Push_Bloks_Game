//
//  TouchView.m
//  GameTest2
//
//  Created by Camilo Monteagudo on 06/03/14.
//  Copyright (c) 2014 Camilo Monteagudo. All rights reserved.
//

#import "TouchView.h"
#import "PathData.h"
#import "SceneData.h"
#import "SceneController.h"

//=========================================================================================================================================
@implementation TouchView
@synthesize IniTimer, Controller;

bool CurAmp;                                                            // Muestra el cursor ampliado
bool CurBck;                                                            // Muestra el cursor del bloque que se va mover

float xCurBck, yCurBck;                                                 // Coordenadas del cursor de bloque
//---------------------------------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  [Controller ShowTooBar:NO Animate:YES];                               // Esconde la barra de opciones si estaba desplegada
  if( Controller.SolucOn ) return;																// Si esta mostrando la solución no hace nada
  
  if( IniTimer!=nil )                                                   // Si esta esperando para moverse
    {
    [IniTimer invalidate];                                              // Para el timer
    IniTimer = nil;                                                     // Quita el timer
    }
  else
   [PathData Start];                                                    // Inicializa un camino nuevo
    
  CGPoint pnt = [[touches anyObject] locationInView: self];             // Punto de inicio del desplazamiento
  [Path SetRefPnt:pnt];                                                 // Pone el punto como referencia
  
  float Size = Scene.zCell;
  CurAmp = (fabsf(Path.Delta.x) < Size && fabsf(Path.Delta.y) < Size);  // Si se toco cerca al punto de referencia

  if( CurAmp ) [self setNeedsDisplay];                                  // Dibuja cursor ampliado
  }

//---------------------------------------------------------------------------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
  {
  if( Controller.SolucOn ) return;																// Si esta mostrando la solución no hace nada
  
  CGPoint pnt = [[touches anyObject] locationInView: self];             // Punto hasta donde se movio el dedo
  
  if( [Path AddPnt:pnt] )                                               // Trata de adicionar el punto al camino
    {
    CurBck = false;  
    PathPnt* pnt = Path.LastPnt;  
      
    if( pnt.Bck )                                                        // Si se arrastra un bloque, determina su posición
      {
      CurBck = true;
      int Size = Scene.zCell;
      
      xCurBck = pnt.pnt.x;
      yCurBck = pnt.pnt.y;
          
      if( pnt.Sent == Horz ) xCurBck += (pnt.Sgn*Size);
      else                   yCurBck += (pnt.Sgn*Size); 
      }
        
    [self setNeedsDisplay];                                             // Provoca que se redibuje la vista
    }
  }

//---------------------------------------------------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
  {
  if( Controller.SolucOn ) return;																// Si esta mostrando la solución no hace nada
  
  if( CurAmp || CurBck )                                                // Si estaba el cursor ampliado o de bloque
    {
    CurAmp = false;                                                     // Esconde cursor ampliado
    CurBck = false;                                                     // Esconde cursor de bloque a mover
    [self setNeedsDisplay];                                             // Refleja los cambios en la pantalla
    }
    
  if( [Path nPoints]<2 || [Controller AnimOn]  ) return;
  
  if( IniTimer!=nil ) [IniTimer invalidate];
      
  IniTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:NO];
  }

//---------------------------------------------------------------------------------------------------------------------------
- (void)updateCurrentTime
  {
  IniTimer = nil;
//  [Path Clear];
//  [self setNeedsDisplay];                                             // Provoca que se redibuje la vista
  
  [Scene.Pusher StartAnimate];
  [Controller AnimatePath];
  }

CGFloat Dashs[] = {4,4};

//---------------------------------------------------------------------------------------------------------------------------
// Only override drawRect: if you perform custom drawing. An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
  {
  if( Path.nPoints<2 ) return;
  int ini = (Path.idxAnim==0)? 0 : Path.idxAnim-1;
  if( ini >=Path.nPoints ) return;
  
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetLineWidth(ct, 2);
  
  [self drawPath:ct Col:[UIColor whiteColor] Init:ini Off:0 ];
  [self drawPath:ct Col:[UIColor blackColor] Init:ini Off:4 ];
  
  PathPnt* pnt = Path.LastPnt;  
  float x = pnt.pnt.x;
  float y = pnt.pnt.y;
    
  CGContextSetLineDash(ct, 0, NULL, 0);
  CGContextFillEllipseInRect(ct, CGRectMake(x-5, y-5, 10, 10 ) );
  }
  
//---------------------------------------------------------------------------------------------------------------------------
-(void) drawPath:(CGContextRef)ct Col:(UIColor*)col Init:(int)ini Off:(int)off
  {
  [col set];
  CGContextSetLineDash(ct, off, Dashs, 2);
    
  float x = [Path PointAt:ini].pnt.x;
  float y = [Path PointAt:ini].pnt.y;
  CGContextMoveToPoint( ct, x, y );
      
  for( int i=ini+1; i<Path.nPoints ; ++i )
    {
    x = [Path PointAt:i].pnt.x;
    y = [Path PointAt:i].pnt.y;
      
    CGContextAddLineToPoint(ct, x, y );
    }
    
  float Size = Scene.zCell;
  if( CurBck )
    {  
    float r = Size/2;
    CGContextAddRect(ct, CGRectMake( xCurBck-r, yCurBck-r, Size, Size) );
    }
  
  if( CurAmp )
    {
    Size *= 1.5;
    CGContextMoveToPoint( ct, x-Size, y );
    CGContextAddLineToPoint(ct, x+Size, y );
      
    CGContextMoveToPoint( ct, x, y-Size );
    CGContextAddLineToPoint(ct, x, y+Size );
    }
    
  CGContextStrokePath(ct);
  }  

//---------------------------------------------------------------------------------------------------------------------------
@end
//=========================================================================================================================================
