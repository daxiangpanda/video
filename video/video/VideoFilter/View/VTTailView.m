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

@property (nonatomic, strong) UIView                      *contentView;
@property (nonatomic, strong) UIImageView                 *appNameImageView;
@property (nonatomic, strong) UIImageView                 *appSlogenImageView;
@property (nonatomic, strong) UIImageView                 *appLogoImageView;
@property (nonatomic, strong) UILabel                     *userNameLabel;
@property (nonatomic, assign) CGFloat                     ratioInside;

@end

@implementation VTTailView


#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame  {
    
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
    }
    return self;
}


#pragma mark - setupView
- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    self.ratioInside = self.frame.size.width/375;
    [self.contentView addSubview:self.appNameImageView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.appSlogenImageView];
    [self.contentView addSubview:self.appLogoImageView];
    self.userNameLabel.font = [UIFont systemFontOfSize:12.0*self.ratioInside];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(148*self.ratioInside);
        make.right.greaterThanOrEqualTo(self.contentView.mas_right);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(@(14*self.ratioInside));
    }];
    
    [self.appNameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(150*self.ratioInside);
        make.top.mas_equalTo(self.contentView.mas_top).offset(108*self.ratioInside);
        make.width.mas_equalTo(@(89*self.ratioInside));
        make.height.mas_equalTo(@(18*self.ratioInside));
    }];
    
    [self.appSlogenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(82*self.ratioInside);
        make.top.mas_equalTo(self.userNameLabel.mas_bottom).offset(10*self.ratioInside);
        make.width.mas_equalTo(@(210*self.ratioInside));
        make.height.mas_equalTo(@(28*self.ratioInside));
    }];
    
    [self.appLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(99*self.ratioInside);
        make.top.mas_equalTo(self.contentView.mas_top).offset(104*self.ratioInside);
        make.width.mas_equalTo(@(44*self.ratioInside));
        make.height.mas_equalTo(@(44*self.ratioInside));
    }];

//

    
    [self layoutIfNeeded];
}

//- (void)setart{
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:30 animations:^{
//            self.userNameLabel.frame = CGRectMake(0, 80, 30, 20);
//        }];
//    });
//}

#pragma mark - public

- (UIView*)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:self.frame];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIImageView *)appSlogenImageView {
    
    if(!_appSlogenImageView) {
        _appSlogenImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tailView_slogen"]];
    }
    return _appSlogenImageView;
}
- (UIImageView*)appNameImageView {
    if(!_appNameImageView) {
        _appNameImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tailView_appName"]];
        
    }
    return _appNameImageView;
}

- (UIImageView*)appLogoImageView {
    if(!_appLogoImageView) {
        _appLogoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tailView_appLogo"]];
        
    }
    return _appLogoImageView;
}

- (UILabel*)userNameLabel {
    if(!_userNameLabel) {
        _userNameLabel = [self createLabel];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.backgroundColor = [UIColor blackColor];
    }
    return _userNameLabel;
}

-(UILabel *)createLabel{
    UILabel *label = [[UILabel alloc]init];
    return label;
}

- (CGFloat)ratioInside {
    if(_ratioInside!=0){
        return _ratioInside;
    }
    return 1.0f;
}

#pragma mark - setter
- (void)setUserName:(NSString *)userName {
    self.userNameLabel.text = [NSString stringWithFormat:@"导演•%@",userName];
}






@end
