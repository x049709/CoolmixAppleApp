//
//  NetworkViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 25/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "NetworkViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPUtility.h"
#import "AppDelegate.h"
#import "FHSTwitterEngine.h"
#import "JSON.h"
#import "FHSTwitterEngine.h"
#import "MBProgressHUD.h"
#import <Social/Social.h>
#import "PostSharingViewController.h"
#import "PAPLoadMoreCell.h"
#import "UITableView+DragLoad.h"
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseTwitterUtils/PF_Twitter.h>



@interface NetworkViewController ()
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;

@end

@implementation NetworkViewController
{
    NSString *Insta_Id;
    NSString *Insta_DisplayName;//webView shouldStartLoadWithRequest


    NSString *selectFBUserid;
    NSString *selectFBUserName;
    NSString *selectTwUserid;
    NSString *selectInstagramUserName;
   
    UIButton * cellBtnFB;
    UIButton * cellBtnTW;
    UIButton * cellBtnInst;
    UIButton *inviteBtn;
    
    NSMutableArray *Instagram_User_Details;
    
    NSMutableArray *arr_Friends;
    
    NSMutableArray *tellemFBFriends;
    NSMutableArray *tellemPFUserFBFriends;
    NSMutableArray *AllActivityFBAllData;
    
    NSMutableArray *tellemTWFriends;
    NSMutableArray *AllActivityTW;
    
    NSMutableArray *tellemInstgrmFriends;
    NSMutableArray *AllActivityInstagm;
    NSMutableArray *AllActivityInstagramAllData;
    NSMutableArray *Instagrm;
    NSMutableArray *instagramUserImg;
    
    NSMutableArray *tellemContacts;
    NSMutableArray *allContacts;
    
    UIActionSheet *actionSheetFB;
    UIActionSheet *actionSheetInviteFB;
    UIActionSheet *actionSheetTW;
    UIActionSheet *actionSheetInviteTW;
    UIActionSheet *actionSheetInstagram;
    UIActionSheet *actionSheetInviteInstagram;
    UIActionSheet *actionSheetContacts;
    UIActionSheet *actionSheetInviteContacts;
    
}
@synthesize lable,netWorkTable,twitterButton,fbButton,instagramButton,activityIndicatorView,navItem, userCircle, contactsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title=@"Friends and Followers";
    }
    return self;
}
- (void)viewDidLoad
{
    //MWLogDebug(@"\nNetworkViewController viewDidLoad started.");
    [super viewDidLoad];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    NSString *accountType = [[PFUser currentUser] valueForKey:@"Accounttype"];
    fbButton.selected=YES;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"PEOPLE";
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:tM.gBackgroundImageExtraLight]];
    self.view.frame = CGRectMake(2.0f, 2.0f, self.view.frame.size.width - 4.0f, self.view.frame.size.height);
    
    [twitterButton setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    [twitterButton setImage:[UIImage imageNamed:@"twitter-selected.png"] forState:UIControlStateSelected];
    [twitterButton setImage:[UIImage imageNamed:@"twitter-unselected.png"] forState:UIControlStateNormal];
    
    [instagramButton setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    [instagramButton setImage:[UIImage imageNamed:@"instagram-selected.png"] forState:UIControlStateSelected];
    [instagramButton setImage:[UIImage imageNamed:@"instagram-unselected.png"] forState:UIControlStateNormal];
    
    [fbButton setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    [fbButton setImage:[UIImage imageNamed:@"facebook-selected.png"] forState:UIControlStateSelected];
    [fbButton setImage:[UIImage imageNamed:@"facebook-unselected.png"] forState:UIControlStateNormal];
    
    [contactsButton setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    [contactsButton setImage:[UIImage imageNamed:@"address-selected.png"] forState:UIControlStateSelected];
    [contactsButton setImage:[UIImage imageNamed:@"address-unselected.png"] forState:UIControlStateNormal];
    
    if ([accountType isEqualToString:@"Twitter"])
    {
        netWorkTable.tag=2;
        twitterButton.selected=YES;
        fbButton.selected=NO;
        instagramButton.selected=NO;
        contactsButton.selected=NO;
    }
    if ([accountType isEqualToString:@"Instagram"])
    {
        netWorkTable.tag=3;
        twitterButton.selected=NO;
        fbButton.selected=NO;
        instagramButton.selected=YES;
    }
    if ([accountType isEqualToString:@"Contacts"])
    {
        netWorkTable.tag=4;
        twitterButton.selected=NO;
        fbButton.selected=NO;
        instagramButton.selected=NO;
        contactsButton.selected=YES;
    }
    if ([accountType isEqualToString:@"FB"])
    {
        netWorkTable.tag=1;
        twitterButton.selected=NO;
        fbButton.selected=YES;
        instagramButton.selected=NO;
        [self.view.window addSubview:ApplicationDelegate.hudd];
        [ApplicationDelegate.hudd show:YES];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (netWorkTable.tag==1 && [fbButton isSelected])
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"FB"])
        {
            [self userAllFacebookFriends];
        }
        else if([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Normal"])
        {
            [self userAllFacebookFriends];
        }
        else
        {
            if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:1] isEqualToString:@"1"])
            {
                [self userAllFacebookFriends];
            }
            else
            {
                [ApplicationDelegate.hudd hide:YES];
                [tellemFBFriends removeAllObjects];
                [AllActivityFBAllData removeAllObjects];
                [netWorkTable reloadData];
            }
        }
    }
    else if (netWorkTable.tag==2 && [twitterButton isSelected])
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Twitter"])
        {
            [self tellemTwitterFriends];
            [self UserAllTwitterFriends];
        }
        else{
            if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:0] isEqualToString:@"1"])
            {
                [self tellemTwitterFriends];
                [self UserAllTwitterFriends];
            }
            else
            {
                [tellemTWFriends removeAllObjects];
                [AllActivityTW removeAllObjects];
                [netWorkTable reloadData];
            }
        }
    }
    else if (netWorkTable.tag==3 && [instagramButton isSelected])
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Instagram"])
        {
            [self tellemInstagramFriends];
            [self userAllInstagramFriends];
        }
        else{
            if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:2] isEqualToString:@"1"])
            {
                [self tellemInstagramFriends];
                [self userAllInstagramFriends];
            }
            else
            {
                [tellemInstgrmFriends removeAllObjects];
                [AllActivityInstagramAllData removeAllObjects];
                [netWorkTable reloadData];
            }
        }
    }
    else if (netWorkTable.tag==4 && [contactsButton isSelected])
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Contacts"])
        {
            [self userAllContacts];
        }
        else
        {
            if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:3] isEqualToString:@"1"])
            {
                [self userAllContacts];
            }
            else
            {
                [ApplicationDelegate.hudd hide:YES];
                [allContacts removeAllObjects];
                [netWorkTable reloadData];
            }
        }
    }

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

#pragma mark Get tellemFriends And allFriends Methods

