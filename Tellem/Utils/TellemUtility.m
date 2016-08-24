//
//  TellemUtility.m
//  Tellem
//
//  Created by Ed Bayudan on 12/27/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "TellemUtility.h"
#import "PAPUtility.h"

@implementation TellemUtility {}

+(void) tellemLog: (NSString *) msgText andMsgInfo: (NSArray *) msgInfo {

    // Create and save log to Tellem in Parse
    PFObject *tellemLog = [PFObject objectWithClassName:kPAPTellemLogClassKey];
    [tellemLog setObject:msgText forKey:kPAPTellemLogMessageTextKey];
    [tellemLog setObject:msgInfo forKey:kPAPTellemLogMessageInfoKey];
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    tellemLog.ACL = ACL;
    [tellemLog save];

}

+(PFUser*) getPFUserWithUserId: (NSString *) userId {
    
    //NSLog(@"TellemUtils getPFUserWithUserId ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *query=[PFUser query];
    [query whereKey:kPAPUserUserNameKey equalTo: userId];
    PFUser *user=(PFUser *)[query getFirstObject];
    return user;
}

+(PFUser*) getPFUserWithObjectId: (NSString *) objectId {
    
    //NSLog(@"TellemUtils getPFUserWithUserId ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *query=[PFUser query];
    [query whereKey:kPAPobjectIDKey equalTo: objectId];
    PFUser *user=(PFUser *)[query getFirstObject];
    return user;
}

+(PFObject*) getCircleWithObjectId: (NSString *) objectId {
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [circleQuery whereKey:kPAPobjectIDKey equalTo: objectId];
    PFObject *circle=[circleQuery getFirstObject];
    return circle;
}


+(NSArray*) getAvailableCirclesToJoinWithOwner: (PFUser *) ownerUser andMemberUser: (PFUser *) memberUser{
    
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [circleQuery whereKey:kPAPCircleOwnerUserIdKey equalTo:ownerUser];
    NSArray *userOwnedCircles = [NSArray array];
    NSArray *memberUserIds = [NSArray array];
    NSMutableArray *availableCircles = [NSMutableArray array];
    userOwnedCircles = [circleQuery findObjects];

    for (PFObject * userOwnedCircle in userOwnedCircles) {
        memberUserIds = [userOwnedCircle valueForKey:kPAPCircleMemberUserIdArray];
        if ([memberUserIds containsObject:[memberUser username]]) {}
        else
        if ([[userOwnedCircle valueForKey:kPAPCircleNameKey] isEqualToString:@"Private"]) {}
        else {
            [availableCircles addObject:userOwnedCircle];
        }
    }
    
    NSArray *sortedCircles = [NSArray array];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kPAPCircleNameKey ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedCircles = [availableCircles sortedArrayUsingDescriptors:sortDescriptors];
    return sortedCircles;
}

+(BOOL) isCircleNameAvailableForOwner: (PFUser *) ownerUser andCircleName: (NSString *) circleName{
    
    PFQuery *query=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [query whereKey:kPAPCircleOwnerUserIdKey equalTo: ownerUser];
    [query whereKey:kPAPCircleNameKey equalTo:circleName];
    if ([query getFirstObject]) {
        return NO;
    } else {
        return YES;
    }
}

+(PFObject*) getCircleProfileForOwner: (PFUser *) ownerUser andCircleName: (NSString *) circleName{
    
    PFQuery *query=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [query whereKey:kPAPCircleOwnerUserIdKey equalTo: ownerUser];
    [query whereKey:kPAPCircleNameKey equalTo:circleName];
    return [query getFirstObject];
}

+(PFObject*) getCircleForOwner: (PFUser *) ownerUser andCircle: (PFObject *) circle{
    
    PFQuery *query=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [query whereKey:kPAPCircleOwnerUserIdKey equalTo: ownerUser];
    [query whereKey:kPAPobjectIDKey equalTo:[circle valueForKey:kPAPobjectIDKey]];
    return [query getFirstObject];
}

+(PFObject*) getCircleObjectForCircle: (PFObject *) circle{
    
    PFQuery *query=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [query whereKey:kPAPobjectIDKey equalTo:[circle valueForKey:kPAPobjectIDKey]];
    return [query getFirstObject];
}


