//
//  SelSceneController.m
//  SmartPusher
//
//  Created by Camilo on 24/11/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "SelSceneController.h"
#import "ScenePages.h"
#import "GlobalData.h"
#import "FocusView.h"
#import "PurchaseController.h"
#import "Sound.h"

int nowZoom = -1;

int zmCols[] = {3,3,5};
int zmRows[] = {2,3,4};

#define NLAYOUT (sizeof(zmCols)/sizeof(zmCols[0]) )

//=========================================================================================================================================
@interface SelSceneController ()
  {
  int nowPage;
  FocusView* SelView;
  }

@property (weak, nonatomic) IBOutlet UIScrollView *Scroll;
@property (weak, nonatomic) IBOutlet UIPageControl *PageCtrl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *Wait;
@property (weak, nonatomic) IBOutlet UIView *ToolBar;
@property (weak, nonatomic) IBOutlet UIButton *btnToolBar;
@property (weak, nonatomic) IBOutlet UIButton *btnZoomIn;
@property (weak, nonatomic) IBOutlet UIButton *btnZoomOut;
@property (weak, nonatomic) IBOutlet UIButton *btnSound;

- (IBAction)OnGoHome:(id)sender;
- (IBAction)OnZoomOut:(id)sender;
- (IBAction)OnZooomIn:(id)sender;

- (IBAction)OnToolBar:(id)sender;
- (IBAction)OnPageCtrl:(id)sender;
- (IBAction)OnTapScroll:(id)sender;
- (IBAction)OnScenesList:(id)sender;
- (IBAction)OnSound:(id)sender;

@end

//=========================================================================================================================================
@implementation SelSceneController
@synthesize ToolBar, btnToolBar, btnZoomIn, btnZoomOut, btnSound;

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  nowZoom = AppData.Zoom;
  if( nowZoom<0 || nowZoom>=NLAYOUT )
    nowZoom = (self.view.bounds.size.width > 350) ? 2 : 1;
    
  [self ShowTooBar:NO Animate:NO];
  [self SetSoundIcon];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se muestra la vista
