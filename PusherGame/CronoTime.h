//
//  CronoTime.h
//  PusherGame
//
//  Created by Camilo Monteagudo Pena on 20/08/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CronoTime : NSObject
  {
  NSDate *TimeRef;
  double TimeSave;
  NSTimer	*ClockTimer;
  
  SEL  UpdateFunc;
  id   UpdateObj;
  }

- (void)   SetUpdateSel:(SEL) uptFunc Class:(id) class;
- (void)   Start;
- (double) GetTime;
- (void)   Stop;
- (void)   Pause;
- (void)   Restore;

@end
