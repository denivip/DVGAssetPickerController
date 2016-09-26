//
//  DVGAssetPickerViewController.h
//  Together
//
//  Created by Nikolay Morev on 17.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DVGAssetPickerMenuItem) {
    DVGAssetPickerMenuItemPhotoLibrary,
    DVGAssetPickerMenuItemCamera,
    DVGAssetPickerMenuItemCancel,
};

@class DVGAssetPickerViewController;

@protocol DVGAssetPickerDelegate <NSObject>

- (void)contentPickerViewController:(DVGAssetPickerViewController *)controller
                    didSelectAssets:(NSArray<PHAsset*> *)assets;
- (void)contentPickerViewController:(DVGAssetPickerViewController *)controller
                    clickedMenuItem:(DVGAssetPickerMenuItem)menuItem;
- (void)contentPickerViewControllerDidCancel:(DVGAssetPickerViewController *)controller;

@end


@protocol DVGAssetPickerDataSource <NSObject>

@optional
- (NSDictionary *)contentPickerViewController:(DVGAssetPickerViewController *)controller
                    textAttributesForMenuItem:(DVGAssetPickerMenuItem)menuItem;

@end


@interface DVGAssetPickerViewController : UIViewController

- (instancetype)init;
- (void)cancel;
@property (nonatomic, weak) _Nullable id<DVGAssetPickerDelegate> delegate;
@property (nonatomic, weak) _Nullable id<DVGAssetPickerDataSource> dataSource;
@property (strong, nonatomic) PHPhotoLibrary * photoLibrary;

@end

NS_ASSUME_NONNULL_END
