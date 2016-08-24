//
//  UserProfileController.m
//  Tellem
//
//  Created by Ed Bayudan on 07/04/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "UserProfileController.h"

static NSString * const kAviaryAPIKey = @"o1kffu3bdtbctbg7";
static NSString * const kAviarySecret = @"b1mdl2dbyp5lq2d1";

@interface UserProfileController ()

@end

@implementation UserProfileController
@synthesize userProfileTitleLabel, profileImageView,profilePictureLabel,profilePicture,userNameLabel,emailAddressLabel,phoneNumberLabel,scrollView,userIdLabel;
@synthesize userNameInput,userNameButton,emailAddressInput,emailAddressButton,phoneNumberInput,phoneNumberButton,userProfile,imagePickedFromGalleryOrCamera,fileUploadBackgroundTaskId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"USER PROFILE";
    
    CGSize scrollViewContentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+20);
    [self.scrollView setContentSize:scrollViewContentSize];
    
    self.userNameInput.delegate = self;
    self.emailAddressInput.delegate = self;
    self.phoneNumberInput.delegate = self;
    
    //User set by the calling controller
    //self.userProfile = [[User alloc] initWithPFUser:[PFUser currentUser]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userProfileTitleLabel.font = [UIFont fontWithName:kFontBold size:18.0];
    
    self.userNameLabel.font = [UIFont fontWithName:kFontThin size:18.0];
    self.userNameLabel.textColor = [UIColor blackColor];
    self.userNameInput.textColor = [UIColor redColor];
    if ([[self.userProfile accountType]  isEqual: @"FB"])
        self.userNameLabel.text=[[self.userProfile displayName] stringByAppendingString:@" via Facebook"];
    else if (([[self.userProfile accountType]  isEqual: @"Twitter"]))
        self.userNameLabel.text=[[self.userProfile displayName] stringByAppendingString:@" via Twitter"];
    else if (([[self.userProfile accountType]  isEqual: @"Instagram"]))
        self.userNameLabel.text=[[self.userProfile displayName] stringByAppendingString:@" via Instagram"];
    else
        self.userNameLabel.text=[[self.userProfile displayName] stringByAppendingString:@" via Tellem"];
    self.userNameLabel.hidden = NO;
    self.userNameInput.hidden = YES;
    self.userNameButton.hidden = YES;
    [self.userNameInput setReturnKeyType:UIReturnKeyDone];
    self.userNameInput.tag=1;
    
    UITapGestureRecognizer *userNameLabelTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userNameLabelTouched)];
    userNameLabelTouch.numberOfTapsRequired = 1;
    [self.userNameLabel setUserInteractionEnabled:YES];
    [self.userNameLabel addGestureRecognizer:userNameLabelTouch];
    
    self.userIdLabel.font = [UIFont fontWithName:kFontThin size:15.0];
    self.userIdLabel.text = [@"UserId: " stringByAppendingString:[self.userProfile userName]];
    self.userIdLabel.textColor = [UIColor blackColor];
    self.userIdLabel.hidden = NO;
    
    self.emailAddressLabel.font = [UIFont fontWithName:kFontThin size:15.0];
    self.emailAddressLabel.text = [@"Email: " stringByAppendingString:[self.userProfile emailAddress]];
    self.emailAddressLabel.textColor = [UIColor blackColor];
    self.emailAddressInput.textColor = [UIColor redColor];
    self.emailAddressLabel.hidden = NO;
    self.emailAddressInput.hidden = YES;
    self.emailAddressButton.hidden = YES;
    [self.emailAddressInput setReturnKeyType:UIReturnKeyDone];
    self.emailAddressInput.tag=3;
    
    UITapGestureRecognizer *emailAddressLabelTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailAddressLabelTouched)];
    emailAddressLabelTouch.numberOfTapsRequired = 1;
    [self.emailAddressLabel setUserInteractionEnabled:YES];
    [self.emailAddressLabel addGestureRecognizer:emailAddressLabelTouch];
    
    self.phoneNumberLabel.font = [UIFont fontWithName:kFontThin size:15.0];
    self.phoneNumberLabel.text =  [@"Phone number: " stringByAppendingString:[self.userProfile telephoneNumber]];
    self.emailAddressLabel.textColor = [UIColor blackColor];
    self.phoneNumberInput.textColor = [UIColor redColor];
    self.phoneNumberLabel.hidden = NO;
    self.phoneNumberInput.hidden = YES;
    self.phoneNumberButton.hidden = YES;
    [self.phoneNumberInput setReturnKeyType:UIReturnKeyDone];
    self.phoneNumberInput.tag=4;
    
    UITapGestureRecognizer *phoneNumberLabelTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneNumberLabelTouched)];
    phoneNumberLabelTouch.numberOfTapsRequired = 1;
    [self.phoneNumberLabel setUserInteractionEnabled:YES];
    [self.phoneNumberLabel addGestureRecognizer:phoneNumberLabelTouch];
    
    UIImage * profilePictureMedium = self.userProfile.profilePictureMediumUIImage;
    UIImageView *labelBackground = [[UIImageView alloc] initWithImage:profilePictureMedium];
    [labelBackground setFrame:CGRectMake(0.0, 0.0, 150.0, 150.0)];
    [self.profilePictureLabel addSubview:labelBackground];
    self.profilePictureLabel.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *profileImageViewTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewTouched)];
    profileImageViewTouch.numberOfTapsRequired = 1;
    [self.profilePictureLabel setUserInteractionEnabled:YES];
    [self.profilePictureLabel addGestureRecognizer:profileImageViewTouch];
}

