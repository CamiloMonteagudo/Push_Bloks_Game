
//---------------------------------------------------------------------------------------------------------------------------
//  DrawView.m
//  GameTest2
//
//  Created by Camilo Monteagudo on 05/03/14.
//  Copyright (c) 2014 Camilo Monteagudo. All rights reserved.
//---------------------------------------------------------------------------------------------------------------------------

#import "DrawView.h"
#import "SceneData.h"

@implementation DrawView

//---------------------------------------------------------------------------------------------------------------------------
// Only override drawRect: if you perform custom drawing. An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
  {
  CGContextRef ct = UIGraphicsGetCurrentContext();

  [DrawView drawSolidEceneInContex:ct];
  [DrawView drawGridInContex:ct];
  [DrawView drawEseneFrameInContex:ct];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Dibuja la regilla en contecto ct
+ (void)drawSolidEceneInContex: (CGContextRef) ct
  {
  UIColor *ColorPared = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
  UIColor *ColorPiso  = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
  
//  UIColor *ColorBlock  = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
  CGFloat Size = Scene.zCell;
  
  float py = Scene.yOff;
  for( int i=0; i<Scene.Rows; ++ i )
    {
    float px = Scene.xOff;
    for( int j=0; j<Scene.Cols; ++ j )
      {
      if( [Scene IsParedCol:j Row:i]  )
        CGContextSetFillColorWithColor(ct, ColorPared.CGColor);
      else
        {
        if( [Scene IsBlockCol:j Row:i]  )
          /*CGContextSetFillColorWithColor(ct, ColorBlock.CGColor)*/;
        else
          CGContextSetFillColorWithColor(ct, ColorPiso.CGColor);
        }
      
      CGRect rc = CGRectMake(px, py, Size, Size );
      CGContextFillRect( ct, rc );
      
      if( [Scene IsTagetCol:j Row:i] )
        [self drawTargetInContex:ct X:px Y:py Info: [Scene GetInfoCol:j Row:i] ];
      
      px += Size;
      }
    py += Size;
    }
  }

//---------------------------------------------------------------------------------------------------------------------------
// Dibuja un indicadord del target en la escena
+ (void) drawTargetInContex: (CGContextRef) ct X:(float) x Y:(float) y Info:(Byte) info
  {
  UIColor *ColorTarget = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];

  CGFloat Size = Scene.zCell;
  
  CGContextSetFillColorWithColor(ct, ColorTarget.CGColor);
  
  CGContextFillEllipseInRect( ct, CGRectMake(x+5, y+5, Size-10, Size-10 ) );
  
  NSString *sNum = [NSString stringWithFormat:@"%d", info ];
  
	// draw the element name
	[[UIColor whiteColor] set];
  
	// draw the element symbol
	UIFont *font = [UIFont boldSystemFontOfSize:12];
	CGSize szStr = [sNum sizeWithFont:font];
  
	CGPoint pnt = CGPointMake( x+(Size-szStr.width)/2, y+(Size-szStr.height)/2 );
  
	[sNum drawAtPoint:pnt withFont:font];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Dibuja la regilla en contecto ct
+ (void)drawGridInContex: (CGContextRef) ct
  {
  UIColor *ColorGrids  = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1];
  
  CGFloat Size = Scene.zCell;
  CGFloat xFin = Scene.xOff + (Size * Scene.Cols);
  CGFloat yFin = Scene.yOff + (Size * Scene.Rows );
  
  CGContextSetLineWidth(ct, 0.5);
  CGContextSetStrokeColorWithColor(ct, ColorGrids.CGColor);
  
  float x = Scene.xOff;
  while( x < xFin+1 )
    {
    CGContextMoveToPoint   (ct, x, Scene.yOff );
    CGContextAddLineToPoint(ct, x, yFin       );
    x = x + Size;
    }
  
  float y = Scene.yOff;
  while( y < yFin+1 )
    {
    CGContextMoveToPoint   (ct, Scene.xOff, y );
    CGContextAddLineToPoint(ct, xFin    , y );
    y = y + Size;
    }
  
  CGContextStrokePath(ct);
  }

//---------------------------------------------------------------------------------------------------------------------------
// Dibuja el marco de la zona de juego
+ (void)drawEseneFrameInContex: (CGContextRef) ct
  {
  UIColor *ColorFrame  = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1];
  
  CGContextSetLineWidth(ct, 1);
  CGContextSetStrokeColorWithColor(ct, ColorFrame.CGColor);
  
  CGFloat Size = Scene.zCell;
  
	CGContextStrokeRect(ct, CGRectMake( Scene.xOff,
                                      Scene.yOff,
                                      Size * Scene.Cols,
                                      Size * Scene.Rows) );
  
  }

//---------------------------------------------------------------------------------------------------------------------------
@end