-(void)userAllFacebookFriends{
    
//TODO FOR V4.0
//    PFUser *user = [PFUser currentUser];
//    if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"FB"])
//    {
//        //Logged in user is FB, get all FB friends
//        //ApplicationDelegate.session=[PFFacebookUtils session];
//        //[FBSession setActiveSession:[PFFacebookUtils session]];
//        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,NSDictionary* result, NSError *error)
//         {
//             if (!error) {
//                 [self updateShareSettings:@"FB" value:@"1"];
//                 NSMutableArray *allFBFriends = [result objectForKey:@"data"];
//                 NSMutableArray *fbFriends=[[NSMutableArray alloc]init];
//                 NSMutableArray *fbFriendsInTellem=[[NSMutableArray alloc]init];
//                 PFQuery *query = [PFUser query];
//                 [query whereKey:@"username" containedIn:[allFBFriends valueForKey:@"id"]];
//                 [query orderByAscending:@"displayName"];
//                 NSArray *fbObjects = [query findObjects];
//                 tellemPFUserFBFriends = [(NSArray*)fbObjects mutableCopy];
//                 tellemFBFriends=[(NSArray*)fbObjects mutableCopy];
//                 for (int i=0; i<allFBFriends.count; i++) {
//                     if (![[fbObjects valueForKey:@"username"] containsObject:[allFBFriends[i] valueForKey:@"id"]]) {
//                         [fbFriends addObject:allFBFriends[i]];
//                     } else {
//                         [fbFriendsInTellem addObject:allFBFriends[i]];
//                     }
//                 }
//                 AllActivityFBAllData = [self sortMutableArray:fbFriends withKey:@"name"];
//                 
//                 if (AllActivityFBAllData.count==0 && tellemFBFriends.count==0) {
//                     [ApplicationDelegate.hudd hide:YES];
//                 }
//                 else {
//                     [ApplicationDelegate.hudd hide:YES];
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         [netWorkTable reloadData];
//                     });
//                 }
//             }
//             else {
//                 //Error connecting to FB
//                 //Change FB setting to 0 with alert
//                 [tellemFBFriends removeAllObjects];
//                 [tellemPFUserFBFriends removeAllObjects];
//                 [AllActivityFBAllData removeAllObjects];
//                 [self updateShareSettings:@"FB" value:@"0"];
//                 [ApplicationDelegate.hudd hide:YES];
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Facebook" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                     [alert show];
//                     [netWorkTable reloadData];
//                 });
//             }
//         }];
//    }
//    else
//    {
//        //Logged in user is not FB, but View FB friends is ON, get all FB friends
//        PFUser *currentUser = [PFUser currentUser];
//        if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:1] isEqualToString:@"1"])
//        {
//            if([[FBSession activeSession]isOpen])
//            {
//                ApplicationDelegate.session=[FBSession activeSession];
//                [FBSession setActiveSession:[FBSession activeSession]];
//                FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//                [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary* result, NSError *error)
//                 {
//                     if (!error) {
//                         [self updateShareSettings:@"FB" value:@"1"];
//                         NSMutableArray *allFBFriends = [result objectForKey:@"data"];
//                         NSMutableArray *fbFriends=[[NSMutableArray alloc]init];
//                         NSMutableArray *fbFriendsInTellem=[[NSMutableArray alloc]init];
//                         PFQuery *query = [PFUser query];
//                         [query whereKey:@"username" containedIn:[allFBFriends valueForKey:@"id"]];
//                         [query orderByAscending:@"displayName"];
//                         NSArray *fbObjects = [query findObjects];
//                         tellemPFUserFBFriends = [(NSArray*)fbObjects mutableCopy];
//                         tellemFBFriends=[(NSArray*)fbObjects mutableCopy];
//                         for (int i=0; i<allFBFriends.count; i++) {
//                             if (![[fbObjects valueForKey:@"username"] containsObject:[allFBFriends[i] valueForKey:@"id"]]) {
//                                 [fbFriends addObject:allFBFriends[i]];
//                             } else {
//                                 [fbFriendsInTellem addObject:allFBFriends[i]];
//                             }
//                         }
//                         AllActivityFBAllData = [self sortMutableArray:fbFriends withKey:@"name"];
//                         
//                         if (AllActivityFBAllData.count==0 && tellemFBFriends.count==0) {
//                             [ApplicationDelegate.hudd hide:YES];
//                         }
//                         else {
//                             [ApplicationDelegate.hudd hide:YES];
//                             dispatch_async(dispatch_get_main_queue(), ^{
//                                 [netWorkTable reloadData];
//                             });
//                         }
//                     }
//                     else {
//                         //Error connecting to FB
//                         //Change FB setting to 0 with alert
//                         [tellemFBFriends removeAllObjects];
//                         [tellemPFUserFBFriends removeAllObjects];
//                         [AllActivityFBAllData removeAllObjects];
//                         [self updateShareSettings:@"FB" value:@"0"];
//                         [ApplicationDelegate.hudd hide:YES];
//                         dispatch_async(dispatch_get_main_queue(), ^{
//                             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Facebook" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                             [alert show];
//                             [netWorkTable reloadData];
//                         });
//
//                     }
//                 }];
//            }
//            else
//            {
//                [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
//                 {
//                     ApplicationDelegate.session=[FBSession activeSession];
//                     [FBSession setActiveSession:[FBSession activeSession]];
//                     FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//                     [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary* result, NSError *error)
//                      {
//                          if (!error) {
//                              [self updateShareSettings:@"FB" value:@"1"];
//                              NSMutableArray *allFBFriends = [result objectForKey:@"data"];
//                              NSMutableArray *fbFriends=[[NSMutableArray alloc]init];
//                              NSMutableArray *fbFriendsInTellem=[[NSMutableArray alloc]init];
//                              PFQuery *query = [PFUser query];
//                              [query whereKey:@"username" containedIn:[allFBFriends valueForKey:@"id"]];
//                              [query orderByAscending:@"displayName"];
//                              NSArray *fbObjects = [query findObjects];
//                              tellemPFUserFBFriends = [(NSArray*)fbObjects mutableCopy];
//                              tellemFBFriends=[(NSArray*)fbObjects mutableCopy];
//                              for (int i=0; i<allFBFriends.count; i++) {
//                                  if (![[fbObjects valueForKey:@"username"] containsObject:[allFBFriends[i] valueForKey:@"id"]]) {
//                                      [fbFriends addObject:allFBFriends[i]];
//                                  } else {
//                                      [fbFriendsInTellem addObject:allFBFriends[i]];
//                                  }
//                              }
//                              AllActivityFBAllData = [self sortMutableArray:fbFriends withKey:@"name"];
//                              
//                              if (AllActivityFBAllData.count==0 && tellemFBFriends.count==0) {
//                                  [ApplicationDelegate.hudd hide:YES];
//                              }
//                              else {
//                                  [ApplicationDelegate.hudd hide:YES];
//                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                      [netWorkTable reloadData];
//                                  });
//                              }
//                          }
//                          else {
//                              //Path appears to get called only on logout - comment out the alert!
//                              //[self updateShareSettings:@"FB" value:@"0"];
//                              //UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tapzzzzz settings to connect to Facebook" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                              //[alert show];
//                              [tellemFBFriends removeAllObjects];
//                              [tellemPFUserFBFriends removeAllObjects];
//                              [AllActivityFBAllData removeAllObjects];
//                              [ApplicationDelegate.hudd hide:YES];
//                              dispatch_async(dispatch_get_main_queue(), ^{
//                                  [netWorkTable reloadData];
//                              });
//                          }
//                     }];
//                }];
//            }
//         }
//        else
//        {
//            //Logged in user is not FB, but View FB friends is not ON, alert user to connect to FB
//            [tellemFBFriends removeAllObjects];
//            [tellemPFUserFBFriends removeAllObjects];
//            [AllActivityFBAllData removeAllObjects];
//            [ApplicationDelegate.hudd hide:YES];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Facebook" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                [alert show];
//                [netWorkTable reloadData];
//            });
//        }
//    }
}

