//
//  ViewController.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/18.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "ViewController.h"
#import "myImagePickerViewController.h"
#import "RecordVideoController.h"

@interface ViewController()

@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addButtonTarget];
}

- (void)addButtonTarget {
    [self.imagePickerButton addTarget:self action:@selector(imagePickerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)imagePickerButtonClick {
    myImagePickerViewController *myIMPicker = [[myImagePickerViewController alloc]init];
    [self.navigationController pushViewController:myIMPicker animated:YES];
}

- (void)recordButtonClick {
    RecordVideoController *recordVC = [[RecordVideoController alloc]init];
    [self.navigationController pushViewController:recordVC animated:YES];
}

@end
