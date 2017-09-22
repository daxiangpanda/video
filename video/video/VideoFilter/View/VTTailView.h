//
//  VTWaterMarkView.h
//  vtell
//
//  Created by 刘鑫忠 on 2017/9/21.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTTailView : UIView

@property (nonatomic,strong) UIImage       *lastFrameImage;
@property (nonatomic,strong) NSString      *userName;
@property (nonatomic,assign) CGFloat       virtualEffectAlpha;
@property (nonatomic,assign) CGFloat       waterMarkAlpha;
@end