-(void)tellemTwitterFriends{
    
    if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Twitter"])
    {
        [PFTwitterUtils initializeWithConsumerKey:kTwitterClientID consumerSecret:kTwitterClientSecret];
        [FHSTwitterEngine sharedEngine].delegate=self;
        [[FHSTwitterEngine sharedEngine]loadAccessToken];
        
        //Tellem TwitterFriends
        NSArray *results=[[FHSTwitterEngine sharedEngine]getFriendsIDs];
        NSArray *friendIds_tw =[(NSDictionary *)results objectForKey:@"ids"];
        NSMutableArray *Arr_tempids=[[NSMutableArray alloc]init];
        PFQuery *query = [PFUser query];
        
        for (int x=0; x<friendIds_tw.count; x++)
        {
            [Arr_tempids addObject:[NSString stringWithFormat:@"%d",[[friendIds_tw objectAtIndex:x] intValue]]];
        }
        [query whereKey:@"username" containedIn:Arr_tempids];
        NSArray *twfriend = [query findObjects];
        tellemTWFriends=[[NSMutableArray alloc]initWithArray:twfriend];
        [self sortTwitterFriends];
        [ApplicationDelegate.hudd hide:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [netWorkTable reloadData];
        });
    }
    else
    {
        PFUser *currentUser = [PFUser currentUser];
        if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:0] isEqualToString:@"1"])
        {
            [PFTwitterUtils initializeWithConsumerKey:kTwitterClientID consumerSecret:kTwitterClientSecret];
            [FHSTwitterEngine sharedEngine].delegate=self;
            [[FHSTwitterEngine sharedEngine]loadAccessToken];
            //Tellem TwitterFriends
            NSArray *results=[[FHSTwitterEngine sharedEngine]getFriendsIDs];
            NSArray *friendIds_tw =[(NSDictionary *)results objectForKey:@"ids"];
            NSMutableArray *Arr_tempids=[[NSMutableArray alloc]init];
            PFQuery *query = [PFUser query];
            
            for (int x=0; x<friendIds_tw.count; x++)
            {
                [Arr_tempids addObject:[NSString stringWithFormat:@"%d",[[friendIds_tw objectAtIndex:x] intValue]]];
            }
            [query whereKey:@"username" containedIn:Arr_tempids];
            NSArray *twfriend = [query findObjects];
            tellemTWFriends=[(NSArray*)twfriend mutableCopy];
            [self sortTwitterFriends];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [netWorkTable reloadData];
            });
        }
        else
        {
            [tellemTWFriends removeAllObjects];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [netWorkTable reloadData];
            });
        }
    }
}
-(void)UserAllTwitterFriends{
    
    if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Twitter"])
    {
        [PFTwitterUtils initializeWithConsumerKey:kTwitterClientID consumerSecret:kTwitterClientSecret];
        [FHSTwitterEngine sharedEngine].delegate=self;
        [[FHSTwitterEngine sharedEngine]loadAccessToken];
        if ([FHSTwitterEngine sharedEngine].authenticatedID == nil) {
            [AllActivityTW removeAllObjects];
            [self updateShareSettings:@"Twitter" value:@"0"];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Twitter" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [netWorkTable reloadData];
            });
        }
        else
        {
            //Get all Twitter followings
            arr_Friends=[[FHSTwitterEngine sharedEngine]listFriendsForUser:[FHSTwitterEngine sharedEngine].authenticatedID isID:YES withCursor:@"-1"];
            AllActivityTW= [(NSDictionary *)arr_Friends objectForKey:@"users"];
            NSMutableArray *friendsTW=[[NSMutableArray alloc]init];
            for (int i=0; i<AllActivityTW.count; i++)
            {
                if (![[tellemTWFriends valueForKey:@"username"] containsObject:[AllActivityTW[i] valueForKey:@"id_str"]])
                {
                    [friendsTW addObject:AllActivityTW[i]];
                }
            }
            [self updateShareSettings:@"Twitter" value:@"1"];
            AllActivityTW = [self sortMutableArray:friendsTW withKey:@"name"];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [netWorkTable reloadData];
            });
        }
    }
    else
    {
        PFUser *currentUser = [PFUser currentUser];
        if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:0] isEqualToString:@"1"])
        {
            [PFTwitterUtils initializeWithConsumerKey:kTwitterClientID consumerSecret:kTwitterClientSecret];
            [FHSTwitterEngine sharedEngine].delegate=self;
            [[FHSTwitterEngine sharedEngine]loadAccessToken];

            if ([FHSTwitterEngine sharedEngine].authenticatedID == nil) {
                [AllActivityTW removeAllObjects];
                [self updateShareSettings:@"Twitter" value:@"0"];
                 [ApplicationDelegate.hudd hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Twitter" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    [netWorkTable reloadData];
                });
            }
            else {
                //User All TwitterFriends
                arr_Friends=[[FHSTwitterEngine sharedEngine]listFriendsForUser:[FHSTwitterEngine sharedEngine].authenticatedID isID:YES withCursor:@"-1"];
                AllActivityTW= [(NSDictionary *)arr_Friends objectForKey:@"users"];
                NSMutableArray *friendsTW=[[NSMutableArray alloc]init];
                for (int i=0; i<AllActivityTW.count; i++)
                {
                    if (![[tellemTWFriends valueForKey:@"username"] containsObject:[AllActivityTW[i] valueForKey:@"id_str"]])
                    {
                        [friendsTW addObject:AllActivityTW[i]];
                    }
                }
                [self updateShareSettings:@"Twitter" value:@"1"];
                AllActivityTW = [self sortMutableArray:friendsTW withKey:@"name"];
                [ApplicationDelegate.hudd hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [netWorkTable reloadData];
                });
            }
        }else
        {
            [AllActivityTW removeAllObjects];
            [self updateShareSettings:@"Twitter" value:@"0"];
             [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Twitter" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [netWorkTable reloadData];
            });
        }
    }
}

- (NSString *)loadAccessToken
{
    if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Twitter"])
    {
        NSString *str=[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@&user_id=%@&screen_name=%@",[PFTwitterUtils twitter].authToken,[PFTwitterUtils twitter].authTokenSecret,[PFTwitterUtils twitter].userId,[PFTwitterUtils twitter].screenName];
        return str;
    }
    else
    {
         return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
    }
   
}
-(void)tellemInstagramFriends{
    
    if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Instagram"])
    {
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@",str_Accesstoken]]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
        NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
        Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        Instagrm=[Response JSONValue];
        NSArray *instgram_arr=[[Instagrm valueForKey:@"data"]valueForKey:@"id"];
        NSMutableArray *Arr_tempids=[[NSMutableArray alloc]init];
        PFQuery *query = [PFUser query];
        
        for (int x=0; x<instgram_arr.count; x++) {
            
            [Arr_tempids addObject:[NSString stringWithFormat:@"%d",[[instgram_arr objectAtIndex:x] intValue]]];
        }
        [query whereKey:@"username" containedIn:Arr_tempids];
        NSArray *instgrmfriend = [query findObjects];
        tellemInstgrmFriends=[(NSArray*)instgrmfriend mutableCopy];
        [self sortInstagramFriends];
        [ApplicationDelegate.hudd hide:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [netWorkTable reloadData];
        });
    }
    else
    {
        PFUser *currentUser = [PFUser currentUser];
        if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:2] isEqualToString:@"1"])
        {
            Ins_ShareAccesstoken=[[NSUserDefaults standardUserDefaults]objectForKey:@"ShareInstaGramToken"];
            NSMutableURLRequest *request =
            [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@",Ins_ShareAccesstoken]]
                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                timeoutInterval:10];
            [request setHTTPMethod:@"GET"];
            
            NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
            NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
            Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            Instagrm=[Response JSONValue];
            NSArray *instgram_arr=[[Instagrm valueForKey:@"data"]valueForKey:@"id"];
            NSMutableArray *Arr_tempids=[[NSMutableArray alloc]init];
            if (instgram_arr == nil) {
                [tellemInstgrmFriends removeAllObjects];
                 [ApplicationDelegate.hudd hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [netWorkTable reloadData];
                });
            }
            else {
                PFQuery *query = [PFUser query];
                for (int x=0; x<instgram_arr.count; x++) {
                    [Arr_tempids addObject:[NSString stringWithFormat:@"%d",[[instgram_arr objectAtIndex:x] intValue]]];
                }
                [query whereKey:@"username" containedIn:Arr_tempids];
                NSArray *instgrmfriend = [query findObjects];
                tellemInstgrmFriends=[(NSArray*)instgrmfriend mutableCopy];
                [self sortInstagramFriends];
                [ApplicationDelegate.hudd hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [netWorkTable reloadData];
                });
            }
        }
        else {
            [tellemInstgrmFriends removeAllObjects];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [netWorkTable reloadData];
            });
        }
    }
}

-(void)userAllInstagramFriends{
    
    if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Instagram"])
    {
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@",str_Accesstoken]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
    
        NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
        NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
        Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableArray *tAllActivityInstagramAllData=[[Response JSONValue] valueForKey:@"data"];
        if (tAllActivityInstagramAllData == nil) {
            [AllActivityInstagramAllData removeAllObjects];
            [self updateShareSettings:@"Instagram" value:@"0"];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Instagram" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [netWorkTable reloadData];
            });
        }
        else {
            [self updateShareSettings:@"Instagram" value:@"1"];
            AllActivityInstagramAllData = [self sortMutableArray:tAllActivityInstagramAllData  withKey:@"full_name"];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [netWorkTable reloadData];
            });
        }
    }
    else{
        PFUser *currentUser = [PFUser currentUser];
        if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:2] isEqualToString:@"1"])
        {
            Ins_ShareAccesstoken=[[NSUserDefaults standardUserDefaults]objectForKey:@"ShareInstaGramToken"];
            NSMutableURLRequest *request =
            [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@",Ins_ShareAccesstoken]]
                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                timeoutInterval:10];
            [request setHTTPMethod:@"GET"];
            
            NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
            NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
            Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSMutableArray *tAllActivityInstagramAllData=[[Response JSONValue] valueForKey:@"data"];
            if (tAllActivityInstagramAllData == nil) {
                [AllActivityInstagramAllData removeAllObjects];
                [self updateShareSettings:@"Instagram" value:@"0"];
                [ApplicationDelegate.hudd hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Instagram" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    [netWorkTable reloadData];
                });
            }
            else {
                [self updateShareSettings:@"Instagram" value:@"1"];
                AllActivityInstagramAllData = [self sortMutableArray:tAllActivityInstagramAllData  withKey:@"full_name"];
                [ApplicationDelegate.hudd hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [netWorkTable reloadData];
                });
            }
        }
        else{
            [AllActivityInstagramAllData removeAllObjects];
            [self updateShareSettings:@"Instagram" value:@"0"];
            [ApplicationDelegate.hudd hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tap settings to connect to Instagram" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [netWorkTable reloadData];
            });
        }
    }
}


