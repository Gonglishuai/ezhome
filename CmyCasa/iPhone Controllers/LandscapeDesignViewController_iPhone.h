//
//  LandscapeDesignViewController_iPhone.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 8/20/15.
//
//

#import <UIKit/UIKit.h>

@interface LandscapeDesignViewController_iPhone : UIViewController

@property (weak, nonatomic, nullable) id<LandscapeDesignViewControllerDelegate_iPhone> delegate;

@property (strong, nonatomic) NSArray * items;
@property (nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;

-(void)clearScrollView;

@end
