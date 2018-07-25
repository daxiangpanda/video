//
//  PosterView.m
//  video
//
//  Created by 刘鑫忠 on 2018/7/25.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import "PosterView.h"
#import <Masonry.h>
#import "UIView+Extension.h"
@interface PosterView()

@property (nonatomic, strong) UILabel *bigTextLabel;
@property (nonatomic, strong) UILabel *mediumTextLabel;
@property (nonatomic, strong) UILabel *smallTextLabel;
@property (nonatomic, strong) UILabel *chLabel;

@property (nonatomic, strong) UIView *contentView;

@end


@implementation PosterView


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
    [self setViewBorderWithcolor:[UIColor whiteColor] radius:0 border:10.0f];
    
    [self.contentView addSubview:self.smallTextLabel];
    [self.contentView addSubview:self.mediumTextLabel];
    [self.contentView addSubview:self.bigTextLabel];
    [self.contentView addSubview:self.chLabel];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.smallTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-5);
        make.left.mas_equalTo(self.contentView.mas_left).offset(5);
        make.top.mas_equalTo(@30);
        make.height.mas_equalTo(@30);
    }];
    
    [self.mediumTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.top.mas_equalTo(self.smallTextLabel.mas_bottom).offset(50);
        make.height.mas_equalTo(@40);
    }];
    
    [self.bigTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.left.mas_equalTo(self.contentView.mas_left	).offset(15);
        make.top.mas_equalTo(self.mediumTextLabel.mas_bottom).offset(40);
        make.height.mas_equalTo(@50);
    }];
    
    [self.chLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.left.mas_equalTo(self.contentView.mas_left    ).offset(15);
        make.top.mas_equalTo(self.bigTextLabel.mas_bottom).offset(40);
        make.height.mas_equalTo(@50);
    }];
    
    [self layoutIfNeeded];
}

- (void)setMainColor:(UIColor *)mainColor {
    self.contentView.backgroundColor = [mainColor colorWithAlphaComponent:0.8f];
}

- (UIView*)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:self.frame];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UILabel *)smallTextLabel {
    if(!_smallTextLabel) {
        _smallTextLabel = [self createLabel];
        _smallTextLabel.backgroundColor = [UIColor clearColor];
        _smallTextLabel.textAlignment = NSTextAlignmentCenter;
        _smallTextLabel.textColor = [UIColor whiteColor];
        _smallTextLabel.font = [UIFont italicSystemFontOfSize:30.0f];
        _smallTextLabel.text = @"Hurry!Ends at 12PM...";
    }
    return _smallTextLabel;
}


- (UILabel *)mediumTextLabel {
    if(!_mediumTextLabel) {
        _mediumTextLabel = [self createLabel];
        _mediumTextLabel.backgroundColor = [UIColor clearColor];
        _mediumTextLabel.textAlignment = NSTextAlignmentCenter;
        _mediumTextLabel.textColor = [UIColor whiteColor];
        _mediumTextLabel.font = [UIFont boldSystemFontOfSize:40.0f];
        _mediumTextLabel.text = @"THE 20-HOUR";
    }
    return _mediumTextLabel;
}

- (UILabel *)bigTextLabel {
    if(!_bigTextLabel) {
        _bigTextLabel = [self createLabel];
        _bigTextLabel.backgroundColor = [UIColor clearColor];
        _bigTextLabel.textAlignment = NSTextAlignmentCenter;
        _bigTextLabel.textColor = [UIColor whiteColor];
        _bigTextLabel.font = [UIFont monospacedDigitSystemFontOfSize:50.0f weight:5.0f];
        _bigTextLabel.text = @"EVENT";
    }
    return _bigTextLabel;
}

- (UILabel *)chLabel {
    if(!_chLabel) {
        _chLabel = [self createLabel];
        _chLabel.backgroundColor = [UIColor clearColor];
        _chLabel.textAlignment = NSTextAlignmentCenter;
        _chLabel.textColor = [UIColor whiteColor];
        _chLabel.font = [UIFont monospacedDigitSystemFontOfSize:80.0f weight:10.0f];
        _chLabel.text = @"甩卖~";
    }
    return _chLabel;
}

-(UILabel *)createLabel{
    UILabel *label = [[UILabel alloc]init];
    return label;
}
@end

