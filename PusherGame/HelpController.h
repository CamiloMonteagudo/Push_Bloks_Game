//
//  HelpController.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 21/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpView.h"

//=========================================================================================================================================
@interface HelpController : UIViewController

@property (weak, nonatomic) IBOutlet HelpView    *HelpZone;
@property (weak, nonatomic) IBOutlet UIView      *HelpFrame;
@property (weak, nonatomic) IBOutlet UILabel     *TopicDesc;
@property (weak, nonatomic) IBOutlet UIButton    *btnPrevTopic;
@property (weak, nonatomic) IBOutlet UIButton    *btnRepitTopic;
@property (weak, nonatomic) IBOutlet UIButton    *btnNextTopic;

@property (weak, nonatomic) IBOutlet UIImageView *Pusher;
@property (weak, nonatomic) IBOutlet UIImageView *Hand;

@property (weak, nonatomic) IBOutlet UIImageView *Target1;
@property (weak, nonatomic) IBOutlet UIImageView *Target2;
@property (weak, nonatomic) IBOutlet UIImageView *Target3;
@property (weak, nonatomic) IBOutlet UIImageView *Target4;

@property (weak, nonatomic) IBOutlet UIImageView *Block1;
@property (weak, nonatomic) IBOutlet UIImageView *Block2;
@property (weak, nonatomic) IBOutlet UIImageView *Block3;
@property (weak, nonatomic) IBOutlet UIImageView *Block4;

- (IBAction)OnPrevTopic:(id)sender;
- (IBAction)OnRepitTopic:(id)sender;
- (IBAction)OnNextTopic:(id)sender;

@end
//=========================================================================================================================================
