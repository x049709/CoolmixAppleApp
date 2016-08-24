//
//  PostViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 05/04/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "PostViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPCache.h"
#import "AppDelegate.h"
#import "UIImage+ImageEffects.h"
#import <ParseTwitterUtils/PFTwitterUtils.h>


static NSString * const kAviaryAPIKey = @"o1kffu3bdtbctbg7";
static NSString * const kAviarySecret = @"b1mdl2dbyp5lq2d1";
@interface PostViewController (){
    NSString  *longitudeLabel;
    NSString *latitudeLabel;
    NSString *fbMessage;
}
@property (nonatomic, retain) UIDocumentInteractionController *docController;
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (strong, nonatomic) NSString *objectID;
@property (nonatomic, strong) PFFile *profilePictureFile;
@property (nonatomic, strong) PFFile *profileThumbnailFile;
@property BOOL isRecording;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property NSURL *currentRecording;
@property NSString *recorderFileName;
@property int recordingTimeInSecs;

@end

@implementation PostViewController
@synthesize commentTextField,photoFile,thumbnailFile,photoPostBackgroundTaskId,fileUploadBackgroundTaskId,postBtn,docFile;
@synthesize image,postImg,pastUrls,autocompleteTableView,postScrollView,typedText,bgImageView,removePicture,circleProfile,selectedCircleFromPostCircle,profileThumbnailFile,profilePictureFile,sortedCircles,pageCircle,recorderFilePath,recorderFileName,recordingTimeInSecs,countdownTimer,startTimer,stopTimedTimer,recordLabel,imageToPostToOtherNetworks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}
- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getMoodWords];
    [self.postScrollView setScrollEnabled:NO];
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    self.navigationItem.title=@"POST";
    [self.navigationController.navigationBar
        setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    [self.view addSubview:autocompleteTableView];
    
    self.recordLabel =[[TellemLabel alloc]initWithFrame:CGRectMake(230, 24, 74, 25)  withBackgroundColor:[UIColor darkGrayColor] andTitle:@"Record"];
    [self.recordLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *recordLabelTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startRecordingTouched:)];
    recordLabelTouch.numberOfTapsRequired = 1;
    [self.recordLabel addGestureRecognizer:recordLabelTouch];
    [self.postScrollView addSubview:self.recordLabel];


    savedSearches = [[NSMutableArray alloc] init];
    self.suggestionArray = [[NSMutableArray alloc] init];
    self.commentTextField.layer.cornerRadius = 4.0f;
    self.commentTextField.layer.borderWidth = 1.0;
    self.commentTextField.layer.borderColor = [[UIColor darkGrayColor]CGColor];
    self.commentTextField.clearsOnInsertion = TRUE;
    [self.commentTextField resignFirstResponder];
    self.commentTextField.delegate = self;
    self.commentTextField.backgroundColor = [UIColor whiteColor];
    self.commentTextField.font = [UIFont fontWithName:kFontThin size:17.0];
    [self.commentTextField setTextColor:[UIColor blackColor]];
    [self.commentTextField setPlaceholderColor:[UIColor darkGrayColor]];
    [self.commentTextField setTintColor:[UIColor blackColor]];
    [self.commentTextField setPlaceholder:@"Type in your comments here..."];
    
    if ([[UIScreen mainScreen] bounds].size.height==568)
    {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 244, 320, 44)];
    }
    else
    {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 200-44, 320, 44)];
    }
    
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    CGSize scrollViewContentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+20);
    [self.scrollView setContentSize:scrollViewContentSize];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.view.backgroundColor = [UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight];

    self.postImg.hidden=YES;
    self.postImg.layer.cornerRadius = 1.0f;
    self.postImg.backgroundColor = [UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight];;
    [self.postImg setUserInteractionEnabled:YES];
    UITapGestureRecognizer *imageViewTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTouched)];
    imageViewTouch.numberOfTapsRequired = 1;
    [self.postImg addGestureRecognizer:imageViewTouch];

    self.typedText=[[NSMutableString alloc]initWithString:@""];
    
    locationManager = [[CLLocationManager alloc] init];
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }

    self.selectedCircle = [[Circle alloc] initWithImage:[UIImage imageNamed:@"lock.png"]  andLabelFrame:CGRectMake(15, 15, self.view.frame.size.width - 120, 40)];
    self.selectedCircle.circleType = kPAPCircleIsNewFromPostView;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCirclesView:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.selectedCircle.circleLabel addGestureRecognizer:tapGestureRecognizer];
    [self.postScrollView addSubview:self.selectedCircle.circleLabel];
  }

