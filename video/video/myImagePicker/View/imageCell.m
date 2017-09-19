//
//  imageCell.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/20.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "imageCell.h"
#import <Masonry.h>

@interface imageCell()

@property (nonatomic, strong) UIImageView* videoImageView;

@end
@implementation imageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark - setupView
-(void)setupView{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    
    [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.mas_equalTo(self.contentView);
    }];
}


#pragma mark - getter
-(UIImageView *)videoImageView{
    if (_videoImageView == nil) {
        _videoImageView = [[UIImageView alloc]init];
        _videoImageView.layer.cornerRadius = 14.0f;
        _videoImageView.layer.masksToBounds = YES;
        [_videoImageView setContentMode:UIViewContentModeScaleToFill];
        [self.contentView addSubview:_videoImageView];
    }
    return _videoImageView;
}

- (void)setVideoImage:(UIImage *)videoImage {
    [self.videoImageView setImage:videoImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
