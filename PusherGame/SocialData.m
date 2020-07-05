//
//  SocialData.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 09/07/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "SocialData.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "GlobalData.h"

SocialData* Social;

//=========================================================================================================================================
// Variables privadas para las funciones sociales
@interface SocialData ()
  {
  UIView * btnFB;
  UIView * btnGC;
  BOOL     LogNotify;
  
  ACAccountStore* accountStore;
  ACAccount*      facebookAccount;
    
  GKLocalPlayer*    localPlayer;
  UIViewController* LBControllerParent;
  }

@end

//=========================================================================================================================================
@implementation SocialData

//-----------------------------------------------------------------------------------------------------------------------------------------
// Valores contantes usados en las redes sociales

#ifdef FREE_TO_PLAY
  #define GAME_URL             NSLocalizedString( @"GameUrlFree", nil )
  #define FB_APP_ID            @"359015990922881"
  #define HIGHT_SCORE_ID       @"PushLite.highscores"
  #define ACHIEVEMENTS_05_ID   @"PushLite.05milpoints"
  #define ACHIEVEMENTS_10_ID   @"PushLite.10milpoints"
  #define ACHIEVEMENTS_20_ID   @"PushLite.20milpoints"
  #define ACHIEVEMENTS_30_ID   @"PushLite.30milpoints"
#else
  #define GAME_URL             NSLocalizedString( @"GameUrlFull", nil )
  #define FB_APP_ID            @"359015990922881"
  #define HIGHT_SCORE_ID       @"PushBlocks_Highscores"
  #define ACHIEVEMENTS_05_ID   @"PushBlocks.05milpoints"
  #define ACHIEVEMENTS_10_ID   @"PushBlocks.10milpoints"
  #define ACHIEVEMENTS_20_ID   @"PushBlocks.20milpoints"
  #define ACHIEVEMENTS_30_ID   @"PushBlocks.30milpoints"
#endif

#define TWITTER_TXT NSLocalizedString( @"TwitterText", nil )
#define FB_DESC     NSLocalizedString( @"FBDesc", nil )
#define FB_MSG      NSLocalizedString( @"FBMsg", nil ) 
#define FB_CAPTION  NSLocalizedString( @"FBCaption", nil ) 

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el objeto global que mantiene los datos para las funciones sociales (Twitter, Facebook y Game Center)
+ (SocialData *) Default
  {
  if( Social == nil )                                                           // Si no se han cargado los datos de la aplicación
    Social = [SocialData new];                                                  // Los carga
  
  return Social;
  }

//***************************************************************************************************************************************//
//******************************************       SOPORTE PARA TWITTER                   ***********************************************//
//***************************************************************************************************************************************//

