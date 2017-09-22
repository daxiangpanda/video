//
//  VTTailView.m
//  vtell
//
//  Created by 刘鑫忠 on 2017/9/21.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTTailView.h"
#import "VTTailWaterMarkView.h"
#import <Masonry.h>
@interface VTTailView ()

//原图
@property (nonatomic, strong) UIImageView                 *lastFrameView;
//模糊效果
@property (nonatomic, strong) UIVisualEffectView          *visualEffectView;
//片尾水印
@property (nonatomic, strong) VTTailWaterMarkView         *tailWaterMarkView;

@end

@implementation VTTailView


#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
    }
    return self;
}


#pragma mark - setupView
- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.lastFrameView];
    [self addSubview:self.tailWaterMarkView];
    [self addSubview:self.visualEffectView];
    
    [self.lastFrameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
//
    [self.tailWaterMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self layoutIfNeeded];
}

//- (void)setart{
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:30 animations:^{
//            self.userNameLabel.frame = CGRectMake(0, 80, 30, 20);
//        }];
//    });
//}


- (UIImageView*)lastFrameView {
    if(!_lastFrameView) {
        _lastFrameView = [[UIImageView alloc]init];
        
    }
    return _lastFrameView;
}

- (UIVisualEffectView *)visualEffectView {
    if (_visualEffectView == nil) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        _visualEffectView.alpha = 0.9;
        _visualEffectView.backgroundColor = [UIColor clearColor];
        _visualEffectView.userInteractionEnabled = NO;
    }
    return _visualEffectView;
}

- (VTTailWaterMarkView*)tailWaterMarkView {
    if(!_tailWaterMarkView) {
        _tailWaterMarkView = [[VTTailWaterMarkView alloc]init];
    }
    return _tailWaterMarkView;
}

-(UILabel *)createLabel{
    UILabel *label = [[UILabel alloc]init];
    return label;
}

#pragma mark - setter
- (void)setUserName:(NSString *)userName {
    self.tailWaterMarkView.userName = [NSString stringWithFormat:@"@%@",userName];
}

- (void)setVirtualEffectAlpha:(CGFloat)virtualEffectAlpha {
    self.visualEffectView.alpha = virtualEffectAlpha;
}

- (void)setWaterMarkAlpha:(CGFloat)waterMarkAlpha {
    self.tailWaterMarkView.alpha = waterMarkAlpha;
}

- (void)setLastFrameImage:(UIImage *)lastFrameImage {
    self.lastFrameView.image = lastFrameImage;
}
@end
