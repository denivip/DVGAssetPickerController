//
//  DVGAssetPickerCollectionLayout.m
//  Together
//
//  Created by Nikolay Morev on 19.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGAssetPickerCollectionLayout.h"

NSString *const DVGAssetPickerSupplementaryKindCheckmark = @"Checkmark";
static CGFloat const kCheckmarkDiameter = 31.f;

@implementation DVGAssetPickerCollectionLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForCheckmarkWithCellAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    UICollectionViewLayoutAttributes *supplement;
    CGRect insetBounds = UIEdgeInsetsInsetRect(self.collectionView.bounds,
                                               self.collectionView.contentInset);
    CGRect rectWithMargins = UIEdgeInsetsInsetRect(insetBounds,
                                                   UIEdgeInsetsMake(0.f, -kCheckmarkDiameter,
                                                                    0.f, 0.f));
    if (CGRectIntersectsRect(rectWithMargins, attributes.frame)) {
        CGRect intersection = CGRectIntersection(rectWithMargins, attributes.frame);
        supplement = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:DVGAssetPickerSupplementaryKindCheckmark withIndexPath:attributes.indexPath];
        supplement.zIndex = attributes.zIndex + 10;
        supplement.size = CGSizeMake(kCheckmarkDiameter, kCheckmarkDiameter);
        CGFloat centerX = MAX(CGRectGetMinX(intersection) + kCheckmarkDiameter/2,
                              CGRectGetMaxX(intersection) - kCheckmarkDiameter/2);
        supplement.center = CGPointMake(centerX,
                                        CGRectGetMaxY(attributes.frame) - kCheckmarkDiameter/2);
    }

    return supplement;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:rect];

    NSMutableArray *supplementaryAttributes = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attributes in attributesInRect) {
        if (self.showCheckmarks) {
            if ([attributes representedElementCategory] == UICollectionElementCategoryCell) {
                UICollectionViewLayoutAttributes *supplement = [self layoutAttributesForCheckmarkWithCellAttributes:attributes];
                if (supplement) [supplementaryAttributes addObject:supplement];
            }
        }
    }

    attributesInRect = [(attributesInRect ?: @[]) arrayByAddingObjectsFromArray:supplementaryAttributes];

    return attributesInRect;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (void)setShowCheckmarks:(BOOL)showCheckmarks
{
    _showCheckmarks = showCheckmarks;
    [self invalidateLayout];
}

@end
