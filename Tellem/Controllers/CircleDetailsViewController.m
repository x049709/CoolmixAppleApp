//
//  CircleDetailsViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "CircleDetailsViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PostSharingViewController.h"
#import "PAPLoadMoreCell.h"
#import "UITableView+DragLoad.h"

static NSString * const kAviaryAPIKey = @"o1kffu3bdtbctbg7";
static NSString * const kAviarySecret = @"b1mdl2dbyp5lq2d1";

@interface CircleDetailsViewController () {
    UITextField *addCircleTextField;
}
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic) NSArray *sortedCircleNames;
@property (nonatomic) NSArray *circleUserIds;
@property (nonatomic) NSArray *sortedCircleActivities;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

@end

@implementation CircleDetailsViewController
{
    
}
@synthesize sortedCircleNames,circleUserIds,sortedCircleActivities,circleTableView,titleText, titleLabel,pageCircle, circleImage, circleOwner, circleName, circleStatus, circleMemberCount,circleMemberArray;
@synthesize activityImageView,activityUserId,activityInitialComment,inputCircleName;
@synthesize memberNameLabel,postTimestampLabel,postLatestCommentsLabel,timeIntervalFormatter,photoFile,thumbnailFile,fileUploadBackgroundTaskId,photoLabel,circleOwnerName,circleView;

- (void)viewDidLoad
{
    //MWLogDebug(@"\nCircleDetailsViewController viewDidLoad started.");
    [super viewDidLoad];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.inputCircleName.delegate = self;
    self.navigationItem.title=@"CIRCLE DETAILS";
    [self.navigationController.navigationBar
        setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.netWorkTable setEditing:NO animated:NO];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Circle data
    //Circle name
    self.circleName.text = [pageCircle valueForKey:kPAPCircleNameKey];
    self.circleName.textColor = [UIColor redColor];
    self.circleName.font = [UIFont fontWithName:kFontNormal size:16];
    self.inputCircleName.hidden = YES;
    self.circleName.hidden = NO;
    [self.inputCircleName setReturnKeyType:UIReturnKeyDone];
    
    UITapGestureRecognizer *circleLabelTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(circleLabelTouched)];
    circleLabelTouch.numberOfTapsRequired = 1;
    [self.circleName setUserInteractionEnabled:YES];
    [self.circleName addGestureRecognizer:circleLabelTouch];

    //Circle owner
    PFUser *circleOwnerId = [self.pageCircle valueForKey:kPAPCircleOwnerUserIdKey];
    PFUser *circleOwnerObject = [TellemUtility getPFUserWithObjectId:[circleOwnerId valueForKey:kPAPobjectIDKey]];
    self.circleOwnerName = [circleOwnerObject username];
    NSString *circleOwnerDisplayName = [circleOwnerObject valueForKey:kPAPUserDisplayNameKey];
    self.circleOwner.text = [@"Circle Owner: " stringByAppendingString:circleOwnerDisplayName];
    self.circleOwner.textColor = [UIColor blackColor];
    self.circleOwner.font = [UIFont fontWithName:kFontThin size:14];
    //Circle status
    NSString *circleStatusText = [self.pageCircle valueForKey:kPAPCircleStatusKey];
    self.circleStatus.text = [@"Circle Status: " stringByAppendingString:circleStatusText];
    self.circleStatus.textColor = [UIColor blackColor];
    self.circleStatus.font = [UIFont fontWithName:kFontThin size:14];
    //Circle member count
    self.circleMemberArray = [self.pageCircle objectForKey:kPAPCircleMemberUserIdArray];
    NSString *memberCount = [NSString stringWithFormat:@"%li",  (unsigned long)circleMemberArray.count];
    self.circleMemberCount.text = [@"Number of members: " stringByAppendingString:memberCount];
    self.circleMemberCount.textColor = [UIColor blackColor];
    self.circleMemberCount.font = [UIFont fontWithName:kFontThin size:14];
    //Circle picture
    UIImage * profileImage = [[UIImage alloc] init];
    profileImage = [self getProfilePicture];
    UIImageView *labelBackground = [[UIImageView alloc] initWithImage:profileImage];
    [labelBackground setFrame:CGRectMake(0.0, 0.0, 110.0, 110.0)];
    [self.photoLabel addSubview:labelBackground];
    self.photoLabel.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *imageViewTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePhotoTouched)];
    imageViewTouch.numberOfTapsRequired = 1;
    [self.photoLabel setUserInteractionEnabled:YES];
    [self.photoLabel addGestureRecognizer:imageViewTouch];
}


