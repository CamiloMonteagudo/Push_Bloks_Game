//
//  Purchases.h
//  SmartPusher
//
//  Created by Camilo on 05/12/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//
#ifdef FREE_TO_PLAY

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "GlobalData.h"

//=========================================================================================================================================
#ifdef SIMULATE_INTERNET

#define SKProduct TestProd

@interface TestProd : NSObject

@property(nonatomic) NSString *productIdentifier;
@property(nonatomic) NSString *localizedTitle;

@property(nonatomic) NSDecimalNumber *price;
@property(nonatomic) NSLocale *priceLocale;

@end
#endif

//=========================================================================================================================================
@protocol ShowPurchaseUI
- (void) UpdatePurchaseInfo;
@end


//=========================================================================================================================================
@interface Purchases : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

  @property (readonly) SKProduct* ProdNoAds;
  @property (readonly) SKProduct* ProdUnLock;
  @property (readonly) SKProduct* ProdSol1;
  @property (readonly) SKProduct* ProdSol2;
  @property (readonly) SKProduct* ProdSol3;
  
  @property bool Respuesta;

  +(void) CreateAppPurshases;

  - (void)RestorePurchases;
  - (void)RequestProdInfo;

  - (BOOL)PurchaseNoAds;
  - (BOOL)PurchaseUnLock;
  - (BOOL)PurchaseSolut1;
  - (BOOL)PurchaseSolut2;
  - (BOOL)PurchaseSolut3;

  @property (nonatomic) id<ShowPurchaseUI> PurchaseNotify;

@end
//=========================================================================================================================================

extern Purchases* AppPurchases;

//=========================================================================================================================================
#endif