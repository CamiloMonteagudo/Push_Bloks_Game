//
//  DrawView.h
//  GameTest2
//
//  Created by Camilo Monteagudo on 05/03/14.
//  Copyright (c) 2014 Camilo Monteagudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView

  + (void) drawSolidEceneInContex: (CGContextRef) ct;
  + (void) drawTargetInContex: (CGContextRef) ct X:(float) x Y:(float) y Info:(Byte) info;
  + (void) drawGridInContex: (CGContextRef) ct;
  + (void) drawEseneFrameInContex: (CGContextRef) ct;
@end