-(void)getMoodWords
{
    NSUInteger limit = 1000;
    PFQuery *query=[PFQuery queryWithClassName:@"Moods"];
    [query setLimit: limit];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects) {
             savedSearches=[objects valueForKey:@"moodtype"];
         }
     }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    tM.gCurrentTab = 2;
    [self getUserLocation];
    self.postImg.hidden=NO;
    [self.removePicture setSelected:NO];
    [self setupCircleLabel];
    [self addPostPhotoButton];
    if (self.image) {
        [self finishedWithImage:self.image];
        self.postPhoto.hidden=NO;
        self.recordLabel.text = @"Record";
        self.recordLabel.hidden=NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self stopRecordingPhotoAudio];
    [self.startTimer invalidate];
    [self.countdownTimer invalidate];
    [self.stopTimedTimer invalidate];
    [self deleteSoundFile:self.recorderFilePath];
}

-(void)addPostPhotoButton
{
    //Add 'post photo' button
    float photoX = self.view.frame.size.width/2 - 28;
    float photoY = self.view.frame.size.height - 77;
    [self.postPhoto setFrame:CGRectMake(photoX, photoY, 56, 56)];
    self.postPhoto.layer.cornerRadius = self.postPhoto.frame.size.height/2.0f;
    self.postPhoto.layer.borderWidth = 4.0;
    self.postPhoto.clipsToBounds=YES;
    self.postPhoto.layer.borderColor=[UIColor whiteColor].CGColor;
    [self.postPhoto setTitle:@"P" forState:UIControlStateNormal];
    self.postPhoto.titleLabel.font = [UIFont fontWithName:kFontBold size:24];
    [self.postPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.postPhoto setSelected:NO];
    [self.view addSubview:self.postPhoto];
}

- (void)selectPictureToPost:(id)sender {
    [self imageViewTouched];
}

- (void)setupCircleLabel
{
    PFUser *user = [PFUser currentUser];
    self.sortedCircles = [NSArray array];
    self.sortedCircles = [TellemUtility getAllCirclesOfUser:user];
    
    //Preferred circle will be used by Post when invoked
    TellemGlobals *tM = [TellemGlobals globalsManager];
    if (tM.gPreferredCircle) {
        self.pageCircle = tM.gPreferredCircle;
        tM.gPreferredCircle = nil;
        self.selectedCircle.circleType = kPAPCircleIsNotNewFromPostView;
        [self.selectedCircle setNewCircleName:[self.pageCircle valueForKey:kPAPCircleNameKey]];
        PFFile *profilePhoto = [PFFile alloc];
        profilePhoto = [self.pageCircle objectForKey:kPAPCircleProfilePicture];
        NSData *profilePhotoData = [profilePhoto getData];
        UIImage * profileImage = [[UIImage alloc] init];
        profileImage = [UIImage imageWithData:profilePhotoData];
        [self.selectedCircle setNewCircleImage:profileImage];
        [self.postScrollView addSubview:self.selectedCircle.circleLabel];
        return;
    }
 
    if ([self.selectedCircle.circleType isEqual:kPAPCircleIsNewFromPostView])
    {
        if (self.sortedCircles.count ==0)
        {
            //Circle has no posts - use default circle for new ones
            [self.postScrollView addSubview:self.selectedCircle.circleLabel];
        }
        else
        {
            //Use first found circle of user
            self.pageCircle = [self.sortedCircles objectAtIndex:0];
            self.selectedCircle.circleType = kPAPCircleIsNotNewFromPostView;
            [self.selectedCircle setNewCircleName:[self.pageCircle valueForKey:kPAPCircleNameKey]];
            PFFile *profilePhoto = [PFFile alloc];
            profilePhoto = [self.pageCircle objectForKey:kPAPCircleProfilePicture];
            NSData *profilePhotoData = [profilePhoto getData];
            UIImage * profileImage = [[UIImage alloc] init];
            profileImage = [UIImage imageWithData:profilePhotoData];
            [self.selectedCircle setNewCircleImage:profileImage];
            [self.postScrollView addSubview:self.selectedCircle.circleLabel];
        }
    }
    else
    {
        //Use circle chosen in PostCirclesView
        [self.postScrollView addSubview:self.selectedCircle.circleLabel];
    }
    
}

