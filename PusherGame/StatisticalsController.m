//
//  StatisticalsController.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 06/07/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "StatisticalsController.h"
#import "GlobalData.h"
#import "SocialData.h"
#import "PurchaseController.h"

//=========================================================================================================================================
// Variables privadas para las funciones sociales
@interface StatisticalsController ()
	{
  NSMutableArray* lstSorted;
	}
@end

//=========================================================================================================================================
// Controlador de la pantalla que maneja los resultados alcanzados en todas las escenas
@implementation StatisticalsController
@synthesize pntsTotal, ToolBar, bntToolBar, LstScenes;

static UIImage  *StarOff;                  // Estrella apagada   para puntuación
static UIImage  *StarOn;                   // Estrella encendida para puntuación

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se carga la vista por primera ves
- (void)viewDidLoad
  {
  [self ShowTooBar:NO Animate:NO];
  
  if( !StarOff ) StarOff= [UIImage imageNamed: @"StarOff" ];                      // Carga la imagen de estrella apagada
  if( !StarOn  ) StarOn = [UIImage imageNamed: @"StarOn"  ];                      // Carga la imagen de estrella encendida
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se muestra la vista
- (void)viewWillAppear:(BOOL)animated
  {
  [self UpdateTotal];  
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se muestra la vista
- (void)UpdateTotal
  {
  NSString* TotalFmt = NSLocalizedString( @"ScoreFrm", nil );
  
  pntsTotal.text = [NSString stringWithFormat:TotalFmt, [AppData getTotalPnts] ];   
  
  [LstScenes reloadData];
  
  if( !lstSorted )
  	{
  	NSIndexPath* Idx = [NSIndexPath indexPathForItem:AppData.IdxScene inSection:0];
  
  	[LstScenes selectRowAtIndexPath:Idx animated:NO scrollPosition:UITableViewScrollPositionTop];  
  	}
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se va a mostrar/esconder el menu de opciones de la parte superior
- (IBAction)OnToolBar:(UIButton *)sender 
  {
  BOOL show = ( ToolBar.frame.origin.y != 0 );
  [self ShowTooBar:show Animate:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Esconde los botones de opciones de la parte superior
- (void)ShowTooBar:(BOOL)show Animate:(BOOL) Anim
  {
  UIImage *Img;
  CGRect rcBar = ToolBar.frame;
  CGRect rcBnt = bntToolBar.frame;
  float  alpha;
  
  if( show )
    {
    if( rcBar.origin.y == 0 ) return;
    
    rcBar.origin.y = 0;
    Img = [UIImage imageNamed:@"PanelUp"];
    alpha = 0.0;                                                      // Oculta la puntuación total
    }
  else
    {
    if( rcBar.origin.y == -rcBar.size.height ) return;
    
    rcBar.origin.y = -rcBar.size.height;
    Img = [UIImage imageNamed:@"PanelDown"];
    alpha = 1.0;                                                      // Muestra la puntuación total
    }
  
  rcBnt.origin.y = rcBar.origin.y + rcBar.size.height;
  
  [UIView animateWithDuration:(Anim?.5:0) animations: ^
    {
    ToolBar.frame    = rcBar;
    bntToolBar.frame = rcBnt;
    
    pntsTotal.alpha = alpha;                                           // Muestra/Oculta la puntuación total
    [bntToolBar setImage:Img forState:UIControlStateNormal];
    }];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Define el nùmero de secciones de la tabla.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
  {
  return 1;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Define el numero de items de la tabla.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
  {
	return AppData.nScenes;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Define el contenido de las celdas de la tabla.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
  {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellScenePoints"];
  
	int idx = (int)[indexPath row];
  if( lstSorted )
    idx = ((NSNumber*)lstSorted[idx]).intValue;
  
  UILabel* Num = (UILabel *)[cell viewWithTag:1];;
  Num.text = [NSString stringWithFormat:@"%02d", idx+1]; 
  
  UILabel* pts = (UILabel *)[cell viewWithTag:7];;
  pts.text = [NSString stringWithFormat:@"%03d", [AppData PuntosAt:idx]]; 
  	
  int Stars = [AppData StarsAt: idx];                                           // Número de estrellas segun la puntuación actual
  for (int i=0; i<5; ++i)                                                       // Muestra cantidad de estrellitas según la puntuación
    {
    UIImageView* Img = (UIImageView *)[cell viewWithTag:2+i];
      
    if( i<Stars ) Img.image = StarOn;                                           // Dibuja estrella encendida
    else          Img.image = StarOff;                                          // Dibuja estrella apagada
    }
    
	return cell;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Notificacion que se ha seleccionado una fila
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
  {
	int idx = (int)[indexPath row];
  
  if( lstSorted )
    idx = ((NSNumber*)lstSorted[idx]).intValue;
  
  AppData.IdxScene = idx;                                                     // Pone la escena seleccionada como la actual
  
  NSString* ID = [AppData isLockAt:idx]? @"Purchases": @"PlayScene";          // Si la escena esta bloqueada, pasa a pantalla de compra
    
  [self performSegueWithIdentifier: ID sender: self];                         // Pasa al pantalla de jugar o de compra
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se ejecuta el oprimir el boton del centro de juegos de IOS
- (IBAction)OnGameCenter:(id)sender 
  {
  [Social ShowLeaderBoard:self ];
  [self ShowTooBar:NO Animate:YES];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se ejecuta al ordenar las escenas por puntuaciòn o por número de escena
- (IBAction)OnSortScores:(id)sender 
  {
  if( lstSorted == nil )
    {
    lstSorted = [NSMutableArray new];
  
    int n = AppData.nScenes;
    for( int i=0; i<n; ++i )
      {
      int j=0;
      int Pnts = [AppData PuntosAt:i];
    
      while( j<lstSorted.count )
      	{
        int idx = ((NSNumber*)lstSorted[j]).intValue;
        if( [AppData PuntosAt:idx] > Pnts  ) break;
        
        ++j;
        }
    
      NSNumber* idx = [NSNumber numberWithInt:i];
    
      [lstSorted insertObject:idx atIndex:j ];
      }
 		}
  else
  	{
    lstSorted = nil;
  	}       
  
  [LstScenes reloadData];
  [self ShowTooBar:NO Animate:YES];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se ejecuta al tocar el boton de retroceder
- (IBAction)btnBack:(id)sender 
  {
  [self dismissViewControllerAnimated:YES completion:^{}];
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


//---------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================

