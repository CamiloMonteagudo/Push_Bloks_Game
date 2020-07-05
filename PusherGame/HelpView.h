//
//  HelpView.h
//  SmartPusher
//
//  Created by Camilo Monteagudo Pena on 24/08/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VFLECHA  0x0001
#define HFLECHA  0x0002
#define VLINE    0x0004
#define HLINE    0x0008

#define WFLECHA  8                        // Grosor para dibujar las flechas

@interface HelpView : UIView
  {
  int draw;                               // Varible que difine que tipo de dibujo hay que realizar
  
  float fvX, fvY, fvL;                    // Datos para dibujar flecha vertical
  float fhX, fhY, fhL;                    // Datos para dibujar flecha horizontal
  
  float lvX, lvY, lvL;                    // Datos para dibujar línea vertical
  float lhX, lhY, lhL;                    // Datos para dibujar línea horizontal
  }

- (void)DrawVertFlechaX:(float)x Y:(float)y Lng:(float)l;
- (void)DrawHorzFlechaX:(float)x Y:(float)y Lng:(float)l;
- (void)DrawVertLineX:  (float)x Y:(float)y Lng:(float)l;
- (void)DrawHorzLineX:  (float)x Y:(float)y Lng:(float)l;

- (void)    SetDraw:(int)Draw;
- (CGPoint) GetEndDraw:(int)IdDraw;
- (void)    IncLenDt:(int)dt Draw:(int)IdDraw;

@end