- (void)userNameLabelTouched{
    
    if ([self.userProfile.displayName isEqualToString:@"Guest"]) {
        return;
    }

    NSString *currentUser = [[PFUser currentUser] username];
    if (![[self.userProfile userName] isEqual:currentUser])
    {
        return;
    }
    
    self.userNameLabel.hidden = YES;
    self.userNameInput.hidden = NO;
    self.userNameButton.hidden = NO;
    self.emailAddressLabel.hidden = NO;
    self.emailAddressInput.hidden = YES;
    self.emailAddressButton.hidden = YES;
    self.phoneNumberLabel.hidden = NO;
    self.phoneNumberInput.hidden = YES;
    self.phoneNumberButton.hidden = YES;
    self.userNameInput.text=[self.userProfile displayName];
    [self.userNameInput resignFirstResponder];
    [self.scrollView setNeedsLayout];
}

- (void)emailAddressLabelTouched{

    NSString *currentUser = [[PFUser currentUser] username];
    if (![[self.userProfile userName] isEqual:currentUser])
    {
        return;
    }
    
    if ([self.userProfile.displayName isEqualToString:@"Guest"]) {
        return;
    }
    self.userNameLabel.hidden = NO;
    self.userNameInput.hidden = YES;
    self.userNameButton.hidden = YES;
    self.emailAddressLabel.hidden = YES;
    self.emailAddressInput.hidden = NO;
    self.emailAddressButton.hidden = NO;
    self.phoneNumberLabel.hidden = NO;
    self.phoneNumberInput.hidden = YES;
    self.phoneNumberButton.hidden = YES;
    self.emailAddressInput.text=[self.userProfile  emailAddress];
    [self.emailAddressInput resignFirstResponder];
    [self.scrollView setNeedsLayout];
}

- (void)phoneNumberLabelTouched{

    NSString *currentUser = [[PFUser currentUser] username];
    if (![[self.userProfile userName] isEqual:currentUser])
    {
        return;
    }

    if ([self.userProfile.displayName isEqualToString:@"Guest"]) {
        return;
    }
    self.userNameLabel.hidden = NO;
    self.userNameInput.hidden = YES;
    self.userNameButton.hidden = YES;
    self.emailAddressLabel.hidden = NO;
    self.emailAddressInput.hidden = YES;
    self.emailAddressButton.hidden = YES;
    self.phoneNumberLabel.hidden = YES;
    self.phoneNumberInput.hidden = NO;
    self.phoneNumberButton.hidden = NO;
    self.phoneNumberInput.text=[self.userProfile  telephoneNumber];
    [self.phoneNumberInput resignFirstResponder];
    [self.scrollView setNeedsLayout];
}

- (void)profileImageViewTouched{

    NSString *currentUser = [[PFUser currentUser] username];
    if (![[self.userProfile userName] isEqual:currentUser])
    {
        return;
    }

    if ([self.userProfile.displayName isEqualToString:@"Guest"]) {
        return;
    }
    if ([[self.userProfile accountType]  isEqualToString: @"FB"] ||
        [[self.userProfile accountType]  isEqualToString: @"Twitter"] ||
        [[self.userProfile accountType]  isEqualToString: @"Instagram"] )
    {
        return;
    }

    self.userNameLabel.hidden = NO;
    self.userNameInput.hidden = YES;
    self.userNameButton.hidden = YES;
    self.emailAddressLabel.hidden = NO;
    self.emailAddressInput.hidden = YES;
    self.emailAddressButton.hidden = YES;
    self.phoneNumberLabel.hidden = NO;
    self.phoneNumberInput.hidden = YES;
    self.phoneNumberButton.hidden = YES;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use photo from camera",@"Use photo from gallery", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)userNameButtonTouched:(id)sender {
    [self restoreAllInputsToLabels];
}