- (void)settingsButtonAction:(id)sender
{
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My profile",@"Settings",@"Log out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)imageViewTouched{

    if (self.postImg.image == nil) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self photoFromCamera];
            /*
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"Use photo from camera",@"Use photo from gallery", nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
            */
        }
        else {
            [self photoFromGallery];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)storeAccessToken:(NSString *)accessToken;
{
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
    imagePickerFromCamera.allowsEditing = YES;
    imagePickerFromCamera.delegate = self;
    [self presentViewController:imagePickerFromCamera animated:YES completion:Nil];
}
-(void)photoFromGallery{
    UIImagePickerController *imagePickerFromGallery=[[UIImagePickerController alloc]init];
    imagePickerFromGallery.allowsEditing=YES;
    imagePickerFromGallery.delegate=self;
    imagePickerFromGallery.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerFromGallery animated:YES completion:Nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imagePicked = [info objectForKey:UIImagePickerControllerEditedImage];
    imagePickedFromGalleryOrCamera=imagePicked;
    [picker dismissViewControllerAnimated:YES completion:Nil];
    [self displayEditorForImage:imagePicked];
}
- (void)displayEditorForImage:(UIImage *)imageToEdit
{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [AFPhotoEditorController setAPIKey:kAviaryAPIKey secret:kAviarySecret];
//    });
//    
//    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
//    [editorController setDelegate:self];
//    self.navigationController.navigationBarHidden=YES;
//    self.tabBarController.tabBar.hidden=YES;
//    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
//    [self.navigationController pushViewController:editorController animated:YES];
}

//- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
//{
//    self.postImg.image=nil;
//    self.postImg.hidden=YES;
//    [removePicture removeFromSuperview];
//    self.postPhoto.hidden=NO;
//    [self.navigationController popViewControllerAnimated:YES];
//    self.tabBarController.tabBar.hidden=NO;
//    self.navigationController.navigationBarHidden=NO;
//
//}

//- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)editedImage
//{
//    [self finishedWithImage:editedImage];
//    self.tabBarController.tabBar.hidden=NO;
//    self.navigationController.navigationBarHidden=NO;
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void) finishedWithImage:(UIImage *)editedImage
{
    self.postImg.hidden=NO;
    self.recordLabel.hidden=NO;
    //postImg.contentMode = UIViewContentModeLeft; doesn't work
    self.postImg.image = editedImage;
    self.postImg.preservesSuperviewLayoutMargins = YES;
    self.image =editedImage;
    self.postPhoto.hidden=YES;
    [self shouldUploadImage:self.image];

    //Add picture to text view
    //float photoX = 5;
    //float photoY = (int)self.postScrollView.frame.size.height/2 - 50;
    //float photoH = (int)self.commentTextField.frame.size.width;
    float photoW = self.commentTextField.frame.size.width -8;
    self.postImg.frame = CGRectMake(4, 100, photoW, photoW);
    self.postImg.backgroundColor= [UIColor colorWithPatternImage:[image applyLightEffect]];
    [self.commentTextField addSubview:postImg];
    //Add 'remove picture button'
    self.removePicture = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removePicture addTarget:self action:@selector(removePictureFromPost:) forControlEvents:UIControlEventTouchUpInside];
    [self.removePicture setFrame:CGRectMake(self.postImg.frame.origin.x+self.postImg.frame.size.width-32, 4.0f, 25.0f, 25.0f)];
    [self.removePicture setBackgroundColor:[UIColor clearColor]];
    [[self.removePicture titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [self.removePicture setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [self.removePicture setSelected:NO];
    [self.removePicture setUserInteractionEnabled:YES];
    [postImg addSubview:self.removePicture];
}

- (void)removePictureFromPost {
    self.postImg.image=nil;
    self.image=nil;
    self.postImg.hidden=YES;
    self.postImg.backgroundColor= [UIColor grayColor];
    [self.removePicture removeFromSuperview];
    self.postPhoto.hidden=NO;
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self stopRecordingPhotoAudio];
    [self.startTimer invalidate];
    [self.countdownTimer invalidate];
    [self.stopTimedTimer invalidate];
    [self deleteSoundFile:self.recorderFilePath];
}

- (void)removePictureFromPost:(id)sender {
    [self removePictureFromPost];
    self.tabBarController.tabBar.hidden=NO;
    self.navigationController.navigationBarHidden=NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.postPhoto.hidden=NO;
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

- (IBAction)postPictureBtn_clicked:(id)sender
{
    if (self.selectedCircle.circleName.length == 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Circle name cannot be empty" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }

    if ([self.selectedCircle.circleName isEqualToString:@"New circle"])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Please enter the new circle name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    // We will post an object on behalf of the user
    if (self.postImg.hidden==YES)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Nothing to post!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    else
    {
        [self.view.window addSubview:ApplicationDelegate.hudd];
        [ApplicationDelegate.hudd show:YES];
        NSArray *shareSettings = [[PFUser currentUser] valueForKey:@"ShareSettings"];
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmedComment.length == 0) {
            trimmedComment = @"Comments intentionally left blank";
        }
        
        NSMutableArray *moodTypes = [[NSMutableArray alloc] init];
        fbMessage=[NSString stringWithFormat:@"%@",trimmedComment];
        if (trimmedComment.length != 0)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                        nil];
            moodTypes = [self buildMoodTypes:trimmedComment];
        }
        // Make sure there were no errors creating the image files
        if (!self.photoFile || !self.thumbnailFile )
        {
            UIImage *defaultImg=[UIImage imageNamed:@"user.png"];
            NSData *imageData = UIImageJPEGRepresentation(defaultImg, 0.8f);
            NSData *thumbnailImageData = UIImagePNGRepresentation(defaultImg);
            self.photoFile = [PFFile fileWithData:imageData];
            self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
            // Make sure there were no errors creating the image files
            if (!self.photoFile || !self.thumbnailFile || trimmedComment.length ==0) {
                [ApplicationDelegate.hudd hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Could not post default photo. Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
                return;
            }
        }
        
        // Both files have finished uploading; create a photo object
        PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
        [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
        [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
        [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
        // Save background audio
        if (self.recorderFilePath) {
            NSData *audioData = [NSData dataWithContentsOfFile:self.recorderFilePath];
            if (audioData) {
                PFFile *audioFile = [PFFile fileWithName:self.recorderFileName data:audioData];
                if (audioFile) {
                    [photo setObject:audioFile forKey:kPAPPhotoPhotoAudioKey];
                    [self deleteSoundFile:self.recorderFilePath];
                }
            }
            [self stopRecordingPhotoAudio];
        }
        // Photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        photo.ACL = photoACL;
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        // Save the photo PFObject
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                 // userInfo might contain any caption which might have been posted by the uploader
                 if (userInfo)
                 {
                     NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                     if (commentText && commentText.length != 0)
                     {
                         // Create and save circle profile if it does not exist, either because the user posted without changing the default circle or choosing a new circle. Get the profile if it does
                         self.circleProfile = [self getCircleProfile];
                         // Create and save photo caption
                         PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                         [comment setObject:kPAPActivityTypeInitPost forKey:kPAPActivityTypeKey];
                         [comment setObject:photo forKey:kPAPActivityPhotoKey];
                         [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                         [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                         [comment setObject:commentText forKey:kPAPActivityContentKey];
                         [comment setObject:moodTypes forKey:kPAPActivityMoodTypeKey];
                         [comment setObject:self.circleProfile forKey:kPAPActivityCircleKey];
                         NSTimeInterval rightNow = [NSDate timeIntervalSinceReferenceDate];
                         rightNow = ((NSTimeInterval)((long long)(rightNow * 1000)) / 1000);
                         NSDate * lastUpdated = [NSDate dateWithTimeIntervalSinceReferenceDate:rightNow];
                         [comment setObject:lastUpdated forKey:kPAPActivityLastUpdated];
                         if (latitudeLabel!=nil) {
                             [comment setObject:latitudeLabel forKey:@"latitude"];
                             [comment setObject:longitudeLabel forKey:@"longitude"];
                         }
                         PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                         [ACL setPublicWriteAccess:YES];
                         [ACL setPublicReadAccess:YES];
                         comment.ACL = ACL;
                         [comment saveEventually];
                         
                         [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                         self.imageToPostToOtherNetworks = self.image;

                         if ([[shareSettings objectAtIndex:0] isEqualToString:@"1"])
                         {
                             [self postOnTwitter:commentText];
                         }
                         
                         [self notifyCircleMembersOfPosting:photo];
                         [commentTextField resignFirstResponder];
                         [ApplicationDelegate.hudd hide:YES];
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Post successful!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                         [alert show];
                         [commentTextField setText:@""];
                         [self removePictureFromPost];
                         self.tabBarController.selectedIndex=0;
                         [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];

                         if ([[shareSettings objectAtIndex:1]isEqualToString:@"1"])
                         {
                             [self performSelector:@selector(postOnFaceBook:) withObject:commentText afterDelay:5.0];
                         }
                         
                         if ([[shareSettings objectAtIndex:2]isEqualToString:@"1"])
                         {
                             [self performSelector:@selector(postOnInstagram:) withObject:commentText afterDelay:10.0];
                         }
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Nothing to post!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                         [alert show];
                         return;
                     }
                 }
             }
             else
             {
                 [ApplicationDelegate.hudd hide:YES];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Post failed!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                 [alert show];
             }
             [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
         }];
    }
    // Dismiss this screen
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}


- (NSMutableArray*) buildMoodTypes:(NSString *)trimmedComment
{
    NSMutableArray *moodTypes = [[NSMutableArray alloc] init];
    NSArray *words = [trimmedComment componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *searchWord, *listWord;
    for (NSString *word in words)
    {
        for(int i=0;i<savedSearches.count;i++)
        {
            searchWord = [word lowercaseString];
            listWord = [[savedSearches objectAtIndex:i] lowercaseString];
            if([listWord isEqualToString:searchWord])
            {
                [moodTypes addObject:searchWord];
                break;
            }
        }
    }
    return moodTypes;
}

- (void)showCirclesView:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostCirclesViewController *postCirclesView = (PostCirclesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostCirclesViewController"];
    postCirclesView.selectFBUserid = [currentUser valueForKey:kPAPUserUserNameKey];
    postCirclesView.selectFBUserName = [currentUser valueForKey:kPAPUserDisplayNameKey];
    postCirclesView.callingController = @"PostViewController";
    postCirclesView.selectedCircleFromPostView = self.selectedCircle;
    postCirclesView.delegate=self;
    postCirclesView.sortedCircleNames = self.sortedCircles;
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:postCirclesView animated:YES];
}

-(void) receiveCirclesArrayData:(NSArray *)arrayData;
{
    self.selectedCircle = [arrayData objectAtIndex:0];
    self.pageCircle = [arrayData objectAtIndex:1];
    PFFile *selectedCircleThumbnail = [self.pageCircle valueForKey:kPAPCircleProfileThumbnail];
    NSString *selectedCircleName = [self.pageCircle valueForKey:kPAPCircleNameKey];
    if (![self.selectedCircle.circleType isEqualToString:kPAPCircleIsNewFromPostCirclesView]) {
        [self.selectedCircle setNewCircleImageFromPFFile:selectedCircleThumbnail];
        [self.selectedCircle setNewCircleName:selectedCircleName];
    }
}

-(void)notifyCircleMembersOfPosting: (PFObject*) photo {
    if ([self.selectedCircle.circleType isEqualToString:kPAPCircleIsNewFromPostCirclesView])
    {
        return;
    }
    if ([self.selectedCircle.circleType isEqualToString:kPAPCircleIsNewFromPostView])
    {
        return;
    }

    PFUser *user = [PFUser currentUser];
    NSArray *userMembers = [NSArray array];
    userMembers = [TellemUtility getAllUserIdsOfCircle:self.pageCircle];
    NSMutableArray *userMutableMembers = [NSMutableArray array];

    for(int i=0;i<userMembers.count;i++)
    {
        NSString *searchUser = [user username];
        NSString *memberUser = [userMembers  objectAtIndex:i];
        if(![memberUser isEqualToString:searchUser])
        {
            [userMutableMembers addObject:memberUser];
        }
    }
    
    if (userMutableMembers.count > 0) {
        NSString *message = [NSString stringWithFormat:@"%@ posted a new photo to a circle!", user[@"displayName"]];
        NSArray *payLoadPhoto = [NSArray array];
        NSArray *payLoadPageIndex = [NSArray array];
        payLoadPhoto = [NSArray arrayWithObjects:@"photo", kPAPobjectIDKey, photo, self.pageCircle,nil];
        payLoadPageIndex = @[@"circle", @"pageIndex", [NSString stringWithFormat:@"%tu", 0]];
        NSArray *payLoad = [NSArray arrayWithObjects:payLoadPhoto, payLoadPageIndex,kPAPPushCommentOnPost,nil];
        [TellemUtility sendMessageToManyUsers:userMutableMembers withCircleName:[self.pageCircle valueForKey:kPAPCircleNameKey] andSendingUser:user andMessage:message andMessageType:kPAPPushCommentOnPost andPayload:payLoad];
        NSString *strFromInt = [NSString stringWithFormat:@"%lu",(unsigned long)userMutableMembers.count];
        NSString *notifyMsg = [@"Sending notifications to " stringByAppendingString:strFromInt];
        notifyMsg = [notifyMsg stringByAppendingString:@" members"];
        NSString *msgInfo = @"Msg is nothing";
        [TellemUtility tellemLog:notifyMsg andMsgInfo:[NSArray arrayWithObjects:msgInfo,userMutableMembers,nil]];
    }
}

-(PFObject*)getCircleProfile {
    PFUser *user = [PFUser currentUser];
    PFACL *ACL = [PFACL ACLWithUser:user];
    PFObject *circle = [PFObject objectWithClassName:kPAPCircleClassKey];
    
    if ([self.selectedCircle.circleType isEqualToString:kPAPCircleIsNewFromPostView] || [self.selectedCircle.circleType isEqualToString:kPAPCircleIsNewFromPostCirclesView] )
    {
        //Create a new circle membership
        //Note that at this point the circle is guaranteed to NOT exist yet
        [circle setObject:user forKey:kPAPCircleOwnerUserIdKey];
        [circle setObject:@"Active" forKey:kPAPCircleStatusKey];
        [circle setObject:self.selectedCircle.circleName forKey:kPAPCircleNameKey];
        NSMutableArray *memberArray = [NSMutableArray array];
        [memberArray addObject:[user username]];
        [circle setObject:memberArray forKey:kPAPCircleMemberUserIdArray];
        UIImage *defaultImg=self.selectedCircle.circleImage;
        NSData *imageData = UIImageJPEGRepresentation(defaultImg, 0.8f);
        NSData *thumbnailImageData = UIImagePNGRepresentation(defaultImg);
        self.profilePictureFile = [PFFile fileWithData:imageData];
        self.profileThumbnailFile = [PFFile fileWithData:thumbnailImageData];
        [circle setObject:self.profilePictureFile forKey:kPAPCircleProfilePicture];
        [circle setObject:self.profileThumbnailFile forKey:kPAPCircleProfileThumbnail];
        circle.ACL = ACL;
        //[circle save];
    }
    else
    //pageCircle should have either the circle from PostCircles or the selected circle from PostCirclesView
    {
        circle = self.pageCircle;
    }

    return circle;
}

-(void)postOnTwitter:(NSString *)commentText
{
    NSLog(@"PostViewController postOnTwitter commentText: %@", commentText);
    [PFTwitterUtils initializeWithConsumerKey:kTwitterClientID consumerSecret:kTwitterClientSecret];
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:kTwitterClientID andSecret:kTwitterClientSecret];
    [FHSTwitterEngine sharedEngine].delegate=self;
    //[self loginOAuth];
    NSData *imageToPost;
    if (self.imageToPostToOtherNetworks == nil) {
        UIImage *blankPosting=[UIImage imageNamed:@"user.png"];
        imageToPost = UIImageJPEGRepresentation(blankPosting, 1.0);
    }
    else {
        imageToPost = UIImageJPEGRepresentation(self.imageToPostToOtherNetworks, 1.0);
    }
    
    id twitMsgWithPic = [[FHSTwitterEngine sharedEngine] postTweet:commentText withImageData:imageToPost];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([twitMsgWithPic isKindOfClass:[NSError class]])
    {
        [ApplicationDelegate.hudd hide:YES];
        NSLog (@"PostViewController: Error posting picture to Twitter:%ld", (long)((NSError *)twitMsgWithPic).code);
    } else
    {
        [ApplicationDelegate.hudd hide:YES];
        NSString *str=@"Successfully posted on Twitter";
        NSLog (@"PostViewController: %@", str);
    }
}

- (NSString *)loadAccessToken
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void)loginOAuth {
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        //NSLog(success?@"OAuth login success":@"OAuth Login failed!");
    }];
    [self presentViewController:loginController animated:YES completion:nil];
}


-(void)postOnFaceBook:(NSString *)commentText
{
//TODO FOR V4
//    NSLog(@"PostViewController postOnFaceBook commentText: %@", commentText);
//    ApplicationDelegate.session=[FBSession activeSession];
//    FBSession *activeFBSession = [FBSession activeSession];
//    [FBSession setActiveSession:activeFBSession];
//    
//    NSArray *permissionsNeeded = @[@"publish_actions"];
    // Request the permissions the user currently has
//    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error)
//        {
//            NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
//            NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
//
//            // Check if all the permissions we need are present in the user's current permissions
//            // If they are not present add them to the permissions to be requested
//            for (NSString *permission in permissionsNeeded)
//            {
//                if (![currentPermissions objectForKey:permission])
//                {
//                    [requestPermissions addObject:permission];
//                }
//            }
//            // If we have permissions to request
//            if ([requestPermissions count] > 0)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self requestPermissionToPost:requestPermissions];
//                });
//            }
//            else
//            {
//            // Permissions are present We can request the user information
//                [self getAllObjects];
//            }
//                                      
//        } else
//        {
//            // An error occurred, we need to handle the error
//            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//            NSLog (@"PostViewController: Error posting picture to Facebook,%@", error);
//        }
//    }];
}

-(void)requestPermissionToPost:(NSMutableArray *)requestPermissions
{
//TODO FOR V4
    // Ask for the missing permissions
//    [FBSession.activeSession requestNewPublishPermissions:requestPermissions defaultAudience:FBSessionDefaultAudienceFriends
//                                        completionHandler:^(FBSession *session, NSError *error)
//     {
//         if (!error) {
//             // Permission granted, we can request the user information[self makeRequestToPostObject];
//             [self getAllObjects];
//         }
//         else
//         {
//             // An error occurred, we need to handle the error
//             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//             NSLog (@"PostViewController: Error posting picture  to Facebook,%@", error);
//         }
//     }];
}

-(void)getAllObjects
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:fbMessage forKey:@"message"];
    if (self.imageToPostToOtherNetworks==nil)
    {
        UIImage *fbpsost=[UIImage imageNamed:@"user.png"];
        [params setObject:UIImagePNGRepresentation(fbpsost) forKey:@"picture"];
    }
    else
    {
        [params setObject:UIImagePNGRepresentation(self.imageToPostToOtherNetworks) forKey:@"picture"];
    }
    //TODO FOR V4
