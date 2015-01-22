//
//  DVGAssetPickerViewController.m
//  Together
//
//  Created by Nikolay Morev on 17.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGAssetPickerViewController.h"
#import "DVGAssetPickerCollectionViewCell.h"
#import "DVGAssetPickerPresentationController.h"
#import "DVGAssetPickerCheckmarkView.h"
#import "DVGAssetPickerCollectionLayout.h"
#import "TLTransitionLayout.h"

// TODO убрать привязки к классам приложения и дать возможность обработать ошибки снаружи
// TODO вынести в отдельную библиотеку и выложить на гитхаб
// TODO сделать примеры и подключение через CocoaPods
// TODO проверки на доступность камеры и библиотеки
// TODO слушать нотификацию об обновлении библиотеки

static NSInteger const DVGAssetPickerMenuItemCount = 3;
static CGFloat const kCollectionViewCollapsedHeight = 144.f;
static CGFloat const kCollectionViewExpandedHeight = 308.f;
static CGFloat const kCollectionViewPadding = 4.f;
static NSTimeInterval const kExpandAnimationDuration = 0.3;

@interface DVGAssetPickerViewController ()
<UIViewControllerTransitioningDelegate,
UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) NSLayoutConstraint *collectionHeightConstraint;
@property (copy, nonatomic) NSArray *assets;
@property (strong, nonatomic) NSMutableSet *selectedAssets;
@property (nonatomic) BOOL collectionViewExpanded;

@end

@implementation DVGAssetPickerViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.assetsLibrary = [[ALAssetsLibrary alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self newCollectionLayout]];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    // To animate between collection view size changes, we extend collection
    // view margins to invisible areas of the screen.
    collectionView.contentInset = UIEdgeInsetsMake(0.f, CGRectGetWidth(self.view.bounds), 0.f, CGRectGetWidth(self.view.bounds));
    [collectionView registerClass:[DVGAssetPickerCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [collectionView registerClass:[DVGAssetPickerCheckmarkView class] forSupplementaryViewOfKind:DVGAssetPickerSupplementaryKindCheckmark withReuseIdentifier:@"Checkmark"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;

    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectZero];
    dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    dividerView.backgroundColor = [UIColor colorWithRed:0.783922f green:0.780392f blue:0.8f alpha:1.f];
    [self.view addSubview:dividerView];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.scrollEnabled = NO;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    _tableView = tableView;

    NSDictionary *bindings = NSDictionaryOfVariableBindings(tableView, collectionView, dividerView);

    [self.view addConstraints:
     @[ [NSLayoutConstraint constraintWithItem:collectionView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:3.f
                                      constant:0.f],
        [NSLayoutConstraint constraintWithItem:collectionView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.f
                                      constant:0.f] ]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[dividerView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView][dividerView(==0.5)][tableView]" options:0 metrics:nil views:bindings]];
    // Hide last cell separator
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:-0.5f]];

    NSLayoutConstraint *collectionHeightConstraint = [NSLayoutConstraint constraintWithItem:collectionView
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.f
                                                                                   constant:kCollectionViewCollapsedHeight];
    [collectionView addConstraint:collectionHeightConstraint];
    _collectionHeightConstraint = collectionHeightConstraint;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Get assets synchronously to prevent thumbnails flicker when view appears.
    self.assets = [self fetchAllAssetsSynchronously];
    [self.collectionView reloadData];

    // Set size only after the tableView has loaded its contents.
    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width,
                                           [self collectionViewHeight] + 0.5f + self.tableView.contentSize.height - 0.5f);
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];

    self.collectionHeightConstraint.constant = [self collectionViewHeight];
}

#pragma mark -

- (NSArray *)fetchAllAssetsSynchronously
{
    NSMutableArray *assets = [NSMutableArray array];
    dispatch_group_t dispatchGroup = dispatch_group_create();

    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSInteger maxCount = 50;
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stopGroups) {
            if (group) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopAssets) {
                    if (result &&
                        [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        [assets addObject:result];
                        maxCount--;
                        if (maxCount == 0) {
                            *stopAssets = *stopGroups = YES;
                        }
                    }
                }];
            }
            else {
                dispatch_group_leave(dispatchGroup);
            }
        } failureBlock:^(NSError *error) {
            // XXX Handle error
            dispatch_group_leave(dispatchGroup);
        }];
    });
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);

    return assets;
}

