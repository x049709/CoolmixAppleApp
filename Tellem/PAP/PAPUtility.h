//
//  PAPUtility.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

typedef enum {
    PAPHomeTabBarItemIndex = 0,
    PAPEmptyTabBarItemIndex = 1,
    PAPActivityTabBarItemIndex = 2
} PAPTabBarControllerViewControllerIndex;


#import "UIImage+ImageEffects.h"

#define kPAPParseEmployeeAccounts [NSArray arrayWithObjects:@"400680", @"403902", @"702499", @"1225726", @"4806789", @"6409809", @"12800553", @"121800083", @"500011038", @"558159381", @"721873341", @"723748661", @"865225242", nil]

@interface PAPUtility : NSObject

extern NSString *const kPAPobjectIDKey;
extern NSString *const kPAPUserIdKey;
extern NSString *const kPAPCreatedAt;
extern NSString *const kPAPUpdatedAt;
extern NSString *const kPAPACL;

extern NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPAPUserDisplayNameKey;
extern NSString *const kPAPUserUserNameKey;
extern NSString *const kPAPUserProfilePicSmallKey;
extern NSString *const kPAPUserProfilePicMediumKey;
extern NSString *const kPAPUserAttributesPhotoCountKey;
extern NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey;
extern NSString *const kPAPUserAccountType;
extern NSString *const kPAPUserEmailKey;
extern NSString *const kPAPUserTelephoneNumberKey;
extern NSString *const kPAPUserShareSettings;
extern NSString *const kPAPUserViewFriends;

extern NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification;

extern NSString *const kPAPActivityClassKey;
extern NSString *const kPAPActivityFromUserKey;
extern NSString *const kPAPActivityToUserKey;
extern NSString *const kPAPActivityCircleKey;
extern NSString *const kPAPActivityTypeKey;
extern NSString *const kPAPActivityPhotoKey;
extern NSString *const kPAPActivityTypeFollow;
extern NSString *const kPAPUserFacebookIDKey;
extern NSString *const kPAPActivityTypeLike;
extern NSString *const kPAPActivityTypeJoined;
extern NSString *const kPAPActivityContentKey;
extern NSString *const kPAPActivityTypeCircleName;
extern NSString *const kPAPActivityTypeComment;
extern NSString *const kPAPActivityMoodTypeKey;
extern NSString *const kPAPActivityTypeInitPost;
extern NSString *const kPAPActivityTypeInitPostWithDefaultPicture;
extern NSString *const kPAPActivityLastUpdated;


extern NSString *const kPAPPhotoClassKey;
extern NSString *const kPAPPhotoPictureKey;
extern NSString *const kPAPPhotoThumbnailKey;
extern NSString *const kPAPPhotoUserKey;
extern NSString *const kPAPPhotoOpenGraphIDKey;
extern NSString *const kPAPUserFacebookFriendsKey;
extern NSString *const kPAPPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kPAPPhotoAttributesLikeCountKey;
extern NSString *const kPAPPhotoAttributesLikersKey;
extern NSString *const kPAPPhotoAttributesCommentCountKey;
extern NSString *const kPAPPhotoAttributesCommentersKey;
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey;
extern NSString *const kPAPPhotoPhotoAudioKey;

extern NSString *const kPAPTellemLogClassKey;
extern NSString *const kPAPTellemLogMessageTextKey;
extern NSString *const kPAPTellemLogMessageInfoKey;

extern NSString *const kPAPCircleClassKey;
extern NSString *const kPAPCircleNameKey;
extern NSString *const kPAPCircleOwnerUserIdKey;
extern NSString *const kPAPCircleMemberUserIdKey;
extern NSString *const kPAPCircleMemberUserIdArray;
extern NSString *const kPAPCircleStatusKey;
extern NSString *const kPAPCircleProfilePicture;
extern NSString *const kPAPCircleProfileThumbnail;

extern NSString *const kPAPUserNotificationsClassKey;
extern NSString *const kPAPUserNotificationsReceivingUserKey;
extern NSString *const kPAPUserNotificationsRemoteNotificationKey;

#pragma mark - Circle Types
extern NSString *const kPAPCircleIsNewFromPostView;
extern NSString *const kPAPCircleIsNewFromPostCirclesView;
extern NSString *const kPAPCircleIsNotNewFromPostView;
extern NSString *const kPAPCircleIsNotNewFromPostCirclesView;
extern NSString *const kPAPCircleSelectedIsAllCircles;

#pragma mark - Push Message Types
extern NSString *const kPAPPushCommentOnPost;
extern NSString *const kPAPPushInviteToCircle;
extern NSString *const kPAPPushTemporaryPassword;

#pragma mark - Font Types
extern NSString *const kFontNormal;
extern NSString *const kFontThin;
extern NSString *const kFontBold;

#pragma mark - Slider Values
extern int kInitialRecTimeInSecs;
extern int kMinRecTimeInSecs;
extern int kMaxRecTimeInSecs;

#pragma mark - Twitter/Instagram Keys

//Instagram
extern NSString *const kAuthUrlString;
extern NSString *const kClientID;
extern NSString *const kClientSecret;
extern NSString *const kRedirectUri;
//Twitter
extern NSString *const kTwitterClientID;
extern NSString *const kTwitterClientSecret;
//EULA
extern NSString *const kEULALink;


#pragma mark - User Info Key

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy;
+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)unfollowUsersEventually:(NSArray *)users;
+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;

//+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
@end
