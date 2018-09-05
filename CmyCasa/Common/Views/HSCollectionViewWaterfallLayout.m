//
//  HSCollectionViewWaterfallLayout.m
//  Homestyler
//
//  This implementation is adopted from https://github.com/chiahsien/CHTCollectionViewWaterfallLayout
//
//  Created by Eric Dong on 4/24/18.
//

#import "HSCollectionViewWaterfallLayout.h"
#import "tgmath.h"

@interface HSCollectionViewWaterfallLayout()

/// The delegate will point to collection view's delegate automatically.
//@property (nonatomic, weak) id <HSCollectionViewDelegateWaterfallLayout> delegate;
/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Array of arrays. Each array stores item attributes for each section
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Dictionary to store section headers' attributes
@property (nonatomic, strong) NSMutableDictionary *headersAttributes;
/// Dictionary to store section footers' attributes
@property (nonatomic, strong) NSMutableDictionary *footersAttributes;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;

@end

@implementation HSCollectionViewWaterfallLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

static CGFloat CHTFloorCGFloat(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

#pragma mark - Public Accessors
- (void)setColumnCount:(NSInteger)columnCount {
    if (_columnCount != columnCount) {
        _columnCount = columnCount;
        [self invalidateLayout];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

- (void)setFooterHeight:(CGFloat)footerHeight {
    if (_footerHeight != footerHeight) {
        _footerHeight = footerHeight;
        [self invalidateLayout];
    }
}

- (void)setHeaderInset:(UIEdgeInsets)headerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_headerInset, headerInset)) {
        _headerInset = headerInset;
        [self invalidateLayout];
    }
}

- (void)setFooterInset:(UIEdgeInsets)footerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_footerInset, footerInset)) {
        _footerInset = footerInset;
        [self invalidateLayout];
    }
}

//- (void)setSectionInset:(UIEdgeInsets)sectionInset {
//    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
//        _sectionInset = sectionInset;
//        [self invalidateLayout];
//    }
//}

- (void)setExtraHeaderPinMarginTop:(CGFloat)extraHeaderPinMarginTop {
    if (_extraHeaderPinMarginTop != extraHeaderPinMarginTop) {
        _extraHeaderPinMarginTop = extraHeaderPinMarginTop;
        [self invalidateLayout];
    }
}

- (NSInteger)columnCountForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:columnCountForSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self columnCountForSection:section];
    } else {
        return self.columnCount;
    }
}

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section {
    UIEdgeInsets sectionInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    } else {
        sectionInset = self.sectionInset;
    }
    CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
    NSInteger columnCount = [self columnCountForSection:section];

    CGFloat columnSpacing = self.minimumInteritemSpacing;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }

    return CHTFloorCGFloat((width - (columnCount - 1) * columnSpacing) / columnCount);
}

#pragma mark - Private Accessors
- (NSMutableDictionary *)headersAttributes {
    if (!_headersAttributes) {
        _headersAttributes = [NSMutableDictionary dictionary];
    }
    return _headersAttributes;
}

