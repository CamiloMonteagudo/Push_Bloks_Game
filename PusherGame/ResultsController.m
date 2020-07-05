//
//  ResultsController.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 31/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "ResultsController.h"
#import "SceneController.h"
#import "GlobalData.h"
#import "UndoData.h"
#import "SceneData.h"
#import "Sound.h"
#import "SocialData.h"

//=========================================================================================================================================
@interface ResultsController ()
  @property (weak, nonatomic) SceneController *Parent;
@end

//=========================================================================================================================================
@implementation ResultsController
@synthesize ImgStar1,ImgStar2,ImgStar3,ImgStar4,ImgStar5,ResultFrame;
@synthesize PntsCompled,PntsMove,PntsTime,PntsTotal, Parent;
@synthesize lbCompled, lbMoves, lbTime, lbTotal;
@synthesize btnFace, btnGame;

//-----------------------------------------------------------------------------------------------------------------------------------------
static UIImage  *StarOff;                  // Estrella apagada   para puntuación
static UIImage  *StarOn;                   // Estrella encendida para puntuación
static CGPoint   StarPos;                  // Posición de todas las estrella al inicio

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se muestra la vista
- (void)viewWillAppear:(BOOL)animated
  {
  [Sound PlayEndScene];
  
  Parent = ((SceneController*)[self parentViewController]);
  
  double Time  = [SceneCrono GetTime];
  
  [SceneCrono Stop];
  
  double Moves    = Undo.Moves; 
  double solMoves = Scene.Moves; 
  double solTime  = Scene.Moves * 3; 
    
  int PuntosEnd= 250 - Parent.NegPnts;
  int PuntosMove=0, PuntosTime=0;
  
  if( Moves!=0 )
    {  
    PuntosMove = ((solMoves/Moves) * 200);  
    PuntosTime = ((solTime /Time ) * 50 );  
    }
    
  int PuntosTotal = PuntosEnd + PuntosMove + PuntosTime;
    
  lbCompled.text = NSLocalizedString( @"lbEnded", nil );                    // Obtiene las etiquetas traducidas
  lbMoves.text   = NSLocalizedString( @"lbMoved", nil );
  lbTime.text    = NSLocalizedString( @"lbTimer", nil );
  lbTotal.text   = NSLocalizedString( @"lbTotal", nil );  
    
  NSString* PntsFmt = NSLocalizedString( @"PointsFrm", nil );               // Formato para los puntos traducidos
  
  PntsCompled.text = [NSString stringWithFormat:PntsFmt, PuntosEnd  ];      // Pone los puntos por completar el nivel
  PntsMove.text    = [NSString stringWithFormat:PntsFmt, PuntosMove ];      // Pone los puntos por el número de movimientos
  PntsTime.text    = [NSString stringWithFormat:PntsFmt, PuntosTime ];      // Pone los puntos por tiempo empleado
  PntsTotal.text   = [NSString stringWithFormat:PntsFmt, PuntosTotal];      // Pone la puntuación total
  
  ResultFrame.center = self.view.center;
   
  int Stars = [AppData GetStars:PuntosTotal];                               // Número de estrellas según la puntuación obtenida
  StarPos = CGPointMake( ResultFrame.bounds.size.width/2, ResultFrame.frame.size.height+25 );
    
  if( !StarOff ) StarOff= [UIImage imageNamed: @"StarOff" ];  // Carga la imagen de estrella apagada
  if( !StarOn  ) StarOn = [UIImage imageNamed: @"StarOn"  ];  // Carga la imagen de estrella encendida
    
  [self InitStar: ImgStar1 On: Stars>=1 ];
  [self InitStar: ImgStar2 On: Stars>=2 ];
  [self InitStar: ImgStar3 On: Stars>=3 ];
  [self InitStar: ImgStar4 On: Stars>=4 ];
  [self InitStar: ImgStar5 On: Stars>=5 ];
    
  [self AnimateFrame];  
  [self AnimateStars];
  
  if( [AppData NowPuntos] < PuntosTotal )                                   // Si alcanzo una puntuación superior a la que tenia
    {
    [AppData setNowPuntos:PuntosTotal];                                     // Guarda la puntuación alcanzada
  
    [Social ScoreNotifyFB:btnFace GC:btnGame];                              // Notifica puntuación en facebook y en Game Center
    }
  else                                                                      // No hay nada que actualizar o notificar
    {
    btnFace.hidden = TRUE;                                                  // Oculta el boton de Facebook
    btnGame.hidden = TRUE;                                                  // Oculta el boton de Game Center
    }
    
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void)AnimateFrame
  {
  ResultFrame.transform = CGAffineTransformMakeScale( 0.1, 0.1 );
  
  [UIView animateWithDuration: 1.5
                     animations:^ {
                                  ResultFrame.transform = CGAffineTransformMakeScale( 1.0, 1.0 );
                                  }];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void)AnimateStars
  {
  float dy = 50 - StarPos.y;
  
  [UIView animateWithDuration: 3
                   animations:^ {
                                ImgStar3.alpha = 1;
                                ImgStar3.transform = CGAffineTransformMakeTranslation( 0, dy);
                                }];
  
  [UIView animateWithDuration: 3
                   animations:^ {
                                ImgStar4.alpha = 1;
                                ImgStar4.transform = CGAffineTransformMakeTranslation( +55, dy);
                                ImgStar2.alpha = 1;
                                ImgStar2.transform = CGAffineTransformMakeTranslation( -55, dy);
                                }];
    
  [UIView animateWithDuration: 3
                   animations:^ {
                                ImgStar5.alpha = 1;
                                ImgStar5.transform = CGAffineTransformMakeTranslation( +110, dy);
                                ImgStar1.alpha = 1;
                                ImgStar1.transform = CGAffineTransformMakeTranslation( -110, dy);
                                }];
    
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
 -(void) InitStar:(UIImageView*) Star On:(BOOL) on
  {
  Star.center = StarPos;
  Star.alpha  = 0;
  Star.hidden = FALSE;  
  Star.image  = (on)? StarOn : StarOff;
  Star.transform = CGAffineTransformMakeTranslation( 0, 0);
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnSelScenes:(id)sender 
  {
  [Parent OnSelScenes:nil];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnRestar:(UIButton *)sender  
  {
  [Parent LoadActualScene];
  [Parent ResultsShow:FALSE];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnNext:(UIButton *)sender 
  {
  if( [Parent SceneNavegate:1] )
    [Parent ResultsShow:FALSE];
  else
    [Parent OnSelScenes:nil]; 
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnBtnGame:(id)sender
  {
  [Social ShowLeaderBoard:self ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnBtnFace:(id)sender
  {
  [Social FacebookLoginBtn:btnFace Notify:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
@end

//=========================================================================================================================================