+(NSArray*) getAllCirclesOfUser: (PFUser *) user {
    //NSLog(@"TellemUtils getAllCircleNamesOfUser ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    NSString *userName = [user username];
    [circleQuery whereKey:kPAPCircleMemberUserIdArray equalTo:[NSString stringWithFormat:userName]];
    NSArray *userCircles = [NSArray array];
    userCircles = [circleQuery findObjects];
    NSArray *sortedCircleProfiles = [NSArray array];
    NSSortDescriptor *sortProfileDescriptor = [[NSSortDescriptor alloc] initWithKey:kPAPCircleNameKey ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortProfileDescriptors = [NSArray arrayWithObject:sortProfileDescriptor];
    sortedCircleProfiles = [userCircles sortedArrayUsingDescriptors:sortProfileDescriptors];
    return sortedCircleProfiles;
}

+(NSArray*) getAllUserIdsOfCircleName: (NSString *) circleName {
    //NSLog(@"TellemUtils getAllUserIdsOfCircleNames ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [circleQuery whereKey:kPAPCircleNameKey equalTo:circleName];
    NSArray *userCircles = [NSArray array];
    NSArray *memberUserIds = [NSArray array];
    userCircles = [circleQuery findObjects];
    memberUserIds = [userCircles valueForKey:kPAPCircleMemberUserIdArray];
    NSArray *sortedMembers = [memberUserIds sortedArrayUsingSelector:@selector(compare:)];
    return sortedMembers;
}

+(NSArray*) getAllUserIdsOfCircle:(PFObject *) circle {
    //NSLog(@"TellemUtils getAllUserIdsOfCircleNames ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [circleQuery whereKey:kPAPobjectIDKey equalTo:[circle valueForKey:kPAPobjectIDKey]];
    NSArray *userCircles = [NSArray array];
    NSArray *memberUserIds = [NSArray array];
    userCircles = [circleQuery findObjects];
    memberUserIds = [userCircles[0] valueForKey:kPAPCircleMemberUserIdArray];
    NSArray *sortedMembers = [memberUserIds sortedArrayUsingSelector:@selector(compare:)];
    return sortedMembers;
}

+(NSArray*) getAllUserIdsOfCircleName: (NSString *) circleName andUserId: (PFUser *) circleOwnerUserId {
    //NSLog(@"TellemUtils getAllUserIdsOfCircleNames ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    [circleQuery whereKey:kPAPCircleNameKey equalTo:circleName];
    [circleQuery whereKey:kPAPCircleOwnerUserIdKey equalTo:circleOwnerUserId];
    NSArray *userCircles = [NSArray array];
    NSArray *memberUserIds = [NSArray array];
    NSArray *sortedMembers = [NSArray array];
    userCircles = [circleQuery findObjects];
    if (userCircles.count == 1) {
        memberUserIds = [[userCircles objectAtIndex:0] valueForKey:kPAPCircleMemberUserIdArray];
        sortedMembers = [memberUserIds sortedArrayUsingSelector:@selector(compare:)];
    }
    return sortedMembers;
}

+(NSArray*) getAlActivitiesOfCircle: (PFObject *) circle {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    NSArray *circleActivityObjects = [NSArray array];
    PFQuery *circleActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [circleActivitiesQuery whereKey:kPAPActivityCircleKey equalTo:circle];
    [circleActivitiesQuery whereKey:kPAPActivityTypeKey  containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [circleActivitiesQuery orderByDescending:@"updatedAt"];
    [circleActivitiesQuery includeKey:kPAPActivityCircleKey];
    [circleActivitiesQuery includeKey:kPAPActivityToUserKey];
    [circleActivitiesQuery includeKey:kPAPActivityPhotoKey];
    circleActivityObjects = [circleActivitiesQuery findObjects];
    return circleActivityObjects;
}

+(NSArray*) getAllActivitiesOfUser: (PFUser *) user {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    
    NSArray *userCircles = [NSArray array];
    userCircles = [TellemUtility getAllCirclesOfUser:user];
    NSArray *userActivityObjects = [NSArray array];
    PFQuery *userActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    //[userActivitiesQuery whereKey:kPAPActivityToUserKey equalTo:user];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey  containedIn:userCircles];
    [userActivitiesQuery whereKey:kPAPActivityTypeKey  containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [userActivitiesQuery orderByDescending:@"updatedAt"];
    [userActivitiesQuery includeKey:kPAPActivityCircleKey];
    [userActivitiesQuery includeKey:kPAPActivityToUserKey];
    [userActivitiesQuery includeKey:kPAPActivityPhotoKey];

    userActivityObjects = [userActivitiesQuery findObjects];
    //[PFObject pinAllInBackground:userActivityObjects];
    return userActivityObjects;
    
}

+(NSArray*) getAllActivitiesOfUserInALoop: (PFUser *) user {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    
    NSArray *userCircles = [NSArray array];
    userCircles = [TellemUtility getAllCirclesOfUser:user];
    NSMutableArray *userActivityArray = [NSMutableArray array];
    for (PFObject *circle in userCircles) {
        NSArray *actArray = [TellemUtility getAlActivitiesOfCircle:circle];
        [userActivityArray addObjectsFromArray:actArray];
    }
    
    NSArray *sortedActivities = [NSArray array];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kPAPUpdatedAt ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedActivities = [userActivityArray sortedArrayUsingDescriptors:sortDescriptors];
    NSArray *shortlistedSortedActivities = [sortedActivities subarrayWithRange:NSMakeRange(0, 50)];
    return shortlistedSortedActivities;
    
}

+(NSArray*) getAllActivitiesOfUserUsingSubquery: (PFUser *) user {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    
    //Get all circles of user
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    NSString *userName = [[PFUser currentUser] username];
    [circleQuery whereKey:kPAPCircleMemberUserIdArray equalTo:[NSString stringWithFormat:userName]];

    PFQuery *userActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey matchesKey:kPAPobjectIDKey inQuery:circleQuery];
    [userActivitiesQuery whereKeyExists:kPAPActivityCircleKey];
    [userActivitiesQuery whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [userActivitiesQuery orderByDescending:@"updatedAt"];
    [userActivitiesQuery includeKey:kPAPActivityCircleKey];
    [userActivitiesQuery includeKey:kPAPActivityToUserKey];
    [userActivitiesQuery includeKey:kPAPActivityPhotoKey];
    userActivitiesQuery.limit = 20;
    
    NSArray *userActivityObjects = [NSArray array];
    userActivityObjects = [userActivitiesQuery findObjects];
    //[PFObject pinAllInBackground:userActivityObjects];
    return userActivityObjects;
    
}

+(NSUInteger) countActivitiesOfUser: (PFUser*) user {
    
    //Get all circles of user
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    NSString *userName = [[PFUser currentUser] username];
    [circleQuery whereKey:kPAPCircleMemberUserIdArray equalTo:[NSString stringWithFormat:userName]];
    
    PFQuery *userActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey matchesKey:kPAPobjectIDKey inQuery:circleQuery];
    [userActivitiesQuery whereKeyExists:kPAPActivityCircleKey];
    [userActivitiesQuery whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [userActivitiesQuery includeKey:kPAPActivityCircleKey];
    NSUInteger activityCount = [userActivitiesQuery countObjects];
    
    return activityCount;
}

+(NSUInteger) countActivitiesOfCircle: (PFObject *) circle {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *circleActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [circleActivitiesQuery whereKey:kPAPActivityCircleKey equalTo:circle];
    [circleActivitiesQuery whereKey:kPAPActivityTypeKey  containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [circleActivitiesQuery includeKey:kPAPActivityCircleKey];
    NSUInteger activityCount = [circleActivitiesQuery countObjects];
    
    return activityCount;
}

+(NSUInteger) countSearchResults: (NSString *) searchRequest {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserId = [currentUser objectId];
    PFQuery *query = [PFUser query];
    //The "i" means case-insensitive search
    [query whereKey:kPAPUserDisplayNameKey matchesRegex:searchRequest modifiers:@"i"];
    [query whereKey:kPAPobjectIDKey notEqualTo:currentUserId];
    [query whereKey:kPAPUserDisplayNameKey notEqualTo:@"Guest"];
    [query orderByAscending:kPAPUserDisplayNameKey];
    NSUInteger searchCount = [query countObjects];
    
    return searchCount;
}

+(NSUInteger) countAllCirclesOfUser: (PFUser *) user {
    //NSLog(@"TellemUtils getAllCircleNamesOfUser ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    NSString *userName = [user username];
    [circleQuery whereKey:kPAPCircleMemberUserIdArray equalTo:[NSString stringWithFormat:userName]];
    NSUInteger searchCount = [circleQuery countObjects];
    return searchCount;
}


+(NSArray*) getAllActivitiesOfUser: (PFUser *) user andIndexSet: (NSIndexSet*) indexSet {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    
    //Get all circles of user
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    NSString *userName = [[PFUser currentUser] username];
    [circleQuery whereKey:kPAPCircleMemberUserIdArray equalTo:[NSString stringWithFormat:userName]];
    
    PFQuery *userActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey matchesKey:kPAPobjectIDKey inQuery:circleQuery];
    [userActivitiesQuery whereKeyExists:kPAPActivityCircleKey];
    [userActivitiesQuery whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [userActivitiesQuery orderByDescending:@"updatedAt"];
    [userActivitiesQuery includeKey:kPAPActivityCircleKey];
    [userActivitiesQuery includeKey:kPAPActivityToUserKey];
    [userActivitiesQuery includeKey:kPAPActivityPhotoKey];
    userActivitiesQuery.limit = indexSet.count;
    userActivitiesQuery.skip = indexSet.firstIndex;
    //NSLog (@"TellemUtils: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexSet.firstIndex, (unsigned long)indexSet.lastIndex,(unsigned long)indexSet.count);
    
    NSArray *userActivityObjects = [NSArray array];
    userActivityObjects = [userActivitiesQuery findObjects];
    //[PFObject pinAllInBackground:userActivityObjects];
    return userActivityObjects;
    
}

+(NSArray*) getAlActivitiesOfCircle: (PFObject *) circle andIndexSet: (NSIndexSet*) indexSet  {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    NSArray *circleActivityObjects = [NSArray array];
    PFQuery *circleActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [circleActivitiesQuery whereKey:kPAPActivityCircleKey equalTo:circle];
    [circleActivitiesQuery whereKey:kPAPActivityTypeKey  containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    [circleActivitiesQuery orderByDescending:@"updatedAt"];
    [circleActivitiesQuery includeKey:kPAPActivityCircleKey];
    [circleActivitiesQuery includeKey:kPAPActivityToUserKey];
    [circleActivitiesQuery includeKey:kPAPActivityPhotoKey];
    circleActivitiesQuery.limit = indexSet.count;
    circleActivitiesQuery.skip = indexSet.firstIndex;
    //NSLog (@"TellemUtils: firstIndex is %lu,  lastIndex is %lu, count is %lu", (unsigned long)indexSet.firstIndex, (unsigned long)indexSet.lastIndex,(unsigned long)indexSet.count);

    circleActivityObjects = [circleActivitiesQuery findObjects];
    return circleActivityObjects;
}


+(NSArray*) getSearchResults:  (NSString *) searchRequest andIndexSet: (NSIndexSet*) indexSet  {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    NSArray *searchResults;
    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserId = [currentUser objectId];
    PFQuery *query = [PFUser query];
    //The "i" means case-insensitive search
    [query whereKey:kPAPUserDisplayNameKey matchesRegex: searchRequest modifiers:@"i"];
    [query whereKey:kPAPobjectIDKey notEqualTo:currentUserId];
    [query whereKey:kPAPUserDisplayNameKey notEqualTo:@"Guest"];
    [query orderByAscending:kPAPUserDisplayNameKey];
    query.limit = indexSet.count;
    query.skip = indexSet.firstIndex;
    searchResults = [query findObjects];
    
    return searchResults;
}

+(NSArray*) getAllCirclesOfUser: (PFUser *) user andIndexSet: (NSIndexSet*) indexSet  {
    //NSLog(@"TellemUtils getAllCircleNamesOfUser ERROR IN COUNTING CIRCLE MEMBERS!");
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    NSString *userName = [user username];
    [circleQuery whereKey:kPAPCircleMemberUserIdArray equalTo:[NSString stringWithFormat:userName]];
    [circleQuery orderByAscending:kPAPCircleNameKey];
    circleQuery.limit = indexSet.count;
    circleQuery.skip = indexSet.firstIndex;
    NSArray *userCircles = [NSArray array];
    userCircles = [circleQuery findObjects];
    return userCircles;
}


+(NSArray*) getAllActivitiesOfUserLight: (PFUser *) user {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    //Gets all activities of user without associated entities
    NSArray *userCircles = [NSArray array];
    userCircles = [TellemUtility getAllCirclesOfUser:user];
    NSArray *userActivityObjects = [NSArray array];
    PFQuery *userActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    //[userActivitiesQuery whereKey:kPAPActivityToUserKey equalTo:user];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey  containedIn:userCircles];
    [userActivitiesQuery includeKey:kPAPActivityCircleKey];
    userActivityObjects = [userActivitiesQuery findObjects];
    //[PFObject pinAllInBackground:userActivityObjects];
    return userActivityObjects;
    
}

+(NSArray*) getAllActivitiesOfUserLightInALoop: (PFUser *) user {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    //Gets all activities of user without associated entities
    NSArray *userCircles = [NSArray array];
    userCircles = [TellemUtility getAllCirclesOfUser:user];
    NSMutableArray *userActivityArray = [NSMutableArray array];
    for (PFObject *circle in userCircles) {
        NSArray *actArray = [TellemUtility getAllActivitiesOfCircleLight:circle];
        [userActivityArray addObjectsFromArray:actArray];
    }
    return userActivityArray;
    
}

+(NSArray*) getAllActivitiesOfUserLightUsingSubquery: (PFUser *) user {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    
    //Get all circles of user
    PFQuery *circleQuery=[PFQuery queryWithClassName:kPAPCircleClassKey];
    NSString *userName = [[PFUser currentUser] username];
    [circleQuery whereKey:kPAPCircleMemberUserIdArray equalTo:[NSString stringWithFormat:userName]];
    
    PFQuery *userActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey matchesKey:kPAPobjectIDKey inQuery:circleQuery];
    [userActivitiesQuery whereKeyExists:kPAPActivityCircleKey];
    [userActivitiesQuery whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture,kPAPActivityTypeComment]];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    userActivitiesQuery.limit = tM.gMaxActivitiesToMap;
    [userActivitiesQuery orderByDescending:@"updatedAt"];
    NSArray *userActivityObjects = [NSArray array];
    userActivityObjects = [userActivitiesQuery findObjects];
    //[PFObject pinAllInBackground:userActivityObjects];
    return userActivityObjects;
    
}

+(NSArray*) getAllActivitiesOfCircleLight: (PFObject *) circle {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    //Gets all activities of circle without associated entities
    NSArray *userActivityObjects = [NSArray array];
    PFQuery *userActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey  equalTo:circle];
    [userActivitiesQuery whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture,kPAPActivityTypeComment]];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    userActivitiesQuery.limit = tM.gMaxActivitiesToMap;
    [userActivitiesQuery orderByDescending:@"updatedAt"];
    userActivityObjects = [userActivitiesQuery findObjects];
    return userActivityObjects;
    
}

+(NSArray*) getAllActivitiesOfToAndFromUser: (PFUser *) user {
    //NSLog(@"TellemUtils getAlActivitiesOfCircle ERROR IN COUNTING CIRCLE MEMBERS!");
    
    PFQuery *toQuery=[PFQuery queryWithClassName:kPAPActivityClassKey];
    [toQuery whereKey:kPAPActivityToUserKey equalTo:user];
    PFQuery *fromQuery=[PFQuery queryWithClassName:kPAPActivityClassKey];
    [fromQuery whereKey:kPAPActivityFromUserKey equalTo:user];
    

    NSArray *userCircles = [NSArray array];
    userCircles = [TellemUtility getAllCirclesOfUser:user];
    NSArray *userActivityObjects = [NSArray array];
    PFQuery *userActivitiesQuery = [PFQuery orQueryWithSubqueries:@[toQuery,fromQuery]];
    [userActivitiesQuery whereKey:kPAPActivityCircleKey  containedIn:userCircles];
    [userActivitiesQuery whereKey:kPAPActivityTypeKey  containedIn:@[kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture,kPAPActivityTypeComment]];
    [userActivitiesQuery orderByDescending:@"updatedAt"];
    [userActivitiesQuery includeKey:kPAPActivityCircleKey];
    [userActivitiesQuery includeKey:kPAPActivityToUserKey];
    [userActivitiesQuery includeKey:kPAPActivityPhotoKey];
    
    userActivityObjects = [userActivitiesQuery findObjects];
    //[PFObject pinAllInBackground:userActivityObjects];
    return userActivityObjects;
    
}

+(int) pickIndexOfInitialPostOfPictureFromCircleActivities: (NSArray *) circleActivities andPushPayload: (NSDictionary*) pushPayload {
    //NSLog(@"TellemUtils getInitialPostOfPicture ERROR IN COUNTING CIRCLE MEMBERS!");
    NSArray *payLoad=[NSArray array];
    NSArray *initialPhoto=[NSArray array];
    payLoad = [pushPayload objectForKey:@"payload"];
    initialPhoto = [[payLoad objectAtIndex:0] objectAtIndex:2];
    NSString *photoKey = [initialPhoto valueForKey:kPAPobjectIDKey];
    
    int photoIndex = 0;
    for(int i = 0; i < circleActivities.count; i++) {
        NSString *activityPhotoKey = [[circleActivities objectAtIndex:i] valueForKey:kPAPActivityPhotoKey];
        NSString *photoObjectId = [activityPhotoKey  valueForKey:kPAPobjectIDKey];
        if ([photoObjectId isEqualToString:photoKey]) {
            photoIndex = i;
            break;
        }
    }
    return photoIndex;
}

+(int) pickIndexOfPhotoFromCircleActivities: (NSArray *) circleActivities andPhoto: (PFObject*) photo {
    //NSLog(@"TellemUtils getInitialPostOfPicture ERROR IN COUNTING CIRCLE MEMBERS!");
    NSString *photoKey = [photo valueForKey:kPAPobjectIDKey];
    
    int photoIndex = 0;
    for(int i = 0; i < circleActivities.count; i++) {
        NSString *activityPhotoKey = [[circleActivities objectAtIndex:i] valueForKey:kPAPActivityPhotoKey];
        NSString *photoObjectId = [activityPhotoKey  valueForKey:kPAPobjectIDKey];
        if ([photoObjectId isEqualToString:photoKey]) {
            photoIndex = i;
            break;
        }
    }
    return photoIndex;
}


+(int) pickIndexOfCirclePostedToFromListOfCircles: (NSArray *) circleList andPushPayload: (NSDictionary*) pushPayload {
    //NSLog(@"TellemUtils getInitialPostOfPicture ERROR IN COUNTING CIRCLE MEMBERS!");
    NSArray *payLoad=[NSArray array];
    NSArray *circlePostedTo=[NSArray array];
    payLoad = [pushPayload objectForKey:@"payload"];
    circlePostedTo = [[payLoad objectAtIndex:0] objectAtIndex:3];
    NSString *circleKey = [circlePostedTo valueForKey:kPAPobjectIDKey];
    
    int circleIndex = 0;
    for(int i = 0; i < circleList.count; i++) {
        NSString *circlePostedToKey = [[circleList objectAtIndex:i] valueForKey:kPAPobjectIDKey];
        if ([circlePostedToKey isEqualToString:circleKey]) {
            circleIndex = i;
            break;
        }
    }
    return circleIndex;
}

+(int) pickIndexOfCircleInvitedToFromListOfCircles: (NSArray *) circleList andPushPayload: (NSDictionary*) pushPayload {
    //NSLog(@"TellemUtils getInitialPostOfPicture ERROR IN COUNTING CIRCLE MEMBERS!");
    NSArray *payLoad=[NSArray array];
    NSArray *circlePostedTo=[NSArray array];
    payLoad = [pushPayload objectForKey:@"payload"];
    circlePostedTo = [[payLoad objectAtIndex:0] objectAtIndex:2];
    NSString *circleKey = [circlePostedTo valueForKey:kPAPobjectIDKey];
    
    int circleIndex = 0;
    for(int i = 0; i < circleList.count; i++) {
        NSString *circlePostedToKey = [[circleList objectAtIndex:i] valueForKey:kPAPobjectIDKey];
        if ([circlePostedToKey isEqualToString:circleKey]) {
            circleIndex = i;
            break;
        }
    }
    return circleIndex;
}


+(void)sendMessageToUser: (PFUser*) receivingUser withCircleName: (NSString*) circleName andSendingUser: (PFUser*) sendingUser {
    //NSLog(@"TellemUtility sendMessageToUser WRONG WAY TO SEND PUSH - INSECURE!");
    
    NSString *message = [NSString stringWithFormat:@"%@ added you to a circle!", sendingUser[kPAPUserDisplayNameKey]];
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" equalTo:[receivingUser username]];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:@{
                    @"alert": message,
                    @"badge": @1,
                    @"sound": @"cheering.caf",
                    @"circle": circleName,
                    @"owner": sendingUser[@"username"]
                    }];
    [push sendPushInBackground];
    
    NSString *alertMsg = [receivingUser[kPAPUserDisplayNameKey] stringByAppendingString: @" added to \""];
    alertMsg = [alertMsg stringByAppendingString: circleName];
    alertMsg = [alertMsg stringByAppendingString: @"\""];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:alertMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
}