- (void)cancel
{
    [self.delegate contentPickerViewControllerDidCancel:self];
}

- (void)setCollectionViewExpanded:(BOOL)collectionViewExpanded fromIndexPath:(NSIndexPath *)indexPath completion:(void (^)())completion
{
    _collectionViewExpanded = collectionViewExpanded;

    UICollectionView *collectionView = self.collectionView;
    [UIView animateWithDuration:kExpandAnimationDuration delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionCurveEaseInOut animations:^{

        if (self.collectionViewExpanded) {
            self.preferredContentSize = CGSizeMake(self.preferredContentSize.width,
                                                   [self collectionViewHeight] + 0.5f + self.tableView.contentSize.height - 0.5f);
        }

        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];

        // Prevent invalidation as a result of bounds change.
        UICollectionViewFlowLayoutInvalidationContext *invalidationContext = [[UICollectionViewFlowLayoutInvalidationContext alloc] init];
        invalidationContext.invalidateFlowLayoutAttributes = NO;
        [collectionView.collectionViewLayout invalidateLayoutWithContext:invalidationContext];

        if (!self.collectionViewExpanded) {
            self.preferredContentSize = CGSizeMake(self.preferredContentSize.width,
                                                   [self collectionViewHeight] + 0.5f + self.tableView.contentSize.height - 0.5f);
        }

        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];

    // Standard animation for invalidateLayout is not good enough: images fade
    // from one size to another and some cells appear from incorrect start
    // positions. Therefore we use third-party library that solves these problems.
    // Unfortunately, two animations don't always exactly match each other, so
    // sometimes we see a little twitching.

    TLTransitionLayout *layout = (TLTransitionLayout *)[collectionView transitionToCollectionViewLayout:[self newCollectionLayout] duration:kExpandAnimationDuration easing:QuadraticEaseInOut completion:^(BOOL completed, BOOL finished) {
        completion();
    }];
    CGPoint toOffset = [collectionView toContentOffsetForLayout:layout
                                                     indexPaths:@[ indexPath ]
                                                      placement:TLTransitionLayoutIndexPathPlacementCenter
                                                placementAnchor:kTLPlacementAnchorDefault
                                                 placementInset:UIEdgeInsetsZero
                                                         toSize:self.collectionView.bounds.size
                                                 toContentInset:self.collectionView.contentInset];
    layout.toContentOffset = toOffset;
}

- (CGFloat)collectionViewHeight
{
    return (self.collectionViewExpanded
            ? kCollectionViewExpandedHeight
            : kCollectionViewCollapsedHeight);
}

- (UICollectionViewFlowLayout *)newCollectionLayout
{
    UICollectionViewFlowLayout *collectionLayout = [[DVGAssetPickerCollectionLayout alloc] init];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionLayout.minimumInteritemSpacing = kCollectionViewPadding;
    collectionLayout.sectionInset = UIEdgeInsetsMake(kCollectionViewPadding, kCollectionViewPadding,
                                                     kCollectionViewPadding, kCollectionViewPadding);
    return collectionLayout;
}

