//
//  SceneController.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 18/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "SceneController.h"
#import "SceneData.h"
#import "GlobalData.h"
#import "DrawView.h"
#import "PathData.h"
#import "UndoData.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "Sound.h"
#import "PurchaseController.h"

//=========================================================================================================================================
@interface SceneController ()
  {
  BOOL showBanner;
  int  LoadedScene;
  
#ifdef SIMULATE_INTERNET
  BOOL bannerLoaded;
#endif
  }

@end

//=========================================================================================================================================
// Controlador para la vista donde se ejecuta el juego
@implementation SceneController
@synthesize GameZone, ToolBar, bntToolBar, PucherCtl, AnimOn, VTouch, Results, txtMoves, txtTime, bntSound, InfoBar, SolucOn, NegPnts, txtNScene;

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  LoadedScene = -1;
  
  [super viewDidLoad];
  
  if( SceneCrono == nil ) SceneCrono = [CronoTime alloc];
  
#ifdef FREE_TO_PLAY
  [self.view addSubview: AppData.BannerView];
  AppData.BannerNotify = self;
  
  GameZone.frame = CGRectInset( GameZone.frame, -25, 0 );
  
#ifdef SIMULATE_INTERNET
  [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(ShoHideBanner:) userInfo:nil repeats:YES];
#endif

#endif
  
  [self ToolBarLayout];
  
  [self DoLayautAnimate:FALSE];
  [self ShowTooBar:NO Animate:NO];

  VTouch.Controller = self;

  [self ResultsShow:FALSE];  
  [self LoadActualScene];
  
  [Sound PrepareSoundsScene];
  [self SetSoundIcon];
  
  }


//-----------------------------------------------------------------------------------------------------------------------------------------
#ifdef FREE_TO_PLAY
#ifdef SIMULATE_INTERNET
- (void)ShoHideBanner: (NSTimer *) timer
  {
  bannerLoaded = !bannerLoaded;
  [self UpdateViewForBanner:AppData.BannerView];
	}
