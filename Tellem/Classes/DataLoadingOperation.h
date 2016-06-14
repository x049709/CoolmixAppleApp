//
//  DataLoadingOperation.h
//  FluentResourcePaging-example
//
//  Created by Alek Astrom on 2014-04-11.
//  Copyright (c) 2014 Alek Åström. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLoadingOperation : NSBlockOperation

- (instancetype)initWithIndexes:(NSIndexSet *)indexes;
- (instancetype)initWithIndexes:(NSIndexSet *)indexes andCircle:(PFObject*) currentCircle;
- (instancetype)initWithIndexes:(NSIndexSet *)indexes andSearchText:(NSString*) searchText;
- (instancetype)initWithIndexes:(NSIndexSet *)indexes andCircleMember:(PFUser*) circleMember;
- (instancetype)initWithIndexes:(NSIndexSet *)indexes andGSRServerURL: (NSString *) serverURL  andServerUser: (NSString*) serverUser andServerPassword: (NSString*) serverPassword;

@property (nonatomic, readonly) NSIndexSet *indexes;
@property (nonatomic, readonly) NSArray *dataPage;

@end