- (void)viewDidAppear:(BOOL)animated
  {
  [super viewDidAppear:animated];
  
  [Sound PlayBackground1];                                                              // Toca sonido de fondo para el juego
  [self LoadPages];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Borra todas las subview dentro de una super view
- (void)CleanSubViews:(UIView* ) view
  {
  for( int i=(int)view.subviews.count-1; i>=0; --i )
    [ ((UIView*)view.subviews[i]) removeFromSuperview];
  }

//------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra el cursos de espera
- (void)ShowWait
  {
  _Wait.hidden = FALSE;
  [_Wait startAnimating];

  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
  }

//------------------------------------------------------------------------------------------------------------------------------------------------------
// Oculta el cursos de espera
- (void)HideWait
  {
  [_Wait stopAnimating];
  _Wait.hidden = TRUE;
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
//
- (void)LoadPages
  {
  if( !AppData.Pages )
    {
    [self CleanSubViews:_Scroll];
    [self ShowWait];
    
    CGSize sz = _Scroll.frame.size;
    AppData.Pages = [[ScenePages alloc] initWithSize:sz Cols:zmCols[nowZoom] Rows:zmRows[nowZoom]];
    [AppData.Pages LoadPages];

    [self CreateScrollContent];
    [self HideWait];
    }
  else
    {
    BOOL Updated = [AppData.Pages UpdatePoints];
    
    if( _Scroll.subviews.count >= [AppData.Pages PageCount] )
      {
      if( Updated ) [self UpdateScrollContent];
      }
    else
      [self CreateScrollContent];
    }

  [self ShowActualScene];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra la scena actual, poniedo la pagina donde esta como activa y mostrando el cursor sobre la escena
- (void)ShowActualScene
  {
  int idx = AppData.IdxScene;
  int pg = [AppData.Pages PageScene:idx ];
  
  [self ScrollToPage:pg animated:NO];
  [self MoveCursorAt:idx];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Crea el contenido del scroll de acuerdo a las paginas cargadas
- (void)CreateScrollContent
  {
  [self CreateCursor];
  
  CGSize sz = _Scroll.frame.size;

  int nPages = [AppData.Pages PageCount];
  
  _Scroll.contentSize = CGSizeMake( nPages*sz.width, sz.height );
  
  for( int i=0; i<nPages; ++i )
    {
    CGRect frame = CGRectMake( i*sz.width, 0, sz.width, sz.height );
    UIImageView * ImgView = [[UIImageView alloc] initWithFrame:frame];
  
    ImgView.image = [AppData.Pages GetPage:i];
    ImgView.tag   = 100+i;
  
    [_Scroll addSubview:ImgView];
    }
  
  _PageCtrl.numberOfPages = nPages;
  
//  [self CreateCursor];
  }


//-----------------------------------------------------------------------------------------------------------------------------------------
// Actualiza el contenido del scroll cuando las imagenes cambian
- (void)UpdateScrollContent
  {
  int nPages = [AppData.Pages PageCount];
  
  for( int i=0; i<nPages; ++i )
    {
    UIImageView* view = (UIImageView*)[_Scroll viewWithTag:100+i];
    view.image = [AppData.Pages GetPage:i];
    }
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Crea la ventana que sirve como cursor de la scena seleccionada
- (void)CreateCursor
  {
  CGRect frame = [AppData.Pages IconFrameScene:0];
  
  SelView = [[FocusView alloc] initWithFrame:frame];
  
  [_Scroll addSubview:SelView];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Crea la ventana que sireva como cursor de la scena seleccionada
- (void)MoveCursorAt:(int) idx
  {
  CGRect frame = [AppData.Pages IconFrameScene:idx];
  
  frame.origin.x += (_PageCtrl.currentPage * _Scroll.frame.size.width);
  
  [SelView MoveAt:frame.origin];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Esconde los botones de opciones de la parte superior
- (void)ShowTooBar:(BOOL)show Animate:(BOOL) Anim
  {
  btnZoomIn.enabled  = ( nowZoom > 0         );
  btnZoomOut.enabled = ( nowZoom < NLAYOUT-1 );
  
  UIImage *Img; 
  CGRect rcBar = ToolBar.frame;
  CGRect rcBnt = btnToolBar.frame;
  
  if( show )
    {
    if( rcBar.origin.y == 0 ) return;
      
    rcBar.origin.y = 0;
    Img = [UIImage imageNamed:@"PanelUp"];
    }
  else
    {
    if( rcBar.origin.y == -rcBar.size.height ) return;
    
    rcBar.origin.y = -rcBar.size.height;
    Img = [UIImage imageNamed:@"PanelDown"];
    }
  
  rcBnt.origin.y = rcBar.origin.y + rcBar.size.height;
  
  [UIView animateWithDuration:(Anim?.5:0) animations: ^
   {
   ToolBar.frame    = rcBar;
   btnToolBar.frame = rcBnt;
   
   [btnToolBar setImage:Img forState:UIControlStateNormal];
   }];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnToolBar:(id)sender
  {
  BOOL show = ( ToolBar.frame.origin.y != 0 );
  [self ShowTooBar:show Animate:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca sobre cualquier zona donde no hay controles
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  [self ShowTooBar:NO Animate:YES];                                   // Esconde el toolbar si estaba desplegado
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnGoHome:(id)sender
  {
  [self ShowTooBar:NO Animate:YES];                                   // Esconde el toolbar si estaba desplegado
  [self dismissViewControllerAnimated:YES completion:^{}];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnZooomIn:(id)sender
  {
  [self ShowTooBar:NO Animate:YES];                                   // Esconde el toolbar si estaba desplegado
  if( nowZoom > 0 )
    {
    --nowZoom;
    AppData.Pages = nil;
    [self LoadPages];
    
    AppData.Zoom = nowZoom;                                    // Guarda # de columnas mostradas, para la proxima vez
    }
  
  btnZoomIn.enabled  = ( nowZoom > 0 );
  btnZoomOut.enabled = ( nowZoom < NLAYOUT-1 );
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnZoomOut:(id)sender
  {
  [self ShowTooBar:NO Animate:YES];                                   // Esconde el toolbar si estaba desplegado
  if( nowZoom < NLAYOUT-1 )
    {
    ++nowZoom;
    AppData.Pages = nil;
    [self LoadPages];
    
    AppData.Zoom = nowZoom;                                    // Guarda # de columnas mostradas, para la proxima vez
    }
  
  btnZoomIn.enabled  = ( nowZoom > 0 );
  btnZoomOut.enabled = ( nowZoom < NLAYOUT-1 );
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando de toca el boton inidicador de página
- (IBAction)OnPageCtrl:(id)sender
  {
  [self ShowTooBar:NO Animate:YES];                                   // Esconde el toolbar si estaba desplegado
  
  [self ScrollToPage:(int)_PageCtrl.currentPage animated:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Corre la pagina el scroll hasta la pagina actual
- (void) ScrollToPage:(int) pg animated:(BOOL) anim
  {
  _PageCtrl.currentPage = pg;
  
  CGSize sz = _Scroll.frame.size;
  float Off =  pg*sz.width;
  
  [_Scroll setContentOffset:CGPointMake(Off, 0) animated:anim ];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se toco sobre la zona de scroll
- (IBAction)OnTapScroll:(id)sender
  {
  [self ShowTooBar:NO Animate:YES];                                             // Esconde el toolbar si estaba desplegado
  
  UITapGestureRecognizer* Tap = sender;
  
  CGPoint pnt = [Tap locationInView: _Scroll];
  int pg = _Scroll.contentOffset.x/_Scroll.frame.size.width;
  
  pnt.x = pnt.x - _Scroll.contentOffset.x;
  
  int nScene = [AppData.Pages SceneAtPoint:pnt Page:pg];
  if( nScene>=0 )
    {
    AppData.IdxScene = nScene;                                                   // Pone la escena seleccionada como la actual
    [self MoveCursorAt: nScene ];
    
    NSString* ID = [AppData isLockAt:nScene]? @"Purchases": @"PlayScene";
    
    [self performSegueWithIdentifier: ID sender: self];                         // Pasa al pantalla de jugar o de compra
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama la oprimir el boton con la lista de las escenas
- (IBAction)OnScenesList:(id)sender
  {
  [self ShowTooBar:NO Animate:YES];                                             // Esconde el toolbar si estaba desplegado
  
  [self performSegueWithIdentifier: @"ListScenes" sender: self];                  // Muestra la lista de escenas
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al primir el boton de sonido
- (IBAction)OnSound:(id)sender
  {
  [Sound SoundsOn: (AppData.Sound!=0)? 0 : 1 ];                                   // Intercambia el estado del sonido
    
  [self SetSoundIcon];                                                            // Pone el icono de sonido adecuado
  
  [self ShowTooBar:NO Animate:YES];                                               // Esconde el panel de opciones
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Pone el icono de sonido de acuerdo a como este definido en la aplicación
- (void) SetSoundIcon
  {
  NSString * fSound = (AppData.Sound != 0 )? @"SonidoOn2" : @"SonidoOff2";
  UIImage *  img    = [UIImage imageNamed:fSound]; 
    
  [btnSound setImage:img forState:UIControlStateNormal ];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se concluye el scroll
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
  {
  CGFloat Off = targetContentOffset->x;                              // Posicion actual del scroll
  
  int pg = Off/_Scroll.frame.size.width;
    
  _PageCtrl.currentPage = pg;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando comienza a desplazarze las scenas
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
  {
  [self ShowTooBar:NO Animate:YES];                                               // Esconde el panel de opciones
  }

#ifdef FREE_TO_PLAY
//------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se va mostrar la pantalla de compra, pone flasheando el item de desploqueo de escenas
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if( [[segue identifier] isEqualToString:@"Purchases"] )
    [[segue destinationViewController] setFlashItem:1];
    
  }
#endif

@end // SelSceneController
//=========================================================================================================================================
