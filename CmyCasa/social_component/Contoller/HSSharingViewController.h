//
//  HSSharingViewController.h
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/9/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HSShareObject;
@class HSSharingLogic;

@protocol HSSharingViewControllerDelegate <NSObject>

@optional
- (void)didCancelSharingViewController;
- (void)didFinishSharingViewController;

@end


@interface HSSharingViewController : UIViewController

@property (nonatomic, weak) id <HSSharingViewControllerDelegate> delegate;
@property (nonatomic, readonly) HSSharingLogic *logic;
@property (nonatomic, weak) IBOutlet UIView * shareContainer;
@property (nonatomic, weak) IBOutlet UIView * shareInfoView;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

-(void)refreshUIData;
-(void)selectPreferedButtons;
-(id)initWithShareText:(HSShareObject*)shareObj;
-(void)initWithShareData:(HSShareObject*)shareObj;
@end
