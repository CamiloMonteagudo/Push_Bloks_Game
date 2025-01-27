//=========================================================================================================================================
//  SceneView.m
//  SmartPusher
//
//  Created by Camilo Monteagudo Pena on 28/08/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//
// Implementa el dibujo del fondo de la escena y del relleno de la pantalla que esta fuera de la zona de juego
//=========================================================================================================================================

#import "SceneView.h"
#import "SceneData.h"
#import "GlobalData.h"

//=========================================================================================================================================
@implementation SceneView

//--------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  UIImage* imgFondo = [UIImage imageNamed:Scene.ImgFill];                   // Carga imagen de fondo para relleno de la pantalla
  if( imgFondo != nil )                                                     // Si la pudo cargar
    [imgFondo drawInRect: [self GetImgRect:imgFondo]];                      // La dibuaja en toda la pantalla
  
//  imgScene = [UIImage imageNamed:Scene.ImgFondo];
  NSString *pImg = [AppData GetFullPath:Scene.ImgFondo];                    // Obtiene el camino completo a la image de fondo de la escena
  UIImage* imgScene = [UIImage imageWithContentsOfFile:pImg];               // Carga imagen desde fichero (Sin cache)
  if( imgScene != nil )                                                     // Si la pudo cargar
  
  [imgScene drawInRect: [self GetImgRect:imgScene]];                        // La dibuja en la zona de juego
    
//  else
//    {
//    CGContextRef ct = UIGraphicsGetCurrentContext();
//  
//    [DrawView drawSolidEceneInContex:ct];
//    }
    
    //  [DrawView drawGridInContex:ct];
    //  [DrawView drawEseneFrameInContex:ct];
  }

//--------------------------------------------------------------------------------------------------------------------------------
// De acuedo al tamaño de la imagen la centra en la zona de juego
- (CGRect) GetImgRect:(UIImage*)Img
  {
  CGSize szImg  = Img.size;
  CGSize szView  = Scene.GameZone.bounds.size;
//  CGSize szView2 = self.bounds.size;
//  
//  float esc1 = Img.scale;
//  float esc2 = self.contentScaleFactor;
  
  float x = ( szView.width  - (szImg.width /2)) / 2;
  float y = ( szView.height - (szImg.height/2)) / 2;
  
  return CGRectMake( x, y, szImg.width/2, szImg.height/2);
  }


//--------------------------------------------------------------------------------------------------------------------------------
// De acuedo al tamaño de la imagen la centra en la zona de juego
//- (CGRect) GetImgRect:(UIImage*)Img
//  {
//  CGSize szImg  = Img.size;
//  CGSize szView = Scene.GameZone.bounds.size;
//  
//  float x = ( szView.width  - (szImg.width /2)) / 2;
//  float y = ( szView.height - (szImg.height/2)) / 2;
//  
//  return CGRectMake( x, y, szImg.width/2, szImg.height/2);
//  }

//--------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================

