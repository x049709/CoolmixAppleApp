//
//  TellemUtility.h
//  Tellem
//
//  Created by Ed Bayudan on 12/27/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableURLRequest+BasicAuth.h"
#import "RestClient.h"

@interface TellemUtility : NSObject {
}
+(void) tellemLog: (NSString *) msgText andMsgInfo: (NSArray *) msgInfo;
+(PFUser*) getPFUserWithUserId: (NSString *) userId;
+(PFUser*) getPFUserWithObjectId: (NSString *) objectId;
+(NSArray*) getAvailableCirclesToJoinWithOwner: (PFUser *) ownerUser andMemberUser: (PFUser *) memberUser;
+(PFObject*) getCircleWithObjectId: (NSString *) objectId;
+(BOOL) isCircleNameAvailableForOwner: (PFUser *) ownerUser andCircleName: (NSString *) circleName;
+(NSArray*) getAlActivitiesOfCircle: (PFObject *) circleName;
+(NSArray*) getAllActivitiesOfUser: (PFUser *) user;
+(NSArray*) getAllActivitiesOfUserInALoop: (PFUser *) user;
+(NSArray*) getAllActivitiesOfUserUsingSubquery: (PFUser *) user;
+(NSUInteger) countActivitiesOfUser: (PFUser*) user;
+(NSUInteger) countActivitiesOfCircle: (PFObject *) circle;
+(NSUInteger) countSearchResults: (NSString *) searchRequest;
+(NSUInteger) countAllCirclesOfUser: (PFUser *) user;
+(NSArray*) getAllActivitiesOfUser: (PFUser *) user andIndexSet: (NSIndexSet*) indexSet;
+(NSArray*) getAlActivitiesOfCircle: (PFObject *) circle andIndexSet: (NSIndexSet*) indexSet;
+(NSArray*) getSearchResults: (NSString *) searchRequest andIndexSet: (NSIndexSet*) indexSet;
+(NSArray*) getAllCirclesOfUser: (PFUser *) user andIndexSet: (NSIndexSet*) indexSet;
+(NSArray*) getAllActivitiesOfUserLight: (PFUser *) user;
+(NSArray*) getAllActivitiesOfCircleLight: (PFObject *) circle;
+(NSArray*) getAllActivitiesOfUserLightInALoop: (PFUser *) user;
+(NSArray*) getAllActivitiesOfUserLightUsingSubquery: (PFUser *) user;
+(NSArray*) getAllActivitiesOfToAndFromUser: (PFUser *) user;
+(NSString*)timeInHumanReadableFormat:(NSTimeInterval)interval;
+(NSArray*) getAllUserIdsOfCircleName: (NSString *) circleName andUserId: (PFUser *) circleOwnerUserId;
+(NSArray*) getAllUserIdsOfCircle:(PFObject *) circle;
+(void)sendMessageToUser: (PFUser*) userName withCircleName: (NSString*) circleName andSendingUser: (PFUser*) sendingUser;
+(void)sendMessageToManyUsers: (NSMutableArray*) receivingUsers withCircleName: (NSString*) circleName andSendingUser: (PFUser*) sendingUser  andMessage: (NSString*) messageToSend;
+(void)sendMessageToManyUsers: (NSMutableArray*) receivingUsers withCircleName: (NSString*) circleName  andSendingUser: (PFUser*) sendingUser  andMessage: (NSString*) messageToSend andPayload: (NSArray*) payload;
+(void)sendMessageToManyUsers: (NSMutableArray*) receivingUsers withCircleName: (NSString*) circleName  andSendingUser: (PFUser*) sendingUser  andMessage: (NSString*) messageToSend andMessageType: (NSString*) msgType andPayload: (NSArray *) payload;
+(NSArray*) getAllCirclesOfUser: (PFUser *) user;
+(PFObject*) getCircleForOwner: (PFUser *) ownerUser andCircle: (PFObject *) circle;
+(PFObject*) getCircleObjectForCircle: (PFObject *) circle;
+(PFObject*) getCircleProfileForOwner: (PFUser *) ownerUser andCircleName: (NSString *) circleName;
+(int) pickIndexOfInitialPostOfPictureFromCircleActivities: (NSArray *) circleActivities andPushPayload: (NSDictionary*) pushPayload;
+(int) pickIndexOfCirclePostedToFromListOfCircles: (NSArray *) circleList andPushPayload: (NSDictionary*) pushPayload;
+(int) pickIndexOfCircleInvitedToFromListOfCircles: (NSArray *) circleList andPushPayload: (NSDictionary*) pushPayload;
+(int) pickIndexOfPhotoFromCircleActivities: (NSArray *) circleActivities andPhoto: (PFObject*) photo;
+(void)sendForgottenPasswordToUser: (NSString*) receivingUser;
+(NSUInteger) countActivitiesForCircle: (PFObject*) circle andPhoto: (PFObject*) photo;
+(NSMutableArray*) getAllFriendsofUser: (PFUser *) user andAccountType: (NSString*) accountType;
+(NSMutableArray*) getCoolmixGSR: (NSString *) serverURL andServerUser: (NSString*) serverUser andServerPassword: (NSString*) serverPassword;
+(NSMutableArray*) getCoolmixGSRImages: (NSMutableArray *) gsrList;






@end
