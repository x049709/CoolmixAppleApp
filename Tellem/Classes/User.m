//
//  User.m
//  Tellem
//
//  Created by Ed Bayudan on 1/31/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "User.h"

@implementation User
@synthesize objectId;
@synthesize createdAt;
@synthesize userName;
@synthesize password;
@synthesize accountType;
@synthesize shareSettings;
@synthesize viewFriends;
@synthesize displayName;
@synthesize emailAddress;
@synthesize profilePictureMedium;
@synthesize profilePictureSmall;
@synthesize telephoneNumber;

- (id) initNewUser;
{
    return self;
}

- (id)initWithPFUser: (PFUser*) pfUser
{
    self = [super init];
    if (self) {
        self.objectId = pfUser.objectId;
        self.createdAt = pfUser.createdAt;
        self.updatedAt = pfUser.updatedAt;
        if (pfUser.username.length >0) {
            self.userName = pfUser.username;
        } else {
            self.userName = @"None";
        }
        if ([[pfUser valueForKey:kPAPUserAccountType] length] >0) {
            self.accountType = [pfUser valueForKey:kPAPUserAccountType];
        } else {
            self.accountType = @"Normal";
        }
        self.shareSettings = [pfUser valueForKey:kPAPUserShareSettings];
        self.viewFriends = [pfUser valueForKey:kPAPUserViewFriends];
        if ([[pfUser valueForKey:kPAPUserDisplayNameKey] length] >0) {
            self.displayName = [pfUser valueForKey:kPAPUserDisplayNameKey];
        } else {
            self.displayName = @"None ";
        }
        if ([[pfUser valueForKey:kPAPUserTelephoneNumberKey] length] >0) {
            self.telephoneNumber = [pfUser valueForKey:kPAPUserTelephoneNumberKey];
        } else {
            self.telephoneNumber = @"None ";
        }
        if ([[pfUser valueForKey:kPAPUserEmailKey] length] >0) {
            self.emailAddress = [pfUser valueForKey:kPAPUserEmailKey];
        } else {
            self.emailAddress = @"None";
            
        }
        self.profilePictureMedium = [pfUser valueForKey:kPAPUserProfilePicMediumKey];
        self.profilePictureSmall = [pfUser valueForKey:kPAPUserProfilePicSmallKey];
    }

    return self;
}

- (UIImage*)profilePictureMediumUIImage
{
    PFFile *profilePhoto = self.profilePictureMedium;
    NSData *profilePhotoData = [profilePhoto getData];
    UIImage *image = [UIImage imageWithData:profilePhotoData];
    return image;
}

- (UIImage*)profilePictureSmallUIImage
{
    PFFile *profilePhoto = self.profilePictureSmall;
    NSData *profilePhotoData = [profilePhoto getData];
    UIImage *image = [UIImage imageWithData:profilePhotoData];
    return image;
}


@end
