//
//  GalleryStreamHeaderView.h
//  EZHome
//
//  Created by liuyufei on 4/18/18.
//

#import <UIKit/UIKit.h>

@protocol GalleryStreamHeaderViewDelegate <NSObject>

- (void)showFilterList:(UIButton *)sender;
- (void)showRoomTypeList:(UIButton *)sender;
- (void)selectedRoomKey:(NSString *)key Value:(NSString *)value;

@end

@interface GalleryStreamHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *filterListButton;
@property (weak, nonatomic) IBOutlet UIButton *roomTypesButton;

@property (nonatomic, weak) id <GalleryStreamHeaderViewDelegate> delegate;
@property (nonatomic, strong) NSArray *roomTypesArr;
@property (nonatomic, strong) NSArray *sortTypesArr;

- (void)setRoomType:(NSString *)text;
- (void)setFilterType:(NSString *)text;

- (void)setFilterButtonState:(BOOL)expanded;
- (void)setRoomTypesButtonState:(BOOL)expanded;

@end