- (UIImage*)getProfilePicture
{
    PFFile *profilePhoto = [PFFile alloc];
    if (self.photoFile) {
        profilePhoto = self.photoFile;
    } else {
        profilePhoto = [self.pageCircle objectForKey:kPAPCircleProfilePicture];
    }
    NSData *profilePhotoData = [profilePhoto getData];
    UIImage *image = [UIImage imageWithData:profilePhotoData];
    return image;
}

- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheetSetting = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile", @"Settings",@"Log out", nil];
    
    [actionSheetSetting showFromTabBar:self.tabBarController.tabBar];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* View = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    if (self.circleMemberArray.count == 0) {
         UILabel *label = [[UILabel alloc] init];
         label.frame = CGRectMake(16, 5, 284, 23);
         label.textColor = [UIColor blackColor];
         label.font = [UIFont fontWithName:kFontNormal size:14];
         label.text = @"No members in this circle";
         label.backgroundColor = [UIColor clearColor];
         [View addSubview:label];
    }
    
    TellemButton *inviteButton=[[TellemButton alloc]initWithFrame:CGRectMake(200, 8, 110, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Invite friends"];
    [inviteButton addTarget:self action:@selector(clickedInviteContacts:) forControlEvents:UIControlEventTouchUpInside];
    [View addSubview:inviteButton];
    return View;
    

}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.circleMemberArray.count == 0) {
        return 40.0;
    } else {
        return 40.0;
    }
}

#pragma mark UItableView DataSource Delegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.circleMemberArray.count;
}

- (void)finishRefresh
{
}
- (void)dragTableDidTriggerRefresh:(UITableView *)tableView
{
    //send refresh request(generally network request) here
    [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:2];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell=nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString *circleMemberId = [self.circleMemberArray objectAtIndex:indexPath.row];
    PFUser *circleMemberObject = [TellemUtility getPFUserWithUserId:circleMemberId];
    NSString *circleMemberName = [circleMemberObject valueForKey:kPAPUserDisplayNameKey];
    PFFile *profilePhoto = [circleMemberObject objectForKey:kPAPUserProfilePicMediumKey];

    //Member photo
    PAPProfileImageView *profilePicture = [[PAPProfileImageView alloc] init];
    [profilePicture setFrame:CGRectMake(0,0,40,40)];
    [profilePicture.profileButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    profilePicture.profileButton.tag = indexPath.row;
    [profilePicture setFile:profilePhoto];
    [cell addSubview:profilePicture];
    
    //Member name
    self.memberNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 5, 200, 17)];
    self.memberNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.memberNameLabel.font = [UIFont fontWithName:kFontNormal size:14];
    self.memberNameLabel.textColor = [UIColor redColor];
    self.memberNameLabel.text = circleMemberName;
    [cell addSubview:self.memberNameLabel];

    //Member account
    NSString *accountType = [circleMemberObject valueForKey:kPAPUserAccountType];
    NSString *accountTypeText;
    if ([accountType  isEqual: @"FB"])
        accountTypeText= @"(via Facebook)";
    else if (([accountType  isEqual: @"Twitter"]))
        accountTypeText= @"(via Twitter)";
    else if (([accountType  isEqual: @"Instagram"]))
        accountTypeText= @"(via Instagram)";
    else
        accountTypeText= @"(via Tellem)";
    
    self.memberNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 20, 200, 14)];
    self.memberNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.memberNameLabel.font = [UIFont fontWithName:kFontThin size:10];
    self.memberNameLabel.textColor = [UIColor blackColor];
    self.memberNameLabel.text = accountTypeText;
    [cell addSubview:self.memberNameLabel];
    
    return cell;
}

-(void)clickedInviteContacts:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:Nil];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.tabIndex = 1;
    [appDelegate presentTabBarController];
}


