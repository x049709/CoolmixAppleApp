//
//  PostSharingViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 09/05/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import "PostSharingViewController.h"
#import "AppDelegate.h"
#import "PAPCache.h"
#import "PAPUtility.h"
#import "FHSTwitterEngine.h"
#import "UIImage+ResizeAdditions.h"
static NSString * const kAviaryAPIKey = @"o1kffu3bdtbctbg7";
static NSString * const kAviarySecret = @"b1mdl2dbyp5lq2d1";

@interface PostSharingViewController ()
{
    NSString  *longitudeLabel;
    NSString *latitudeLabel;
    NSString *fbMessage;
}

@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *defoultImg;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (strong, nonatomic) NSString *objectID;
@end

@implementation PostSharingViewController
@synthesize fb_userId,SelectImageView,postTextView,image,defoultImg,tw_userId,selectedUserAccountType,autocompleteUrls,autocompleteTableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    postTextView.clipsToBounds = YES;
    postTextView.layer.cornerRadius = 10.0f;
    
    savedSearches = [[NSMutableArray alloc] init];
    //txtField.delegate = self;
    _suggestionArray = [[NSMutableArray alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height==568)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 244, 320, 44)];
    }
    else
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 200-44, 320, 44)];
    }
    
    _scrollView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    
    [self readyMessage];

  //  self.autocompleteUrls = [[NSMutableArray alloc] init];
    [self readyMessage];
