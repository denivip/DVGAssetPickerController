//
//  DVGAssetPickerPresentationController.m
//  Together
//
//  Created by Nikolay Morev on 17.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGAssetPickerPresentationController.h"
#import "DVGAssetPickerViewController.h"

@interface DVGAssetPickerPresentationController ()

@property (nonatomic, retain, readonly) DVGAssetPickerViewController *presentedViewController;
@property (weak, nonatomic) UIButton *backgroundButton;

@end

@implementation DVGAssetPickerPresentationController

- (void)presentationTransitionWillBegin
{
    UIView *containerView = self.containerView;

    UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backgroundButton.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundButton.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.33f];
    [backgroundButton addTarget:self action:@selector(didTapBackgroundButton) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:backgroundButton];
    _backgroundButton = backgroundButton;

    [containerView addSubview:self.presentedViewController.view];

    NSDictionary *bindings = NSDictionaryOfVariableBindings(backgroundButton);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundButton]|" options:0 metrics:nil views:bindings]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundButton]|" options:0 metrics:nil views:bindings]];

    backgroundButton.alpha = 0.f;
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        backgroundButton.alpha = 1.f;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (!completed) {
        [_backgroundButton removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin
{
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.backgroundButton.alpha = 0.f;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.backgroundButton removeFromSuperview];
    }];
}

- (CGRect)frameOfPresentedViewInContainerView
{
    [self.presentedViewController.view updateConstraintsIfNeeded];
    [self.presentedViewController.view layoutIfNeeded];

    CGRect bounds = self.containerView.bounds;
    CGSize size = self.presentedViewController.preferredContentSize;

    bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(CGRectGetHeight(bounds) - size.height, 0.f, 0.f, 0.f));

    return bounds;
}

- (BOOL)shouldPresentInFullscreen
{
    return NO;
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];

    if (container == self.presentedViewController) {
        if ([self.presentedViewController isViewLoaded] && self.presentedViewController.view.window) {
            self.presentedViewController.view.frame = [self frameOfPresentedViewInContainerView];
        }
    }
}

- (void)didTapBackgroundButton
{
    [self.presentedViewController cancel];
}

@end
