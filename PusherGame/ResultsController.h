//
//  ResultsController.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 31/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <UIKit/UIKit.h>

//=========================================================================================================================================
@interface ResultsController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *ResultFrame;

@property (weak, nonatomic) IBOutlet UIImageView *ImgStar1;
@property (weak, nonatomic) IBOutlet UIImageView *ImgStar2;
@property (weak, nonatomic) IBOutlet UIImageView *ImgStar3;
@property (weak, nonatomic) IBOutlet UIImageView *ImgStar4;
@property (weak, nonatomic) IBOutlet UIImageView *ImgStar5;

@property (weak, nonatomic) IBOutlet UILabel *PntsCompled;
@property (weak, nonatomic) IBOutlet UILabel *PntsMove;
@property (weak, nonatomic) IBOutlet UILabel *PntsTime;
@property (weak, nonatomic) IBOutlet UILabel *PntsTotal;

@property (weak, nonatomic) IBOutlet UILabel *lbCompled;
@property (weak, nonatomic) IBOutlet UILabel *lbMoves;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbTotal;

@property (weak, nonatomic) IBOutlet UIButton *btnFace;
@property (weak, nonatomic) IBOutlet UIButton *btnGame;


- (IBAction)OnSelScenes:(UIButton *)sender;
- (IBAction)OnRestar:(UIButton *)sender;
- (IBAction)OnNext:(UIButton *)sender;
- (IBAction)OnBtnGame:(id)sender;
- (IBAction)OnBtnFace:(id)sender;

@end

//=========================================================================================================================================