+(void)sendMessageToManyUsers: (NSMutableArray*) receivingUsers withCircleName: (NSString*) circleName  andSendingUser: (PFUser*) sendingUser  andMessage: (NSString*) messageToSend {
    //NSLog(@"TellemUtility sendMessageToUser WRONG WAY TO SEND PUSH - INSECURE!");
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" containedIn:receivingUsers];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:@{
                    @"alert": messageToSend,
                    @"badge": @1,
                    @"sound": @"cheering.caf",
                    @"circle": circleName,
                    @"owner": sendingUser[@"username"],
                    @"members": receivingUsers
                    }];
    [push sendPushInBackground];
}

+(void)sendMessageToManyUsers: (NSMutableArray*) receivingUsers withCircleName: (NSString*) circleName  andSendingUser: (PFUser*) sendingUser  andMessage: (NSString*) messageToSend andPayload: (NSArray *) payload {
    //NSLog(@"TellemUtility sendMessageToUser WRONG WAY TO SEND PUSH - INSECURE!");
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" containedIn:receivingUsers];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:@{
                    @"alert": messageToSend,
                    @"badge": @1,
                    @"sound": @"cheering.caf",
                    @"circle": circleName,
                    @"owner": sendingUser[@"username"],
                    @"members": receivingUsers,
                    @"payload": payload
                   }];
    [push sendPushInBackground];
}