- (void)didTapOnPhotoAction:(UIButton*) sender {
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Perform the real delete action here. Note: you may need to check editing style
    NSMutableArray *membersToKeep = [NSMutableArray array];
    NSString *currentUserId = [[PFUser currentUser] username];
    for(int i=0;i<self.circleMemberArray.count;i++)
    {
        NSString *memberUser = [self.circleMemberArray objectAtIndex:i];
        if(i == indexPath.row)
        {
            if ([currentUserId isEqual:memberUser])
            {
                //OK to remove oneself from group
            }
            else
                if ([currentUserId isEqual:self.circleOwnerName])
                {
                    //Circle owner can remove anyone
                }
                else
                {
                    [membersToKeep addObject:memberUser];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Sorry, you can only remove yourself from the circle." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
        }
        else
        {
            [membersToKeep addObject:memberUser];
        }
    }
    
    if (membersToKeep.count != self.circleMemberArray.count)
    //Update circle array as member was removed
    {
        [self.pageCircle setObject:membersToKeep forKey:kPAPCircleMemberUserIdArray];
        [self.pageCircle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if(!error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //self.pageCircle = currentCircle;
                     self.circleMemberArray = [self.pageCircle objectForKey:kPAPCircleMemberUserIdArray];
                     [self.netWorkTable reloadData];
                     NSString *memberCount = [NSString stringWithFormat:@"%li",  (unsigned long)self.circleMemberArray.count];
                     self.circleMemberCount.text = [@"Number of members: " stringByAppendingString:memberCount];
                 });
             }
             else
             {
                 [ApplicationDelegate.hudd hide:YES];
                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Error occured while saving circle members" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
             }
         }];
        
    }
    
    [self performSelector:@selector(hideDeleteButton:) withObject:nil afterDelay:0.1];
}


- (void)hideDeleteButton:(id)obj
{
    [self.netWorkTable setEditing:NO animated:YES];
}

- (void)circleLabelTouched{
    
    NSString *currentUserId = [[PFUser currentUser] objectId];
    PFUser *circleOwnerUser = [pageCircle valueForKey:kPAPCircleOwnerUserIdKey];
    NSString *circleOwnerId = [circleOwnerUser valueForKey:kPAPobjectIDKey];
    
    if ([currentUserId isEqualToString:circleOwnerId]) {
        self.circleName.hidden = YES;
        self.inputCircleName.hidden = NO;
        self.inputCircleName.text = [pageCircle valueForKey:kPAPCircleNameKey];
        [self.inputCircleName resignFirstResponder];
        [self.view setNeedsLayout];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Sorry, only the owner can change the circle name." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        
    }
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [txtView resignFirstResponder];
        self.circleName.hidden = NO;
        txtView.hidden = YES;
        self.circleName.text = txtView.text;
        NSString *selectedCircleName = [txtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (selectedCircleName.length == 0)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Circle name cannot be empty" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            return YES;
        }
        else
        {
            [pageCircle setObject:self.circleName.text forKey:kPAPCircleNameKey];
            [pageCircle saveEventually];
            return NO;
        }
    }
    return YES;
}

- (void)profilePhotoTouched{
    NSString *currentUserId = [[PFUser currentUser] objectId];
    PFUser *circleOwnerUser = [pageCircle valueForKey:kPAPCircleOwnerUserIdKey];
    NSString *circleOwnerId = [circleOwnerUser valueForKey:kPAPobjectIDKey];

    if (![currentUserId isEqualToString:circleOwnerId]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Sorry, only the owner can change the image." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }

    self.inputCircleName.hidden = YES;
    [self.inputCircleName resignFirstResponder];
    self.circleName.hidden = NO;

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use photo from camera",@"Use photo from gallery", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
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
    imagePickerFromGallery.allowsEditing=YES;
    imagePickerFromGallery.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerFromGallery animated:YES completion:Nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
    imagePickedFromGalleryOrCamera=imagePicked;
    [picker dismissViewControllerAnimated:YES completion:Nil];
    //[self displayEditorForImage:imagePicked];
    
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
//    self.circleImage.image = Nil;;
//    [self.navigationController popViewControllerAnimated:YES];
//    self.tabBarController.tabBar.hidden=NO;
//    self.navigationController.navigationBarHidden=NO;
//    
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
//    self.photoFile = [PFFile fileWithData:imageData];
//    self.circleImage.image =  resizedImage;
//    [self shouldUploadImage:editedImage];
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [pageCircle setObject:self.photoFile forKey:kPAPCircleProfilePicture];
                [pageCircle setObject:self.thumbnailFile forKey:kPAPCircleProfileThumbnail];
                [pageCircle saveEventually];
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

@end
