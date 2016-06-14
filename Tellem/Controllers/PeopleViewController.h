//
//  PeopleViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Ed Bayudan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import <FacebookSDK/FBRequest.h>
#import "PAPPhotoTimelineViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "FHSTwitterEngine.h"
#import "UIImage+ImageEffects.h"
#import "AddCirclesViewController.h"
#import "TellemUtility.h"
#import "ContactPerson.h"
#import "DataReceiver.h"
#import "TellemButton.h"
@import AddressBook;

@interface PeopleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FHSTwitterEngineAccessTokenDelegate,UIActionSheetDelegate,
    //FBRequestDelegate, //TODO FOR V4
    FBWebDialogsDelegate,UIWebViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, AddCirclesSendDataProtocol,UISearchBarDelegate,DataReceiver>
{
    UIWebView *webView;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *searchBarLabel;
@property (strong, nonatomic) IBOutlet UIButton *searchCancelButton;
@property (strong, nonatomic) IBOutlet UITableView *netWorkTable;
@property (strong, nonatomic) IBOutlet UIButton *fbButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *instagramButton;
@property (strong, nonatomic) IBOutlet UIButton *contactsButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) NSMutableArray *userCircle;
@property NSArray *userSearchResults;

- (IBAction)searchCancelButton_clicked:(id)sender;

- (IBAction)fbButton_clicked:(id)sender;
- (IBAction)twitterButton_clicked:(id)sender;
- (IBAction)instagramButton_clicked:(id)sender;
- (IBAction)contactsButton_clicked:(id)sender;
- (void)updateShareSettings:(NSString*)type value:(NSString*)setting;


@end
