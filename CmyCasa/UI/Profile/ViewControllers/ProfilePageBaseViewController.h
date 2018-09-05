//
//  ProfilePageBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/22/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileMasterBaseViewController.h"


typedef enum ProfileUserTypes{

    kUserProfileTypeLoggedInUser =1000,
    kUserProfileTypePublicUser =1001,

}ProfileUserType;

typedef  struct {
    NSUInteger collumnsCount;
    NSUInteger minRowsCount;

} CollectionViewRowsSize;

@protocol ProfilePageCollectionDelegate <NSObject>

-(Class)getCollectionCellClass;
-(UIEdgeInsets) getCellEdgeInsets;
-(CollectionViewRowsSize)getCollectionGridSize;
-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser;
-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)minimumLineSpacingForSection;
-(ProfileUserType)getViewedProfileUserType;
@end

@protocol ProfilePageTableViewDelegate <NSObject>

-(NSString*)getCellIdentifierForIndexpath:(NSIndexPath *)path;
-(UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath *)path;
-(NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path;
-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser;
-(void)rowSelectedAtIndex:(NSIndexPath*)indexPath;
-(ProfileUserType)getViewedProfileUserType;
-(void)reachedRowAtIndex:(NSInteger)rowIndex fromTotalCount:(NSInteger)totalCount;
@end

@protocol ProfileCellUnifiedInitProtocol <NSObject>
- (void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType;
@end

@interface ProfilePageBaseViewController : UIViewController

@property(nonatomic, assign) ProfileTabs dataSelectedTab;
@property(nonatomic, strong) NSArray *presentingData;
@property(nonatomic, weak) id<ProfilePageCollectionDelegate,ProfilePageTableViewDelegate> dataDelegate;
@property (weak, nonatomic) IBOutlet UILabel *listMessageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tableLoadingIndicator;


- (void)initDisplay:(NSArray *)data;
- (void)updateDisplay:(BOOL)isLoggedInUserProfile;
- (void)refreshContent;
- (void)insertHeaderView:(UIView*)headerView;
- (BOOL)scrollToTop;
- (void)removeFooter;
- (void)removeHeader;
- (void)setViewDisabled:(BOOL)disabled;
- (void)startLoadingIndicator;
- (void)stopLoadingIndicator;

@end
