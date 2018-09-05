//
//  ProfileUserListBase.m
//  Homestyler
//
//  Created by Eric Dong on 04/12/2018.
//

#import "ProfileUserListBase.h"

@interface ProfileUserListBase ()

- (void)loadMoreFromOffset:(NSUInteger)offset withCompletion:(void(^)(BOOL success))completion;

@end

@implementation ProfileUserListBase

- (instancetype)init {
    self = [super init];
    NSAssert([self class] != [ProfileUserListBase class], @"This is an abstract class");
    return self;
}

- (BOOL)hasMoreData {
    return self.users == nil || self.users.count < _total;
}

- (void)reloadWithCompletion:(void(^)(BOOL success))completion {
    [self loadMoreFromOffset:0 withCompletion:completion];
}

- (void)loadMoreWithCompletion:(void(^)(BOOL success))completion {
    NSUInteger offset = self.users.count;
    [self loadMoreFromOffset:offset withCompletion:completion];
}

- (void)loadMoreFromOffset:(NSUInteger)offset withCompletion:(void(^)(BOOL success))completion {
    //implement in sub-classes
}

@end
