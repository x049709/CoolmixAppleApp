//
//  User.h
//  Tellem
//
//  Created by Ed Bayudan on 1/31/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAPUtility.h"

@interface User : NSObject

@property  (strong, nonatomic) NSString* objectId;
@property  (strong, nonatomic) NSDate* createdAt;
@property  (strong, nonatomic) NSDate* updatedAt;
@property  (strong, nonatomic) NSString* userName;
@property  (strong, readonly)  NSString* password;
@property  (strong, nonatomic) NSString* accountType;
@property  (strong, nonatomic) NSArray* shareSettings;
@property  (strong, nonatomic) NSArray* viewFriends;
@property  (strong, nonatomic) NSString* displayName;
@property  (strong, nonatomic) NSString* emailAddress;
@property  (strong, nonatomic) PFFile* profilePictureMedium;
@property  (strong, nonatomic) PFFile* profilePictureSmall;
@property  (strong, nonatomic) NSString* telephoneNumber;

- (id) initNewUser;
- (id) initWithPFUser: (PFUser*) pfUser;
- (void) setNewProfilePictureMedium: (UIImage*) inProfilePictureMedium;
- (void) setNewProfilePictureSmall: (UIImage*) inProfilePictureSmall;
- (UIImage*)profilePictureMediumUIImage;
- (UIImage*)profilePictureSmallUIImage;

@end