+(void)sendMessageToManyUsers: (NSMutableArray*) receivingUsers withCircleName: (NSString*) circleName  andSendingUser: (PFUser*) sendingUser  andMessage: (NSString*) messageToSend andMessageType: (NSString*) msgType andPayload: (NSArray *) payload {
    //NSLog(@"TellemUtility sendMessageToUser WRONG WAY TO SEND PUSH - INSECURE!");
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" containedIn:receivingUsers];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:@{
                    @"alert": messageToSend,
                    @"badge": @1,
                    @"sound": @"cheering.caf",
                    @"circle": circleName,
                    @"msgtype": msgType,
                    @"owner": sendingUser[@"username"],
                    @"members": receivingUsers,
                    @"payload": payload
                    }];
    [push sendPushInBackground];
}

+(void)sendForgottenPasswordToUser: (NSString*) receivingUser {
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"DDD"];
    NSInteger dayInYear = [[dateFormat stringFromDate:today] integerValue];
    NSString *dayInYearString = [NSString stringWithFormat: @"%ld", (long)dayInYear];
    NSString *temporaryPassword = [receivingUser stringByAppendingString:dayInYearString];
    NSString *messageToSend = [@"Your temporary password is:" stringByAppendingString:temporaryPassword];
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" equalTo:receivingUser];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:@{
                    @"alert": messageToSend,
                    @"badge": @1,
                    @"msgtype": kPAPPushTemporaryPassword,
                    @"sound": @"cheering.caf"
                    }];
    [push sendPushInBackground];
}


