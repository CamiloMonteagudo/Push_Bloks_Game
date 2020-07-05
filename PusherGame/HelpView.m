//
//  HelpView.m
//  SmartPusher
//
//  Created by Camilo Monteagudo Pena on 24/08/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "HelpView.h"

@implementation HelpView

//---------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
  {
  self = [super initWithFrame:frame];
  if( self )
    {
    // Initialization code
    }
    
  return self;
  }

//---------------------------------------------------------------------------------------------------------------------------
// Establece cuales son los objetos que se dibujan
- (void) SetDraw:(int)Draw
  {
  draw = Draw;
  
  [self setNeedsDisplay];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Incrementa la longitud del dibujo 'IdDraw' la magnitud 'dt'
- (void) IncLenDt:(int)dt Draw:(int)IdDraw
  {
	if( IdDraw == HFLECHA ) fhL += dt;
  if( IdDraw == VFLECHA ) fvL += dt;
  if( IdDraw == HLINE   ) lhL += dt ;
  if( IdDraw == VLINE   ) lvL += dt ;
  
  [self setNeedsDisplay];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Obtiene el punto final del dibujo 'IdDraw'
- (CGPoint) GetEndDraw:(int)IdDraw
  {
  float x=0, y=0;
  
	if( IdDraw == HFLECHA ) { x =fhX+fhL; y=fhY;     }
  if( IdDraw == VFLECHA ) { x =fvX    ; y=fvY-fvL; }
  if( IdDraw == HLINE   ) { x =lhX+lhL; y=lhY;     }
  if( IdDraw == VLINE   ) { x =lvX    ; y=lvY-lvL; }
  
  return CGPointMake(x, y);
  }

//---------------------------------------------------------------------------------------------------------------------------
// Define que hay que dibujar una flecha vertical
- (void)DrawVertFlechaX:(float)x Y:(float)y Lng:(float)l
  {
  fvX = x; fvY = y; fvL = l;
  
  draw |= VFLECHA;
  [self setNeedsDisplay];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Define que hay que dibujar una flecha horizontal
- (void)DrawHorzFlechaX:(float)x Y:(float)y Lng:(float)l
  {
  fhX = x; fhY = y; fhL = l;
  
  draw |= HFLECHA;
  [self setNeedsDisplay];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Define que hay que dibujar una flecha vertical
- (void)DrawVertLineX:(float)x Y:(float)y Lng:(float)l
  {
  lvX = x; lvY = y; lvL = l;
  
  draw |= VLINE;
  [self setNeedsDisplay];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Define que hay que dibujar una flecha horizontal
- (void)DrawHorzLineX:(float)x Y:(float)y Lng:(float)l
  {
  lhX = x; lhY = y; lhL = l;
  
  draw |= HLINE;
  [self setNeedsDisplay];
  }

//---------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  CGContextRef ct = UIGraphicsGetCurrentContext();

	if( draw & HFLECHA ) [self drawHFlecha:ct];
  if( draw & VFLECHA ) [self drawVFlecha:ct];
  if( draw & HLINE   ) [self drawHLine:ct  ];
  if( draw & VLINE   ) [self drawVLine:ct  ];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Dibuja una flecha Horizontal
- (void)drawHFlecha:(CGContextRef) ct
	{
  CGContextSetLineWidth(ct, 0.5);
  
  float w2 = fhL;
  float h4 = WFLECHA;
  float h1 = h4/4;
  float h2 = h4/2;
  float h3 = 3*h1;
  float w1 = w2 - 2*h4;
  float y  = fhY - WFLECHA/2.0;
  
  CGContextMoveToPoint   (ct, fhX   , y+h1 );
  CGContextAddLineToPoint(ct, fhX+w1, y+h1 );
  CGContextAddLineToPoint(ct, fhX+w1, y     );
  CGContextAddLineToPoint(ct, fhX+w2, y+h2 );
  CGContextAddLineToPoint(ct, fhX+w1, y+h4 );
  CGContextAddLineToPoint(ct, fhX+w1, y+h3 );
  CGContextAddLineToPoint(ct, fhX   , y+h3 );
  CGContextAddLineToPoint(ct, fhX   , y+h1 );
  
  CGContextFillPath(ct);
	}

//---------------------------------------------------------------------------------------------------------------------------
// Dibuja una flecha Vertical
- (void)drawVFlecha:(CGContextRef) ct
	{
  CGContextSetLineWidth(ct, 0.5);
  
  float w4 = WFLECHA;
  float h2 = fvL;
  float w1 = w4/4;
  float w2 = w4/2;
  float h1 = h2 - 2*w4;
  float x  = fvX;

  CGContextMoveToPoint   (ct, x+w1, fvY    );
  CGContextAddLineToPoint(ct, x+w1, fvY-h1 );
  CGContextAddLineToPoint(ct, x+w2, fvY-h1 );
  CGContextAddLineToPoint(ct, x   , fvY-h2 );
  CGContextAddLineToPoint(ct, x-w2, fvY-h1 );
  CGContextAddLineToPoint(ct, x-w1, fvY-h1 );
  CGContextAddLineToPoint(ct, x-w1, fvY    );
  CGContextAddLineToPoint(ct, x+w1, fvY    );
  
  CGContextFillPath(ct);
	}

//---------------------------------------------------------------------------------------------------------------------------
CGFloat Dashs2[] = {4,4};
//---------------------------------------------------------------------------------------------------------------------------
// Dibuja el camino horizontal
- (void)drawHLine:(CGContextRef) ct
	{
  [[UIColor whiteColor] set];
  
  CGContextSetLineWidth(ct, 2);
  
  CGContextSetLineDash(ct, 4, Dashs2, 2);
  
  int nCell = lhL/40;
  int end   = lhX + (40*nCell);
  
  CGContextMoveToPoint   ( ct, lhX, lhY + 1 );
  CGContextAddLineToPoint( ct, end, lhY + 1 );
  
  CGContextStrokePath(ct);
  
  [[UIColor blackColor] set];
  
  CGContextSetLineDash(ct, 0, Dashs2, 2);
  
  CGContextMoveToPoint   ( ct, lhX, lhY + 1 );
  CGContextAddLineToPoint( ct, end, lhY + 1 );
  
  CGContextStrokePath(ct);
	}
  
//---------------------------------------------------------------------------------------------------------------------------
// Dibuja el camino vertical
- (void)drawVLine:(CGContextRef) ct
	{
  [[UIColor whiteColor] set];
  
  CGContextSetLineWidth(ct, 2);
  
  CGContextSetLineDash(ct, 4, Dashs2, 2);
  
  int nCell = lvL/40;
  int end   = lvY - (40*nCell);
  
  CGContextMoveToPoint   ( ct, lvX+1, lvY );
  CGContextAddLineToPoint( ct, lvX+1, end );
  
  CGContextStrokePath(ct);
  
  [[UIColor blackColor] set];
  
  CGContextSetLineDash(ct, 9, Dashs2, 2);
  
  CGContextMoveToPoint   ( ct, lvX+1, lvY );
  CGContextAddLineToPoint( ct, lvX+1, end );
  
  CGContextStrokePath(ct);
	}
//---------------------------------------------------------------------------------------------------------------------------


@end