//    [FBRequestConnection startWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
//    {
//        NSString *str;
//        if (error)
//        {
//            [ApplicationDelegate.hudd hide:YES];
//            NSLog (@"PostViewController: Error posting picture to Facebook,%@", error);
//        }
//        else
//        {
//            [ApplicationDelegate.hudd hide:YES];
//            str=@"Successfully posted on Facebook";
//            NSLog (@"PostViewController: %@", str);
//        }
//     }];
}

-(void)postOnInstagram:(NSString *)commentText{
    
    NSLog(@"PostViewController postOnInstagram commentText: %@", commentText);
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        CGRect rect = CGRectMake(0,0,0,0);
        NSString *jpgPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Home_1_instgram.igo"];
        //UIImage *imageN = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@", jpgPath]];
        if (self.imageToPostToOtherNetworks==nil)
        {
            UIImage *instaImg=[UIImage imageNamed:@"user.png"];
            [UIImagePNGRepresentation(instaImg) writeToFile:jpgPath atomically:YES];
        }
        else
        {
            [UIImagePNGRepresentation(self.imageToPostToOtherNetworks) writeToFile:jpgPath atomically:YES];
        }
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@",jpgPath]];
        self.docFile.UTI = @"com.instagram.exclusivegram";
        
        self.docFile = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
        
        
        [self.docFile presentOpenInMenuFromRect: rect inView: self.view animated: YES ];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Instagram not installed in this device!\nTo share image please install Instagram." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    
}
- (void)handleCommentTimeout:(NSTimer *)aTimer
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tellem", nil) message:NSLocalizedString(@"Your comments will be posted next time there is an internet connection.", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    [alert show];
}

