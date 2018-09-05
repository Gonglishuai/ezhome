//
//  ProfileArticlesViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import "ProfileInstanceBaseViewController.h"
#import "ProfileProtocols.h"

@protocol DesignItemDelegate;
@protocol ArticleItemDelegate;

@interface ProfileArticlesViewController : ProfileInstanceBaseViewController <LikeDesignDelegate, CommentDesignDelegate>

@property(nonatomic,assign) id<ArticleItemDelegate,ProfileInstanceDataDelegate,ProfileCountersDelegate, LikeDesignDelegate, CommentDesignDelegate> rootArticlesDelegate;
@end