- (void)collectionViewScrollToItemAtIndexPathCentered:(NSIndexPath *)indexPath
{
    // For unknown reason standard method scrollToItemAtIndexPath:atScrollPosition:
    // doesn't always work correctly (for example, indexPath.row from 1 to 2).

    UICollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
    UIEdgeInsets inset = self.collectionView.contentInset;
    UIEdgeInsets sectionInset = layout.sectionInset;
    CGRect frame = [layout layoutAttributesForItemAtIndexPath:indexPath].frame;
    CGPoint offset = frame.origin;
    offset.x -= inset.left;
    offset.y -= inset.top;
    offset.x -= sectionInset.left;
    offset.y -= sectionInset.top;
    offset.x -= (CGRectGetWidth(self.view.bounds) - CGRectGetWidth(frame) - (sectionInset.left + sectionInset.right)) / 2.f;
    CGFloat maxOffset = self.collectionView.contentSize.width - inset.right - CGRectGetWidth(self.view.bounds);
    CGFloat minOffset = -inset.left;
    offset.x = MAX(minOffset, (MIN(maxOffset, offset.x)));

    [self.collectionView setContentOffset:offset animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return DVGAssetPickerMenuItemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    switch ((DVGAssetPickerMenuItem)indexPath.row) {
        case DVGAssetPickerMenuItemPhotoLibrary: {
            NSInteger selectedCount = [self.selectedAssets count];
            if (!self.collectionViewExpanded || selectedCount == 0) {
                cell.textLabel.text = NSLocalizedString(@"Photo Library", nil);
            }
            else if (selectedCount == 1) {
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Select %d Photo", nil), selectedCount];
            }
            else {
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Select %d Photos", nil), selectedCount];
            }
            break;
        }

        case DVGAssetPickerMenuItemCamera:
            cell.textLabel.text = NSLocalizedString(@"Take Photo", nil);
            break;

        case DVGAssetPickerMenuItemCancel:
            cell.textLabel.text = NSLocalizedString(@"Cancel", nil);
            break;
    }

    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = cell.tintColor;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DVGAssetPickerMenuItem menuItem = (DVGAssetPickerMenuItem)indexPath.row;
    switch (menuItem) {
        case DVGAssetPickerMenuItemPhotoLibrary:
            if (!self.collectionViewExpanded || [self.selectedAssets count] == 0) {
                [self.delegate contentPickerViewController:self
                                           clickedMenuItem:menuItem];
            }
            else {
                [self.delegate contentPickerViewController:self
                                           didSelectAssets:[self.selectedAssets allObjects]];
            }
            break;

        case DVGAssetPickerMenuItemCamera:
        case DVGAssetPickerMenuItemCancel:
            [self.delegate contentPickerViewController:self
                                       clickedMenuItem:menuItem];
            break;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.assets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.row];
    DVGAssetPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    UIImage *thumbnail = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    cell.imageView.image = thumbnail;

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if ([kind isEqualToString:DVGAssetPickerSupplementaryKindCheckmark]) {
        ALAsset *asset = self.assets[indexPath.row];
        DVGAssetPickerCheckmarkView *checkmark = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Checkmark" forIndexPath:indexPath];
        checkmark.selected = [self.selectedAssets containsObject:asset];
        view = checkmark;
    }

    return view;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.row];

    if (!self.collectionViewExpanded) {
        self.selectedAssets = [NSMutableSet setWithObject:asset];

        __weak __typeof__(self) self_weak_ = self;
        [self setCollectionViewExpanded:YES fromIndexPath:indexPath completion:^{
            __strong __typeof__(self) self = self_weak_;

            DVGAssetPickerCollectionLayout *layout = (id)self.collectionView.collectionViewLayout;
            layout.showCheckmarks = self.collectionViewExpanded;
            [self.tableView reloadData];
        }];
    }
    else {
        if ([self.selectedAssets containsObject:asset]) {
            [self.selectedAssets removeObject:asset];
        }
        else {
            [self.selectedAssets addObject:asset];
        }
        [self collectionViewScrollToItemAtIndexPathCentered:indexPath];
        [collectionView reloadData];
        [self.tableView reloadData];
    }

    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout
                                           newLayout:(UICollectionViewLayout *)toLayout
{
    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout
                                                  nextLayout:toLayout
                                          supplementaryKinds:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.row];
    UIImage *thumbnail = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];

    CGFloat height = [self collectionViewHeight] - kCollectionViewPadding * 2;
    CGFloat maxWidth = CGRectGetWidth(self.view.bounds) - kCollectionViewPadding * 2;
    CGFloat width = (thumbnail
                     ? thumbnail.size.width * height / thumbnail.size.height
                     : height);
    width = MIN(maxWidth, width);
    CGSize size = CGSizeMake(width, height);

    return size;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    return [[DVGAssetPickerPresentationController alloc] initWithPresentedViewController:presented
                                                                  presentingViewController:presenting];
}

@end
