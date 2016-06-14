//
//  DataLoadingOperation.m
//  FluentResourcePaging-example
//
//  Created by Alek Astrom on 2014-04-11.
//  Copyright (c) 2014 Alek Åström. All rights reserved.
//

#import "DataLoadingOperation.h"

const NSTimeInterval DataLoadingOperationDuration = 0.3;

@implementation DataLoadingOperation

- (instancetype)initWithIndexes:(NSIndexSet *)indexes {
    self = [super init];
    if (self) {
        _indexes = indexes;
        typeof(self) weakSelf = self;
        [self addExecutionBlock:^{
            //getAllActivitiesOfUser
            NSArray *dataPage = [NSArray array];
            dataPage = [TellemUtility getAllActivitiesOfUser:[PFUser currentUser] andIndexSet:indexes];
            weakSelf->_dataPage = dataPage;
            //NSLog (@"NSIndex: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexes.firstIndex, (unsigned long)indexes.lastIndex,(unsigned long)indexes.count);
        }];
    }
    
    return self;
}

- (instancetype)initWithIndexes:(NSIndexSet *)indexes andCircle:(PFObject*) currentCircle {
    self = [super init];
    if (self) {
        _indexes = indexes;
        typeof(self) weakSelf = self;
        [self addExecutionBlock:^{
            //getAlActivitiesOfCircle
            NSArray *dataPage = [NSArray array];
            dataPage = [TellemUtility getAlActivitiesOfCircle:currentCircle andIndexSet:indexes];
            weakSelf->_dataPage = dataPage;
            //NSLog (@"NSIndex: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexes.firstIndex, (unsigned long)indexes.lastIndex,(unsigned long)indexes.count);
        }];
    }
    
    return self;
}

- (instancetype)initWithIndexes:(NSIndexSet *)indexes andSearchText:(NSString*) searchText {
    self = [super init];
    if (self) {
        _indexes = indexes;
        typeof(self) weakSelf = self;
        [self addExecutionBlock:^{
            //getSearchResults
            NSArray *dataPage = [NSArray array];
            dataPage = [TellemUtility getSearchResults:searchText andIndexSet:indexes];
            weakSelf->_dataPage = dataPage;
            //NSLog (@"NSIndex: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexes.firstIndex, (unsigned long)indexes.lastIndex,(unsigned long)indexes.count);
        }];
    }
    
    return self;
}

- (instancetype)initWithIndexes:(NSIndexSet *)indexes andCircleMember:(PFUser*) circleMember {
    self = [super init];
    if (self) {
        _indexes = indexes;
        typeof(self) weakSelf = self;
        [self addExecutionBlock:^{
            //getSearchResults
            NSArray *dataPage = [NSArray array];
            dataPage = [TellemUtility getAllCirclesOfUser:circleMember andIndexSet:indexes];
            weakSelf->_dataPage = dataPage;
            //NSLog (@"NSIndex: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexes.firstIndex, (unsigned long)indexes.lastIndex,(unsigned long)indexes.count);
        }];
    }
    
    return self;
}

- (instancetype)initWithIndexes:(NSIndexSet *)indexes andGSRServerURL: (NSString *) serverURL  andServerUser: (NSString*) serverUser andServerPassword: (NSString*) serverPassword {
    self = [super init];
    if (self) {
        _indexes = indexes;
        typeof(self) weakSelf = self;
        [self addExecutionBlock:^{
            //getSearchResults
            NSArray *dataPage = [NSArray array];
            dataPage = [TellemUtility getCoolmixGSR:serverURL andServerUser:serverUser andServerPassword:serverPassword];
            weakSelf->_dataPage = dataPage;
            //NSLog (@"NSIndex: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexes.firstIndex, (unsigned long)indexes.lastIndex,(unsigned long)indexes.count);
        }];
    }
    
    return self;
}

@end