- (NSMutableDictionary *)footersAttributes {
    if (!_footersAttributes) {
        _footersAttributes = [NSMutableDictionary dictionary];
    }
    return _footersAttributes;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (NSMutableArray *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

#pragma mark - Init
- (void)commonInit {
    _columnCount = 2;
    _headerHeight = 0;
    _footerHeight = 0;
    _headerInset  = UIEdgeInsetsZero;
    _footerInset  = UIEdgeInsetsZero;
    _extraHeaderPinMarginTop = 0;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Methods to Override
- (void)prepareLayout {
    [super prepareLayout];

    [self.headersAttributes removeAllObjects];
    [self.footersAttributes removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.columnHeights removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];

    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }

    NSAssert([self.delegate conformsToProtocol:@protocol(HSCollectionViewDelegateWaterfallLayout)], @"UICollectionView's delegate should conform to HSCollectionViewDelegateWaterfallLayout protocol");
    NSAssert(self.columnCount > 0 || [self.delegate respondsToSelector:@selector(collectionView:layout:columnCountForSection:)], @"UICollectionViewWaterfallLayout's columnCount should be greater than 0, or delegate must implement columnCountForSection:");

    // Initialize variables
    NSInteger idx = 0;

    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger columnCount = [self columnCountForSection:section];
        NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:columnCount];
        for (idx = 0; idx < columnCount; idx++) {
            [sectionColumnHeights addObject:@(0)];
        }
        [self.columnHeights addObject:sectionColumnHeights];
    }
    // Create attributes
    CGFloat top = 0;
    UICollectionViewLayoutAttributes *attributes;

    for (NSInteger section = 0; section < numberOfSections; ++section) {
        /*
         * 1. Get section-specific metrics (minimumLineSpacing, sectionInset)
         */
        CGFloat lineSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            lineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
        } else {
            lineSpacing = self.minimumLineSpacing;
        }

        CGFloat columnSpacing = self.minimumInteritemSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
        }

        UIEdgeInsets sectionInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        } else {
            sectionInset = self.sectionInset;
        }

        CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
        NSInteger columnCount = [self columnCountForSection:section];
        CGFloat itemWidth = CHTFloorCGFloat((width - (columnCount - 1) * columnSpacing) / columnCount);

        /*
         * 2. Section header
         */
        CGFloat headerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
            headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
        } else {
            headerHeight = self.headerHeight;
        }

        // UICollectionViewLayoutAttributes instances for header and footer are always required on iOS 10 and earlier
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];

        if (headerHeight > 0) {
            UIEdgeInsets headerInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
                headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
            } else {
                headerInset = self.headerInset;
            }

            top += headerInset.top;

            attributes.frame = CGRectMake(headerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (headerInset.left + headerInset.right),
                                          headerHeight);

            top = CGRectGetMaxY(attributes.frame) + headerInset.bottom;
        }

        self.headersAttributes[@(section)] = attributes;
        [self.allItemAttributes addObject:attributes];

        top += sectionInset.top;
        for (idx = 0; idx < columnCount; idx++) {
            self.columnHeights[section][idx] = @(top);
        }

        /*
         * 3. Section items
         */
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];

        // Item will be put into shortest column.
        for (idx = 0; idx < itemCount; idx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            NSUInteger columnIndex = [self nextColumnIndexForItem:idx inSection:section];
            CGFloat xOffset = sectionInset.left + (itemWidth + columnSpacing) * columnIndex;
            CGFloat yOffset = [self.columnHeights[section][columnIndex] floatValue];
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            CGFloat itemHeight = 0;
            if (itemSize.height > 0 && itemSize.width > 0) {
                itemHeight = CHTFloorCGFloat(itemSize.height * itemWidth / itemSize.width);
            }

            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
            [itemAttributes addObject:attributes];
            [self.allItemAttributes addObject:attributes];
            self.columnHeights[section][columnIndex] = @(CGRectGetMaxY(attributes.frame) + lineSpacing);
        }

        [self.sectionItemAttributes addObject:itemAttributes];

        /*
         * 4. Section footer
         */
        CGFloat footerHeight;
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        if (((NSArray *)self.columnHeights[section]).count > 0) {
            top = [self.columnHeights[section][columnIndex] floatValue] - lineSpacing + sectionInset.bottom;
        } else {
            top = 0;
        }

        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
            footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
        } else {
            footerHeight = self.footerHeight;
        }

        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];

        if (footerHeight > 0) {
            UIEdgeInsets footerInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForFooterInSection:)]) {
                footerInset = [self.delegate collectionView:self.collectionView layout:self insetForFooterInSection:section];
            } else {
                footerInset = self.footerInset;
            }

            top += footerInset.top;

            attributes.frame = CGRectMake(footerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (footerInset.left + footerInset.right),
                                          footerHeight);

            top = CGRectGetMaxY(attributes.frame) + footerInset.bottom;
        }

        self.footersAttributes[@(section)] = attributes;
        [self.allItemAttributes addObject:attributes];

        for (idx = 0; idx < columnCount; idx++) {
            self.columnHeights[section][idx] = @(top);
        }
    } // end of for (NSInteger section = 0; section < numberOfSections; ++section)

    // Build union rects
    idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);

        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }

        idx = rectEndIndex;

        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }

    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = [[[self.columnHeights lastObject] firstObject] floatValue];

    if (contentSize.height < self.minimumContentHeight) {
        contentSize.height = self.minimumContentHeight;
    }

    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.sectionItemAttributes count]) {
        return nil;
    }
    if (path.item >= [((NSArray *)self.sectionItemAttributes[path.section]) count]) {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes = self.headersAttributes[@(indexPath.section)];

        if (self.sectionHeadersPinToVisibleBounds && attributes.size.height > 0) {
            CGRect headerFrame = attributes.frame;
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];

            CGFloat aboveHeadersHeight = self.extraHeaderPinMarginTop;
            for (NSInteger section = 0; section < indexPath.section; ++section) {
                UICollectionViewLayoutAttributes *headerAttributes = self.headersAttributes[@(section)];
                if (headerAttributes == nil)
                    continue;

                aboveHeadersHeight += headerAttributes.frame.size.height;
                UIEdgeInsets headerInset;
                if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
                    headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
                } else {
                    headerInset = self.headerInset;
                }
                aboveHeadersHeight += (headerInset.top + headerInset.bottom);
            }

            CGFloat headerY = MAX(headerFrame.origin.y, self.collectionView.contentOffset.y + aboveHeadersHeight);
            attributes.frame = CGRectMake(headerFrame.origin.x, headerY, headerFrame.size.width, headerFrame.size.height);
            attributes.zIndex = 1024;
        }
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        // TODO: sectionFootersPinToVisibleBounds support
        attributes = self.footersAttributes[@(indexPath.section)];
    }
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableDictionary *cellAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplHeaderAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplFooterAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *decorAttrDict = [NSMutableDictionary dictionary];

    if (self.sectionHeadersPinToVisibleBounds) {
        NSInteger numberOfSections = [self.collectionView numberOfSections];
        for (NSInteger section = 0; section < numberOfSections; ++section) {
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            if (attr.size.height > 0 && CGRectIntersectsRect(rect, attr.frame)) {
                supplHeaderAttrDict[attr.indexPath] = attr;
            }
        }
    }
    // TODO: sectionFootersPinToVisibleBounds support

    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            switch (attr.representedElementCategory) {
                case UICollectionElementCategorySupplementaryView:
                    if (!self.sectionHeadersPinToVisibleBounds && [attr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                        supplHeaderAttrDict[attr.indexPath] = attr;
                    } else if ([attr.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
                        supplFooterAttrDict[attr.indexPath] = attr;
                    }
                    break;
                case UICollectionElementCategoryDecorationView:
                    decorAttrDict[attr.indexPath] = attr;
                    break;
                case UICollectionElementCategoryCell:
                    cellAttrDict[attr.indexPath] = attr;
                    break;
            }
        }
    }

    NSArray *result = [cellAttrDict.allValues arrayByAddingObjectsFromArray:supplHeaderAttrDict.allValues];
    result = [result arrayByAddingObjectsFromArray:supplFooterAttrDict.allValues];
    result = [result arrayByAddingObjectsFromArray:decorAttrDict.allValues];
    return result;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (self.sectionHeadersPinToVisibleBounds)
        return YES;
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}


#pragma mark - Private Methods

/**
 *  Find the shortest column.
 *
 *  @return index for the shortest column
 */
- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;

    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];

    return index;
}

/**
 *  Find the longest column.
 *
 *  @return index for the longest column
 */
- (NSUInteger)longestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;

    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];

    return index;
}

/**
 *  Find the index for the next column.
 *
 *  @return index for the next column
 */
- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section {
    NSInteger columnCount = [self columnCountForSection:section];
    return [self shortestColumnIndexInSection:section];
}

@end