//-----------------------------------------------------------------------------------------------------------------------------------------
// Llama la interface de twitter, con el mensaje TWITTER_TXT y un enlace a GAME_URL
- (void) ShowTwitterUI:(UIViewController*) parent 
  {
  SLComposeViewController* Twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
  
  [Twitter setInitialText: TWITTER_TXT];
  
  NSURL* GameUrl = [NSURL URLWithString: GAME_URL];
  
  [Twitter addURL:GameUrl];
  
  [parent presentViewController: Twitter 
                       animated:YES 
                     completion:^(void) {NSLog(@"twitter done");} ];   
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Determina si se el componente de twitter esta disponible o no
- (BOOL) IsTwitter
  {
  return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
  }

//***************************************************************************************************************************************//
//******************************************       SOPORTE PARA FACEBOOK        *********************************************************//
//***************************************************************************************************************************************//

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se loguea en facebook para poder notificar los sucesos en el juego
- (void) FacebookLoginBtn:(UIView *) BtnFB Notify:(BOOL)notify;
  {
  btnFB     = BtnFB;
  btnGC     = nil;
  LogNotify = notify;
  
  NSThread* nowThread = [NSThread currentThread];
  accountStore = [[ACAccountStore alloc] init];

  NSDictionary *emailReadPermisson = @{
                                       ACFacebookAppIdKey       : FB_APP_ID,
                                       ACFacebookPermissionsKey : @[@"email"],
                                       ACFacebookAudienceKey    : ACFacebookAudienceEveryone,
                                       };

  ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierFacebook];
    
  // Solicita permiso de lectura
  [accountStore requestAccessToAccountsWithType:facebookAccountType options:emailReadPermisson completion:^(BOOL granted, NSError *error)
    {
    if( granted )
      {
      NSDictionary *publishWritePermisson = @{
                                              ACFacebookAppIdKey       : FB_APP_ID,
                                              ACFacebookPermissionsKey : @[@"publish_actions"],
                                              ACFacebookAudienceKey    : ACFacebookAudienceEveryone
                                             };

      // Solicita permiso para escribir
      [accountStore requestAccessToAccountsWithType:facebookAccountType options:publishWritePermisson completion:^(BOOL granted, NSError *error)
        {
        if( granted )
          {
          NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
          
          facebookAccount = [accounts lastObject];
          // NSLog(@"Successfull access for account: %@", facebookAccount.username);
          }
          
        [self performSelector:@selector(EndFacebookLogin:) onThread:nowThread withObject:error waitUntilDone:NO];
        }];
      }
    else
      {
      [self performSelector:@selector(EndFacebookLogin:) onThread:nowThread withObject:error waitUntilDone:NO];
      }
    }];

  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se se termina el proceso de registro (Login) en Facebook
- (void)EndFacebookLogin:(id) Arg1
	{
  NSError *error = (NSError *)Arg1;
  
  if( error )
    {
    NSString* Msg;
    
         if( error.code == 6  ) Msg = NSLocalizedString( @"FBNoUser", nil );   // Maneja errores personalizados
//  else if( error.code == ?? ) Msg = NSLocalizedString( @"Descripcion del error", nil );
    else                        Msg = [error localizedDescription];                         // Muestra descripción por defeto
  
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Facebook Errror"             // Muestra el mensaje con descripción del error
                                                    message: Msg
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
    btnFB.alpha   = 1;                                                                      // Pone botón de FB a toda su intencidad
    }
  else
    {
    btnFB.alpha = 0.5;                                                                      // Pone botón de FB un poco opaco
    
    if( LogNotify ) [self ScoreNotifyFB:btnFB GC:nil];                                      // Hay que notificar la puntuación actual
    }
    
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Notifica en Facebook la puntuación alcanzada y luego en GameCenter
-(void) ScoreNotifyFB:(UIView *) BtnFB GC:(UIView *) BtnGC
  {
  btnFB = BtnFB;
  btnGC = BtnGC;
  
  if( !facebookAccount )
    {
    [self EndNotifyFacebook: [NSError errorWithDomain:@"Local" code:0 userInfo:nil] ];
    return;
    }
  
  NSDictionary* params = @{ @"link":        GAME_URL,
                            @"caption":     FB_CAPTION,
                            @"description": [NSString stringWithFormat: FB_DESC, [AppData getTotalPnts] ],
                            @"message":     FB_MSG
                            };
  
  NSURL* feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    
  SLRequest* request = [SLRequest requestForServiceType:SLServiceTypeFacebook 
                                          requestMethod:SLRequestMethodPOST 
                                                    URL:feedURL 
                                             parameters:params];
  
  request.account = facebookAccount;
  
  NSThread* nowThread = [NSThread currentThread];
  
  [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
    [self performSelector:@selector(EndNotifyFacebook:) onThread:nowThread withObject:error waitUntilDone:NO];
    }];
   
  } 

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama después de terminar la notificación de la puntuación en Face book
- (void)EndNotifyFacebook:(id) Arg1
	{
  NSError *error = (NSError *)Arg1;
  
  if( error )                                       // Si hubo error
    {
    // NSLog(@"%@", error);
    [self AnimateNoSendFB:TRUE];                    // Anima (no enviado) el boton de facebook y luego notifica en Game Center
    }
  else
    [self AnimateOkSendFB:TRUE];                    // Anima (enviado) el boton de facebook y luego notifica en Game Center
  }

//***************************************************************************************************************************************//
//********************************************       SOPORTE PARA GAME CENTER        ****************************************************//
//***************************************************************************************************************************************//

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicializa el registro en el centro de juegos de IOS
-(void)initGameCenter:(UIViewController*) parent
  {
  if( localPlayer ) return;
  
  Class gkClass = NSClassFromString(@"GKLocalPlayer");
  
  BOOL iosSupported = [[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending;
  
  if( !gkClass || !iosSupported ) return;
  
  localPlayer = [GKLocalPlayer localPlayer];
  
  localPlayer.authenticateHandler = ^(UIViewController* ctller, NSError *error)
    {
    if( ctller != nil )
      [parent presentViewController: ctller animated:YES completion:^(void){} ];   
    };
  }                                           

//-----------------------------------------------------------------------------------------------------------------------------------------
// Determina si el centro de juego esta disponible o no para la aplicación
- (BOOL) IsGameCenter
  {
  return (localPlayer && localPlayer.authenticated);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Notifica al Centro de juegos de IOS que cambio la puntuación del juego
- (void) GameCenterNotify
  {
  if( ![localPlayer isAuthenticated] )
    {
    [self EndNotifyGameCenter: [NSError errorWithDomain:@"Local" code:0 userInfo:nil] ];
    return;
    }
  
  long Pnts = [AppData getTotalPnts];
  
  GKScore* score = [[GKScore alloc] initWithCategory: HIGHT_SCORE_ID ];
  
  score.value = Pnts;
  
  NSThread* nowThread = [NSThread currentThread];
  
  [score reportScoreWithCompletionHandler:^(NSError *error)
    {
    [self performSelector:@selector(EndNotifyGameCenter:) onThread:nowThread withObject:error waitUntilDone:NO];
    }];
  
  [self NotifyAchievements:Pnts];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama después de terminar la notificación de la puntuación en Game Center
- (void)EndNotifyGameCenter:(id) Arg1
	{
  NSError *error = (NSError *)Arg1;
  
  if( error )
    {
    // NSLog(@"%@", error);
    [self AnimateNoSendFB:NO];
    }
  else
    [self AnimateOkSendFB:NO];
  }


//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra las puntuaciones de los juegos registrados en el Centro de Juegos
- (void) ShowLeaderBoard:(UIViewController*) parent
  {
  GKLeaderboardViewController* LBController = [[GKLeaderboardViewController alloc] init];
  
  LBController.category = HIGHT_SCORE_ID;
  LBController.leaderboardDelegate = self;
  
  LBControllerParent = parent;
  
  parent.modalPresentationStyle = UIModalPresentationFullScreen;
  [parent presentViewController: LBController animated:YES completion:^(void){} ];   
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Implementa GKLeaderboardViewControllerDelegate y su responsabilidad es cerrar el Leaderboard
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
  {
  [LBControllerParent dismissViewControllerAnimated:YES completion:^(void){} ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Notifica al Centro de juegos que se ha alcancado una meta de acuando a la cantidad de puntos
- (void)NotifyAchievements:(long) Pnts 
  {
  NSString *ID;
  
       if( Pnts>=  5000 ) ID = ACHIEVEMENTS_05_ID;
  else if( Pnts>= 10000 ) ID = ACHIEVEMENTS_10_ID; 
  else if( Pnts>= 20000 ) ID = ACHIEVEMENTS_20_ID; 
  else if( Pnts>= 30000 ) ID = ACHIEVEMENTS_30_ID; 
  else return;
  
  GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:ID];
  
  achievement.percentComplete = 100.0;
  
  [achievement reportAchievementWithCompletionHandler:^(NSError *error) {}]; 
  }


//***************************************************************************************************************************************//
//********************************************       ANIMACIÓN DE LOS BOTONES        ****************************************************//
//***************************************************************************************************************************************//

//-----------------------------------------------------------------------------------------------------------------------------------------
// Crea un efecto que indica que se relizo la notificación y oculta el boton
- (void)AnimateOkSendFB:(BOOL) fb
  {
  UIView * Bnt = fb? btnFB : btnGC;
  if( Bnt==nil ) return;
  
  Bnt.transform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
  Bnt.hidden = FALSE;
  Bnt.alpha = 1.0;
    
  [UIView animateWithDuration:0.66 delay:0 options:UIViewAnimationOptionRepeat
                   animations:^ {
                                [UIView setAnimationRepeatCount:3];
                                Bnt.transform = CGAffineTransformMakeScale( 1.5, 1.5 );
                                }
                   completion:^(BOOL f)
                                {
                                [UIView animateWithDuration:1
                                        animations:^{
                                                    Bnt.alpha = 0.0;
                                                    Bnt.transform = CGAffineTransformMakeScale( 8.0, 8.0 );
                                                    }
                                        completion:^(BOOL f)
                                                    {
                                                    if( fb && btnGC ) [self GameCenterNotify];
                                                    } ];
                                } ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Desplaza el boton hacia ambos lados 3 veces indicando no se pudo enviar la notificación
- (void)AnimateNoSendFB:(BOOL) fb
  {
  UIView * Bnt = fb? btnFB : btnGC;
  if( Bnt==nil ) return;
  
  Bnt.transform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
  Bnt.hidden = FALSE;
  Bnt.alpha = 1.0;
    
  [UIView animateWithDuration:0.1
          animations:^ {
                       Bnt.transform = CGAffineTransformMakeTranslation(-5, 0);
                       }
          completion:^(BOOL f)
                       {
                       [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                               animations:^ {
                                            [UIView setAnimationRepeatCount:3.5];
                                            Bnt.transform = CGAffineTransformMakeTranslation(10, 0);
                                            }
                               completion:^(BOOL f)
                                            {
                                            [UIView animateWithDuration:0.1
                                                    animations:^{
                                                                Bnt.transform = CGAffineTransformMakeTranslation( -5, 0	);
                                                                }
                                                    completion:^(BOOL f)
                                                                {
                                                                if( fb && btnGC ) [self GameCenterNotify];
                                                                } ];
                                            } ];
                       } ];
  }


@end
//=========================================================================================================================================
