//
//  LocationsPopupViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import <UIKit/UIKit.h>

@protocol LocationsDelegate
- (void) locationSelected:(NSString*) key :(NSString*) value;
@end

@interface LocationsPopupViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
}

@property(nonatomic,assign) id<LocationsDelegate>  delegate;
@property(nonatomic) NSMutableArray * locs;
- (void) setLocations:(NSMutableArray*) locations;

@end
