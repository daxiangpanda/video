//
//  ViewController.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/18.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *openImagePicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.openImagePicker addTarget:self action:@selector(openImagePickerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)openImagePickerButtonTapped{
    UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
//    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets) {
//        
//    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