-(void) userAllContacts {
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusDenied || status == kABAuthorizationStatusRestricted) {
        [[[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Tellem needs access to your contacts so you can invite them to join your social circles." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (!addressBook) {
        //NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (error) {
            //NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
        }
        if (granted) {
            [self updateShareSettings:@"Contacts" value:@"1"];
            allContacts = [self listPeopleInAddressBook:addressBook];
            dispatch_async(dispatch_get_main_queue(), ^{
                [netWorkTable reloadData];
            });
        } else {
            //Error connecting to Contacts
            //Change Contacts setting to 0 with alert
            [allContacts removeAllObjects];
            [self updateShareSettings:@"Contacts" value:@"0"];
            [[[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Tellem requires access to your contacts so you can invite them to join your social circles." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [netWorkTable reloadData];
            [ApplicationDelegate.hudd hide:YES];
        }
        CFRelease(addressBook);
    });
    [ApplicationDelegate.hudd hide:YES];
    

}

- (NSMutableArray*)listPeopleInAddressBook:(ABAddressBookRef)addressBook
{
    NSMutableArray *contactPeople =[NSMutableArray array];
    NSMutableArray *listOfContacts =[NSMutableArray array];
    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSInteger numberOfPeople = [allPeople count];
    
    for (NSInteger i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        NSString *firstName, *lastName, *fullName, *trimmedFullName;
        if (CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty))) {
            firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        }
        if ([firstName length] == 0) {
            firstName = @" ";
        }
        
        if (CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty))) {
            lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        }
        if ([lastName length] == 0) {
            lastName = @" ";
        }
        
        fullName = [firstName stringByAppendingString:@" "];
        fullName = [fullName stringByAppendingString:lastName];
        trimmedFullName = [fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        NSMutableArray *listOfPhones =[NSMutableArray array];
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            NSString *phoneNumber, *phoneLabel;
            if (CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i))) {
                phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            }
            if (CFBridgingRelease(ABMultiValueCopyLabelAtIndex(phoneNumbers, i))) {
                phoneLabel = CFBridgingRelease(ABMultiValueCopyLabelAtIndex(phoneNumbers, i));
            }
            if ([phoneNumber length] == 0) {
                phoneNumber = @" ";
            }
            if ([phoneLabel length] == 0) {
                phoneLabel = @" ";
            }
            [listOfPhones addObject:@[phoneLabel, phoneNumber]];
        }
        CFRelease(phoneNumbers);
        
        ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
        CFIndex numberOfEmails = ABMultiValueGetCount(emailAddresses);
        NSMutableArray *listOfEmails =[NSMutableArray array];
        for (CFIndex i = 0; i < numberOfEmails; i++) {
            NSString *emailAddress;
            if (CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailAddresses, i))) {
                emailAddress = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailAddresses, i));
            }
            if ([emailAddress length] == 0) {
                emailAddress = @" ";
            }
            [listOfEmails addObject:emailAddress];
        }
        CFRelease(emailAddresses);
        
        ContactPerson *contactPerson = [ContactPerson personWithFirstName:firstName andLastName:lastName andPhoneNumbers:listOfPhones andEmails:listOfEmails];
        NSDictionary *contactDict = [[NSDictionary alloc] initWithObjectsAndKeys:contactPerson,@"contactPerson",trimmedFullName,@"fullName",nil];
        [listOfContacts addObject:contactDict];
    }
    
    for (int i = 0; i < listOfContacts.count; i++) {
        ContactPerson* cPerson = [[ContactPerson alloc] init];
        cPerson = [listOfContacts[i] valueForKey:@"contactPerson"];
        NSString *fullName  = [listOfContacts[i] valueForKey:@"fullName"];
        if ([fullName length] > 0) {
            if (cPerson.emailAddresses.count == 0 && cPerson.phoneNumbers.count == 0) {}
            else
                [contactPeople addObject:listOfContacts[i]];
        }
    }
    
    return [self sortMutableArray:contactPeople  withKey:@"fullName"];
}

-(void)updateShareSettings:(NSString*)type value:(NSString*)setting
{
    NSMutableArray *shareSettings=[[NSMutableArray alloc]initWithCapacity:4];
    PFUser *currentUser = [PFUser currentUser];
    if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:0] isEqualToString:@"1"])
        [shareSettings setObject:@"1" atIndexedSubscript:0];
    else
        [shareSettings setObject:@"0" atIndexedSubscript:0];

    if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:1] isEqualToString:@"1"])
        [shareSettings setObject:@"1" atIndexedSubscript:1];
    else
        [shareSettings setObject:@"0" atIndexedSubscript:1];

    if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:2] isEqualToString:@"1"])
        [shareSettings setObject:@"1" atIndexedSubscript:2];
    else
        [shareSettings setObject:@"0" atIndexedSubscript:2];
    
    if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:3] isEqualToString:@"1"])
        [shareSettings setObject:@"1" atIndexedSubscript:3];
    else
        [shareSettings setObject:@"0" atIndexedSubscript:3];

    
    if ([type isEqualToString:@"Twitter"])
        [shareSettings setObject:setting atIndexedSubscript:0];
    else if ([type isEqualToString:@"FB"])
        [shareSettings setObject:setting atIndexedSubscript:1];
    else if ([type isEqualToString:@"Instagram"])
        [shareSettings setObject:setting atIndexedSubscript:2];
    else //@"Contacts"
        [shareSettings setObject:setting atIndexedSubscript:3];
    
    //NSLog(@"NetworkViewController updateShareSettings shareSettings  %@ ",shareSettings);
    [[PFUser currentUser] setObject:shareSettings forKey:@"ViewFriends"];
    //[[PFUser currentUser] save];
}