- (IBAction)emailAddressButtonTouched:(id)sender {
    [self restoreAllInputsToLabels];
}

- (IBAction)phoneNumberButtonTouched:(id)sender {
    [self restoreAllInputsToLabels];
}

- (void)restoreAllInputsToLabels {
    self.userNameLabel.hidden = NO;
    self.userNameInput.hidden = YES;
    self.userNameButton.hidden = YES;
    [self.userNameInput resignFirstResponder];
    self.emailAddressLabel.hidden = NO;
    self.emailAddressInput.hidden = YES;
    self.emailAddressButton.hidden = YES;
    [self.emailAddressInput resignFirstResponder];
    self.phoneNumberLabel.hidden = NO;
    self.phoneNumberInput.hidden = YES;
    self.phoneNumberButton.hidden = YES;
    [self.phoneNumberInput resignFirstResponder];
}

- (void)restoreUserNameLabelToInput {
    self.userNameLabel.hidden = YES;
    self.userNameInput.hidden = NO;
    self.userNameButton.hidden = NO;
    [self.userNameInput canBecomeFirstResponder];
}

- (void)restoreEmailAddressLabelToInput {
    self.emailAddressLabel.hidden = YES;
    self.emailAddressInput.hidden = NO;
    self.emailAddressButton.hidden = NO;
    [self.emailAddressInput canBecomeFirstResponder];
}

- (void)restorePhoneNumberLabelToInput {
    self.phoneNumberLabel.hidden = YES;
    self.phoneNumberInput.hidden = NO;
    self.phoneNumberButton.hidden = NO;
    [self.phoneNumberInput canBecomeFirstResponder];
}

- (BOOL) textField:(UITextField *)textFld shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textFld resignFirstResponder];
        textFld.hidden = YES;
        NSString *newTxtFldText = [textFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([self areEntriesValid:textFld andNewText:newTxtFldText]) {
            [self saveTextField:textFld andNewText:newTxtFldText];
            [self.view setNeedsLayout];
        }
        return NO;
    }
    return YES;
}

- (void) showEmptyMessage:(UITextField*) textFld {
    NSString *errorMsg = @"Error saving user profile changes";
    if (textFld.tag ==1) errorMsg = @"User name cannot be empty";
    if (textFld.tag ==2) errorMsg = @"User id cannot be empty";
    if (textFld.tag ==3) errorMsg = @"Email address cannot be empty";
    if (textFld.tag ==4) errorMsg = @"Telephone number cannot be empty";
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:errorMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
}

- (BOOL) areEntriesValid:(UITextField*) textFld andNewText:(NSString*) newTxtFldText {
    BOOL entryIsValid = NO;
    NSString *errorMsg = @"Error saving user profile changes";
    
    if (newTxtFldText.length == 0)
    {
        if (textFld.tag ==1) errorMsg = @"User name cannot be empty";
        if (textFld.tag ==2) errorMsg = @"User id cannot be empty";
        if (textFld.tag ==3) errorMsg = @"Email address cannot be empty";
        if (textFld.tag ==4) errorMsg = @"Telephone number cannot be empty";
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:errorMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        entryIsValid = NO;
    }
    else
    {
        if (textFld.tag ==1) entryIsValid = YES;
        if (textFld.tag ==2) entryIsValid = YES;
        if (textFld.tag ==3) {
            if ([self isEmailValid:newTxtFldText]) {
                entryIsValid = YES;
            } else {
                errorMsg = @"Email must be in valid format";
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:errorMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
                entryIsValid = NO;
            }
        }
        if (textFld.tag ==4) {
            if ([self isPhoneValidInUS:newTxtFldText]) {
                entryIsValid = YES;
            } else {
                errorMsg = @"Telephone number must be 10 numbers";
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:errorMsg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
                entryIsValid = NO;
            }
        }
    }

    [self restoreAllInputsToLabels];
    if (textFld.tag ==1) [self restoreUserNameLabelToInput];
    if (textFld.tag ==3) [self restoreEmailAddressLabelToInput];
    if (textFld.tag ==4) [self restorePhoneNumberLabelToInput];

    return entryIsValid;
}

-(BOOL) isEmailValid:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid=[emailTest evaluateWithObject:checkString];
    return isValid;
}

