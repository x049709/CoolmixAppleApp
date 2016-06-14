//
//  TellemGlobals.m
//  UTellem
//
//  Created by Ed Bayudan on 2/15/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "TellemGlobals.h"

@implementation TellemGlobals

@synthesize gBackgroundImageExtraLight,gPostRecordingTimeInSecs,gCannedEmailMessage,gCannedTextMessage,gFacebookOK,gTwitterOK,gFacebookSharingOK,gTwitterSharingOK,gPreferredCircle,gActivitiesPerPage,gMaxActivitiesToShow,gActivitiesToShow,gCurrentTab,gMaxActivitiesToMap,gCoolmixServerURL,gCoolmixServerUser,gCoolmixServerPassword;
;

#pragma mark Singleton Methods

+ (id)globalsManager {
    static TellemGlobals *sharedTellemGlobals = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTellemGlobals = [[self alloc] init];
    });
    return sharedTellemGlobals;
}

- (id)init {
    if (self = [super init]) {
        gBackgroundImageExtraLight = [UIImage  imageNamed:@"white_bg"];
        gFacebookOK = YES;
        gTwitterOK = YES;
        gFacebookSharingOK = YES;
        gTwitterSharingOK = YES;
        gPostRecordingTimeInSecs = @"20";
        gActivitiesPerPage=15;
        gMaxActivitiesToShow=1000;
        gActivitiesToShow=gMaxActivitiesToShow;
        gCurrentTab=99;
        gMaxActivitiesToMap=1000;
        gCannedEmailMessage = @",";
        gCannedEmailMessage = [gCannedEmailMessage stringByAppendingString:@"<p>I just joined this new social network with fresh new features!"];
        gCannedEmailMessage = [gCannedEmailMessage stringByAppendingString:@"<p><a href=\"http://appstore.com\">Click here to go to the Apple AppStore and search for Tellem</a></p><p>"];
        gCannedEmailMessage = [gCannedEmailMessage stringByAppendingString:@"After you install the app, log in using Instagram or your email.  Then we can connect! <p>Thanks!"];
        gCannedTextMessage  = @". Join my new social network! Download the app Tellem at the Apple AppStore at http://appstore.com. After you install the app, log in using Instagram or your email. Then we can connect!  Thanks!";
        gCoolmixServerURL = @"http://162.243.212.149:8080/v1.0";
        gCoolmixServerUser = @"Martin";
        gCoolmixServerPassword = @"Roseland00";

        NSLog(@"Tellem Globals:\n");
        NSLog(@"gFacebookOK=%@",gFacebookOK ? @"YES" : @"NO");
        NSLog(@"gTwitterOK=%@",gTwitterOK ? @"YES" : @"NO");
        NSLog(@"gFacebookSharingOK=%@",gFacebookSharingOK ? @"YES" : @"NO");
        NSLog(@"gTwitterSharingOK=%@",gTwitterSharingOK ? @"YES" : @"NO");
        NSLog(@"gPostRecordingTimeInSecs=%@\n",gPostRecordingTimeInSecs);
        NSLog(@"gActivitiesPerPage=%lu\n",(unsigned long)gActivitiesPerPage);
        NSLog(@"gMaxActivitiesToShow=%lu\n",(unsigned long)gMaxActivitiesToShow);
        NSLog(@"gCurrentTab=%lu\n",(unsigned long)gCurrentTab);
        NSLog(@"gMaxActivitiesToMap=%lu\n",(unsigned long)gMaxActivitiesToMap);
        NSLog(@"gCoolmixServerURL=%@",gCoolmixServerURL);
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
