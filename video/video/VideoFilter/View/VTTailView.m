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
@property (nonatomic, strong) UIVisualEffect              *visualEffect;
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
    
    [self.l mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-28);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
        make.left.lessThanOrEqualTo(self.mas_left).offset(20);
        make.height.mas_equalTo(@32);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-28);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
        make.left.lessThanOrEqualTo(self.mas_left).offset(20);
        make.height.mas_equalTo(@32);
    }];
    
    [self layoutIfNeeded];
}

- (void)setart{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:30 animations:^{
            self.userNameLabel.frame = CGRectMake(0, 80, 30, 20);
        }];
    });
}




- (UILabel*)userNameLabel {
    if(!_userNameLabel) {
        _userNameLabel = [self createLabel];
        _userNameLabel.font = [UIFont systemFontOfSize:50.0f];
        _userNameLabel.textAlignment = NSTextAlignmentRight;
        _userNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_userNameLabel];
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