-(BOOL) isPhoneValidInUS:(NSString *)checkString
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet characterSetWithCharactersInString:@"01234567890"] invertedSet];
    NSRange r = [checkString rangeOfCharacterFromSet: nonNumbers];
    if (r.location == NSNotFound && checkString.length == 10)
    {
        return YES;
    } else
    {
        return NO;
    }
}

- (void) saveTextField:(UITextField*) textFld andNewText:(NSString*) newTxtFldText {
    PFUser *currentUser = [PFUser currentUser];
    
    if (textFld.tag ==1) {
        [currentUser setObject:newTxtFldText forKey:kPAPUserDisplayNameKey];
        self.userProfile.displayName = newTxtFldText;
        [currentUser saveEventually];
        if ([[self.userProfile accountType]  isEqual: @"FB"])
            self.userNameLabel.text=[newTxtFldText stringByAppendingString:@" via Facebook"];
        else if (([[self.userProfile accountType]  isEqual: @"Twitter"]))
            self.userNameLabel.text=[newTxtFldText stringByAppendingString:@" via Twitter"];
        else if (([[self.userProfile accountType]  isEqual: @"Instagram"]))
            self.userNameLabel.text=[newTxtFldText stringByAppendingString:@" via Instagram"];
        else
            self.userNameLabel.text=[newTxtFldText stringByAppendingString:@" via Tellem"];
    }

    if (textFld.tag ==3) {
        [currentUser setObject:newTxtFldText forKey:kPAPUserEmailKey];
        self.userProfile.emailAddress = newTxtFldText;
         self.emailAddressLabel.text = [@"Email: " stringByAppendingString:newTxtFldText];
        [currentUser saveEventually];
    }
    
    if (textFld.tag ==4) {
        [currentUser setObject:newTxtFldText forKey:kPAPUserTelephoneNumberKey];
        self.userProfile.telephoneNumber = newTxtFldText;
        self.phoneNumberLabel.text =  [@"Phone number: " stringByAppendingString:newTxtFldText];
        [currentUser saveEventually];
    }
    
    [self restoreAllInputsToLabels];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self photoFromCamera];
            break;
        case 1:
            [self photoFromGallery];
            break;
        default:
            break;
    }
}

-(void)photoFromCamera{
    UIImagePickerController * imagePickerFromCamera = [[UIImagePickerController alloc] init];
    imagePickerFromCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerFromCamera.delegate = self;
    [self presentViewController:imagePickerFromCamera animated:YES completion:Nil];
}

-(void)photoFromGallery{
    UIImagePickerController *imagePickerFromGallery=[[UIImagePickerController alloc]init];
    imagePickerFromGallery.delegate=self;
    imagePickerFromGallery.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerFromGallery animated:YES completion:Nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imagePickedFromGalleryOrCamera=imagePicked;
    [picker dismissViewControllerAnimated:YES completion:Nil];
    //[self displayEditorForImage:imagePicked];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
    [self.scrollView setNeedsLayout];
}

//- (void)displayEditorForImage:(UIImage *)imageToEdit
//{
//    // kAviaryAPIKey and kAviarySecret are developer defined
//    // and contain your API key and secret respectively
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [AFPhotoEditorController setAPIKey:kAviaryAPIKey secret:kAviarySecret];
//    });
//    
//    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
//    [editorController setDelegate:self];
//    self.navigationController.navigationBarHidden=NO;
//    self.tabBarController.tabBar.hidden=NO;
//    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
//    [self.navigationController pushViewController:editorController animated:YES];
//}
//
//- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
//{
//    [self.navigationController popViewControllerAnimated:YES];
//    self.tabBarController.tabBar.hidden=NO;
//    self.navigationController.navigationBarHidden=NO;
//}
//
//- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)editedImage
//{
//    UIImage *resizedImage = [editedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
//    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
//    if (!imageData) {
//        return;
//    }
//    
//    [self shouldUploadImage:editedImage];
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    PFUser *currentUser = [PFUser currentUser];
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    //JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.userProfile.profilePictureMedium = [PFFile fileWithData:imageData];
    self.userProfile.profilePictureSmall = [PFFile fileWithData:thumbnailImageData];
    
    //Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.userProfile.profilePictureMedium saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.userProfile.profilePictureSmall saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [currentUser setObject:self.userProfile.profilePictureMedium forKey:kPAPUserProfilePicMediumKey];
                    [currentUser setObject:self.userProfile.profilePictureSmall forKey:kPAPUserProfilePicSmallKey];
                    [currentUser saveEventually];
                    dispatch_async(dispatch_get_main_queue(), ^{
                    //    [self.scrollView setNeedsLayout];
                        [self.view setNeedsLayout];
                    });
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                } else {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
