//
//  UIMenuManager.h
//  CmyCasa
//
//  Created by Berenson Sergei on 1/28/13.
//
//

#import <Foundation/Foundation.h>
#import "MenuViewController.h"
#import "NewDesignViewController.h"
#import "MenuOptionType.h"
#import "UIManager.h"
#import <ARKit/ARKit.h>

#define DesignSortTypeFor3D             @"1"
#define DesignSortTypeFor2D             @"2"
#define DesignSortTypeForArticles       @"1"

#define DesignStreamType3D              @"1"
#define DesignStreamType2D              @"2"
#define DesignStreamTypeArticles        @"3"
#define DesignStreamTypeEmptyRooms      @"4"

@protocol IphoneMenuManagerDelegate <NSObject>

-(IBAction)openMenu:(id)sender;

@end

@interface UIMenuManager : NSObject<NewDesignViewControllerDelegate>

@property (nonatomic, strong) MenuViewController * menuViewController;
@property (nonatomic) BOOL isUserChangedFilter;
@property (nonatomic) BOOL isMenuOpenAllowed;
@property (nonatomic) BOOL isMenuPresented;

+ (id)sharedInstance;
- (void)openMenu:(UIViewController *)parentView;
- (void)openProfilePageForsomeUser:(NSString*)userid;
- (void)openProfessionalByID:(NSString*)profid;
- (NSInteger)getMenuOptionSelectedIndex;
- (void)updateMenuOptionSelectionIndex:(NSInteger)index;
- (void)updateMenuSelectionIndexAccordingToUserId:(NSString*)userId;
- (void)loginRequestedIphone:(UIViewController *)senderView loadOrigin:(NSString *)loadOriginEvent;
- (void)loginRequestedIpad:(UIViewController *)senderView loadOrigin:(NSString *)loadOriginEvent;
- (void)loginRequestedIphone:(UIViewController *)senderView withCompletionBlock:(void (^)(BOOL success))block loadOrigin:(NSString *)loadOriginEvent;
- (void)removeNewDesignViewController;
- (void)removeNewDesignViewControllerIPhone;
- (void)resetPasswordPressed:(UIViewController*)senderView;
- (void)openAboutPagePressed:(UIViewController*)senderView;
- (void)openTermsPagePressed:(UIViewController*)senderView;
- (void)logoutWithUI;
- (NSString *)getSortTypeForDesignStreamType:(NSString *)type;
- (NSString *)getLocalizedStringForSortType:(NSString *)type;
- (void)setCurrentSortTypeFilter:(NSString *)filter;
- (void)showAlert;

-(void)backPressed:(UIViewController*)senderView;

#pragma mark-
#pragma mark iPhone menu actions

- (void)createEmailWithTitle:(NSString *)title andBody:(NSString *)body forPresentingTarget:(UIViewController *)target withRecipients:(NSArray *)toAddresses;
- (void)returnToInitialPage;
- (void)professionalsIphonePressed:(id)sender;
- (void)newDesignPressedIphone;
- (void)openSettingsIphone;
- (void)refreshMenu;
- (void)openAboutPageIphonePressed:(UIViewController*)senderView;
- (void)closeModalViewsAndPushNewView :(UIViewController*) ctrlToCheck :(id)sender;
- (void)applicationHomePressed:(id)sender;
- (void)myHomePressed:(id)sender;
- (BOOL)isOptionActive:(NSString*)option;

- (void)openGalleryStreamWithType:(NSString*)itemType
                      andRoomType:(NSString*)roomType
                        andSortBy:(NSString*) sortBy;

- (void)openSettingsPressed:(UIViewController*)senderView;
@end
