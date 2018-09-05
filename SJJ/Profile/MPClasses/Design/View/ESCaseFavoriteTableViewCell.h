//
//  ESCaseFavoriteTableViewCell.h
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESCaseFavoriteTableViewCell : UITableViewCell
- (void)setFavNum:(NSString *)num isFav:(BOOL)isFav tapBlock:(void(^)(void))tapBlock;
@end
