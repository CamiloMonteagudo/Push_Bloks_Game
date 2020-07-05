//
//  ViewController.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 18/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "MainController.h"
#import "SocialData.h"
#import "ScenePages.h"
#import "Sound.h"
#import "Purchases.h"

@interface MainController ()

@property (weak, nonatomic) IBOutlet UIImageView *Fondo;
@property (weak, nonatomic) IBOutlet UIButton *Compar;

@end

//=========================================================================================================================================
@implementation MainController
@synthesize bntSound, ShowZone, bntTwitter, bntGameCenter, bntFacebook, Fondo, Compar;

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  #ifdef FREE_TO_PLAY
    Fondo.image = [UIImage imageNamed:@"Welcome2@2x.jpg"];
    Compar.hidden = FALSE;
  #else
    Fondo.image = [UIImage imageNamed:@"Welcome@2x.jpg"];
    Compar.hidden = TRUE;
  #endif
  
  CGSize szView   = self.view.bounds.size;
    
  CGFloat xZoom = szView.height/480;
  CGFloat yZoom = szView.width /320;
    
  CGFloat Zoom = (xZoom < yZoom)? xZoom : yZoom;
  if( Zoom>2 ) Zoom = 2.0;
    
  ShowZone.center    = self.view.center;
  ShowZone.transform = CGAffineTransformMakeScale( Zoom, Zoom );
  
  [GlobalData Default];
  [SocialData Default];
  [Social initGameCenter:self];
  
  [self SetSoundIcon];
  
//  [bntTwitter setEnabled:[Social IsTwitter] ];
 // [bntGameCenter setEnabled:[Social IsGameCenter] ];
  }
  
//---------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
  {
  [Sound PlayBackground1];                                                              // Toca sonido de fondo para el juego 
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el botor para apagar/encender el sonido
- (IBAction)OnChangeSound:(UIButton *)sender 
  {
  [Sound SoundsOn: (AppData.Sound!=0)? 0 : 1 ];
  
  [self SetSoundIcon];
  }
//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama para enviar un mesaje por Twitter
- (IBAction)OnTwitterBtn:(id)sender 
  {
  [Social ShowTwitterUI:self];
  }	

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando de oprime el boton de Facebook y da permiso para enviar un post cada ves que se complete una escena
- (IBAction)OnFecebookBtn:(id)sender 
  {
  [Social FacebookLoginBtn:bntFacebook Notify:NO];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra el LeaderBoard del centro de juegos de IOS si esta disponible
- (IBAction)OnGameCenter:(id)sender 
  {
  [Social ShowLeaderBoard:self ];
  }
                              
//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) SetSoundIcon
  {
  #ifdef FREE_TO_PLAY
    return;
  #else
    UIImage *  img    = nil;
    if( AppData.Sound == 0 ) img = [UIImage imageNamed:@"SonidoOff"];
    
    [bntSound setImage:img forState:UIControlStateNormal ];
  #endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================