#endif
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
// Distribuye los botones del toobar de acuerdo al tamaño disponible
- (void) ToolBarLayout
  {
  CGRect rcBar = ToolBar.frame;
  if( rcBar.size.width>490 )
    {
    int x = 10;
    int n = (int)ToolBar.subviews.count-1;
    for( int i=0; i<n; ++i )
      {
      UIView* bnt = ToolBar.subviews[i];
      bnt.frame = CGRectMake(x, 10, 50, 50);
      
      x += 60;
      }
    
    UIView* bnt = ToolBar.subviews[n];
    bnt.frame = CGRectMake( rcBar.size.width-60, 10, 50, 50);
    
    rcBar.size.height = 70;
    ToolBar.frame = rcBar;    
    }
  
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra los resultados una ves completada la escena
- (void) ResultsShow:(BOOL) show
  {
  if( show )
    { 
    Results.frame  = self.view.frame;
    Results.hidden = FALSE;
    
    [self.view addSubview:Results];    
    }
  else  
    {
    [Results removeFromSuperview];
    [Sound PlayBackground2];                                                          // Restaura sonido de fondo para el juego
    }
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) LoadActualScene
  {
  [SceneData LoadNum: AppData.IdxScene Game:GameZone Push:PucherCtl ];                // Carga la escena desde fichero
  
  [UndoData Start];                                                                   // Inicializa el undo
  
  int col = [Scene Pusher].Col;                                                       // Obtiene posición del pusher
  int row = [Scene Pusher].Row;
    
  PathPnt* p = [PathPnt PntWithCol:col Row:row Sent:Indef Sign:0 Bck:false];          // Crea punto con infomación 
  [Undo AddPnt:p Block:nil];                                                          // Adiciona el primer punto al undo
  
  txtMoves.text  = @"0";                                                              // Borra los movimientos
  txtTime.text   = @"0:0";                                                            // Borra el tiempo
  
  int nScene = AppData.IdxScene+1;
  int Puntos = AppData.NowPuntos;
  
  txtNScene.text = [NSString stringWithFormat:@"%d : %d", nScene, Puntos ];           // Actualiza datos de la escena actual
  
  if( LoadedScene != AppData.IdxScene )                                               // Si es una escena nueva
    {
    tmGame  = 0;                                                                      // Pone el tiempo jugado a 0
    NegPnts = 0;                                                                      // Pone puntos negativos a 0
    
    LoadedScene = AppData.IdxScene;                                                   // Guarda referencia a la escena cargada
    }
   else
    tmGame += [SceneCrono GetTime];                                                   // Acumula el tiempo jugado
  
  [GameZone setNeedsDisplay];                                                         // Actualiza el fondo de la escena
  
  [SceneCrono SetUpdateSel:@selector(updateTime) Class:self];                         // Inicializa el cronometro
  [SceneCrono Start];                                                                 // Comienza a contar el tiempo
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Llamada cada 1 segundo para actualizar el tiempo de juego en la pantalla
- (void)updateTime
  {
  double tm = [SceneCrono GetTime];                                                   // Obtiene el tiempo trascurrido

  int min = tm/60;                                                                    // Extrae los minutos
  int seg = tm - (min*60);                                                            // Extrae los segundos restantes
    
  txtTime.text = [NSString stringWithFormat:@"%d:%d", min, seg];                      // Lo muestra en la pantalla
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
  {
  [Sound PlayBackground2];                                                            // Toca sonido de fondo para el juego
  [SceneCrono Restore];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated
  {
  [SceneCrono Pause];
  
#ifdef FREE_TO_PLAY
  AppData.BannerNotify = nil;
  [super viewDidDisappear:animated];
#endif
  
  [Sound StopBackground2];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
#ifdef FREE_TO_PLAY
- (void) UpdateViewForBanner:(ADBannerView *)banner
  {
#ifdef SIMULATE_INTERNET
  BOOL Loaded = bannerLoaded;
#else
  BOOL Loaded = AppData.BannerView.bannerLoaded;
#endif

  if( showBanner != Loaded && AppData.PurchaseNoAds==FALSE )
    {
    showBanner = Loaded;
    
    [self DoLayautAnimate:TRUE];
    }
  }
#endif

//---------------------------------------------------------------------------------------------------------------------------------------------
// Distrubuye adecuadamente la zona de juego y de propaganda, según el espacio disponible y si hay anuncios o no
- (void)DoLayautAnimate:(BOOL)Anim 
  {
  CGSize szView   = self.view.bounds.size;
  
  CGFloat split = szView.height;
  
#ifdef FREE_TO_PLAY
  CGSize szBanner = AppData.BannerView.frame.size;
  if( showBanner ) split -= szBanner.height;
#endif
  
  CGFloat xZoom = split/480;
  CGFloat yZoom = szView.width/320;
  
  CGFloat Zoom = (xZoom < yZoom)? xZoom : yZoom;
  if( Zoom>2 ) Zoom = 2.0;
  
  [UIView animateWithDuration: Anim? 0.4 : 0
                   animations:^ {
                     GameZone.center    = CGPointMake( szView.width/2, split/2 );
                     GameZone.transform = CGAffineTransformMakeScale( Zoom, Zoom );
                     
#ifdef FREE_TO_PLAY
                     AppData.BannerView.frame = CGRectMake( 0, split, szView.width, szBanner.height );
#endif
                   }];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se va a mostrar/esconder el menu de opciones de la parte superior
- (IBAction)OnToolBar:(id)sender 
  {
  BOOL show = ( ToolBar.frame.origin.y != 0 );
  [self ShowTooBar:show Animate:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Esconde los botones de opciones de la parte superior
- (void)ShowTooBar:(BOOL)show Animate:(BOOL) Anim
  {
  UIImage *Img;
  CGRect rcBar = ToolBar.frame;                                       // Recuadro de la barra de botones
  CGRect rcBnt = bntToolBar.frame;                                    // Recuadro del boton para mostrar/esconder la barra de botones
  float  alpha;
  
  if( show )                                                          // Si hay que mostrar la bara de botones
    {
    if( rcBar.origin.y == 0 ) return;                                 // Si la posicion del recuadro es 0, ya se esta mostrando
    
    rcBar.origin.y = 0;                                               // Pone origen del recuadro a 0 (para que se vea)
      
    Img = [UIImage imageNamed:@"PanelUp"];                            // Carga imagen para esconder la barra (hacia arriba)
    alpha = 0.0;                                                      // Oculta barra de informacióm
    }
  else
    {
   	if( rcBar.origin.y == -rcBar.size.height ) return;                // Si el recuadro esta fuera de la pantalla, ya esta oculto
   
    rcBar.origin.y = -rcBar.size.height;                              // Pone el recuadro fuera de la pantalla (lo ocualta)
      
    Img = [UIImage imageNamed:@"PanelDown"];                          // Carga imagen para mostar la barra (hacia abajo)
    alpha = 1.0;                                                      // Muestra barra de informacióm
    }
  
  rcBnt.origin.y = rcBar.origin.y + rcBar.size.height;                // Pone la posición del boton según el recuadro de la barra
  
  [UIView animateWithDuration:(Anim?.5:0) animations: ^               // Muestra/Ocualta la barra, animada
   	{
   	ToolBar.frame    = rcBar;                                         // Pone nueva posición para la barra
   	bntToolBar.frame = rcBnt;                                         // Pone nueva posición para el boton
   
    InfoBar.alpha = alpha;                                            // Muestra/Oculta barra de informacion de la escena
    
   	[bntToolBar setImage:Img forState:UIControlStateNormal];          // Pone la imagen adecuada para el boton
   	}];
    
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Llamado al oprimir el boton de pasar a la pantalla de selección de escena
- (IBAction)OnSelScenes:(id)sender 
  {
  SceneCrono = nil;
  [self dismissViewControllerAnimated:YES completion:^{}];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el boton de reiniciar la escena
- (IBAction)OnRestar:(id)sender 
  {
  [self EndAnimate];																									// Si habia una animación en curso la termina			
  				
  SolucOn = FALSE;                                                    // Quita el modo de mostar la solución (si estaba)
  [self ToolBtnsHide:FALSE];		  																		// Muestra todos los botones del toolbar
    
  [self LoadActualScene];  																						// Recarga la escena
  [self ShowTooBar:NO Animate:YES];																		// Oculta el toolbar
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el boton de undo
- (IBAction)OnUndo:(id)sender 
  {
  if( AnimOn || SolucOn ) return;
  
  [Undo DoUndo];
  txtMoves.text = [NSString stringWithFormat:@"%d", Undo.Moves];      // Actualiza movimientos
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el boton de mostrar la solución
- (IBAction)OnSolution:(id)sender 
  {
  if( AnimOn || SolucOn ) return;
  
  [self ShowTooBar:NO Animate:YES];
  
  #ifdef FREE_TO_PLAY
    int lavel = AppData.IdxScene / 18;
    bool BuySol = true;
  
         if( lavel==0 && !AppData.PurchaseSolLavel1 ) BuySol = false;
    else if( lavel==1 && !AppData.PurchaseSolLavel2 ) BuySol = false;
    else if( lavel==2 && !AppData.PurchaseSolLavel3 ) BuySol = false;
    
    if( !BuySol )
      {
      [self performSegueWithIdentifier: @"Purchases" sender: self];               // Pasa a la pantalla de compra
      return;
      }
  #else
    double tm = [SceneCrono GetTime] + tmGame;

    if( tm/60 < 10 && [AppData NowPuntos]<300 )
    	{
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"lbWarn", nil )
     	  																							message: NSLocalizedString( @"lbNoSol", nil )
    		  																					 delegate: self
    			  																cancelButtonTitle: NSLocalizedString( @"lbClose", nil )
    				  							                otherButtonTitles: nil];
      [alert show];
    
      return;
  	  }
  #endif
    
  [self LoadActualScene];  														// Carga la escena actual
  if( [Scene LoadSolution] )													// Carga la solución de la escena actual
    {
    SolucOn = TRUE;                                   // Pone modo de mostrar la solución
    NegPnts = 250;                                    // Penaliza con 200 puntos por usar la solucion
    
    [self ToolBtnsHide:TRUE];		  										// Esconde los botones que se pueden usar
    
    [Scene.Pusher StartAnimate];
    [self AnimatePath];
    }
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Esconde/muestra los botones del toolbar en el modo solución
- (void) ToolBtnsHide: (BOOL) hide
	{
  int n = (int)ToolBar.subviews.count;			  					// Número de botones en el toolbar
  for( int i=2; i<n; ++i )															// Recorre todo los botones a partir del 3ro
    {
    UIView* bnt = ToolBar.subviews[i];									// Obtiene boton actual
    bnt.hidden = hide;																	// Lo oculta/muestra
    }
  
  int idxRef = hide? 0 : 2;															// Indice de boton de referencia para posicionar el boton de reiniciar
  
  CGRect rc1 = ((UIView*)ToolBar.subviews[idxRef]).frame;
  CGRect rc2 = ((UIView*)ToolBar.subviews[1]).frame;
  
  rc2.origin.y = rc1.origin.y;
  
  ((UIView*)ToolBar.subviews[1]).frame = rc2;    
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el boton de mostrar la escena anterior 
- (IBAction)OnPrevScene:(id)sender 
  {
  [self SceneNavegate:-1 ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el boton de mostrar la escena proxima
- (IBAction)OnNextScene:(id)sender 
  {
  [self SceneNavegate:1 ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se mueve a otra escena, si inc=-1 anterior, si inc=1 posterior
- (bool) SceneNavegate: (int) inc
  {
  if( AnimOn || SolucOn ) return false;                             // Si esta durante una animacion o solucion no hace nada
    
  int idx = AppData.IdxScene + inc;                                 // Pasa a la proxima escena
  
  for(;;)
    {
    if( idx >= AppData.nScenes || idx <0 ) return false;            // Si esta fuera del rango valido, no hace nada
    
    if( ![AppData isLockAt:idx] ) break;                            // Si la escena no esta lockeada, continua abajo
    
    idx += inc;                                                     // Pasa al lo proxima escena y repite el ciclo
    }
  
  AppData.IdxScene = idx;                                           // La pone como la escena actual
  [self LoadActualScene];                                           // Caraga la escena y la muestra
  
  return true;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el boton para mostrar el estado del sonido
- (IBAction)OnSound:(UIButton *)sender 
  {
  [Sound SoundsOn: (AppData.Sound!=0)? 0 : 1 ];                                  // Intercambia el estado del sonido
    
  [self SetSoundIcon];                                                            // Pone el icono de sonido adecuado
  
  [self ShowTooBar:NO Animate:YES];                                               // Esconde el panel de opciones
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Pone el icono de sonido de acuerdo a como este definido en la aplicación
- (void) SetSoundIcon
  {
  NSString * fSound = (AppData.Sound != 0 )? @"SonidoOn2" : @"SonidoOff2";
  UIImage *  img    = [UIImage imageNamed:fSound]; 
    
  [bntSound setImage:img forState:UIControlStateNormal ];
  }

//---------------------------------------------------------------------------------------------------------------------------
// Termina la animación si esta encurso
- (void) EndAnimate
	{
  [Path Clear];                                                                   // Borra el camino completo
  AnimOn = false;                                                                 // Pone bandera de no animación
  
  if( !SolucOn )                                                                 // Si no esta animando la solución
    [VTouch setNeedsDisplay];                                                     // Actualiza dibujo del camino
  
  [Scene.Pusher EndAnimate];                                                      // Termina la animación del caminado del pusher
  return;                                                                         // Termina la función y la animación
	}

//---------------------------------------------------------------------------------------------------------------------------
// Anima el segmento del camino definido entre el punto idxAnim y el siguiente, el cual pasa a se idxAnim
- (void)AnimatePath
  {
  AnimOn = true;                                                                    // Pone una bandera para saber que se esta animando
  
  int idx = Path.idxAnim + 1;                                                       // Corre el punto de animación hacia adelante
  Path.idxAnim = idx;                                                               // Guarda punto viegente para la proxima animación
  
  if( idx >= Path.nPoints )                                                         // Si el punto vigente no esta dentro del camino  
    {
    [self EndAnimate];																																
    return;                                                                         // Termina la función y la animación
    }
  
  PathPnt* pt1 = [Path PointAt:idx-1];                                              // Obtiene el punto inicial
  PathPnt* pt2 = [Path PointAt:idx  ];                                              // Obtiene el punto final
  
  int dx = pt2.Col-pt1.Col;                                                         // Calcula desplazamiento hoizontal
  int dy = pt2.Row-pt1.Row;                                                         // Calcula desplazamiento vertical   
  
  float ang = [self GetAngleDx: dx Dy: dy ];                                        // Calcula el angulo de rotación del pusher
  Scene.Pusher.Angle = ang;                                                         // Rota el pusher al angulo indicado
  
  BlockData *Bck = [Path BlockAt:idx];                                              // Obtiene bloque que se esta empujando
  
  [Undo AddPnt:pt2 Block:Bck];                                                      // Adiciona la operación a la lista de undo
  
  [UIView animateWithDuration:abs(dx+dy)/PathSpeed delay:0.2 options:0        			// Determina tiempo de la inimación  
                   animations: ^{
                                if( Bck!=nil )                                      // Si se esta empujando un bloque
                                  {
                                  [Bck MoveCol: Bck.Col+dx Row: Bck.Row+dy];        // Realiza movimiento del bloque
                                  [Sound PlayPushBlock];                            // Toca sonido de empujar bloque
                                  }
                     
                                [Scene.Pusher MoveCol:pt2.Col Row:pt2.Row];         // Realiza movimiento del pusher
                                }
                   completion: ^(BOOL f)                                            // Al terminar la animación
                                {
                                [Sound StopPushBlock];                             // Toca sonido de empujar bloque
                                txtMoves.text = [NSString stringWithFormat:@"%d", Undo.Moves];      // Actualiza movimientos
     
                                if( !SolucOn )                                     // Si no esta animando la solución
                                  [VTouch setNeedsDisplay];                         // Actualiza dibujo del camino
     /*                           else if( Bck!=nil )                                 // Si esta animando la solución y empuja un bloque
                                  [Sound PlayWalking];                              // Restaura sonido de caminar
     */
                                [self InTargetBlock:Bck];                           // Chequea si esta sobre un target
                                [self AnimatePath];                                 // Continua animando el proximo segmento
                                }
   ];
  
  }

//---------------------------------------------------------------------------------------------------------------------------
-(float) GetAngleDx:(int) dx Dy:(int) dy
  {
  if( dy==0 ) return (dx>0)? 0      :   M_PI;
  else        return (dy>0)? M_PI/2 : 3*M_PI/2;
  }

//---------------------------------------------------------------------------------------------------------------------------
- (void) InTargetBlock:(BlockData *) Bck
  {
  if( Bck==nil || ![Bck InTarget] ) return;                                         // Si no es bloque o no esta sobre un target
  
  [self AnimateBlock:Bck];  																												// Anima puesta del bloque sobre el target

  if( [Scene AllBlockInTarget] )																										// Si todos los bloque esta sobre los targets
    {
    [Scene.Pusher EndAnimate];																											// Termina caminado del pusher
    
    if( !SolucOn ) [self ResultsShow:TRUE];							      											// Muestra resultados si no esta en la solución
    }
  }

//---------------------------------------------------------------------------------------------------------------------------
- (void) AnimateBlock:(BlockData *) Bck
  {
  UIImageView *img = Bck.Ctl;
  CGRect     frame = img.frame;
  
  [UIView animateWithDuration: 0.8
                   animations: ^
                                {
                                img.frame = CGRectInset(frame, 6, 6 );
                                }
                   completion: ^(BOOL f)
                                {
                                [UIView animateWithDuration: 0.8 animations: ^{img.frame = frame;}];
                                }
  ];
  
  [Sound PlayOnTarget];
  }

#ifdef FREE_TO_PLAY
//------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se va mostrar otra pantalla
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
   int lavel = AppData.IdxScene / 18;
   
  if( [[segue identifier] isEqualToString:@"Purchases"] )
    [[segue destinationViewController] setFlashItem: lavel + 2 ];
    
  }
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================


    