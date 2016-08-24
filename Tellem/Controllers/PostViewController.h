//
//  PostViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 05/04/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSTwitterEngine.h"
//#import <AviarySDK/AviarySDK.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+WordAt.h"
#import "PostCirclesViewController.h"
#import "Circle.h"
#import "UIPlaceHolderTextView.h"
#import <AVFoundation/AVFoundation.h>
#import "TellemLabel.h"


@interface PostViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UIScrollViewDelegate,FHSTwitterEngineAccessTokenDelegate,UITableViewDelegate,UITextViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,UIDocumentInteractionControllerDelegate, PostCirclesSendDataProtocol>
{
    NSMutableArray *pastUrls;
    NSMutableArray *savedSearches;
    UITableView *autocompleteTableView;
    UIImage *imagePickedFromGalleryOrCamera;
    CLLocationManager *locationManager;
    NSString *TemporaryString;
    NSRange rangeat;
    int lengthOfString;
}

@property (nonatomic, retain) NSMutableArray *suggestionArray;
@property (nonatomic, retain) UIScrollView *scrollView;
@property(nonatomic,retain)UIDocumentInteractionController *docFile;
@property (weak, nonatomic) IBOutlet UIPlaceholderTextView *commentTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *postScrollView;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (nonatomic, retain) NSMutableArray *pastUrls;
@property (nonatomic, strong) NSMutableArray *autocompleteUrls;
@property (nonatomic, retain) UITableView *autocompleteTableView;
@property (nonatomic, strong) PFObject *circleProfile;
@property (strong, nonatomic) IBOutlet UIImageView *postImg;
@property (weak, nonatomic) IBOutlet UIButton *postPhoto;
@property (nonatomic, strong) NSMutableString *typedText;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *addPicture;
@property (strong, nonatomic) IBOutlet TellemLabel *recordLabel;
@property (strong, nonatomic) IBOutlet UIButton *removePicture;
@property (nonatomic, retain) NSArray *selectedCircleFromPostCircle;
@property (nonatomic, retain) NSArray *sortedCircles;
@property (nonatomic, strong) PFObject *pageCircle;
@property (nonatomic, strong) Circle *selectedCircle;
@property (nonatomic, strong) UIImage *image;
@property (atomic, strong) UIImage *imageToPostToOtherNetworks;
@property NSTimer *startTimer;
@property NSTimer *countdownTimer;
@property NSTimer *stopTimedTimer;
@property NSString *recorderFilePath;

- (IBAction)postPictureBtn_clicked:(id)sender;
- (void)removePictureFromPost:(id)sender;
- (BOOL)isAcceptableTextLength:(NSUInteger)length;
- (BOOL)shouldUploadImage:(UIImage *)anImage;
- (void)stopRecordingPhotoAudio;
- (void)deleteSoundFile:(NSString *)audioFilePath;

@end


