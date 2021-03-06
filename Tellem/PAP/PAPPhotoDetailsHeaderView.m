//
//  PAPPhotoDetailsHeaderView.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPUtility.h"
#import "PAPCache.h"
#import "UIImage+ImageEffects.h"

#define baseHorizontalOffset 2.0f
#define baseWidth 316.0f

#define horiBorderSpacing 6.0f
#define horiMediumSpacing 8.0f

#define vertBorderSpacing 6.0f
#define vertSmallSpacing 2.0f


#define nameHeaderX baseHorizontalOffset
#define nameHeaderY 0.0f
#define nameHeaderWidth baseWidth
#define nameHeaderHeight 46.0f

#define avatarImageX horiBorderSpacing
#define avatarImageY vertBorderSpacing
#define avatarImageDim 35.0f

#define nameLabelX avatarImageX+avatarImageDim+horiMediumSpacing
#define nameLabelY avatarImageY+vertSmallSpacing
#define nameLabelMaxWidth 316.0f - (horiBorderSpacing+avatarImageDim+horiMediumSpacing+horiBorderSpacing)

#define timeLabelX nameLabelX
#define timeLabelMaxWidth nameLabelMaxWidth

#define mainImageX baseHorizontalOffset
#define mainImageY nameHeaderHeight
#define mainImageWidth baseWidth
#define mainImageHeight 316.0f

#define likeBarX baseHorizontalOffset
#define likeBarY nameHeaderHeight + mainImageHeight
#define likeBarWidth baseWidth
#define likeBarHeight 43.0f

#define likeButtonX 9.0f
#define likeButtonY 7.0f
#define likeButtonDim 28.0f

#define likeProfileXBase 46.0f
#define likeProfileXSpace 3.0f
#define likeProfileY 6.0f
#define likeProfileDim 30.0f

#define viewTotalHeight likeBarY+likeBarHeight
#define numLikePics 7.0f

@interface PAPPhotoDetailsHeaderView ()

// View components
@property (nonatomic, strong) UIView *nameHeaderView;
@property (nonatomic, strong) PFImageView *photoImageView;
@property (nonatomic, strong) UIView *likeBarView;
@property (nonatomic, strong) NSMutableArray *currentLikeAvatars;
@property (nonatomic, strong) NSString *audioFilePath;
@property (nonatomic, strong) UIImage *photoInUIImage;

// Redeclare for edit
@property (nonatomic, strong, readwrite) PFUser *photographer;

// Private methods
- (void)createView;

@end


static TTTTimeIntervalFormatter *timeFormatter;

@implementation PAPPhotoDetailsHeaderView

@synthesize photo;
@synthesize photographer;
@synthesize likeUsers;
@synthesize nameHeaderView;
@synthesize photoImageView;
@synthesize likeBarView;
@synthesize likeButton;
@synthesize delegate;
@synthesize currentLikeAvatars,audioFilePath;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.photo = aPhoto;
        self.photographer = [self.photo objectForKey:kPAPPhotoUserKey];
        self.likeUsers = nil;
        
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        self.photo = aPhoto;
        self.photographer = aPhotographer;
        self.likeUsers = theLikeUsers;
        
        self.backgroundColor = [UIColor clearColor];

        if (self.photo && self.photographer && self.likeUsers) {
            [self createView];
        }
    }
    return self;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //[PAPUtility drawSideDropShadowForRect:self.nameHeaderView.frame inContext:UIGraphicsGetCurrentContext()];
    //[PAPUtility drawSideDropShadowForRect:self.photoImageView.frame inContext:UIGraphicsGetCurrentContext()];
    //[PAPUtility drawSideDropShadowForRect:self.likeBarView.frame inContext:UIGraphicsGetCurrentContext()];
}

- (void)homePhotoDetailsWillDisappear{
    if (self.audioFilePath) {
        [self deleteSoundFile:self.audioFilePath];
    }
    if (self.soundPlayer) {
        [self.soundPlayer stop];
    }
    [self stopAudioSession];
}

#pragma mark - PAPPhotoDetailsHeaderView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, viewTotalHeight);
}

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;
    //NSLog (@"aPhoto,%@",aPhoto);
    if (self.photo && self.photographer && self.likeUsers) {
        [self createView];
        [self setNeedsDisplay];
    }
}

