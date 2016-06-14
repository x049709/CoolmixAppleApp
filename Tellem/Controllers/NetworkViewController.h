//
//  NetworkViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//TODO FOR V4#import <FacebookSDK/FBRequest.h>
#import "PAPPhotoTimelineViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "FHSTwitterEngine.h"
#import "UIImage+ImageEffects.h"
#import "AddCirclesViewController.h"
#import "TellemUtility.h"
#import "ContactPerson.h"
@import AddressBook;

@interface NetworkViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FHSTwitterEngineAccessTokenDelegate,UIActionSheetDelegate,
    //FBRequestDelegate, TODO FOR V4
    FBWebDialogsDelegate,UIWebViewDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, AddCirclesSendDataProtocol>{
    
    UIWebView *webView;
}
@property (strong, nonatomic) IBOutlet UITableView *netWorkTable;
@property (strong, nonatomic) IBOutlet UIButton *fbButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *instagramButton;
@property (strong, nonatomic) IBOutlet UIButton *contactsButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) NSMutableArray *userCircle;
@property(strong,nonatomic)UILabel *lable;


- (IBAction)fbButton_clicked:(id)sender;
- (IBAction)twitterButton_clicked:(id)sender;
- (IBAction)instagramButton_clicked:(id)sender;
- (IBAction)contactsButton_clicked:(id)sender;
- (void)updateShareSettings:(NSString*)type value:(NSString*)setting;


@end
