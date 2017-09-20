//
//  myImagePickerViewController.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/18.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "myImagePickerViewController.h"
#import "imagePickerLayout.h"
#import "imageCell.h"
#import <UIKit/UIKit.h>
#import <TZImagePickerController.h>
#import <Photos/Photos.h>
#import <Masonry.h>

@interface myImagePickerViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray     *photoArray;
@property (nonatomic, strong) imagePickerLayout *layout;
@end

@implementation myImagePickerViewController

#pragma mark - life cycle
- (id)initWithColumnsCount:(NSInteger)count {
    imagePickerLayout *layout = [[imagePickerLayout alloc] initWithColumsCount:count];
    if (self = [super initWithCollectionViewLayout:layout]) {
        _layout = layout;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getOriginalImages];
    [self setupView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupView {
//    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.view);
//    }];
}


#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.width/4*3;
}

#pragma mark - tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    imageCell *cell = [[imageCell alloc]init];
    if(indexPath.row<_photoArray.count){
        cell.videoImage = [_photoArray objectAtIndex:indexPath.row];
    }
    return cell;
}




//#pragma mark - getter
//- (UITableView*)tableView {
//    if(!_tableView) {
//        _tableView = [[UITableView alloc]init];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//    }
//    return _tableView;
//}

- (NSMutableArray*)photoArray {
    if(!_photoArray) {
        _photoArray = [[NSMutableArray alloc]init];
    }
    return _photoArray;
}

- (void)getOriginalImages
{
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:YES];
    }
    
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    // 遍历相机胶卷,获取大图
    [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
}


/**
 *  遍历相簿中的所有图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        // 是否要原图
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        
        // 从asset中获得图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [self.photoArray addObject:result];
            NSLog(@"%@", result);
        }];
    }
}


@end