+ (NSString *)timeInHumanReadableFormat:(NSTimeInterval)interval
{
    NSString *retVal = @"At time of event";
    if (interval == 0) return retVal;
    
    int second = 1;
    int minute = second*60;
    int hour = minute*60;
    int day = hour*24;
    // interval can be before (negative) or after (positive)
    int num = abs(interval);
    
    NSString *beforeOrAfter = @"ago";
    NSString *unit = @"day";
    if (interval > 0) {
        beforeOrAfter = @"after";
    }
    
    if (num >= day) {
        num /= day;
        if (num > 1) unit = @"days";
    } else if (num >= hour) {
        num /= hour;
        unit = (num > 1) ? @"hours" : @"hour";
    } else if (num >= minute) {
        num /= minute;
        unit = (num > 1) ? @"minutes" : @"minute";
    } else if (num >= second) {
        num /= second;
        unit = (num > 1) ? @"seconds" : @"second";
        
    }
    
    return [NSString stringWithFormat:@"%d %@ %@", num, unit, beforeOrAfter];
}

+(NSUInteger) countActivitiesForCircle: (PFObject*) circle andPhoto: (PFObject*) photo {
    
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityPhotoKey equalTo:photo];
    [query whereKey:kPAPActivityCircleKey equalTo:circle];
    [query whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeComment,kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    NSUInteger activityCount = [query countObjects];

    return activityCount;
}

