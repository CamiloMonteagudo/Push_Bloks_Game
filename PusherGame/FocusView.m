//
//  Focus.m
//  SmartPusher
//
//  Created by Camilo on 01/12/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "FocusView.h"
#define W_LINE 1

@interface FocusView()
  {
  CGFloat off;
  CGRect  Marco;
  }
@end

//=========================================================================================================================================
@implementation FocusView

//-----------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
  {
  Marco = CGRectInset( frame, -W_LINE, -W_LINE );
  self = [super initWithFrame:Marco];
  if (self)
    {
    off = 0;
    self.backgroundColor = [UIColor whiteColor];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(EndTime:) userInfo:nil repeats:YES];
    }
    
  return self;
  }

 CGFloat Dashs3[2] = {4,4};

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetLineWidth(ct, W_LINE);
    
  [[UIColor blackColor] set];
  CGContextSetLineDash(ct, off, Dashs3, 2);

  CGRect rc = CGRectInset( self.bounds, W_LINE/2.0, W_LINE/2.0 );
  
  CGContextAddRect(ct, rc );
    
  CGContextStrokePath(ct);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
//
- (void)EndTime: (NSTimer *) timer
  {
  ++off;
  if( off>8 ) off=0;
  
  [self setNeedsDisplay];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Mueve la ventana al punto pnt
- (void)MoveAt:(CGPoint) pnt
  {
  Marco.origin.x = pnt.x - W_LINE;
  Marco.origin.y = pnt.y - W_LINE;
  
  self.frame = Marco;
  }


@end
//=========================================================================================================================================
