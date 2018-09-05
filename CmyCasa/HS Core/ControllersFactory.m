//
//  ControllersFactory.m
//  Homestyler
//
//  Created by Ma'ayan on 11/21/13.
//
//

#import "ControllersFactory.h"


#define MAIN_STORYBOARD_IPAD                    @"MainStoryboard_iPad"
#define MAIN_STORYBOARD_IPHONE                  @"MainStoryboard_iPhone"

#define GALLERY_STORYBOARD_IPAD                 @"GalleryStoryboard_iPad"
#define GALLERY_STORYBOARD_IPHONE               @"GalleryStoryBoard_iPhone"

#define NEW_PROFILE_STORYBOARD_IPAD             @"NewProfileStoryboard_iPad"
#define NEW_PROFILE_STORYBOARD_IPHONE           @"ProfileStoryBoard_iPhone"

#define LOGIN_STORYBOARD_IPAD                   @"LoginStoryboard_iPad"
#define LOGIN_STORYBOARD_IPHONE                 @"LoginStoryboard_iPhone"

#define REDESIGN_STORYBOARD_IPAD                @"RedesignStoryboard_iPad"
#define REDESIGN_STORYBOARD_IPHONE              @"RedesignStoryboard_iPhone"

#define PROFESSIONALS_STORYBOARD_IPAD           @"ProfsStoryboard_iPad"
#define PROFESSIONALS_STORYBOARD_IPHONE         @"ProfsStoryboard_iPhone"

#define PRODUCT_TAG_VIEW_STORYBOARD             @"ProductTagView"
#define LAYERS_VIEW_STORYBOARD             @"LayersView"

@interface ControllersFactory ()

+ (NSString *)storyboardNameFromStoryboardType:(StoryboardType)storyboardType;

@end


#pragma mark - Implementation

@implementation ControllersFactory

#pragma mark - Instantiate view controller

+ (id)instantiateViewControllerWithIdentifier:(NSString *)identifier inStoryboard:(StoryboardType)storyboardType
{
    id viewController = nil;
    
    NSString *storyboardName = [self storyboardNameFromStoryboardType:storyboardType];
    
    if (storyboardName)
    {
        UIStoryboard *storyboard = nil;
        
        @try
        {
            storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        }
        @catch (NSException *exception)
        {NSLog(@"Exception: %@",exception);}
        @finally
        {}
        
        @try
        {
            viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        }
        @catch (NSException *exception)
        {NSLog(@"Exception: %@",exception);}
        @finally
        {}
    }
    
    return viewController;
}



#pragma mark - Storyboard name from type

+ (NSString *)storyboardNameFromStoryboardType:(StoryboardType)storyboardType
{
    NSString *storybaordName = nil;
    
    switch (storyboardType)
    {
        case kMainStoryBoard:
            if (IS_IPAD)
                storybaordName = MAIN_STORYBOARD_IPAD;
            else
                storybaordName = MAIN_STORYBOARD_IPHONE;
            break;
        case kGalleryStoryboard:
            if (IS_IPAD)
                storybaordName = GALLERY_STORYBOARD_IPAD;
            else
                storybaordName = GALLERY_STORYBOARD_IPHONE;
            break;
        case kProfileStoryboard:
        case kNewProfileStoryboard:
            if (IS_IPAD)
                storybaordName = NEW_PROFILE_STORYBOARD_IPAD;
            else
                storybaordName = NEW_PROFILE_STORYBOARD_IPHONE;
            break;
        case kLoginStoryboard:
            if (IS_IPAD)
                storybaordName = LOGIN_STORYBOARD_IPAD;
            else
                storybaordName = LOGIN_STORYBOARD_IPHONE;
            break;
        case kRedesignStoryboard:
            if (IS_IPAD)
                storybaordName = REDESIGN_STORYBOARD_IPAD;
            else
                storybaordName = REDESIGN_STORYBOARD_IPHONE;
            break;
        case kProfessionalsStoryboard:
            if (IS_IPAD)
                storybaordName = PROFESSIONALS_STORYBOARD_IPAD;
            else
                storybaordName = PROFESSIONALS_STORYBOARD_IPHONE;
            break;
            
        case kProductTagViewStoryboard:
                storybaordName = PRODUCT_TAG_VIEW_STORYBOARD;
            break;
        case kLayersViewStoryboard:
            storybaordName = LAYERS_VIEW_STORYBOARD;
            break;
            
           
        default:
            storybaordName=@"temp_Storyboard";
            break;
    }
    
    return storybaordName;
}

@end
