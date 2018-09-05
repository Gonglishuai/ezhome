//
//  WCSharingViewController.h
//  Homestyler
//
//  Created by lvwei on 13/04/2017.
//
//

#import <UIKit/UIKit.h>

@interface WCSharingViewController : UIViewController

-(id)initWithShareData:(HSShareObject*)shareObj;
-(void)enterSharingView:(UIViewController *)parent;
-(bool)exitSharingView;


@end
