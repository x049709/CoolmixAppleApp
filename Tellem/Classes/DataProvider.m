//
//  DataProvider.m
//  FluentResourcePaging-example
//
//  Created by Alek Astrom on 2013-12-28.
//  Copyright (c) 2013 Alek Åström. All rights reserved.
//

#import "DataProvider.h"
#import "AWPagedArray.h"
#import "DataLoadingOperation.h"

const NSUInteger DataProviderDefaultPageSize = 20;
const NSUInteger DataProviderDataCount = 151;

@interface DataProvider () <AWPagedArrayDelegate>
@end

@implementation DataProvider {
    AWPagedArray *_pagedArray;
    NSOperationQueue *_operationQueue;
    NSMutableDictionary *_dataLoadingOperations;
}

#pragma mark - Cleanup
- (void)dealloc {
    //NSLog (@"DataProvider about to dealloc");
    [_operationQueue.operations makeObjectsPerformSelector:@selector(cancel)];
    _pagedArray = nil;
}

#pragma mark - Initialization
- (instancetype)init {
    TellemGlobals *tM = [TellemGlobals globalsManager];
    return [self initWithPageSize:tM.gActivitiesPerPage andProviderCount:tM.gActivitiesToShow];
}

- (instancetype)initWithPageSize:(NSUInteger)pageSize andProviderCount:(NSUInteger) providerCount {

    self = [super init];
    if (self) {
        _pagedArray = [[AWPagedArray alloc] initWithCount:providerCount objectsPerPage:pageSize];
        _pagedArray.delegate = self;
        _dataLoadingOperations = [NSMutableDictionary dictionary];
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

#pragma mark - Accessors
- (NSUInteger)loadedCount {
    return _pagedArray.pages.count*_pagedArray.objectsPerPage;
}
- (NSUInteger)pageSize {
    return _pagedArray.objectsPerPage;
}
- (NSArray *)dataObjects {
    return (NSArray *)_pagedArray;
}

#pragma mark - Other public methods
- (BOOL)isLoadingDataAtIndex:(NSUInteger)index {
    return _dataLoadingOperations[@([_pagedArray pageForIndex:index])] != nil;
}
- (void)loadDataForIndex:(NSUInteger)index {
    [self _setShouldLoadDataForPage:[_pagedArray pageForIndex:index]];
}

#pragma mark - Private methods
- (void)_setShouldLoadDataForPage:(NSUInteger)page {
    
    if (!_pagedArray.pages[@(page)] && !_dataLoadingOperations[@(page)]) {
        // Don't load data if there already is a loading operation in progress
        [self _loadDataForPage:page];
    }
}
- (void)_loadDataForPage:(NSUInteger)page {
    //NSLog (@"_loadDataForPage,%lu",(unsigned long)page);
    NSIndexSet *indexes = [_pagedArray indexSetForPage:page];
    
    NSOperation *loadingOperation = [self _loadingOperationForPage:page indexes:indexes];
    _dataLoadingOperations[@(page)] = loadingOperation;
    
    if ([self.delegate respondsToSelector:@selector(dataProvider:willLoadDataAtIndexes:)]) {
        [self.delegate dataProvider:self willLoadDataAtIndexes:indexes];
    }
    [_operationQueue addOperation:loadingOperation];
}

- (NSOperation *)_loadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes {
    //NSLog (@"_loadingOperationForDataload,%lu,%@",(unsigned long)_dataLoader,indexes);

    DataLoadingOperation *operation;
    if (_dataLoader == 0) //load data for home activities
    {
        operation = [[DataLoadingOperation alloc] initWithIndexes:indexes];
    }
    else
        if (_dataLoader == 1) //load data for circle activities
        {
            operation = [[DataLoadingOperation alloc] initWithIndexes:indexes andCircle:_currentCircle];
        }
        else
            if (_dataLoader == 2) //load data for people searches
            {
                operation = [[DataLoadingOperation alloc] initWithIndexes:indexes andSearchText:_searchText];
            }
            else
                if (_dataLoader == 3) //load data for circle list
                {
                    operation = [[DataLoadingOperation alloc] initWithIndexes:indexes andCircleMember:_circleMember];
                }
                else
                    if (_dataLoader == 4) //load data for GSR list
                    {
                        operation = [[DataLoadingOperation alloc] initWithIndexes:indexes andGSRServerURL:_serverURL andServerUser:_serverUser andServerPassword:_serverPassword];
                    }
    
    // Remember to not retain self in block since we store the operation
    __weak typeof(self) weakSelf = self;
    __weak typeof(operation) weakOperation = operation;
    operation.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf _dataOperation:weakOperation finishedLoadingForPage:page];
        }];
    };

    return operation;
}
- (void)_preloadNextPageIfNeededForIndex:(NSUInteger)index {
    
    if (!self.shouldLoadAutomatically) {
        return;
    }
    
    NSUInteger currentPage = [_pagedArray pageForIndex:index];
    NSUInteger preloadPage = [_pagedArray pageForIndex:index+self.automaticPreloadMargin];
    
    if (preloadPage > currentPage && preloadPage <= _pagedArray.numberOfPages) {
        [self _setShouldLoadDataForPage:preloadPage];
    }
}
- (void)_dataOperation:(DataLoadingOperation *)operation finishedLoadingForPage:(NSUInteger)page {
    
    [_dataLoadingOperations removeObjectForKey:@(page)];
    [_pagedArray setObjects:operation.dataPage forPage:page];
    
    if ([self.delegate respondsToSelector:@selector(dataProvider:didLoadDataAtIndexes:)]) {
        [self.delegate dataProvider:self didLoadDataAtIndexes:operation.indexes];
    }
}

#pragma mark - Paged array delegate
- (void)pagedArray:(AWPagedArray *)pagedArray willAccessIndex:(NSUInteger)index returnObject:(__autoreleasing id *)returnObject {

    if ([*returnObject isKindOfClass:[NSNull class]] && self.shouldLoadAutomatically) {
        [self _setShouldLoadDataForPage:[pagedArray pageForIndex:index]];
    } else {
        [self _preloadNextPageIfNeededForIndex:index];
    }
}

@end
