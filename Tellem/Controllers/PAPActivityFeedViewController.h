//
//  PAPActivityFeedViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPActivityCell.h"
#import "PAPAccountViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate,UIActionSheetDelegate,FBFriendPickerDelegate>{
}

+ (NSString *)stringForActivityType:(NSString *)activityType;

@end
