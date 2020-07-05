//
//  ViewController.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 18/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GlobalData.h"

@interface MainController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *bntSound;
@property (weak, nonatomic) IBOutlet UIButton *bntTwitter;
@property (weak, nonatomic) IBOutlet UIButton *bntGameCenter;
@property (weak, nonatomic) IBOutlet UIButton *bntFacebook;

- (IBAction)OnChangeSound:(UIButton *)sender;
- (IBAction)OnTwitterBtn:(id)sender;
- (IBAction)OnFecebookBtn:(id)sender;
- (IBAction)OnGameCenter:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *ShowZone;

@end
