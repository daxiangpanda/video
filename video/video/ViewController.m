//
//  ViewController.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/18.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "ViewController.h"
#import "myImagePickerViewController.h"

@interface ViewController()

@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.imagePickerButton addTarget:self action:@selector(imagePickerButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)imagePickerButtonClick {
    myImagePickerViewController *myIMPicker = [[myImagePickerViewController alloc]init];
    [self.navigationController pushViewController:myIMPicker animated:YES];
}



@end
