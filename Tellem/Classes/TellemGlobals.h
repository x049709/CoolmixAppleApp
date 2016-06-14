//
//  TellemGlobals.h
//  UTellem
//
//  Created by Ed Bayudan on 2/15/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TellemGlobals : NSObject
{
}

@property (atomic, readonly) UIImage *gBackgroundImageExtraLight;
@property (atomic, strong) NSString *gPostRecordingTimeInSecs;
@property (atomic, readonly) NSString *gCannedEmailMessage;
@property (atomic, readonly) NSString *gCannedTextMessage;
@property (atomic, readonly) BOOL gFacebookOK;
@property (atomic, readonly) BOOL gTwitterOK;
@property (atomic, readonly) BOOL gFacebookSharingOK;
@property (atomic, readonly) BOOL gTwitterSharingOK;
@property (atomic, strong) PFObject *gPreferredCircle;
@property NSUInteger gActivitiesPerPage;
@property NSUInteger gMaxActivitiesToShow;
@property NSUInteger gActivitiesToShow;
@property NSUInteger gCurrentTab;
@property NSUInteger gMaxActivitiesToMap;
@property NSString   *gCoolmixServerURL;
@property NSString   *gCoolmixServerUser;
@property NSString   *gCoolmixServerPassword;



+ (id)globalsManager;

@end
