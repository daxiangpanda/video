//
//  UIView+Extension.m
//  video
//
//  Created by 刘鑫忠 on 2018/7/25.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

 - (void)setViewBorderWithcolor:(UIColor *)color radius:(float)radius border:(float)border{
    //设置layer
    CALayer *layer=[self layer];
    //是否设置边框以及是否可见
    [layer setMasksToBounds:YES];
    //设置边框圆角的弧度
    [layer setCornerRadius:radius];
    //设置边框线的宽
    [layer setBorderWidth:border];
    //设置边框线的颜色
    [layer setBorderColor:[color CGColor]];
}

@end
