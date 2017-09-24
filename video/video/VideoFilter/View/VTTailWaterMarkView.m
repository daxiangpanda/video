#import "VTTailWaterMarkView.h"
#import <Masonry.h>
@interface VTTailWaterMarkView ()

//原图
@property (nonatomic, strong) UIImageView                 *appNameImageView;

@property (nonatomic, strong) UILabel                     *userNameLabel;

@end

@implementation VTTailWaterMarkView


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
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
//        make.height.mas_equalTo(@100);
//        make.width.mas_equalTo(self.mas_width);
    }];
    
    [self.appNameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(-50);
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

- (UIImageView*)appNameImageView {
    if(!_appNameImageView) {
        _appNameImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"trailWaterMark_appIcon"]];

        [self addSubview:_appNameImageView];
    }
    return _appNameImageView;
}


- (UILabel*)userNameLabel {
    if(!_userNameLabel) {
        _userNameLabel = [self createLabel];
        _userNameLabel.font = [UIFont systemFontOfSize:20.0f];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.backgroundColor = [UIColor blackColor];
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
    self.userNameLabel.text = [NSString stringWithFormat:@"%@",userName];
}

- (void)setWaterMarkAlpha:(CGFloat)waterMarkAlpha {
    self.userNameLabel.alpha = waterMarkAlpha;
    self.appNameImageView.alpha = waterMarkAlpha;
    
}

@end
