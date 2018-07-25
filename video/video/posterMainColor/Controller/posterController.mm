//
//  posterMainColor.m
//  video
//
//  Created by 刘鑫忠 on 2018/7/25.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import "posterController.h"
#import "UIImage+PointColor.h"
#import "UIImage+ColorImage.h"
#import "Palette.h"
#import "UIImage+Palette.h"
#import "UIColor+Enhancement.h"
#import "PosterView.h"
//#import <opencv2/opencv.hpp>

@interface posterController()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) PosterView *posterImageView;

@end


@implementation posterController

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
}

- (void)viewDidLoad {
    UIImage *backgroundImage = [UIImage imageNamed:@"indoor.jpg"];
    self.backgroundImageView.image = backgroundImage;
    
    __weak typeof (self) weakSelf = self;

    [backgroundImage getPaletteImageColor:^(PaletteColorModel *recommendColor, NSDictionary *allModeColorDic, NSError *error) {
        if (!recommendColor){
            return;
        }
        weakSelf.posterImageView.mainColor = [UIColor colorFromRGBcode:recommendColor.imageColorString];
    }];
}

- (UIImageView *)backgroundImageView {
    if(!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self.view addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (PosterView *)posterImageView {
    if(!_posterImageView) {
        _posterImageView = [[PosterView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 5 * 4, [UIScreen mainScreen].bounds.size.height / 5 * 4)];
        _posterImageView.center = self.backgroundImageView.center;
        [self.view addSubview:_posterImageView];
    }
    return _posterImageView;
}
@end
