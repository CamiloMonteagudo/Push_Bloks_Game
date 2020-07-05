//
//  StatisticalsController.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 06/07/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticalsController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *pntsTotal;
@property (weak, nonatomic) IBOutlet UIView *ToolBar;
@property (weak, nonatomic) IBOutlet UIButton *bntToolBar;
@property (weak, nonatomic) IBOutlet UITableView *LstScenes;

- (IBAction)btnBack:(id)sender;
- (IBAction)OnToolBar:(UIButton *)sender;
- (IBAction)OnGameCenter:(id)sender;
- (IBAction)OnSortScores:(id)sender;

@end
