//
//  MPHome3dview.h
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MPHome3DViewDelegate <NSObject>

/**
 *  @brief the method for get collectionView items count.
 *
 *  @param nil.
 *
 *  @return NSUInteger the count of items.
 */
- (NSUInteger) get3DNumberOfItemsInCollection;

/**
 *  @brief the method for click item.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void) didSelectedItemAtIndex:(NSUInteger)index;

/**
 *  @brief the method for refresh new dataSource.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)refresh3DLoadNewData:(void(^) (void))finish;

/**
 *  @brief the method for refresh more dataSource.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)refresh3DLoadMoreData:(void(^) (void))finish;
@end

@interface MPHome3dview : UIView
/// delegate.
@property (weak, nonatomic)id <MPHome3DViewDelegate> delegate;

/// collectionView.
@property (strong, nonatomic)UICollectionView *home3DCollectionView;

/**
 *  @brief the method for refresh view.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
- (void)refresh3DHomeCaseView;

- (void)startMJRefreshHeader;

@end
