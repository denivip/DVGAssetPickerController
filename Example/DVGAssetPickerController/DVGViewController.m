//
//  DVGViewController.m
//  DVGAssetPickerController
//
//  Created by Nikolay Morev on 01/22/2015.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "DVGViewController.h"
#import <DVGAssetPickerController/DVGAssetPickerViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface DVGViewController ()
<DVGAssetPickerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *imagesContainer;

@end

@implementation DVGViewController

- (void)showAssetsThumbnails:(NSArray *)assets
{
    for (UIView *view in self.imagesContainer.subviews) {
        [view removeFromSuperview];
    }

    NSUInteger assetsCount = assets.count;
    CGRect bounds = self.imagesContainer.bounds;
    CGFloat padding = 8.f;
    bounds = CGRectInset(bounds, padding, padding);
    CGFloat distance = CGRectGetHeight(bounds) / assetsCount;

    for (ALAsset *asset in assets) {
        NSLog(@"%@", asset);

        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;

        CGRect slice, remainder;
        CGRectDivide(bounds, &slice, &remainder, distance, CGRectMinYEdge);
        bounds = remainder;

        imageView.frame = slice;
        [self.imagesContainer addSubview:imageView];

        CGRectDivide(remainder, &slice, &remainder, padding, CGRectMinYEdge);
        bounds = remainder;
    }
}

- (IBAction)pickPhoto:(id)sender
{
    DVGAssetPickerViewController *picker = [[DVGAssetPickerViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - DVGAssetPickerDelegate

- (void)contentPickerViewController:(DVGAssetPickerViewController *)controller
                    didSelectAssets:(NSArray *)assets
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self showAssetsThumbnails:assets];
    }];
}

- (void)contentPickerViewController:(DVGAssetPickerViewController *)controller
                    clickedMenuItem:(DVGAssetPickerMenuItem)menuItem
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self dismissViewControllerAnimated:YES completion:^{
        UIImagePickerControllerSourceType sourceType;
        switch (menuItem) {
            case DVGAssetPickerMenuItemPhotoLibrary:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;

            case DVGAssetPickerMenuItemCamera:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;

            case DVGAssetPickerMenuItemCancel:
                break;
        }

        switch (menuItem) {
            case DVGAssetPickerMenuItemPhotoLibrary:
            case DVGAssetPickerMenuItemCamera: {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = NO;
                imagePickerController.sourceType = sourceType;
                imagePickerController.mediaTypes = @[ (id)kUTTypeImage ];
                [self presentViewController:imagePickerController animated:YES completion:nil];
                break;
            }

            case DVGAssetPickerMenuItemCancel:
                break;
        }
    }];
}

- (void)contentPickerViewControllerDidCancel:(DVGAssetPickerViewController *)controller
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
