//
//  UserProfileController.h
//  Tellem
//
//  Created by Ed Bayudan on 07/04/14.
//  Copyright (c) 2014 Tellem, LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAPImageView.h"
#import "User.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPUtility.h"



@interface UserProfileController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *userProfileTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *profilePictureLabel;
@property (weak, nonatomic) IBOutlet PAPImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *userNameInput;
@property (strong, nonatomic) IBOutlet UIButton *userNameButton;
@property (strong, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailAddressInput;
@property (strong, nonatomic) IBOutlet UIButton *emailAddressButton;
@property (strong, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberInput;
@property (strong, nonatomic) IBOutlet UIButton *phoneNumberButton;
@property User *userProfile;
@property UIImage *imagePickedFromGalleryOrCamera;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;



- (IBAction)userNameButtonTouched:(id)sender;
- (IBAction)emailAddressButtonTouched:(id)sender;
- (IBAction)phoneNumberButtonTouched:(id)sender;
- (BOOL)isEmailValid:(NSString *)checkString;
- (void)restoreUserNameLabelToInput;
- (void)restoreEmailAddressLabelToInput;
- (void)restorePhoneNumberLabelToInput;
- (BOOL)shouldUploadImage:(UIImage *)anImage;


@end
