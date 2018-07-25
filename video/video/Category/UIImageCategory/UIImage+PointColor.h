//
//  UIImage+PointColor.h
//  video
//
//  Created by 刘鑫忠 on 2018/7/25.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (PointColor)

- (UIColor *)colorAtPixel:(CGPoint)point;
- (UIColor *)averageColor;
@end

NS_ASSUME_NONNULL_END
