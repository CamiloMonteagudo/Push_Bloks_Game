//
//  Purchases.m
//  SmartPusher
//
//  Created by Camilo on 05/12/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "GlobalData.h"
#import "Purchases.h"

//=========================================================================================================================================
#define PURSHASE_NOADS          @"com.BigXSoft.PushBlocks.NoAds2"
#define PURSHASE_UNLOCK         @"com.BigXSoft.PushBlocks.UnLock"
#define PURSHASE_SOLUTION1      @"com.BigXSoft.PushBlocks.Solution1"
#define PURSHASE_SOLUTION2      @"com.BigXSoft.PushBlocks.Solution2"
#define PURSHASE_SOLUTION3      @"com.BigXSoft.PushBlocks.Solution3"
//=========================================================================================================================================

Purchases* AppPurchases;

//=========================================================================================================================================
#ifdef SIMULATE_INTERNET

@implementation TestProd
@end

#endif

//=========================================================================================================================================
@interface Purchases()
  {
  SKProductsRequest* request;
  }

@end

NSSet* LstProds;

//=========================================================================================================================================
// Maneja las compras hechas desde la aplicación
@implementation Purchases
@synthesize ProdNoAds,ProdUnLock,ProdSol1,ProdSol2,ProdSol3, PurchaseNotify;