- (void)setLikeUsers:(NSMutableArray *)anArray {
    likeUsers = [anArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *liker1, PFUser *liker2) {
        NSString *displayName1 = [liker1 objectForKey:kPAPUserDisplayNameKey];
        NSString *displayName2 = [liker2 objectForKey:kPAPUserDisplayNameKey];
        
        if ([[liker1 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedAscending;
        } else if ([[liker2 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedDescending;
        }
        
        return [displayName1 compare:displayName2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];;
    
    for (PAPProfileImageView *image in currentLikeAvatars) {
        [image removeFromSuperview];
    }

    [likeButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.likeUsers.count] forState:UIControlStateNormal];

    self.currentLikeAvatars = [[NSMutableArray alloc] initWithCapacity:likeUsers.count];
    NSInteger i;
    NSInteger numOfPics = numLikePics > self.likeUsers.count ? self.likeUsers.count : numLikePics;

    for (i = 0; i < numOfPics; i++) {
        PAPProfileImageView *profilePic = [[PAPProfileImageView alloc] init];
        [profilePic setFrame:CGRectMake(likeProfileXBase + i * (likeProfileXSpace + likeProfileDim), likeProfileY, likeProfileDim, likeProfileDim)];
        [profilePic.profileButton addTarget:self action:@selector(didTapLikerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        profilePic.profileButton.tag = i;
        [profilePic setFile:[[self.likeUsers objectAtIndex:i] objectForKey:kPAPUserProfilePicMediumKey]];// kPAPUserProfilePicSmallKey
        [likeBarView addSubview:profilePic];
        [currentLikeAvatars addObject:profilePic];
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeButtonState:(BOOL)selected {
    if (selected) {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( -1.0f, 0.0f, 0.0f, 0.0f)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    } else {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    }
    [likeButton setSelected:selected];
}

- (void)reloadLikeBar {
    self.likeUsers = [[PAPCache sharedCache] likersForPhoto:self.photo];
    [self setLikeButtonState:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:self.photo]];
    [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];    
}


#pragma mark - ()

- (void)createView {    
    /*
     Create middle section of the header view; the image
     */
    self.photoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, mainImageHeight)];
    //self.photoImageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
    //UIImage *bgImage = [[UIImage imageNamed:@"DetailBackground.png"] applyLightEffect];
    //self.photoImageView.backgroundColor= [UIColor colorWithPatternImage:bgImage];
    //self.photoImageView.backgroundColor = [UIColor blackColor];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFFile *imageFile = [self.photo objectForKey:kPAPPhotoPictureKey];

    if (imageFile) {
        self.photoImageView.file = imageFile;
        [self.photoImageView loadInBackground];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoInUIImage = image;
                self.photoImageView.backgroundColor= [UIColor colorWithPatternImage:[image applyLightEffect]];
            }
        }];
    }
    
    UITapGestureRecognizer *photoImageViewTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoImageViewTouched)];
    photoImageViewTouch.numberOfTapsRequired = 1;
    [self.photoImageView setUserInteractionEnabled:YES];
    [self.photoImageView addGestureRecognizer:photoImageViewTouch];

    UITapGestureRecognizer *photoImageViewStopTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoImageViewStopTouched)];
    photoImageViewStopTouch.numberOfTapsRequired = 2;
    [self.photoImageView setUserInteractionEnabled:YES];
    [self.photoImageView addGestureRecognizer:photoImageViewStopTouch];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photoImageViewLongPress:)];
    [self.photoImageView addGestureRecognizer:longPressGesture];

    [self.photoImageView setUserInteractionEnabled:YES];
    [self.photoImageView addGestureRecognizer:photoImageViewStopTouch];
    
    UISwipeGestureRecognizer *photoImageViewSwipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(photoImageViewSwiped:)];
    UISwipeGestureRecognizer *photoImageViewSwipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(photoImageViewSwiped:)];
    
    // Setting the swipe direction.
    [photoImageViewSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [photoImageViewSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [self.photoImageView addGestureRecognizer:photoImageViewSwipeLeft];
    [self.photoImageView addGestureRecognizer:photoImageViewSwipeRight];
    
    [self addSubview:self.photoImageView];
    
    /*
     Create top of header view with name and avatar
     */
    self.nameHeaderView = [[UIView alloc] initWithFrame:CGRectMake(nameHeaderX, nameHeaderY, nameHeaderWidth, nameHeaderHeight)];
    self.nameHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]];
    [self addSubview:self.nameHeaderView];
    
    CALayer *layer = self.nameHeaderView.layer;
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.masksToBounds = NO;
    //layer.shadowRadius = 1.0f;
    ///layer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
    //layer.shadowOpacity = 0.5f;
    //layer.shouldRasterize = YES;
    
    //layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, self.nameHeaderView.frame.size.height - 4.0f, self.nameHeaderView.frame.size.width, 4.0f)].CGPath;

    // Load data for header
    [self.photographer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // Create avatar view
        PAPProfileImageView *avatarImageView = [[PAPProfileImageView alloc] initWithFrame:CGRectMake(avatarImageX, avatarImageY, avatarImageDim, avatarImageDim)];
        
        [avatarImageView setFile:[self.photographer objectForKey:@"profilePictureMedium"]];// set profilepictureKey Directely   @"profilePictureMedium"  kPAPUserProfilePicMediumKey
        [avatarImageView setBackgroundColor:[UIColor clearColor]];
        [avatarImageView setOpaque:NO];
        [avatarImageView.profileButton addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[avatarImageView load:^(UIImage *image, NSError *error) {}];
        [nameHeaderView addSubview:avatarImageView];
        
        // Create name label
        NSString *nameString = [self.photographer objectForKey:kPAPUserDisplayNameKey];
        UIButton *userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nameHeaderView addSubview:userButton];
        [userButton setBackgroundColor:[UIColor clearColor]];
        [[userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [userButton setTitle:nameString forState:UIControlStateNormal];
        [userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [[userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        //[[userButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        //[userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
        [userButton addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // we resize the button to fit the user's name to avoid having a huge touch area
        CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
        CGFloat constrainWidth = self.nameHeaderView.bounds.size.width - (avatarImageView.bounds.origin.x + avatarImageView.bounds.size.width);
        CGSize constrainSize = CGSizeMake(constrainWidth, self.nameHeaderView.bounds.size.height - userButtonPoint.y*2.0f);
        CGSize userButtonSize = [userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                      attributes:@{NSFontAttributeName:userButton.titleLabel.font}
                                                                         context:nil].size;
        
        CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
        [userButton setFrame:userButtonFrame];
        
        // Create time label
        NSString *timeString = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[self.photo createdAt]];
        CGSize timeLabelSize = [timeString boundingRectWithSize:CGSizeMake(nameLabelMaxWidth, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                        context:nil].size;
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, nameLabelY+userButtonSize.height, timeLabelSize.width, timeLabelSize.height)];
        [timeLabel setText:timeString];
        [timeLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [timeLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [timeLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [timeLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameHeaderView addSubview:timeLabel];
        
        [self setNeedsDisplay];
    }];
    
    /*
     Create bottom section fo the header view; the likes
     */
    likeBarView = [[UIView alloc] initWithFrame:CGRectMake(likeBarX, likeBarY, likeBarWidth, likeBarHeight)];
    [likeBarView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
    [self addSubview:likeBarView];
    
    // Create the heart-shaped like button
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeButton setFrame:CGRectMake(likeButtonX, likeButtonY, likeButtonDim, likeButtonDim)];
    [likeButton setBackgroundColor:[UIColor clearColor]];
    [likeButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
    [likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [likeButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
    [likeButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.750f] forState:UIControlStateSelected];
    [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[likeButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[likeButton titleLabel] setMinimumScaleFactor:0.8f];
    [[likeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [likeButton setAdjustsImageWhenDisabled:NO];
    [likeButton setAdjustsImageWhenHighlighted:NO];
    [likeButton setBackgroundImage:[UIImage imageNamed:@"ButtonLike.png"] forState:UIControlStateNormal];
    [likeButton setBackgroundImage:[UIImage imageNamed:@"ButtonLikeSelected.png"] forState:UIControlStateSelected];
    [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [likeBarView addSubview:likeButton];
    
    [self reloadLikeBar];
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)]];
    [separator setFrame:CGRectMake(0.0f, likeBarView.frame.size.height - 2.0f, likeBarView.frame.size.width, 2.0f)];
    [likeBarView addSubview:separator];    
}

- (void)photoImageViewTouched{
    PFFile *backgroundAudio = [self.photo objectForKey:kPAPPhotoPhotoAudioKey];
    [backgroundAudio getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
        if (!error) {
            //NSLog(@"Got the audio");
            //NSLog(@"Audio Size : %lu", (unsigned long)result.length);
            if (![self startAudioSession]) {
                //NSLog(@"AudioSession did not start properly");
                return;
            }

            NSURL *audioUrl = [NSURL URLWithString: backgroundAudio.url];
            //download file and play from disk
            NSData *audioData = [NSData dataWithContentsOfURL:audioUrl];
            NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
            NSString *caldate = [now description];
            self.audioFilePath = [NSString stringWithFormat:@"%@/%@.m4a", docDirPath, caldate];
            
            [audioData writeToFile:audioFilePath atomically:YES];
            
            NSError *error;
            NSURL *fileURL = [NSURL fileURLWithPath:self.audioFilePath];
            self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
            if (self.soundPlayer  == nil) {
                //NSLog(@"AudioPlayer did not load properly: %@", [error description]);
            } else {
                [self.soundPlayer  play];
            }
        }
        else {
            //NSLog(@"Failed to get the audio");
        }
    }];
}

- (void)photoImageViewStopTouched{
    [self.soundPlayer stop];
    [self stopAudioSession];
 }

- (BOOL)startAudioSession
{
    //NSLog(@"PAPPhotoDetailsController startAudioSession started");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:&err];
    if(err){
        //NSLog(@"PAPPhotoDetailsController error audioSession setCategory:AVAudioSessionCategoryAmbient: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }

    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
        //NSLog(@"PAPPhotoDetailsController audioSession setActive:YES %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        //NSLog(@"PAPPhotoDetailsController audio input hardware not available");
        return NO;
    }

    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    err = nil;
    if(err){
        //NSLog(@"PAPPhotoDetailsController audioSession overrideOutputAudioPort %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    return YES;
}

- (BOOL)stopAudioSession
{
    //NSLog(@"PAPPhotoDetailsController playback stopped");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;

    err = nil;
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&err];
    if(err){
        //NSLog(@"PAPPhotoDetailsController audioSession overrideOutputAudioPort %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    err = nil;
    [audioSession setActive:NO error:&err];
    if(err){
        //NSLog(@"PAPPhotoDetailsController audioSession setActive:NO %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    return YES;
}

- (void)deleteSoundFile:(NSString *)audioFilePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:audioFilePath error:&error];
    if (success) {
        //NSLog(@"Temp sound file removed");
    }
    else
    {
        //NSLog(@"Could not delete temp sound file:%@ ",[error localizedDescription]);
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
    BOOL liked = !button.selected;
    [button removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setLikeButtonState:liked];

    NSArray *originalLikeUsersArray = [NSArray arrayWithArray:self.likeUsers];
    NSMutableSet *newLikeUsersSet = [NSMutableSet setWithCapacity:[self.likeUsers count]];
    
    for (PFUser *likeUser in self.likeUsers) {
        // add all current likeUsers BUT currentUser
        if (![[likeUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [newLikeUsersSet addObject:likeUser];
        }
    }
    
    if (liked) {
        [[PAPCache sharedCache] incrementLikerCountForPhoto:self.photo];
        [newLikeUsersSet addObject:[PFUser currentUser]];
    } else {
        [[PAPCache sharedCache] decrementLikerCountForPhoto:self.photo];
    }
    
    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:self.photo liked:liked];

    [self setLikeUsers:[newLikeUsersSet allObjects]];

    if (liked) {
        [PAPUtility likePhotoInBackground:self.photo block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:NO];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:self.photo block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:YES];
            }
        }];
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:self.photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:liked] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
}

- (void)didTapLikerButtonAction:(UIButton *)button {
    PFUser *user = [self.likeUsers objectAtIndex:button.tag];
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate photoDetailsHeaderView:self didTapUserButton:button user:user];
    }    
}

- (void)didTapUserNameButtonAction:(UIButton *)button {
    //if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didTapUserButton:user:)]) {
    //    [delegate photoDetailsHeaderView:self didTapUserButton:button user:self.photographer];
    //}
}

- (void)photoImageViewSwiped:(UISwipeGestureRecognizer *)swipe {
    
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didSwipePhotoImage:photo:)]) {
        [delegate photoDetailsHeaderView:self didSwipePhotoImage:swipe photo:self.photo];
    }
    
}

-(void)photoImageViewLongPress: (id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didLongPress:)]) {
        [delegate photoDetailsHeaderView:self didLongPress:self.photoInUIImage];
    }
}

@end
