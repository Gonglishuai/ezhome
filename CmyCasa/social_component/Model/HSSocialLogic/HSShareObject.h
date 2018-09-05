//
//  HSShareObject.h
//  Homestyler
//
//  Created by Berenson Sergei on 11/11/13.
//
//

#import <Foundation/Foundation.h>
#import "HSSharingConstants.h"

@interface HSShareObject : NSObject


@property(nonatomic,strong) NSString * designShareLink;//fb link
@property(nonatomic,strong) NSString * designShareLinkOriginal;//fb link
@property(nonatomic,strong) NSURL * pictureURL;
@property(nonatomic,strong) UIImage * picture;
@property(nonatomic,strong) NSString * _description;
@property(nonatomic,strong) NSString * caption; //fb caption
@property(nonatomic,strong) NSString * message;

@property(nonatomic,strong) NSString * name; //fb name
@property(nonatomic) HSSocialNetworkType type;
@property(nonatomic,strong) NSArray * hashtags;
@property(nonatomic) BOOL canComposeMessage;

-(NSString*)getSharingMessage;

@end
