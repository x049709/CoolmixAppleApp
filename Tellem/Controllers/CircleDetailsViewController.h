//
//  CircleDetailsViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import "UIImage+ResizeAdditions.h"
#import "AddCirclesViewController.h"
#import "TellemUtility.h"
#import "PAPProfileImageView.h"
#import "CirclePhotoDetailsViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import "User.h"
#import "TellemButton.h"


@interface CircleDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,AddCirclesSendDataProtocol,UIActionSheetDelegate,AddCirclesSendDataProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate>{
    
    UIWebView *webView;
    UIImage *imagePickedFromGalleryOrCamera;

}
@property (strong, nonatomic) IBOutlet UIView *circleView;
@property (strong, nonatomic) IBOutlet UITableView *netWorkTable;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) NSMutableArray *userCircle;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property PFObject *pageCircle;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSArray *circleMemberArray;
@property (nonatomic) NSString *selectFBUserid;
@property (nonatomic) NSString *selectFBUserName;
@property (strong, nonatomic) IBOutlet UIImageView *activityImageView;
@property (strong, nonatomic) IBOutlet UILabel *activityUserId;
@property (strong, nonatomic) IBOutlet UILabel *activityInitialComment;
@property (strong, nonatomic) UIButton *circleAvatar;
@property (strong, nonatomic)  UILabel *memberNameLabel;
@property (nonatomic, strong) UILabel *postTimestampLabel;
@property (nonatomic, strong) UILabel *postLatestCommentsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *circleImage;
@property (strong, nonatomic) IBOutlet UILabel *circleName;
@property (strong, nonatomic) IBOutlet UILabel *circleOwner;
@property (strong, nonatomic) IBOutlet UILabel *circleStatus;
@property (strong, nonatomic) IBOutlet UILabel *circleMemberCount;
@property (strong, nonatomic) IBOutlet UITableView *circleTableView;
@property (strong, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong, nonatomic) IBOutlet UITextView *inputCircleName;
@property NSString *circleOwnerName;


@end
