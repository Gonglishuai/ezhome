//
//  ControllersFactory.h
//  Homestyler
//
//  Created by Ma'ayan on 11/21/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kMainStoryBoard             = 101,
    kGalleryStoryboard          = 102,
    kProfileStoryboard          = 103,
    kNewProfileStoryboard       = 104,
    kLoginStoryboard            = 105,
    kRedesignStoryboard         = 106,
    kProfessionalsStoryboard    = 107,
    kProductTagViewStoryboard   = 108,
    kLayersViewStoryboard       = 109

} StoryboardType;

@interface ControllersFactory : NSObject

+ (id)instantiateViewControllerWithIdentifier:(NSString *)identifier inStoryboard:(StoryboardType)storyboardType;

@end
