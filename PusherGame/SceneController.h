//
//  SceneController.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 18/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalData.h"
#import "TouchView.h"
#import <iAd/iAd.h>

#ifdef FREE_TO_PLAY
  @interface SceneController : UIViewController <ADBannerViewDelegate>
#else
  @interface SceneController : UIViewController
#endif
  {
  double tmGame;
  }

@property (weak, nonatomic) IBOutlet UIView      *GameZone;
@property (weak, nonatomic) IBOutlet UIView      *ToolBar;
@property (weak, nonatomic) IBOutlet UIButton    *bntToolBar;
@property (weak, nonatomic) IBOutlet UIImageView *PucherCtl;
@property (weak, nonatomic) IBOutlet TouchView   *VTouch;
@property (weak, nonatomic) IBOutlet UIView      *Results;
@property (weak, nonatomic) IBOutlet UIView      *InfoBar;
@property (weak, nonatomic) IBOutlet UILabel     *txtMoves;
@property (weak, nonatomic) IBOutlet UILabel     *txtTime;
@property (weak, nonatomic) IBOutlet UILabel     *txtNScene;
@property (weak, nonatomic) IBOutlet UIButton    *bntSound;

@property bool AnimOn;
@property bool SolucOn;
@property int  NegPnts;

- (IBAction) OnToolBar:(id)sender;
- (IBAction) OnSelScenes:(id)sender;
- (IBAction) OnRestar:(id)sender;
- (IBAction) OnUndo:(id)sender;
- (IBAction) OnSolution:(id)sender;
- (IBAction) OnPrevScene:(id)sender;
- (IBAction) OnNextScene:(id)sender;
- (IBAction) OnSound:(UIButton *)sender;

- (void) AnimatePath;
- (void) LoadActualScene;
- (void) ShowTooBar:(BOOL)show Animate:(BOOL) Anim;
- (void) ResultsShow:(BOOL) show;
- (bool) SceneNavegate: (int) inc;

@end
