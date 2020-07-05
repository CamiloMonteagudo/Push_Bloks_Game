//
//  PurchaseController.h
//  SmartPusher
//
//  Created by Camilo on 06/12/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Purchases.h"

#ifdef FREE_TO_PLAY

@interface PurchaseController : UIViewController <ShowPurchaseUI>

@property (nonatomic) int FlashItem;

@end

#endif