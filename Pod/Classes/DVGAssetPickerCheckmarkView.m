//
//  DVGAssetPickerCheckmarkView.m
//  Together
//
//  Created by Nikolay Morev on 19.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGAssetPickerCheckmarkView.h"

@interface DVGAssetPickerCheckmarkView ()
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation DVGAssetPickerCheckmarkView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [UIImage imageNamed:@"DVGAssetPickerController.bundle/BlueCheckUnselected"];
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    self.imageView.image = (_selected
                            ? [UIImage imageNamed:@"DVGAssetPickerController.bundle/BlueCheckSelected"]
                            : [UIImage imageNamed:@"DVGAssetPickerController.bundle/BlueCheckUnselected"]);
}

@end
