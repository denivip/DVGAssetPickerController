//
//  DVGAssetPickerCollectionViewCell.m
//  Together
//
//  Created by Nikolay Morev on 17.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGAssetPickerCollectionViewCell.h"

@implementation DVGAssetPickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;

        NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    }
    return self;
}

@end
