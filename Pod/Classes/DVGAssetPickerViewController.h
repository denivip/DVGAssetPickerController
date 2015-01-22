//
//  DVGAssetPickerViewController.h
//  Together
//
//  Created by Nikolay Morev on 17.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSUInteger, DVGAssetPickerMenuItem) {
    DVGAssetPickerMenuItemPhotoLibrary,
    DVGAssetPickerMenuItemCamera,
    DVGAssetPickerMenuItemCancel,
};

@class DVGAssetPickerViewController;

@protocol DVGAssetPickerDelegate <NSObject>

- (void)contentPickerViewController:(DVGAssetPickerViewController *)controller
                    didSelectAssets:(NSArray *)assets;
- (void)contentPickerViewController:(DVGAssetPickerViewController *)controller
                    clickedMenuItem:(DVGAssetPickerMenuItem)menuItem;
- (void)contentPickerViewControllerDidCancel:(DVGAssetPickerViewController *)controller;

@end

@interface DVGAssetPickerViewController : UIViewController

- (instancetype)init;
- (void)cancel;
@property (nonatomic, weak) id<DVGAssetPickerDelegate> delegate;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@end
