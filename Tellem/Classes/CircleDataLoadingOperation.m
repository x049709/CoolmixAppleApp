//
//  CircleDataLoadingOperation.m
//  FluentResourcePaging-example
//
//  Created by Alek Astrom on 2014-04-11.
//  Copyright (c) 2014 Alek Åström. All rights reserved.
//

#import "CircleDataLoadingOperation.h"

const NSTimeInterval CircleDataLoadingOperationDuration = 0.3;

@implementation CircleDataLoadingOperation

- (instancetype)initWithIndexes:(NSIndexSet *)indexes {
    /*
    TellemGlobals *tM = [TellemGlobals globalsManager];
    NSUInteger diff = indexes.lastIndex + indexes.count - tM.gMaxActivitiesToShow;
    NSIndexSet *indexSetToUse;
    if (diff>0) {
        indexSetToUse = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexes.firstIndex, indexes.lastIndex - diff)];
    } else {
        indexSetToUse = [[NSIndexSet alloc] initWithIndexSet:indexes];
    }
    */
    self = [super init];
    
    if (self) {
        
        _indexes = indexes;
        
        typeof(self) weakSelf = self;
        [self addExecutionBlock:^{
            //Get data
            TellemGlobals *tM = [TellemGlobals globalsManager];
            NSArray *dataPage = [NSArray array];
            dataPage = [TellemUtility getAlActivitiesOfCircle:tM.gCurrentCircle andIndexSet:indexes];
            weakSelf->_dataPage = dataPage;
            //NSLog (@"NSIndex: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexes.firstIndex, (unsigned long)indexes.lastIndex,(unsigned long)indexes.count);

        }];
    }
    
    return self;
}

@end