#pragma mark viewForHeaderInSection

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    //NSLog(@"NetworkViewController viewForHeaderInSection tellemFBFriends: %@",tellemFBFriends);
    //NSLog(@"NetworkViewController viewForHeaderInSection AllActivityFBAllData: %@",AllActivityFBAllData);
    UIView* View = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 50.0)];
    if (netWorkTable.tag==1)
    {
        if (section==0)
        {
            NSString *tellemCount = [NSString stringWithFormat:@"%d", tellemFBFriends.count];
            NSString *sectionTitle = [[@"Friends in Tellem (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            
            cellBtnFB=[[UIButton alloc]initWithFrame:CGRectMake(200, 18, 120, 25)];
            [cellBtnFB setTitle:@"Add to Tellem" forState:UIControlStateNormal];
            [cellBtnFB setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [cellBtnFB addTarget:self action:@selector(inviteFriendsToInstallTellem) forControlEvents:UIControlEventTouchUpInside];
            //[View addSubview:cellBtnFB];
            // Create header view and add label as a subview
            [View addSubview:label];
        }
        else{
            NSString *tellemCount = [NSString stringWithFormat:@"%d", AllActivityFBAllData.count];
            NSString *sectionTitle = [[@"Friends (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            // Create header view and add label as a subview
            [View addSubview:label];
        }
    }
    else if (netWorkTable.tag==2)
    {
        if (section==0)
        {
            NSString *tellemCount = [NSString stringWithFormat:@"%d", tellemTWFriends.count];
            NSString *sectionTitle = [[@"Following in Tellem (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            
            cellBtnTW=[[UIButton alloc]initWithFrame:CGRectMake(200, 18, 120, 25)];
            [cellBtnTW setTitle:@"Add to Tellem" forState:UIControlStateNormal];
            [cellBtnTW setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

            [cellBtnTW addTarget:self action:@selector(inviteFriendsToInstallTellem) forControlEvents:UIControlEventTouchUpInside];
            //[View addSubview:cellBtnTW];
            // Create header view and add label as a subview
            [View addSubview:label];
            
            // Create header view and add label as a subview
            [View addSubview:label];
        }
        else{
            NSString *tellemCount = [NSString stringWithFormat:@"%d", AllActivityTW.count];
            NSString *sectionTitle = [[@"Following (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            // Create header view and add label as a subview
            [View addSubview:label];
        }
    }
    else if (netWorkTable.tag==3)
    {
        if (section==0)
        {
            NSString *tellemCount = [NSString stringWithFormat:@"%d", tellemInstgrmFriends.count];
            NSString *sectionTitle = [[@"Following in Tellem (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            
            cellBtnInst=[[UIButton alloc]initWithFrame:CGRectMake(200, 18, 120, 25)];
            [cellBtnInst setTitle:@"Add to Tellem" forState:UIControlStateNormal];
            [cellBtnInst setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [cellBtnInst addTarget:self action:@selector(inviteFriendsToInstallTellem) forControlEvents:UIControlEventTouchUpInside];
            // Create header view and add label as a subview
            [View addSubview:label];
        }
        else{
            NSString *tellemCount = [NSString stringWithFormat:@"%d", AllActivityInstagramAllData.count];
            NSString *sectionTitle = [[@"Following (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            // Create header view and add label as a subview
            [View addSubview:label];
        }
    }
    else if (netWorkTable.tag==4)
    {
        if (section==0)
        {
            NSString *tellemCount = [NSString stringWithFormat:@"%d", tellemContacts.count];
            NSString *sectionTitle = [[@"Contacts in Tellem (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            
            cellBtnFB=[[UIButton alloc]initWithFrame:CGRectMake(200, 18, 120, 25)];
            [cellBtnFB setTitle:@"Add to Tellem" forState:UIControlStateNormal];
            [cellBtnFB setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [cellBtnFB addTarget:self action:@selector(inviteFriendsToInstallTellem) forControlEvents:UIControlEventTouchUpInside];
            //[View addSubview:cellBtnFB];
            // Create header view and add label as a subview
            [View addSubview:label];
        }
        else{
            NSString *tellemCount = [NSString stringWithFormat:@"%d", allContacts.count];
            NSString *sectionTitle = [[@"Contacts (" stringByAppendingString:tellemCount] stringByAppendingString:@")"];
            // Create label with section title
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(16, 5, 284, 23);
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:kFontNormal size:17];
            label.text = sectionTitle;
            label.backgroundColor = [UIColor clearColor];
            // Create header view and add label as a subview
            [View addSubview:label];
        }
    }

    return View;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

#pragma mark UItableView DataSource Delegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (netWorkTable.tag==1)
    {
        if (section==0)
        {
            if (tellemFBFriends.count==0)
            {
                return 1;
            }
            else{
                
                return tellemFBFriends.count;
            }
            
        }
        else
        {
            if (AllActivityFBAllData.count==0)
            {
                return 1;
            }
            else
            {
                return AllActivityFBAllData .count;
            }
        }
    }
    else if (netWorkTable.tag==2)
    {
        if (section==0)
        {
            if (tellemTWFriends.count==0)
            {
                return 1;
            }
            else
            {
                return tellemTWFriends.count;
                
            }
        }
        else
        {
            if (AllActivityTW.count==0)
            {
                return 1;
            }
            else
            {
                return AllActivityTW.count;
            }
        }
    }
    else if (netWorkTable.tag==3)
    {
        if (section==0)
        {
            if (tellemInstgrmFriends.count==0)
            {
                return 1;
            }else
            {
                return tellemInstgrmFriends.count;
                
            }
        }
        else
        {
            if (AllActivityInstagramAllData.count==0)
            {
                return 1;
            }
            else
            {
                return AllActivityInstagramAllData.count;
            }
        }
    }
    else if (netWorkTable.tag==4)
    {
        if (section==0)
        {
            if (tellemContacts.count==0)
            {
                return 1;
            }
            else{
                
                return tellemContacts.count;
            }
            
        }
        else
        {
            if (allContacts.count==0)
            {
                return 1;
            }
            else
            {
                return allContacts .count+1;
            }
        }
    }
else
    {
        return 0;
    }
}
- (void)finishRefresh
{
    [netWorkTable finishRefresh];
    [netWorkTable reloadData];
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
    cell.textLabel.font = [UIFont fontWithName:kFontThin size:14];
    if (netWorkTable.tag==1)
    {
        if (indexPath.section==0)
        {
            if (tellemFBFriends.count==0)
            {
                cell.textLabel.text=@"None";
            }
            else
            {
                UILabel *nameLbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 150, 40)];
                nameLbl.font = [UIFont fontWithName:kFontThin size:14];
                nameLbl.text=[[tellemFBFriends objectAtIndex:indexPath.row]valueForKey:@"displayName"];
                [cell addSubview:nameLbl];
                //TODO FOR V4
                //FBProfilePictureView *profilePictureView=[[FBProfilePictureView alloc]initWithFrame:CGRectMake(2,2, 46, 46)];
                //profilePictureView.profileID=[[tellemFBFriends objectAtIndex:indexPath.row]valueForKey:@"username"];
                //[cell addSubview:profilePictureView];
            }
        }
        else
        {
            if (AllActivityFBAllData.count==0)
            {
                cell.textLabel.text=@"None";
            }
            else
            {
                UILabel *nameLbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 40)];
                nameLbl.font = [UIFont fontWithName:kFontThin size:14];
                nameLbl.text=[[AllActivityFBAllData objectAtIndex:indexPath.row]valueForKey:@"name"];
                [cell addSubview:nameLbl];
                
                UIButton *inviteButton=[[UIButton alloc]initWithFrame:CGRectMake(240, 8, 60, 25)];
                [inviteButton setBackgroundImage:[UIImage imageNamed:@"invite.png"] forState:UIControlStateNormal];
                inviteButton.titleLabel.font = [UIFont fontWithName:kFontNormal size:14];
                [inviteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [inviteButton addTarget:self action:@selector(clickedInviteFB:) forControlEvents:UIControlEventTouchUpInside];
                inviteButton.tag=indexPath.row;
                [cell addSubview:inviteButton];
                //TODO FOR V4
                //FBProfilePictureView *profilePictureView=[[FBProfilePictureView alloc]initWithFrame:CGRectMake(2,2, 46, 46)];
                //profilePictureView.profileID=[[AllActivityFBAllData objectAtIndex:indexPath.row]valueForKey:@"username"];
                //[cell addSubview:profilePictureView];
            }
        }
    }
    else if (netWorkTable.tag==2)
    {
        
        if (indexPath.section==0)
        {
            if (tellemTWFriends.count==0)
            {
                cell.textLabel.text=@"None";
            }
            else
            {
                UILabel *nameLblTW=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 40)];
                nameLblTW.font = [UIFont fontWithName:kFontThin size:14];
                nameLblTW.text=[[tellemTWFriends objectAtIndex:indexPath.row]valueForKey:@"displayName"];
                [cell addSubview:nameLblTW];
                UIImageView *userImg=[[UIImageView alloc]initWithFrame:CGRectMake(2,2, 46, 46)];
                __block UIImage *MyPictureTW = [[UIImage alloc]init];
                PFFile *imageFile = [[tellemTWFriends objectAtIndex:indexPath.row]valueForKey:@"profilePictureMedium"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        MyPictureTW = [UIImage imageWithData:data];
                        userImg.image = MyPictureTW;
                    }
                }];
                [cell addSubview:userImg];
            }
        }
        else
        {
            if (AllActivityTW.count==0)
            {
                cell.textLabel.text=@"None";
            }
            else
            {
                UILabel *nameLblTW=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 40)];
                nameLblTW.font = [UIFont fontWithName:kFontThin size:14];
                nameLblTW.text=[[AllActivityTW objectAtIndex:indexPath.row]valueForKey:@"name"];
                [cell addSubview:nameLblTW];
                
                UIImageView *userImg=[[UIImageView alloc]initWithFrame:CGRectMake(2,2,46,46)];
                NSMutableArray *url_arr=[[AllActivityTW valueForKey:@"profile_image_url_https"]objectAtIndex:indexPath.row];
                
                NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",url_arr]];
                NSURLRequest* request = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response,NSData * data, NSError * error) {
                    if (!error){
                        userImg.image = [UIImage imageWithData:data];
                    }
                                               
                }];
                [cell addSubview:userImg];
                
                UIButton *inviteButton=[[UIButton alloc]initWithFrame:CGRectMake(240, 8, 60, 25)];
                [inviteButton setBackgroundImage:[UIImage imageNamed:@"invite.png"] forState:UIControlStateNormal];
                inviteButton.titleLabel.font = [UIFont fontWithName:kFontNormal size:14];
                [inviteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [inviteButton addTarget:self action:@selector(clickedInviteTwitter:) forControlEvents:UIControlEventTouchUpInside];
                inviteButton.tag=indexPath.row;
                [cell addSubview:inviteButton];
            }
        }
    }
    else if (netWorkTable.tag==3)
    {
        if (indexPath.section==0)
        {
            if (tellemInstgrmFriends.count==0)
            {
                cell.textLabel.text=@"None";
            }
            else
            {
                UILabel *nameLblInsta=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 40)];
                nameLblInsta.font = [UIFont fontWithName:kFontThin size:14];
                nameLblInsta.text=[[tellemInstgrmFriends objectAtIndex:indexPath.row]valueForKey:@"displayName"];
                 [cell addSubview:nameLblInsta];
                UIImageView *userImg=[[UIImageView alloc]initWithFrame:CGRectMake(2,2,46,46)];
                __block UIImage *MyPictureInsta = [[UIImage alloc]init];
                PFFile *imageFile = [[tellemInstgrmFriends objectAtIndex:indexPath.row]valueForKey:@"profilePictureMedium"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        MyPictureInsta = [UIImage imageWithData:data];
                        userImg.image = MyPictureInsta;
                    }
                }];
                [cell addSubview:userImg];
            }
        }
        else
        {
            if (AllActivityInstagramAllData.count==0)
            {
                cell.textLabel.text=@"None";
            }
            else
            {
                UILabel *nameLblInsta=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 40)];
                nameLblInsta.font = [UIFont fontWithName:kFontThin size:14];
                NSString *fullName =[[AllActivityInstagramAllData objectAtIndex:indexPath.row] valueForKey:@"full_name"];
                //NSLog (@"fullName %@", fullName);
                if (fullName.length == 0) {
                    fullName =[[AllActivityInstagramAllData objectAtIndex:indexPath.row] valueForKey:@"username"];
                };
                nameLblInsta.text=fullName;
                [cell addSubview:nameLblInsta];
        
                NSString *profilePictureURL =[[AllActivityInstagramAllData objectAtIndex:indexPath.row] valueForKey:@"profile_picture"];
                //NSLog (@"profilePictureURL %@", profilePictureURL);
                UIImageView *userImg=[[UIImageView alloc]initWithFrame:CGRectMake(2,2,46,46)];
                NSURL* url = [NSURL URLWithString:profilePictureURL];
                NSURLRequest* request = [NSURLRequest requestWithURL:url];

                UIButton *inviteButton=[[UIButton alloc]initWithFrame:CGRectMake(240, 8, 60, 25)];
                [inviteButton setBackgroundImage:[UIImage imageNamed:@"invite.png"] forState:UIControlStateNormal];
                inviteButton.titleLabel.font = [UIFont fontWithName:kFontNormal size:14];
                [inviteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [inviteButton addTarget:self action:@selector(clickedInviteInstagram:) forControlEvents:UIControlEventTouchUpInside];
                inviteButton.tag=indexPath.row;
                [cell addSubview:inviteButton];
                

                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
                    if (!error){
                        userImg.image = [UIImage imageWithData:data];
                        }
                    }];
                [cell addSubview:userImg];
            }
        }
    }
    else if (netWorkTable.tag==4)
    {
        if (indexPath.section==0)
        {
            if (tellemContacts.count==0)
            {
                cell.textLabel.text=@"None";
            }
            else
            {
                UILabel *nameLbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 150, 40)];
                nameLbl.font = [UIFont fontWithName:kFontThin size:14];
                NSArray *contactArray = [tellemContacts  objectAtIndex:indexPath.row];
                nameLbl.text = [contactArray valueForKey:@"fullName"];
                [cell addSubview:nameLbl];
                UIButton *userPicture=[[UIButton alloc]initWithFrame:CGRectMake(2,2, 46, 46)];
                [userPicture setBackgroundImage:[UIImage imageNamed:@"user.png"] forState:UIControlStateNormal];
                [cell addSubview:userPicture];
            }
        }
        else
        {
            if (allContacts.count==0)
            {
                UILabel *nameLbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 40)];
                nameLbl.font = [UIFont fontWithName:kFontThin size:14];
                nameLbl.text=@"Others";
                [cell addSubview:nameLbl];
                
                UIButton *inviteButton=[[UIButton alloc]initWithFrame:CGRectMake(240, 8, 60, 25)];
                [inviteButton setBackgroundImage:[UIImage imageNamed:@"invite.png"] forState:UIControlStateNormal];
                inviteButton.titleLabel.font = [UIFont fontWithName:kFontNormal size:14];
                [inviteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [inviteButton addTarget:self action:@selector(clickedInviteContacts:) forControlEvents:UIControlEventTouchUpInside];
                inviteButton.tag=indexPath.row;
                [cell addSubview:inviteButton];
                
                UIButton *userPicture = [UIButton buttonWithType:UIButtonTypeCustom];
                [userPicture setFrame:CGRectMake(2,2, 46, 46)];
                [userPicture setBackgroundImage:[UIImage imageNamed:@"user.png"] forState:UIControlStateNormal];
                [cell addSubview:userPicture];
            }
            else
            {
                NSArray *contactArray = [allContacts  objectAtIndex:indexPath.row];
                UILabel *nameLbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 2, 200, 40)];
                nameLbl.text = [contactArray valueForKey:@"fullName"];
                nameLbl.font = [UIFont fontWithName:kFontThin size:14];
                [cell addSubview:nameLbl];

                UIButton *inviteButton=[[UIButton alloc]initWithFrame:CGRectMake(240, 8, 60, 25)];
                [inviteButton setBackgroundImage:[UIImage imageNamed:@"invite.png"] forState:UIControlStateNormal];
                inviteButton.titleLabel.font = [UIFont fontWithName:kFontNormal size:14];
                [inviteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [inviteButton addTarget:self action:@selector(clickedInviteContacts:) forControlEvents:UIControlEventTouchUpInside];
                inviteButton.tag=indexPath.row;
                [cell addSubview:inviteButton];
                //TODO FOR V4
                //FBProfilePictureView *profilePictureView=[[FBProfilePictureView alloc]initWithFrame:CGRectMake(2,2, 46, 46)];
                //[cell addSubview:profilePictureView];
            }
        }
    }

    
    return cell;
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
    
    if (netWorkTable.tag==1)
    {
        if (indexPath.section==0)
        {
            if (tellemFBFriends.count==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite friends to Tellem" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else
            {
                selectFBUserid=[[tellemFBFriends objectAtIndex:indexPath.row]valueForKey:@"username"];
                selectFBUserName=[[tellemFBFriends objectAtIndex:indexPath.row]valueForKey:@"displayName"];
                actionSheetFB = [[UIActionSheet alloc]
                                 initWithTitle:[@"Link up with " stringByAppendingString:selectFBUserName]
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Add to circle",@"Send a message", nil];
                
                actionSheetFB.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheetFB showFromTabBar:self.tabBarController.tabBar];
                actionSheetFB.tag=indexPath.row;
            }
        }
        else
        {
            if (AllActivityFBAllData.count==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite friends to Tellem" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else
            {
            }
        }
     }
    else if (netWorkTable.tag==2)
    {
        if (indexPath.section==0)
        {
            if (tellemTWFriends.count==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite friends to Tellem" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else
            {
                selectTwUserid=[[tellemTWFriends objectAtIndex:indexPath.row]valueForKey:@"username"];
                actionSheetTW = [[UIActionSheet alloc]
                                initWithTitle:[@"Link up with " stringByAppendingString:selectTwUserid]
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Add to circle",@"Send a message", nil];

                actionSheetTW.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheetTW showFromTabBar:self.tabBarController.tabBar];
                actionSheetTW.tag=indexPath.row;
            }
        }
        else
        {
            if (AllActivityTW.count==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite friends to Tellem" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else
            {
            }
        }
    }
    else if (netWorkTable.tag==3)
    {
        if (indexPath.section==0)
        {
            if (tellemInstgrmFriends.count==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite friends to Tellem" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else{
                NSString *fullName =[[AllActivityInstagramAllData objectAtIndex:indexPath.row] valueForKey:@"full_name"];
                if (fullName.length == 0) {
                    fullName =[[AllActivityInstagramAllData objectAtIndex:indexPath.row] valueForKey:@"username"];
                };

                selectInstagramUserName = fullName;
                actionSheetInstagram = [[UIActionSheet alloc]
                                 initWithTitle:[@"Link up with " stringByAppendingString:selectInstagramUserName]
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Add to circle",@"Send a message", nil];
                
                actionSheetInstagram.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheetInstagram showFromTabBar:self.tabBarController.tabBar];
                actionSheetInstagram.tag=indexPath.row;
            }
        }
        else
        {
            if (AllActivityInstagramAllData.count==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite friends to Tellem" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else
            {
            }
        }
    }
    else if (netWorkTable.tag==4)
    {
        if (indexPath.section==0)
        {
            if (tellemContacts.count==0)
            {
            }
            else
            {
                selectFBUserid=[[tellemContacts objectAtIndex:indexPath.row]valueForKey:@"username"];
                selectFBUserName=[[tellemContacts objectAtIndex:indexPath.row]valueForKey:@"displayName"];
                actionSheetContacts = [[UIActionSheet alloc]
                                 initWithTitle:[@"Link up with " stringByAppendingString:selectFBUserName]
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Add to circle",@"Send a message", nil];
                
                actionSheetContacts.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheetContacts showFromTabBar:self.tabBarController.tabBar];
                actionSheetContacts.tag=indexPath.row;
            }
        }
        else
        {
            if (allContacts.count==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite contacts to Tellem" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else
            {
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet==actionSheetFB)
    {
        if (buttonIndex == 0)
        {
            [self showCirclesView];
        } else
        {
            [self messageWithFriend];
        }
    }
    if (actionSheet==actionSheetInviteFB)
    {
        if (buttonIndex == 0)
        {
            [self inviteFBbyEmail:actionSheet];
        } else
        {
            [self inviteFBbyTextMessage:actionSheet];
        }
    }
    else
    if (actionSheet==actionSheetTW)
    {
        if (buttonIndex == 0)
        {
            [self showCirclesView];
        } else
        {
            [self messageWithFriend];
        }
    }
    else
        if (actionSheet==actionSheetInviteTW)
        {
            if (buttonIndex == 0)
            {
                [self inviteTWbyEmail:actionSheet];
            } else
            {
                [self inviteTWbyTextMessage:actionSheet];
            }
        }
        else
        if (actionSheet==actionSheetInstagram)
        {
            if (buttonIndex == 0)
            {
                [self showCirclesView];
            } else
            {
                [self messageWithFriend];
            }
        }
    else
        if (actionSheet==actionSheetInviteInstagram)
        {
            if (buttonIndex == 0)
            {
                [self inviteInstagrambyEmail:actionSheet];
            } else
            {
                [self inviteInstagrambyTextMessage:actionSheet];
            }
        }
        else
    if (actionSheet==actionSheetContacts)
    {
        if (buttonIndex == 0)
        {
            [self showCirclesView];
        } else
        {
            [self messageWithFriend];
        }
    }
    else
        if (actionSheet==actionSheetInviteContacts)
        {
            if (buttonIndex == 0)
            {
                [self inviteContactbyEmail:actionSheet];
            } else
            {
                [self inviteContactbyTextMessage:actionSheet];
            }
        }
}

#pragma mark Button Action

- (IBAction)fbButton_clicked:(id)sender {
    
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    netWorkTable.tag=1;
    twitterButton.selected=NO;
    fbButton.selected=YES;
    instagramButton.selected=NO;
    contactsButton.selected=NO;
    [self userAllFacebookFriends];
}

- (IBAction)twitterButton_clicked:(id)sender {
    
    netWorkTable.tag=2;
    twitterButton.selected=YES;
    fbButton.selected=NO;
    instagramButton.selected=NO;
    [self.view.window addSubview:ApplicationDelegate.hudd];
    contactsButton.selected=NO;
    [ApplicationDelegate.hudd show:YES];
    [self tellemTwitterFriends];
    [self UserAllTwitterFriends];
}

- (IBAction)instagramButton_clicked:(id)sender {
    
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    netWorkTable.tag=3;
    twitterButton.selected=NO;
    fbButton.selected=NO;
    instagramButton.selected=YES;
    contactsButton.selected=NO;
    [self tellemInstagramFriends];
    [self userAllInstagramFriends];
}

- (IBAction)contactsButton_clicked:(id)sender {
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    netWorkTable.tag=4;
    twitterButton.selected=NO;
    fbButton.selected=NO;
    instagramButton.selected=NO;
    contactsButton.selected=YES;
    [self userAllContacts];
}


-(void)inviteFriendsToInstallTellem{
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Invite friends to install Tellem" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark Tellem Friends Timeline Post & Accounts Details Method

-(void)fbSharingView{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostSharingViewController *fb_Friend = (PostSharingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FacebookFriends"];
    fb_Friend.fb_userId= selectFBUserid;
    fb_Friend.selectedUserAccountType=@"FB";
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:fb_Friend animated:YES];
}

-(void)twitterSharingView{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostSharingViewController *tw_Friend = (PostSharingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FacebookFriends"];
    tw_Friend.tw_userId=selectTwUserid ;
    tw_Friend.selectedUserAccountType=@"Twitter";
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:tw_Friend animated:YES];
}

-(void)showCirclesView{    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddCirclesViewController *addCirclesView = (AddCirclesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AddCirclesViewController"];
    addCirclesView.selectedUser =  [TellemUtility getPFUserWithUserId:selectFBUserid];
    addCirclesView.callingController = @"NetworkViewController";
    addCirclesView.delegate=self;
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:addCirclesView animated:YES];
    
}

-(void) receiveCirclesData:(NSString *)stringData;
{
}

-(void) messageWithFriend{
    if ([MFMessageComposeViewController canSendText])
    {
        PFUser *user = [PFUser currentUser];
        NSString *userName=user[@"displayName"];
        if (userName) {
            userName = [@" (" stringByAppendingString:userName];
            userName = [userName stringByAppendingString:@"), "];
        } else {
            userName = @",";
        }
        NSString *bodyText =@"Hey, what's up?";
        NSString *subjectText = [@"Messaging with " stringByAppendingString:userName];
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        [message setSubject:subjectText];
        [message setBody:bodyText];
        
        [self presentViewController:message animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send texts");
    }

}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // Remove the message view
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (result == MessageComposeResultCancelled)
    {
        //NSLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent)
    {
        //NSLog(@"Message sent");
    }
    else
    {
        //NSLog(@"Message failed");
    }
}

-(void)tellemFBUserAccount{
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:[tellemPFUserFBFriends objectAtIndex:actionSheetFB.tag]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

-(void)tellemTWUserAccounts{
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:[tellemTWFriends objectAtIndex:actionSheetFB.tag]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

#pragma mark Friends Invite Events

-(void)clickedInviteFB:(UIButton *)button
{
    NSString *firstName=[[AllActivityFBAllData objectAtIndex:button.tag]valueForKey:@"first_name"];
    actionSheetInviteFB = [[UIActionSheet alloc]
                                 initWithTitle:[@"Invite " stringByAppendingString:firstName]
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Via email",@"Via text message", nil];
    
    actionSheetInviteFB.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetInviteFB showFromTabBar:self.tabBarController.tabBar];
    actionSheetInviteFB.tag=button.tag;
}

-(void)clickedInviteTwitter:(UIButton *)button
{
    NSString *userName=[[AllActivityTW objectAtIndex:button.tag]valueForKey:@"name"];
    actionSheetInviteTW = [[UIActionSheet alloc]
                           initWithTitle:[@"Invite " stringByAppendingString:userName]
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Via email",@"Via text message", nil];
    
    actionSheetInviteTW.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetInviteTW showFromTabBar:self.tabBarController.tabBar];
    actionSheetInviteTW.tag=button.tag;
}

-(void)clickedInviteInstagram:(UIButton *)button
{
    NSString *fullName =[[AllActivityInstagramAllData objectAtIndex:button.tag] valueForKey:@"full_name"];
    if (fullName.length == 0) {
        fullName =[[AllActivityInstagramAllData objectAtIndex:button.tag] valueForKey:@"username"];
    };
    actionSheetInviteInstagram = [[UIActionSheet alloc]
                           initWithTitle:[@"Invite " stringByAppendingString:fullName]
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Via email",@"Via text message", nil];
    
    actionSheetInviteInstagram.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetInviteInstagram showFromTabBar:self.tabBarController.tabBar];
    actionSheetInviteInstagram.tag=button.tag;

}

-(void)clickedInviteContacts:(UIButton *)button
{
    NSString *fullName = @"";
    NSArray *phoneNumbers, *emailAddresses;
    NSArray *contactArray = [allContacts  objectAtIndex:button.tag];
    ContactPerson *cPerson = [contactArray valueForKey:@"contactPerson"];
    fullName = [contactArray valueForKey:@"fullName"];
    phoneNumbers = cPerson.phoneNumbers;
    emailAddresses = cPerson.emailAddresses;

    actionSheetInviteContacts = [[UIActionSheet alloc]
                     initWithTitle:[@"Invite " stringByAppendingString:fullName]
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"Via email",@"Via text message", nil];
    
    actionSheetInviteContacts.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetInviteContacts showFromTabBar:self.tabBarController.tabBar];
    actionSheetInviteContacts.tag=button.tag;
}

-(void)inviteFBbyEmail: (UIActionSheet *) actionSheet
{
    NSString *firstName=[[AllActivityFBAllData objectAtIndex:actionSheet.tag]valueForKey:@"first_name"];
    NSString *userName=[[AllActivityFBAllData objectAtIndex:actionSheet.tag]valueForKey:@"username"];
    if (userName) {
        userName = [@" (" stringByAppendingString:userName];
        userName = [userName stringByAppendingString:@"), "];
    } else {
        userName = @" ";
    }
    
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *subjectText = @"Join my private circle";
        NSString *bodyText =@"<html>";
        bodyText = [bodyText stringByAppendingString:@"<head></head><body>Hi "];
        bodyText = [bodyText stringByAppendingString:firstName];
        bodyText = [bodyText stringByAppendingString:@","];
        bodyText = [bodyText stringByAppendingString:@"<p>I just joined this new social network with unbelievable privacy features!"];
        bodyText = [bodyText stringByAppendingString:@"<p><a href=\"http://appstore.com/keynote\">Click here to install Tellem</a></p><p>"];
        bodyText = [bodyText stringByAppendingString:@"After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number.  Then we can connect! <p>Thanks!"];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subjectText];
        [mail setMessageBody:bodyText isHTML:YES];
        [mail setToRecipients:@[userName]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send email");
    }
}

-(void)inviteFBbyTextMessage: (UIActionSheet *) actionSheet {
    NSString *firstName=[[AllActivityFBAllData objectAtIndex:actionSheet.tag]valueForKey:@"first_name"];
    NSString *userName=[[AllActivityFBAllData objectAtIndex:actionSheet.tag]valueForKey:@"username"];
    if (userName) {
        userName = [@" (" stringByAppendingString:userName];
        userName = [userName stringByAppendingString:@"), "];
    } else {
        userName = @" ";
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        NSString *bodyText =[@"Hey "  stringByAppendingString:firstName];
        bodyText  = [bodyText stringByAppendingString:@". Join my private circle at http://appstore.com/keynote. After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number. Then we can connect!  Thanks!"];
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        [message setBody:bodyText];
        [message setRecipients:@[userName]];
        
        [self presentViewController:message animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send texts");
    }
    
}

-(void)inviteTWbyEmail: (UIActionSheet *) actionSheet
{
    NSString *userName=[[AllActivityTW objectAtIndex:actionSheet.tag]valueForKey:@"name"];
    if (userName) {
        userName = [@" (" stringByAppendingString:userName];
        userName = [userName stringByAppendingString:@"), "];
    } else {
        userName = @" ";
    }
    
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *subjectText = @"Join my private circle";
        NSString *bodyText =@"<html>";
        bodyText = [bodyText stringByAppendingString:@"<head></head><body>Hi "];
        bodyText = [bodyText stringByAppendingString:userName];
        bodyText = [bodyText stringByAppendingString:@","];
        bodyText = [bodyText stringByAppendingString:@"<p>I just joined this new social network with unbelievable privacy features!"];
        bodyText = [bodyText stringByAppendingString:@"<p><a href=\"http://appstore.com/keynote\">Click here to install Tellem</a></p><p>"];
        bodyText = [bodyText stringByAppendingString:@"After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number.  Then we can connect! <p>Thanks!"];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subjectText];
        [mail setMessageBody:bodyText isHTML:YES];
        [mail setToRecipients:@[userName]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send email");
    }
}

-(void)inviteTWbyTextMessage: (UIActionSheet *) actionSheet {
    NSString *userName=[[AllActivityTW objectAtIndex:actionSheet.tag]valueForKey:@"name"];
    if (userName) {
        userName = [@" (" stringByAppendingString:userName];
        userName = [userName stringByAppendingString:@"), "];
    } else {
        userName = @" ";
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        NSString *bodyText =[@"Hey "  stringByAppendingString:userName];
        bodyText  = [bodyText stringByAppendingString:@". Join my private circle at http://appstore.com/keynote. After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number. Then we can connect!  Thanks!"];
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        [message setBody:bodyText];
        [message setRecipients:@[userName]];
        
        [self presentViewController:message animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send texts");
    }
    
}

-(void)inviteInstagrambyEmail: (UIActionSheet *) actionSheet
{
    NSString *userName =[[AllActivityInstagramAllData objectAtIndex:actionSheet.tag] valueForKey:@"full_name"];
    if (userName.length == 0) {
        userName =[[AllActivityInstagramAllData objectAtIndex:actionSheet.tag] valueForKey:@"username"];
    };
    if (userName) {
        userName = [@" (" stringByAppendingString:userName];
        userName = [userName stringByAppendingString:@"), "];
    } else {
        userName = @" ";
    }
    
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *subjectText = @"Join my private circle";
        NSString *bodyText =@"<html>";
        bodyText = [bodyText stringByAppendingString:@"<head></head><body>Hi "];
        bodyText = [bodyText stringByAppendingString:userName];
        bodyText = [bodyText stringByAppendingString:@","];
        bodyText = [bodyText stringByAppendingString:@"<p>I just joined this new social network with unbelievable privacy features!"];
        bodyText = [bodyText stringByAppendingString:@"<p><a href=\"http://appstore.com/keynote\">Click here to install Tellem</a></p><p>"];
        bodyText = [bodyText stringByAppendingString:@"After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number.  Then we can connect! <p>Thanks!"];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subjectText];
        [mail setMessageBody:bodyText isHTML:YES];
        [mail setToRecipients:@[userName]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send email");
    }
}

-(void)inviteInstagrambyTextMessage: (UIActionSheet *) actionSheet {
    NSString *userName =[[AllActivityInstagramAllData objectAtIndex:actionSheet.tag] valueForKey:@"full_name"];
    if (userName.length == 0) {
        userName =[[AllActivityInstagramAllData objectAtIndex:actionSheet.tag] valueForKey:@"username"];
    };
    if (userName) {
        userName = [@" (" stringByAppendingString:userName];
        userName = [userName stringByAppendingString:@"), "];
    } else {
        userName = @" ";
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        NSString *bodyText =[@"Hey "  stringByAppendingString:userName];
        bodyText  = [bodyText stringByAppendingString:@". Join my private circle at http://appstore.com/keynote. After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number. Then we can connect!  Thanks!"];
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        [message setBody:bodyText];
        [message setRecipients:@[userName]];
        
        [self presentViewController:message animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send texts");
    }
    
}

-(void)inviteContactbyEmail: (UIActionSheet *) actionSheet
{
    NSString *fullName = @"";
    NSArray *emailAddresses = [NSArray array];
    
    ContactPerson *cPerson =[[allContacts objectAtIndex:actionSheet.tag]valueForKey:@"contactPerson"];
    fullName=cPerson.firstName;
    emailAddresses=cPerson.emailAddresses;
    
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *subjectText = @"Join my private circle";
        NSString *bodyText =@"<html>";
        bodyText = [bodyText stringByAppendingString:@"<head></head><body>Hi "];
        bodyText = [bodyText stringByAppendingString:fullName];
        bodyText = [bodyText stringByAppendingString:@","];
        bodyText = [bodyText stringByAppendingString:@"<p>I just joined this new social network with unbelievable privacy features!"];
        bodyText = [bodyText stringByAppendingString:@"<p><a href=\"http://appstore.com/keynote\">Click here to install Tellem</a></p><p>"];
        bodyText = [bodyText stringByAppendingString:@"After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number.  Then we can connect! <p>Thanks!"];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subjectText];
        [mail setMessageBody:bodyText isHTML:YES];
        [mail setToRecipients:emailAddresses];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send email");
    }
}

-(void)inviteContactbyTextMessage: (UIActionSheet *) actionSheet {
    NSString *fullName = @"";
    NSMutableArray *phoneNumbersArray = [NSMutableArray array];
    
    ContactPerson *cPerson =[[allContacts objectAtIndex:actionSheet.tag]valueForKey:@"contactPerson"];
    fullName=cPerson.firstName;
    for (NSArray * pNArray in cPerson.phoneNumbers) {
        NSString *phoneNumber = [pNArray objectAtIndex:1];
        if (phoneNumber.length >0) {
            [phoneNumbersArray addObject:phoneNumber];
        }
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        NSString *bodyText =[@"Hey "  stringByAppendingString:fullName];
        bodyText  = [bodyText stringByAppendingString:@". Join my private circle at http://appstore.com/keynote. After you install the app, log in using Facebook, Twitter, Instagram, or if you prefer, your email or telephone number. Then we can connect!  Thanks!"];
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        [message setBody:bodyText];
        [message setRecipients:phoneNumbersArray];
                              
        [self presentViewController:message animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send texts");
    }
                          
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
        {
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Mail sent!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            break;
        }
        case MFMailComposeResultFailed:
        {
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Failed to send mail! Try again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            break;
        }
        default:
            //NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:NULL];
}
                      
-(void) sortTwitterFriends
{
    //NSLog(@"sortTwitterFriends %@", tellemTWFriends);
    if (tellemTWFriends.count>1) {
        //NSLog(@"sortTwitterFriends %@", tellemTWFriends);
    }
}

-(void) sortInstagramFriends
{
    //NSLog(@"sortInstagramFriends %@", tellemInstgrmFriends);
    if (tellemInstgrmFriends.count>1) {
        //NSLog(@"sortInstagramFriends %@", tellemInstgrmFriends);
   }
}

-(void) sortAllTwitterFriends
{
    //NSLog(@"sortAllTwitterFriends %@", AllActivityTW);
    if (AllActivityTW.count>1) {
        //NSLog(@"sortAllTwitterFriends %@", AllActivityTW);
    }
}

-(void) sortAllInstagramFriends
{
    //NSLog(@"sortAllInstagramFriends %@", AllActivityInstagramAllData);
    if (AllActivityInstagramAllData.count>1) {
        //NSLog(@"sortAllInstagramFriends %@", AllActivityInstagramAllData);
    }
}

-(NSMutableArray *) sortMutableArray: (NSMutableArray *) mutableArray
{
    return [self sortMutableArray:mutableArray withKey:@""];
}

-(NSMutableArray *) sortMutableArray: (NSMutableArray *) mutableArray withKey:(NSString *)sortKey
{
    //NSLog(@"sortMutableArray %d", mutableArray.count);
    if (mutableArray.count>1) {
        //NSLog(@"sortMutableArray input %@", mutableArray);
        if (![sortKey isEqualToString:@""]) {
            NSArray *array = [NSArray arrayWithArray:mutableArray];
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSArray *sortedArray;
            sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
            //NSLog(@"sortMutableArray output %@", array);
            return [sortedArray mutableCopy];
        } else {
            [mutableArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
            //NSLog(@"sortMutableArray output %@", mutableArray);
            return mutableArray;
        }
    } else {
        return mutableArray;
    }
}


@end