//    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 72, 320, 132) style:UITableViewStylePlain];
//    autocompleteTableView.delegate = self;
//    autocompleteTableView.dataSource = self;
//    autocompleteTableView.scrollEnabled = YES;
//    autocompleteTableView.hidden = YES;
    [self.view addSubview:autocompleteTableView];

    SelectImageView.hidden=YES;
    self.postTextView.delegate = self;
	// Do any additional setup after loading the view.
}
-(void)readyMessage
{
    PFQuery *query=[PFQuery queryWithClassName:@"Dictionary"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         savedSearches=[objects valueForKey:@"keywords"];
     }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Sharing Button Action
- (IBAction)shareButton_clicked:(id)sender
{
    
    if (SelectImageView.hidden==YES )
    {
        [self.view.window addSubview:ApplicationDelegate.hudd];
        [ApplicationDelegate.hudd show:YES];

        //NSLog(@"hide..");
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.postTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        fbMessage=[NSString stringWithFormat:@"%@",trimmedComment];
        if (trimmedComment.length != 0)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                        nil];
        }
        defoultImg=[UIImage imageNamed:@"user.png"];
        NSData *imageData = UIImageJPEGRepresentation(defoultImg, 0.8f);
        NSData *thumbnailImageData = UIImagePNGRepresentation(defoultImg);
        self.photoFile = [PFFile fileWithData:imageData];
        self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
        
        // Make sure there were no errors creating the image files
        if (!self.photoFile || !self.thumbnailFile || trimmedComment.length ==0) {
            [ApplicationDelegate.hudd hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Couldn't post your photo" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            return;
        }
        // both files have finished uploading
        // create a photo object
        
        PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
        [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
        [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
        [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
        
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        photo.ACL = photoACL;
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        
        // Save the Photo PFObject
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                
                // userInfo might contain any caption which might have been posted by the uploader
                if (userInfo) {
                    NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                    
                    if (commentText && commentText.length != 0) {
                        // create and save photo caption
                        PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
                        [comment setObject:photo forKey:kPAPActivityPhotoKey];
                        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                        [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                        [comment setObject:commentText forKey:kPAPActivityContentKey];
                        
                        if (latitudeLabel!=nil) {
                            [comment setObject:latitudeLabel forKey:@"latitude"];
                            [comment setObject:longitudeLabel forKey:@"longitude"];
                        }
                        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        [ACL setPublicReadAccess:YES];
                        comment.ACL = ACL;
                        [comment saveEventually];
                        
                        [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                        TemporaryString=postTextView.text;
                        PFUser *currentUser = [PFUser currentUser];
                        //NSLog(@"%@",currentUser);
                        
                        //NSLog(@"%@",[currentUser valueForKey:@"Accounttype"]);
                        
                        if ([selectedUserAccountType isEqualToString:@"FB"])
                        {
                            [self FacebookSahring];
                        }
                            
                        if ([selectedUserAccountType isEqualToString:@"Twitter"])
                        {
                            [self TwitterSharing];
                        }
                        [postTextView resignFirstResponder];
                        [ApplicationDelegate.hudd hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Couldn't post your photo"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                        [postTextView setText:@""];
                        SelectImageView.image=nil;
                        SelectImageView.image=[UIImage imageNamed:@""];
                     }
                }
            } else {
                [ApplicationDelegate.hudd hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Couldn't post your photo" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        
        // Dismiss this screen
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        
        
    }else
    {
        [self.view.window addSubview:ApplicationDelegate.hudd];
        [ApplicationDelegate.hudd show:YES];

        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.postTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        fbMessage=[NSString stringWithFormat:@"%@",trimmedComment];
        if (trimmedComment.length != 0) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                        nil];
        }
        
        // Make sure there were no errors creating the image files
        if (!self.photoFile || !self.thumbnailFile) {
            
            [ApplicationDelegate.hudd hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Couldn't post your photo" delegate:nil             cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            return;
        }
        // both files have finished uploading
        
        // create a photo object
        
        PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
        [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
        [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
        [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
        
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        photo.ACL = photoACL;
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        
        // Save the Photo PFObject
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                
                // userInfo might contain any caption which might have been posted by the uploader
                if (userInfo) {
                    NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                    
                    if (commentText && commentText.length != 0) {
                        // create and save photo caption
                        PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
                        [comment setObject:photo forKey:kPAPActivityPhotoKey];
                        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                        [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                        [comment setObject:commentText forKey:kPAPActivityContentKey];
                        
                        if (latitudeLabel!=nil) {
                            [comment setObject:latitudeLabel forKey:@"latitude"];
                            [comment setObject:longitudeLabel forKey:@"longitude"];
                        }
                        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        [ACL setPublicReadAccess:YES];
                        comment.ACL = ACL;
                        [comment saveEventually];
                        
                        [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                        TemporaryString=postTextView.text;
                        PFUser *currentUser = [PFUser currentUser];
                        //NSLog(@"%@",currentUser);
                        
                        //NSLog(@"%@",[currentUser valueForKey:@"Accounttype"]);
                        
                        if ([selectedUserAccountType isEqualToString:@"FB"])
                        {
                            [self FacebookSahring];
                        }
                        if ([selectedUserAccountType isEqualToString:@"Twitter"])
                        {
                            //NSLog(@"Linked");
                        }
                        [postTextView resignFirstResponder];
                        autocompleteTableView.hidden = YES;
                        [ApplicationDelegate.hudd hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Couldn't post your photo" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                        [postTextView setText:@""];
                        SelectImageView.image=nil;
                        SelectImageView.image=[UIImage imageNamed:@""];
                    }
                    else
                    {
                        PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
                        [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
                        [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
                        [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
                        
                        // Photos are public, but may only be modified by the user who uploaded them
                        
                        if (latitudeLabel!=nil)
                        {
                            [photo setObject:latitudeLabel forKey:@"latitude"];
                            [photo setObject:longitudeLabel forKey:@"longitude"];
                        }
                        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        [photoACL setPublicReadAccess:YES];
                        photo.ACL = photoACL;
                        [photo saveEventually];
                        [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                        PFUser *currentUser = [PFUser currentUser];
                        //NSLog(@"%@",currentUser);
                        
                        //NSLog(@"%@",[currentUser valueForKey:@"Accounttype"]);
                        
                        if ([selectedUserAccountType isEqualToString:@"FB"])
                        {
                            [self FacebookSahring];
                        }
                        if ([selectedUserAccountType isEqualToString:@"Twitter"])
                        {
                            //NSLog(@"Linked");
                        }
                        autocompleteTableView.hidden = YES;
                        [ApplicationDelegate.hudd hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Couldn't post your photo" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                        SelectImageView.image=nil;
                        SelectImageView.image=[UIImage imageNamed:@""];
                    }
                }
            }
            else
            {
                [ApplicationDelegate.hudd hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Couldn't post your photo" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
    }
    
    // Dismiss this screen
}
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return autocompleteUrls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    cell.textLabel.textColor=[UIColor blueColor];
    cell.textLabel.text = [autocompleteUrls objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSCharacterSet *separator = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableArray *stringComponents = [NSMutableArray arrayWithArray:[postTextView.text componentsSeparatedByCharactersInSet:separator]];
    
    [stringComponents addObject:selectedCell.textLabel.text];
    
    postTextView.text = [stringComponents componentsJoinedByString:@" "];
    autocompleteTableView.hidden = YES;
}


#pragma mark Open ActionSheet & Delegate
- (IBAction)SharePhotoSelectButton:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Select image"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel Button"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Photo FromCamera",@"Photo From Gallery", nil];
    
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

#pragma mark Open ImagePicker & Image upload from Camera Or PhotoGallery

-(void)photoFromCamera{
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}
-(void)photoFromGallery{
    UIImagePickerController *Image_Picker=[[UIImagePickerController alloc]init];
    Image_Picker.delegate=self;
    Image_Picker.allowsEditing=YES;
    Image_Picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:Image_Picker animated:YES completion:Nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *New_Image = [info objectForKey:UIImagePickerControllerOriginalImage];
    IMagePicked=New_Image;
    [picker dismissViewControllerAnimated:YES completion:Nil];
    //[self displayEditorForImage:New_Image];
}

#pragma mark Photo Editor Events
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
//    //    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:editorController];
//    self.navigationController.navigationBarHidden=YES;
//    self.tabBarController.tabBar.hidden=YES;
//    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
//    [self.navigationController pushViewController:editorController animated:YES];    //    [ApplicationDelegate.navController presentViewController:editorController animated:YES completion:nil];
//}
//- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
//{
//    SelectImageView.hidden=YES;
//    SelectImageView.image = IMagePicked;
//    //self.image =IMagePicked;
//    [self shouldUploadImage:IMagePicked];
//    [self.navigationController popViewControllerAnimated:YES];
//    self.tabBarController.tabBar.hidden=NO;
//    self.navigationController.navigationBarHidden=NO;
//}
//- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
//{
//    SelectImageView.hidden=NO;
//    SelectImageView.image = image;
//    self.image =image;
//    [self shouldUploadImage:self.image];
//    [self.navigationController popViewControllerAnimated:YES];
//    self.tabBarController.tabBar.hidden=NO;
//    self.navigationController.navigationBarHidden=NO;
//    
//}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark Upload Image
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
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}


- (IBAction)removeSelectPic:(id)sender
{
    SelectImageView.image=nil;
    SelectImageView.hidden=YES;
}
#pragma mark Get Location
-(void)GetUserLocation{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Tellem" message:@"Failed to get your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        longitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    [locationManager stopUpdatingLocation];
}

#pragma mark Photo & Comments Sharing FB and Twitter Events
-(void)FacebookSahring
{
    //TODO FOR V4
//    if (ApplicationDelegate.session.isOpen)
//    {
//        if (ApplicationDelegate.session.isOpen)
//        {
//            NSMutableDictionary  *postVariablesDictionary = [[NSMutableDictionary alloc] init];
//            if (image==nil)
//            {
//                [postVariablesDictionary setObject:defoultImg forKey:@"source"];
//            }
//            else{
//                [postVariablesDictionary setObject:image forKey:@"source"];
//                //[postVariablesDictionary setObject:UIImagePNGRepresentation(self.image)  forKey:@"source"];
//            }
//            [postVariablesDictionary setObject:fbMessage forKey:@"message"];
//            //NSLog(@"%@",fb_userId);
//            [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/photos",fb_userId] parameters:postVariablesDictionary HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
//            {
//                if (!error)
//                {
//                    [ApplicationDelegate.hudd hide:YES];
//                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Posted on Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    alert.tag=111;
//                    [alert show];
//                }
//                else
//                {
//                    [ApplicationDelegate.hudd hide:YES];
//                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Posted on Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    [alert show];
//                }
//            }];
//            
//        }
//    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==111)
    {
        if (buttonIndex == 0)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
        }
    }
    else{
    }
    
}
-(void)TwitterSharing{
    
    NSData *dataObj = UIImageJPEGRepresentation(defoultImg, 1.0);
    NSMutableArray *twitPic_res= [[FHSTwitterEngine sharedEngine]uploadImageToTwitPic:dataObj withMessage:@"message" twitPicAPIKey:@"c1d12f3924baff015704f6861e44a18b"];
    NSString *twittStr=[twitPic_res valueForKey:@"url"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSString *tweet = twittStr;
            //NSError *returnCode = [[FHSTwitterEngine sharedEngine]postTweet:theWholeString withImageData:imageData];
            id returned = [[FHSTwitterEngine sharedEngine]getTimelineForUser:tw_userId isID:YES count:1];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSString *message = nil;
            
            if ([returned isKindOfClass:[NSError class]]) {
                NSError *error = (NSError *)returned;
                message = [NSString stringWithFormat:@"Error %ld ",(long)error.code];
                message = [message stringByAppendingString:error.localizedDescription];
            } else {
                message = tweet;
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Tellem" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
            });
        }
    });
}

#pragma mark TextView Delegate
//- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
//    
//    // Put anything that starts with this substring into the autocompleteUrls array
//    // The items in this array is what will show up in the table view
//    //[autocompleteUrls removeAllObjects];
//    // for(NSString *curString in [[PFUser currentUser] objectForKey:@"Keywords"])
//    {
//        // NSRange substringRange = [curString rangeOfString:substring];
//        //NSRange substringRangeLowerCase = [curString rangeOfString:[substring lowercaseString]];
//		//NSRange substringRangeUpperCase = [curString rangeOfString:[substring uppercaseString]];
//        
//        //if (substringRangeLowerCase.length != 0 || substringRangeUpperCase.length != 0) {
//        //[autocompleteUrls addObject:curString];
//        //}
//    }
//    autocompleteTableView.hidden = NO;
//    [autocompleteTableView reloadData];
//}
-(void)processSuggestionLogic:(NSString*)string
{
    [self.suggestionArray removeAllObjects];
    
    for(int i=0;i<savedSearches.count;i++)
    {
        if([[[savedSearches objectAtIndex:i] lowercaseString] rangeOfString:[string lowercaseString]].location!=NSNotFound)
        {
            [self.suggestionArray addObject:[savedSearches objectAtIndex:i]];
        }
    }
    
    //NSLog(@"Suggested Locations: %@",self.suggestionArray);
    [self createSuggestedView:self.suggestionArray];
}

-(void)createSuggestedView:(NSArray*)array
{
    if(array.count>0)
    {
        //remove labels from scrollview
        [self clearSuggestions];
        
        self.scrollView.hidden = NO;
        
        //scrollview
        self.scrollView.backgroundColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
        //self.scrollView.alpha = 0.4;
        [self.view addSubview:self.scrollView];
        [self.view bringSubviewToFront:self.scrollView];
        
        int x = 5;
        //int y = self.view.frame.size.height - keyboardHeight - 44;
        for(int i=0;i<array.count;i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(x, 10, self.view.frame.size.width, 30);
            //[btn setBackgroundColor:[UIColor blackColor]];
            //btn.alpha = 0.5;
            [btn setTitle:[NSString stringWithFormat:@" %@ |",[array objectAtIndex:i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(selectedSuggestion:) forControlEvents:UIControlEventTouchUpInside];
            //[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.textColor = [UIColor whiteColor];
            [btn sizeToFit];
            x = x + btn.frame.size.width;
            [self.scrollView addSubview:btn];
        }
        self.scrollView.contentSize = CGSizeMake(x, 0);
    }
    else{
        [self clearSuggestions];
    }
}
-(void)selectedSuggestion:(UIButton*)tempBtn
{
    NSString *BeforeString;
    NSString *AboveString;
    self.scrollView.hidden = YES;
    NSString *string = [tempBtn.currentTitle substringToIndex:([tempBtn.currentTitle length]-1)];
    string = [string substringToIndex:([string length]-1)];
    string = [string substringFromIndex:1];
    int indexAtWhereEnd=0;
    int lengthOfTextView=postTextView.text.length-1;
    if (rangeat.location!=lengthOfTextView) {
        for (int i=rangeat.location;i<lengthOfTextView ; i++) {
            
            char chara=[postTextView.text characterAtIndex:i];
            if ([[NSString stringWithFormat:@"%c",chara]isEqualToString:@" "])
            {
                indexAtWhereEnd=i;
                break;
            }
        }
        if (indexAtWhereEnd==0)
        {
            BeforeString=@"";
            AboveString=[postTextView.text substringToIndex:rangeat.location+1];
        }
        else
        {
            BeforeString=[postTextView.text substringFromIndex:indexAtWhereEnd];
            AboveString=[postTextView.text substringToIndex:indexAtWhereEnd];
        }
    }
    else
    {
        BeforeString=@"";
        AboveString=[postTextView.text substringToIndex:rangeat.location+1];
    }
    NSMutableArray *arr_StringArray=[NSMutableArray arrayWithArray:[AboveString componentsSeparatedByString:@" "]];
    [arr_StringArray replaceObjectAtIndex:[arr_StringArray count]-1 withObject:string];
    NSString *NewString=[[arr_StringArray componentsJoinedByString:@" "] stringByAppendingString:BeforeString];
    
    postTextView.text=NewString;
    [self clearSuggestions];
    [postTextView resignFirstResponder];
    
}
-(void)clearSuggestions
{
    NSArray *subviews = [self.scrollView subviews];
    for(UIView *subview in subviews)
    {
        if([subview isKindOfClass:[UIButton class]])
        {
            [subview removeFromSuperview];
        }
    }
    self.scrollView.hidden = YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //NSLog(@"Length-->%d Location-->%d",range.length,range.location);
    NSString *firstFour = [textView.text substringToIndex:range.location];
    NSString *lastFour = [textView.text substringFromIndex:range.location];
    
    //NSLog(@"First-->%@",firstFour);
    //NSLog(@"First-->%@",lastFour);
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    if (text.length>0) {
        lengthOfString=text.length;
        // For any other character return TRUE so that the text gets added to the view
        rangeat=range;
        
        [self processSuggestionLogic:text];
    }
    
    //[self searchAutocompleteEntriesWithSubstring:substring];
    //autocompleteTableView.hidden = NO;
    return YES;

}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    // autocompleteTableView.hidden = NO;
    [autocompleteTableView reloadData];
    [postTextView resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    self.scrollView.hidden = YES;
    [postTextView resignFirstResponder];
    autocompleteTableView.hidden=YES;
    return YES;
}

@end
