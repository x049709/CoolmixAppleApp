//
//  CircleTimelineViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import "PAPProfileImageView.h"
#import "CirclePhotoDetailsViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import "DataReceiver.h"

@interface CircleTimelineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,DataReceiver>{
    
    UIWebView *webView;
}
@property (strong, nonatomic) IBOutlet UITableView *netWorkTable;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) NSMutableArray *userCircle;
@property (weak, nonatomic) IBOutlet UITableView *circleTableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property PFObject *pageCircle;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property (nonatomic) NSString *selectFBUserid;
@property (nonatomic) NSString *selectFBUserName;
@property (strong, nonatomic) IBOutlet UIImageView *activityImageView;
@property (strong, nonatomic) IBOutlet UILabel *activityUserId;
@property (strong, nonatomic) IBOutlet UILabel *activityInitialComment;
@property (strong, nonatomic) UIButton *circleAvatar;
@property (strong, nonatomic)  UILabel *posterNameLabel;
@property (nonatomic, strong) UILabel *postTimestampLabel;
@property (nonatomic, strong) UILabel *postLatestCommentsLabel;
@property NSDictionary *pushPayload;
@property (nonatomic) NSArray *sortedCircleActivities;

@end