-(void)processSuggestionLogic:(NSString*)string
{
    [self.suggestionArray removeAllObjects];
    
    for(int i=0;i<savedSearches.count;i++)
    {
        if([[[savedSearches objectAtIndex:i] lowercaseString] rangeOfString:[string lowercaseString]].location!=NSNotFound)
        {
            [self.suggestionArray addObject:[[savedSearches objectAtIndex:i] lowercaseString]];
        }
    }
    
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
        //[self.typedText setString:@""];
    }
}

-(void)selectedSuggestion:(UIButton*)tempBtn
{
    NSString *BeforeString;
    NSString *AboveString;
    self.scrollView.hidden = YES;
    NSString *selectedString = [tempBtn.currentTitle substringToIndex:([tempBtn.currentTitle length]-1)];
    selectedString = [selectedString substringToIndex:([selectedString length]-1)];
    selectedString = [selectedString substringFromIndex:1];
    int indexAtWhereEnd=0;
    int lengthOfTextView=commentTextField.text.length-1;
    if (rangeat.location!=lengthOfTextView) {
        for (int i=rangeat.location;i<lengthOfTextView ; i++) {
            
            char chara=[commentTextField.text characterAtIndex:i];
            if ([[NSString stringWithFormat:@"%c",chara]isEqualToString:@" "]) {
                indexAtWhereEnd=i;
                break;
            }
        }
        if (indexAtWhereEnd==0) {
            BeforeString=@"";
            AboveString=[commentTextField.text substringToIndex:rangeat.location+1];
        }
        else
        {
            BeforeString=[commentTextField.text substringFromIndex:indexAtWhereEnd];
            AboveString=[commentTextField.text substringToIndex:indexAtWhereEnd];
        }
    }else
    {
        BeforeString=@"";
        AboveString=[commentTextField.text substringToIndex:rangeat.location+1];
       
    }
    NSMutableArray *arr_StringArray=[NSMutableArray arrayWithArray:[AboveString componentsSeparatedByString:@" "]];
    [arr_StringArray replaceObjectAtIndex:[arr_StringArray count]-1 withObject:selectedString];
    NSString *NewString=[[arr_StringArray componentsJoinedByString:@" "] stringByAppendingString:BeforeString];
    
    
    commentTextField.text=NewString;
    [self.typedText setString:@""];
    [self clearSuggestions];
    //[commentTextField resignFirstResponder];
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
//TODO: Handle deleting text (backspace 1 char; currently, must delete last word entered)
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //NSLog (@"PostViewController textView shouldChangeTextInRange: Current word: %@ New letter: %@", typedText, text);
    
    if (range.length ==1 && [text isEqualToString:@""]) {
        return YES;
    }
    
    if (![self isAcceptableTextLength:textView.text.length + text.length - range.length]) {
        return NO;
    }

    NSString *trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.typedText appendString:text];
    NSString *trimmedString = [self.typedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.typedText setString:trimmedString];

    if ([trimmedText isEqualToString:@"\n"]) {
        [self.typedText setString:@""];
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }

    if (trimmedText.length>0) {
        lengthOfString=trimmedText.length;
        // For any other character return TRUE so that the text gets added to the view
        rangeat=range;
        [self processSuggestionLogic:typedText];
    } else {
        [self.typedText setString:@""];
    }

    if (range.length ==1 && [text isEqualToString:@""]) {
        return YES;
    }
    
    if (![self isAcceptableTextLength:textView.text.length + text.length - range.length]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isAcceptableTextLength:(NSUInteger)length {
    //NSLog (@"PostViewController textView isAcceptableTextLength:, %lu", (unsigned long)length);
    return length <= 200;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    //autocompleteTableView.hidden = NO;
    //[autocompleteTableView reloadData];
    [commentTextField resignFirstResponder];
    [self.postScrollView setScrollEnabled:YES];

    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{

    [commentTextField resignFirstResponder];
    [self.postScrollView setScrollEnabled:NO];
     self.scrollView.hidden = YES;
     //autocompleteTableView.hidden=YES;
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self.postScrollView setScrollEnabled:NO];
}

-(void)getUserLocation{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"PostViewController. locationManager. Failed to get your location");
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

- (void)startRecordingTouched:(id)sender {
   //NSLog (@"startRecordingClicked");
    self.recordLabel.userInteractionEnabled = NO;
    self.postPhoto.hidden = YES;
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(startRecording:) userInfo:nil repeats:NO];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    self.recordingTimeInSecs = [tM.gPostRecordingTimeInSecs intValue];
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    //NSLog(@"Recording started...");
    self.stopTimedTimer = [NSTimer scheduledTimerWithTimeInterval:self.recordingTimeInSecs target:self selector:@selector(stopTimedRecording:) userInfo:nil repeats:NO];
    //NSLog(@"Recording stops in %d seconds...",self.recordingTimeInSecs);
}

