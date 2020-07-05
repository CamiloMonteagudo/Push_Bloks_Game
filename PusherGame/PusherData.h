//
//  PusherData.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 29/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>

//=========================================================================================================================================
@interface PusherData : NSObject

@property (weak, nonatomic) UIImageView *Ctl;
@property (copy, nonatomic) NSString *Name;

@property int  Col;
@property int  Row;
@property Byte On;

+ (PusherData *) FromString: (NSString *) sData;

- (void) AssociteView:(UIImageView*) view;
- (void) MoveCol:(int) col Row:(int) row;

- (void) StartAnimate;
- (void) EndAnimate;

- (float) Angle;
- (void)  setAngle:(float) ang;
- (NSMutableArray*) GetAnimImgs;

@end

//=========================================================================================================================================
