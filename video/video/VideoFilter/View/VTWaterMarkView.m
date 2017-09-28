//
//  VTWaterMarkView.m
//  vtell
//
//  Created by 刘鑫忠 on 2017/9/21.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTWaterMarkView.h"
#import <Masonry.h>

@interface VTWaterMarkView ()

@property (nonatomic, strong) UIView          *contentView;
@property (nonatomic, strong) UIImageView     *waterMarkImageView;
@property (nonatomic, strong) UILabel         *userNameLabel;

@end

@implementation VTWaterMarkView


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
    self.backgroundColor = [UIColor blueColor];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.waterMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-48);
        make.width.mas_equalTo(@108);
        make.height.mas_equalTo(@46);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-28);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.left.lessThanOrEqualTo(self.contentView.mas_left).offset(20);
        make.height.mas_equalTo(@32);
    }];
    
    [self layoutIfNeeded];
}

- (UIView*)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:self.viewFrame];
        [self addSubview:_contentView];
    }
    return _contentView;
}
- (UIImageView*)waterMarkImageView {
    if(!_waterMarkImageView) {
        _waterMarkImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"midWaterMark"]];
        [self.contentView addSubview:_waterMarkImageView];
    }
    return _waterMarkImageView;
}

- (UILabel*)userNameLabel {
    if(!_userNameLabel) {
        _userNameLabel = [self createLabel];
        _userNameLabel.font = [UIFont systemFontOfSize:30.0f];
        _userNameLabel.textAlignment = NSTextAlignmentRight;
        _userNameLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_userNameLabel];
    }
    return _userNameLabel;
}

-(UILabel *)createLabel{
    UILabel *label = [[UILabel alloc]init];
    return label;
}

#pragma mark - setter
- (void)setUserName:(NSString *)userName {
    self.userNameLabel.text = [NSString stringWithFormat:@"@%@",userName];
}

@end