- (void)stopRecordingPhotoAudio
{
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(stopRecording:) userInfo:nil repeats:NO];
    //NSLog(@"Recording stops in 2 seconds...");
}

-(void) updateCountdown {
    int minutes, seconds;
    
    self.recordingTimeInSecs--;;
    minutes = (self.recordingTimeInSecs % 3600) / 60;
    seconds = (self.recordingTimeInSecs %3600) % 60;
    self.recordLabel.text = [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}

- (void)startRecording:(id)sender
{
    if (![self startAudioSession])
        return;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    NSError *err = nil;
    self.recorder = [[ AVAudioRecorder alloc] initWithURL:self.createDatedRecordingFile settings:self.recordSettings error:&err];
    if(!self.recorder){
        //NSLog(@"PostViewController could not create recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    [self.recorder prepareToRecord];
    [self.recorder record];
    self.isRecording = YES;
}

- (void)stopRecording:(id)sender
{
    //NSLog(@"Recording about to stop....");
    if (self.isRecording) {
        [self.recorder stop];
        self.currentRecording = self.recorder.url;
        self.isRecording = NO;
        self.recordLabel.text = @"Record";
        self.recordLabel.userInteractionEnabled = YES;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setActive:NO error:&err];
        if(err){
            //NSLog(@"PostViewController error audioSession setActive:NO %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        }
    //NSLog(@"Recording stopped.");
    }

}

- (void)stopTimedRecording:(id)sender
{
    //NSLog(@"TimedRecording about to stop....");
    [self stopRecording:sender];
    [self.startTimer invalidate];
    [self.countdownTimer invalidate];
    [self.stopTimedTimer invalidate];
    //self.postPicture.hidden = NO;
    self.postPhoto.hidden = NO;
}

- (BOOL)startAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        //NSLog(@"PostViewController error audioSession setCategory: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
        //NSLog(@"PostViewController audioSession setActive:YES %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        //NSLog(@"PostViewController audio input hardware not available");
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)recordSettings
{
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:24000.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    return recordSettings;
}

- (NSURL *)createDatedRecordingFile
{
    NSTimeInterval  timeToday = [[NSDate date] timeIntervalSince1970];
    NSNumber *doubletimeToday = [NSNumber numberWithDouble:timeToday];
    self.recorderFileName = [[doubletimeToday stringValue] stringByAppendingString:@".m4a"];
    self.recorderFilePath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"], self.recorderFileName];
    return [NSURL fileURLWithPath:recorderFilePath];
}

- (void)deleteSoundFile:(NSString *)audioFilePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:audioFilePath error:&error];
    if (success) {
        //NSLog(@"Temp recorded sound file removed");
    }
    else
    {
        //NSLog(@"Could not delete temp sound file:%@ ",[error localizedDescription]);
    }
}

@end
