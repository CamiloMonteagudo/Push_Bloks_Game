//
//  ScenePages.h
//  SmartPusher
//
//  Created by Camilo on 23/11/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>

//=========================================================================================================================================


//=========================================================================================================================================
@interface ScenePages : NSObject

- (ScenePages*) initWithSize:(CGSize) size Cols:(int) Cols Rows:(int) Rows;

- (void)     LoadPages;
- (UIImage*) GetPage:(int) idx;
- (int)      PageCount;
- (int)      SceneAtPoint:(CGPoint)pnt Page:(int)pg;
- (BOOL)     UpdatePoints;
- (CGRect)   IconFrameScene:(int)idx;
- (int)      PageScene:(int)idx;

@end
//=========================================================================================================================================
