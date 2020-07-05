//
//  PurchaseController.m
//  SmartPusher
//
//  Created by Camilo on 06/12/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "GlobalData.h"
#import "PurchaseController.h"

#ifdef FREE_TO_PLAY

//=========================================================================================================================================
@interface PurchaseController ()
  {
  NSString *Titles[5];
  NSString *Prices[5];
  bool      Buys[5];
  }

@property (weak, nonatomic) IBOutlet UILabel  *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnRestore;
@property (weak, nonatomic) IBOutlet UIView   *Panel;
@property (weak, nonatomic) IBOutlet UITableView *LstPurchases;

- (IBAction)btnBack:(id)sender;
- (IBAction)OnRestorePurchase:(id)sender;

@end

//=========================================================================================================================================
@implementation PurchaseController
@synthesize Panel, btnRestore, lbTitle, LstPurchases, FlashItem;

UIImage  *BuyOk;                    // Icono para los item que ya fueron comprados
UIImage  *BuyItem;                  // Icono para los iconos que se pueden comprar

//---------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( self != nil )
    {
    FlashItem = -1;
    }

  return self;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se carga la vista por primera ves
- (void)viewDidLoad
  {
  lbTitle.text = NSLocalizedString( @"PurchaseTitle" , nil );
  [btnRestore setTitle:NSLocalizedString( @"Restore" , nil ) forState:UIControlStateNormal];
  
  if( !BuyOk    ) BuyOk   = [UIImage imageNamed: @"BuyOk"   ];            // Carga icono para los item comprados
  if( !BuyItem  ) BuyItem = [UIImage imageNamed: @"BuyItem" ];            // Carga icono para los items que se pueden comprar
  
  float Zoom = 1;
  if( self.view.frame.size.width >= 2*Panel.frame.size.width )
    Zoom = 2;
  
  Panel.center = self.view.center;
  Panel.transform = CGAffineTransformMakeScale( Zoom, Zoom );
  
  AppPurchases.PurchaseNotify = self;                                     // Cuando se termine una compra, se notifica a este objeto
  
  [self LoadPurchaseData];
  
  if( !AppPurchases.Respuesta ) [AppPurchases RequestProdInfo];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
-(void) LoadPurchaseData
  {
  Titles[0] = (AppPurchases.ProdNoAds )? AppPurchases.ProdNoAds.localizedTitle  : NSLocalizedString( @"ProdNoAds" , nil );
  Titles[1] = (AppPurchases.ProdUnLock)? AppPurchases.ProdUnLock.localizedTitle : NSLocalizedString( @"ProdUnlock", nil );
  Titles[2] = (AppPurchases.ProdSol1  )? AppPurchases.ProdSol1.localizedTitle   : NSLocalizedString( @"ProdSol1"  , nil );
  Titles[3] = (AppPurchases.ProdSol2  )? AppPurchases.ProdSol2.localizedTitle   : NSLocalizedString( @"ProdSol2"  , nil );
  Titles[4] = (AppPurchases.ProdSol3  )? AppPurchases.ProdSol3.localizedTitle   : NSLocalizedString( @"ProdSol3"  , nil );
    
  Prices[0] = [self PriceProd:AppPurchases.ProdNoAds  ];
  Prices[1] = [self PriceProd:AppPurchases.ProdUnLock ];
  Prices[2] = [self PriceProd:AppPurchases.ProdSol1   ];
  Prices[3] = [self PriceProd:AppPurchases.ProdSol2   ];
  Prices[4] = [self PriceProd:AppPurchases.ProdSol3   ];
  
  Buys[0] = AppData.PurchaseNoAds;
  Buys[1] = AppData.PurchaseUnlock;
  Buys[2] = AppData.PurchaseSolLavel1;
  Buys[3] = AppData.PurchaseSolLavel2;
  Buys[4] = AppData.PurchaseSolLavel3;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
-(NSString *) PriceProd:(SKProduct*) product
  {
  if( product == nil ) return @"";
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [numberFormatter setLocale:product.priceLocale];

  return [numberFormatter stringFromNumber:product.price];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando la vista esta a punto de desaperecer
- (void)viewWillDisappear:(BOOL)animated
  {
  AppPurchases.PurchaseNotify = nil;                                    // Quita la notificación de la compra terminada
  }

////---------------------------------------------------------------------------------------------------------------------------------------------
//// Define el nùmero de secciones de la tabla.
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
//  {
//  return 1;
//  }
//
//---------------------------------------------------------------------------------------------------------------------------------------------
// Define el numero de items de la tabla.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
  {
	return 5;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Define el contenido de las celdas de la tabla.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
  {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemPurchaseCell"];
  
	int idx = (int)[indexPath row];

  UIView* panel = cell.contentView;
  
  UILabel*      Title = (UILabel*    )panel.subviews[0];
  UILabel*      Price = (UILabel*    )panel.subviews[1];
  UIImageView* btnBuy = (UIImageView*)panel.subviews[2];
  
  UIActivityIndicatorView* Wait = (UIActivityIndicatorView*)panel.subviews[3];
    
  if( Buys[idx] )
    {
    btnBuy.image = BuyOk;
    
    Title.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    Price.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    }
  else
    {
    btnBuy.image = BuyItem;
    
    if( idx==FlashItem )
      {
      UIColor *Col = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
      Title.textColor = Col;
      Price.textColor = Col;
      
      [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                       animations:^{
                                    Title.alpha = 0.5;
                                    }
                      completion:^(BOOL finished) {Title.alpha = 1.0;}];
      }
    }
    
  Title.text = Titles[idx];
  Price.text = Prices[idx];

  if( [self InPurchaseProcess:idx] )
    {
    btnBuy.hidden = TRUE;
    Wait.hidden   = FALSE;
    
    [Wait startAnimating];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
    }
  else
    {
    btnBuy.hidden = FALSE;
    Wait.hidden   = TRUE;
    }

	return cell;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Dertermina si el producto con indice Idx esta en poceso de compra o no
- (bool) InPurchaseProcess:(int) idx
  {
  switch( idx )
    {
    case 0: return ( AppData.ProcessNoAds     );
    case 1: return ( AppData.ProcessUnlock    );
    case 2: return ( AppData.ProcessSolLavel1 );
    case 3: return ( AppData.ProcessSolLavel2 );
    case 4: return ( AppData.ProcessSolLavel3 );
    }
    
  return false;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Notificacion que se ha seleccionado una fila
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
	int idx = (int)[indexPath row];

  if( ![self InPurchaseProcess:idx] )
    {
    switch( idx )
      {
      case 0: if( !AppData.PurchaseNoAds     ) [AppPurchases PurchaseNoAds ]; break;
      case 1: if( !AppData.PurchaseUnlock    ) [AppPurchases PurchaseUnLock]; break;
      case 2: if( !AppData.PurchaseSolLavel1 ) [AppPurchases PurchaseSolut1]; break;
      case 3: if( !AppData.PurchaseSolLavel2 ) [AppPurchases PurchaseSolut2]; break;
      case 4: if( !AppData.PurchaseSolLavel3 ) [AppPurchases PurchaseSolut3]; break;
      }
      
    [LstPurchases reloadData];
    }

  [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:FALSE];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se ejecuta al tocar el boton de retroceder
- (IBAction)btnBack:(id)sender 
  {
  [self dismissViewControllerAnimated:YES completion:^{}];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza todas las compras que el usuario haya realizado anteriormente
- (IBAction)OnRestorePurchase:(id)sender
  {
  [AppPurchases RestorePurchases];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se termina de realizar la compra de un Item para que se refresque la interface de usuario
- (void)UpdatePurchaseInfo
  {
  [self LoadPurchaseData];
  [LstPurchases reloadData];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
@end

#endif
//=========================================================================================================================================