+(NSMutableArray*) getAllFriendsofUser: (PFUser *) user andAccountType: (NSString*) accountType  {
    //NSLog(@"TellemUtils getAllFriendsofUser ERROR IN COUNTING CIRCLE MEMBERS!");
    NSMutableArray *friendsOfUser = [NSMutableArray array];
    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery whereKey:kPAPUserAccountType equalTo:accountType];
    [friendsQuery whereKey:kPAPobjectIDKey notEqualTo:[user objectId]];
    [friendsQuery orderByAscending:kPAPUserDisplayNameKey];
    
    friendsOfUser = (NSMutableArray*)[friendsQuery findObjects];
    return friendsOfUser;
}

+ (NSMutableArray*) getCoolmixGSR: (NSString *) serverURL andServerUser: (NSString*) serverUser andServerPassword: (NSString*) serverPassword
{
    NSMutableArray *gsrList = [NSMutableArray new];
    NSString *requestURL = [serverURL stringByAppendingString:@"/gsrApi/gsr/"];
    NSString *requestUser = serverUser;
    NSString *requestPassword = serverPassword;
    NSString *escapedURL = [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:escapedURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:requestUser andPassword:requestPassword];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil)
    {
        gsrList = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    }
    
    return gsrList;

}

+ (NSMutableArray*) getCoolmixGSRImages: (NSMutableArray *) gsrList
{
    NSMutableArray *gsrImages = [NSMutableArray new];
    RestClient *restClient = [[RestClient alloc] init];
    TellemGlobals *tM = [TellemGlobals globalsManager];

    for (NSDictionary *item in gsrList) {
        NSString *imageFileName = [item objectForKey:@"imageFileName"];
        NSString *imageFilePath = [item objectForKey:@"imageFilePath"];
        UIImage *gsrImage = [restClient getImageFromMix:tM.gCoolmixServerURL andServerUser:tM.gCoolmixServerUser andServerPassword:tM.gCoolmixServerPassword andImageFilePath:imageFilePath andImageFileName:imageFileName];
        [gsrImages addObject:gsrImage];
    }
    
    return gsrImages;
    
}

@end

