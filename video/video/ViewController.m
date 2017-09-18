//
//  ViewController.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/18.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "ViewController.h"
#import <TZImagePickerController.h>

@interface ViewController ()<TZImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *openImagePicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.openImagePicker addTarget:self action:@selector(openImagePickerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)openImagePickerButtonTapped{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    
    

    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
}

@end
