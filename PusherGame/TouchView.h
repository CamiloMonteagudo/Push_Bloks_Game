//
//  TouchView.h
//  GameTest2
//
//  Created by Camilo Monteagudo on 06/03/14.
//  Copyright (c) 2014 Camilo Monteagudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SceneController;

//=========================================================================================================================================
@interface TouchView : UIView

@property (weak, nonatomic)	NSTimer	*IniTimer;
@property (strong, nonatomic) SceneController *Controller;

@end
//=========================================================================================================================================
