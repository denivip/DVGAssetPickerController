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
        imageView.image = [UIImage imageNamed:@"BlueCheckUnselected" inBundle:[self imageBundle] compatibleWithTraitCollection:nil];
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return self;
}

- (NSBundle*)imageBundle
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    NSString *imageBundlePath = [frameworkBundle pathForResource:@"DVGAssetPickerController" ofType:@"bundle"];
    return [NSBundle bundleWithPath:imageBundlePath];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    NSString *imageName = _selected ? @"BlueCheckSelected" : @"BlueCheckUnselected";
    self.imageView.image = [UIImage imageNamed:imageName inBundle:[self imageBundle] compatibleWithTraitCollection:nil];
}

@end
