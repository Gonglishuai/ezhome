//
//  ProfileCollectionViewHeader.h
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import <UIKit/UIKit.h>

typedef enum {
    BigMode = 0,
    SmallMode = 1,
} ProfileViewDisplayMode;

typedef enum {
    DesignsData = 0,
    FeaturedData = 1,
} ProfileViewDataType;

@protocol ProfileCollectionViewHeaderDelegate <NSObject>
@optional
-(void)setViewDisplayMode:(ProfileViewDisplayMode)mode;
-(void)setViewDataType:(ProfileViewDataType)type;
@end

@interface ProfileCollectionViewHeader : UICollectionReusableView

@property (nonatomic, weak) id<ProfileCollectionViewHeaderDelegate> delegate;

- (void)setDesignsCount:(NSInteger)count;

@end
