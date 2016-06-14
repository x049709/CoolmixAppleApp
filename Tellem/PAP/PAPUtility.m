//
//  PAPUtility.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPUtility.h"
#import "UIImage+ResizeAdditions.h"
#import "AppDelegate.h"
#import "PAPCache.h"

NSString *const kPAPobjectIDKey   = @"objectId";
NSString *const kPAPUserIdKey   = @"user";
NSString *const kPAPUpdatedAt   = @"updatedAt";
NSString *const kPAPACL   = @"ACL";

NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey  = @"com.parse.testtellem.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey = @"com.parse.Anypic.userDefaults.cache.facebookFriends";
NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification = @"com.parse.Anypic.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kPAPUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kPAPUserFacebookIDKey   = @"facebookId";
NSString *const kPAPUserUserNameKey   = @"username";
NSString *const kPAPUserProfilePicSmallKey   = @"profilePictureSmall";
NSString *const kPAPUserDisplayNameKey       = @"displayName";
NSString *const kPAPUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";
NSString *const kPAPUserProfilePicMediumKey  = @"profilePictureMedium";
NSString *const kPAPUserAccountType  = @"Accounttype";
NSString *const kPAPUserEmailKey  = @"email";
NSString *const kPAPUserTelephoneNumberKey  = @"telephoneNumber";
NSString *const kPAPUserShareSettings  = @"ShareSettings";
NSString *const kPAPUserViewFriends  = @"ViewFriends";

NSString *const kPAPActivityClassKey=@"Activity";
NSString *const kPAPActivityFromUserKey=@"fromUser";
NSString *const kPAPActivityToUserKey=@"toUser";
NSString *const kPAPActivityCircleKey = @"circleKey";
NSString *const kPAPActivityTypeKey=@"type";
NSString *const kPAPActivityTypeFollow=@"follow";
NSString *const kPAPActivityTypeLike = @"like";
NSString *const kPAPActivityPhotoKey = @"photo";
NSString *const kPAPActivityContentKey = @"content";
NSString *const kPAPActivityMoodTypeKey = @"moodtypes";
NSString *const kPAPActivityTypeComment = @"comment";
NSString *const kPAPActivityTypeCircleName = @"circleName";
NSString *const kPAPActivityTypeInitPost = @"initPost";
NSString *const kPAPActivityTypeInitPostWithDefaultPicture = @"initPostWithDefaultPicture";
NSString *const kPAPActivityTypeJoined = @"joined";
NSString *const kPAPActivityLastUpdated = @"lastUpdated";

NSString *const kPAPTellemLogClassKey=@"TellemLog";
NSString *const kPAPTellemLogMessageTextKey=@"messageText";
NSString *const kPAPTellemLogMessageInfoKey=@"messageInfo";

NSString *const kPAPCircleClassKey=@"Circle";
NSString *const kPAPCircleNameKey=@"circleName";
NSString *const kPAPCircleOwnerUserIdKey=@"ownerUserIdKey";
NSString *const kPAPCircleMemberUserIdKey=@"memberUserIdKey";
NSString *const kPAPCircleMemberUserIdArray=@"memberUserIdArray";
NSString *const kPAPCircleStatusKey=@"status";
NSString *const kPAPCircleProfilePicture=@"profilePicture";
NSString *const kPAPCircleProfileThumbnail=@"profileThumbnail";

NSString *const kPAPPhotoClassKey = @"Photo";
NSString *const kPAPPhotoPictureKey         = @"image";
NSString *const kPAPPhotoThumbnailKey       = @"thumbnail";
NSString *const kPAPPhotoUserKey            = @"user";
NSString *const kPAPPhotoOpenGraphIDKey    = @"fbOpenGraphID";
NSString *const kPAPPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kPAPPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kPAPPhotoAttributesLikersKey               = @"likers";
NSString *const kPAPPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kPAPPhotoAttributesCommentersKey           = @"commenters";
NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey = @"comment";
NSString *const kPAPPhotoPhotoAudioKey = @"photoAudio";