//---------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa el objeto global de compras dentro de la aplicación
+(void) CreateAppPurshases
  {
  LstProds = [NSSet setWithObjects:PURSHASE_NOADS,PURSHASE_UNLOCK,PURSHASE_SOLUTION1,PURSHASE_SOLUTION2,PURSHASE_SOLUTION3,nil];
  
  AppPurchases = [Purchases new];
  
  [[SKPaymentQueue defaultQueue] addTransactionObserver:AppPurchases];
  
  [AppPurchases RequestProdInfo];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Solicita la información sobre los productos que hay en AppStore
- (void)RequestProdInfo
  {
#ifdef SIMULATE_INTERNET
  int tm = 3 + rand()%27;
  [NSTimer scheduledTimerWithTimeInterval:tm target:self selector:@selector(ReturnProdInfo:) userInfo:nil repeats:NO];
  
#else
  request = [[SKProductsRequest alloc] initWithProductIdentifiers:LstProds ];
  [request setDelegate:AppPurchases];
  [request start];
#endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Función que restaura todas las compras hechas anteriormente
- (void)RestorePurchases
  {
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Función que retorna los produtos que estan listo para la compra dentro de la aplicación
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
  {
  for( SKProduct* Prod in response.products )
    {
    NSString* ProdId = Prod.productIdentifier;
    
         if( [ProdId isEqualToString:PURSHASE_NOADS    ] ) ProdNoAds  = Prod;
    else if( [ProdId isEqualToString:PURSHASE_UNLOCK   ] ) ProdUnLock = Prod;
    else if( [ProdId isEqualToString:PURSHASE_SOLUTION1] ) ProdSol1   = Prod;
    else if( [ProdId isEqualToString:PURSHASE_SOLUTION2] ) ProdSol2   = Prod;
    else if( [ProdId isEqualToString:PURSHASE_SOLUTION3] ) ProdSol3   = Prod;
    }
  
  _Respuesta = true;
  
  if( PurchaseNotify ) [PurchaseNotify UpdatePurchaseInfo];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Función que es llamada cuando una compra es completada
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
  {
  for( SKPaymentTransaction* Transation in transactions )
    {
    NSString* ProdId = Transation.payment.productIdentifier;
      
    if( Transation.transactionState == SKPaymentTransactionStatePurchased ||
        Transation.transactionState == SKPaymentTransactionStateRestored  )
        {
             if( [ProdId isEqualToString:PURSHASE_NOADS    ] ) AppData.PurchaseNoAds     = TRUE;
        else if( [ProdId isEqualToString:PURSHASE_UNLOCK   ] ) [AppData UnLockAll];
        else if( [ProdId isEqualToString:PURSHASE_SOLUTION1] ) AppData.PurchaseSolLavel1 = TRUE;
        else if( [ProdId isEqualToString:PURSHASE_SOLUTION2] ) AppData.PurchaseSolLavel2 = TRUE;
        else if( [ProdId isEqualToString:PURSHASE_SOLUTION3] ) AppData.PurchaseSolLavel3 = TRUE;
        
        [queue finishTransaction:Transation];
        }
      
    [self ProductInProsess:FALSE ProdId:ProdId];
    }
    
  [AppData Save];
  
  if( PurchaseNotify ) [PurchaseNotify UpdatePurchaseInfo];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Pone el estado de procesamiento del producto
- (void) ProductInProsess:(BOOL) Procesing ProdId:(NSString*) ID
  {
       if( [ID isEqualToString:PURSHASE_NOADS    ] ) AppData.ProcessNoAds     = Procesing;
  else if( [ID isEqualToString:PURSHASE_UNLOCK   ] ) AppData.ProcessUnlock    = Procesing;
  else if( [ID isEqualToString:PURSHASE_SOLUTION1] ) AppData.ProcessSolLavel1 = Procesing;
  else if( [ID isEqualToString:PURSHASE_SOLUTION2] ) AppData.ProcessSolLavel2 = Procesing;
  else if( [ID isEqualToString:PURSHASE_SOLUTION3] ) AppData.ProcessSolLavel3 = Procesing;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Desencadena el proceso de compra de un producto
- (BOOL) PurchaseProduct:(SKProduct*) Prod
  {
  if( Prod == nil )
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Error", nil )
     																								message: NSLocalizedString( @"NoInternet", nil )
    																							 delegate: self 
    																			cancelButtonTitle: NSLocalizedString( @"lbClose", nil )  
    											                otherButtonTitles: nil]; 
    [alert show];
    
    return FALSE;
    }
    
  [self ProductInProsess:TRUE ProdId:Prod.productIdentifier ];
    
#ifdef SIMULATE_INTERNET
  int tm = 3 + rand()%27;
  [NSTimer scheduledTimerWithTimeInterval:tm target:self selector:@selector(Payment:) userInfo:Prod repeats:NO];
#else
  SKPayment* PayRequest = [SKPayment paymentWithProduct:Prod];
  
  [[SKPaymentQueue defaultQueue] addPayment:PayRequest];
#endif
  
  return TRUE;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Funciones especificas para la compra de cada uno de los produtos dentro de la aplicación
- (BOOL)PurchaseNoAds  {return [self PurchaseProduct:ProdNoAds ]; }
- (BOOL)PurchaseUnLock {return [self PurchaseProduct:ProdUnLock]; }
- (BOOL)PurchaseSolut1 {return [self PurchaseProduct:ProdSol1  ]; }
- (BOOL)PurchaseSolut2 {return [self PurchaseProduct:ProdSol2  ]; }
- (BOOL)PurchaseSolut3 {return [self PurchaseProduct:ProdSol3  ]; }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Funciones usadas para simular el proceso se compra
#ifdef SIMULATE_INTERNET

// Emula la función productsRequest, que devuelve información sobre los productos desde AppStore
- (void)ReturnProdInfo: (NSTimer *) timer
  {
  NSLocale* loc = [NSLocale autoupdatingCurrentLocale];
  
  ProdNoAds  = [TestProd new];
  ProdNoAds.productIdentifier = PURSHASE_NOADS;
  ProdNoAds.localizedTitle = @"Quitar los anuncios";
  ProdNoAds.price = [NSDecimalNumber decimalNumberWithMantissa:99 exponent:-2 isNegative:false];
  ProdNoAds.priceLocale = loc;
  
  ProdUnLock = [TestProd new];
  ProdUnLock.productIdentifier = PURSHASE_UNLOCK;
  ProdUnLock.localizedTitle = @"Desbloquear todas las escenas";
  ProdUnLock.price = [NSDecimalNumber decimalNumberWithMantissa:99 exponent:-2 isNegative:false];
  ProdUnLock.priceLocale = loc;
  
  ProdSol1   = [TestProd new];
  ProdSol1.productIdentifier = PURSHASE_SOLUTION1;
  ProdSol1.localizedTitle = @"Soluciones para escenas en el agua";
  ProdSol1.price = [NSDecimalNumber decimalNumberWithMantissa:99 exponent:-2 isNegative:false];
  ProdSol1.priceLocale = loc;
  
  ProdSol2   = [TestProd new];
  ProdSol2.productIdentifier = PURSHASE_SOLUTION2;
  ProdSol2.localizedTitle = @"Soluciones para escenas en el aire";
  ProdSol2.price = [NSDecimalNumber decimalNumberWithMantissa:99 exponent:-2 isNegative:false];
  ProdSol2.priceLocale = loc;
  
  ProdSol3   = [TestProd new];
  ProdSol3.productIdentifier = PURSHASE_SOLUTION3;
  ProdSol3.localizedTitle = @"Soluciones para escenas en el espacio";
  ProdSol3.price = [NSDecimalNumber decimalNumberWithMantissa:99 exponent:-2 isNegative:false];
  ProdSol3.priceLocale = loc;
    
  _Respuesta = true;
  
  if( PurchaseNotify ) [PurchaseNotify UpdatePurchaseInfo];
	}

//---------------------------------------------------------------------------------------------------------------------------------------------
// Emula la función paymentQueue, que es la que recibe la confirmación de AppStore que termino el proceso de compra de un producto
- (void)Payment: (NSTimer *) timer
  {
  SKProduct* Prod = timer.userInfo;
  
  NSString* ProdId = Prod.productIdentifier;
        
       if( [ProdId isEqualToString:PURSHASE_NOADS    ] ) AppData.PurchaseNoAds     = TRUE;
  else if( [ProdId isEqualToString:PURSHASE_UNLOCK   ] ) [AppData UnLockAll];
  else if( [ProdId isEqualToString:PURSHASE_SOLUTION1] ) AppData.PurchaseSolLavel1 = TRUE;
  else if( [ProdId isEqualToString:PURSHASE_SOLUTION2] ) AppData.PurchaseSolLavel2 = TRUE;
  else if( [ProdId isEqualToString:PURSHASE_SOLUTION3] ) AppData.PurchaseSolLavel3 = TRUE;
    
  [AppData Save];
  
  [self ProductInProsess:FALSE ProdId:ProdId];
  
  if( PurchaseNotify ) [PurchaseNotify UpdatePurchaseInfo];
  }

#endif
//-----------------------------------------------------------------------------------------------------------------------------------------


@end

//=========================================================================================================================================