NSString *const kPAPUserNotificationsClassKey = @"UserNotifications";
NSString *const kPAPUserNotificationsReceivingUserKey = @"receivingUser";
NSString *const kPAPUserNotificationsRemoteNotificationKey = @"remoteNotification";
extern NSString *const kPAPUserNotificationsUserIdKey;

#pragma mark - Circle Types
NSString *const kPAPCircleIsNewFromPostView = @"NEWFROMPOST";
NSString *const kPAPCircleIsNewFromPostCirclesView = @"NEWFROMPOSTCIRCLES";
NSString *const kPAPCircleIsNotNewFromPostView = @"NOTNEWFROMPOST";
NSString *const kPAPCircleIsNotNewFromPostCirclesView = @"NOTNEWFROMPOSTCIRCLES";
NSString *const kPAPCircleSelectedIsAllCircles = @"ALLCIRCLESSELECTED";


#pragma mark - Push Message Types
NSString *const kPAPPushCommentOnPost = @"commentOnPost";
NSString *const kPAPPushInviteToCircle = @"inviteToCircle";
NSString *const kPAPPushTemporaryPassword = @"temporaryPassword";

#pragma mark - Font Types
//NSString *const kFontNormal = @"HelveticaNeue";
//NSString *const kFontThin = @"HelveticaNeue-Thin";
//NSString *const kFontBold = @"HelveticaNeue-Bold";
NSString *const kFontNormal = @"DINAlternate-Bold";
NSString *const kFontThin = @"DINAlternate-Bold";
NSString *const kFontBold = @"DINAlternate-Bold";

#pragma mark - Slider Values
int kInitialRecTimeInSecs = 20;
int kMinRecTimeInSecs = 5;
int kMaxRecTimeInSecs = 60;

#pragma mark - Twitter/Instagram Keys

//Instagram
NSString *const kAuthUrlString = @"https://instagram.com/oauth/authorize";
NSString *const kClientID = @"38501cdada074d42990b0d433d513df6";
NSString *const kClientSecret = @"0368e7aecdc341bb94072d3e268506aa";
NSString *const kRedirectUri = @"http://mydomain.com/NeverGonnaFindMe/";
//Twitter
NSString *const kTwitterClientID = @"COPyKvw1MdFFIEYL5CQMfJhub";
NSString *const kTwitterClientSecret = @"oLZyYZhseImGU00SnVgTVTqUXOgidEnxr0Ylh1xrrwjCFXBbb2";
//EULA
NSString *const kEULALink = @"http://utellem.net/eula";


@implementation PAPUtility


#pragma mark - PAPUtility
#pragma mark Like Photos
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:kPAPActivityTypeFollow forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
    
}
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [PAPUtility followUserEventually:user block:completionBlock];
        [[PAPCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey equalTo:user];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}
+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryComments whereKey:kPAPActivityPhotoKey equalTo:photo];
    //[queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    [queryComments whereKey:kPAPActivityTypeKey containedIn:@[kPAPActivityTypeComment,kPAPActivityTypeInitPost,kPAPActivityTypeInitPostWithDefaultPicture]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityPhotoKey];
    
    return query;
}

+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
        [likeActivity setObject:kPAPActivityTypeLike forKey:kPAPActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey];
        [likeActivity setObject:photo forKey:kPAPActivityPhotoKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kPAPPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPost] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPostWithDefaultPicture] && [activity objectForKey:kPAPActivityFromUserKey])
                        {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    
}

+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPost] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeInitPostWithDefaultPicture] && [activity objectForKey:kPAPActivityFromUserKey])
                        {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];  
}
+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey containedIn:users];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[PAPCache sharedCache] setFollowStatus:NO user:user];
    }
}

#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}
+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:kPAPActivityTypeFollow forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
}

@end
