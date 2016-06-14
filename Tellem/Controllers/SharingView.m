//
//  SharingView.m
//  Tellem
//
//  Created by Ed Bayudan on 05/04/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import "SharingView.h"
#import <Parse/PFUser.h>
#import "FHSTwitterEngine.h"
#import "AppDelegate.h"
#import "PAPUtility.h"
#import "PAPCache.h"
#import "JSON.h"
#import <Social/Social.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseTwitterUtils/PF_Twitter.h>


@interface SharingView ()
{
    NSMutableArray * Instagram_User_Details;
    NSString *Insta_Id;
    NSString *Twitter_Username;
    BOOL isTwitter_BtnOn,isViewTwitter_BtnOn;
    BOOL isInstagram_BtnOn,isViewInstagram_BtnOn, isInstagramLoggedIn;
}
@end

@implementation SharingView

@synthesize shareLabel, viewLabel,settingsScrollView,user_Facebook_Switch,user_Twitter_Switch,user_Instagram_Switch,user_Contacts_Switch,viewUser_Facebook_Switch,viewUser_Twitter_Switch,viewUser_Contacts_Switch,viewUser_Instagram_Switch,recTimeLabel,recTimeInSecs,sliderMinLabel,sliderMaxLabel;
@synthesize viewUser_Facebook_Label,viewUser_Twitter_Label,viewUser_Instagram_Label,linkEULA;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    self.navigationItem.title=@"SETTINGS";
    self.view.backgroundColor = [UIColor darkGrayColor];
    CGSize scrollViewContentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.settingsScrollView setContentSize:scrollViewContentSize];
    self.user_Facebook_Switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.user_Twitter_Switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.user_Instagram_Switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.viewUser_Facebook_Switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.viewUser_Twitter_Switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.viewUser_Instagram_Switch.transform = CGAffineTransformMakeScale(0.75, 0.75);

    [[UILabel appearance] setFont:[UIFont fontWithName:kFontThin size:15.0]];
    [UIButton appearance].titleLabel.font = [UIFont fontWithName:kFontThin size:15.0];
    self.shareLabel.font = [UIFont fontWithName:kFontBold size:16.0];
    self.viewLabel.font = [UIFont fontWithName:kFontBold size:16.0];
    self.recTimeLabel.font = [UIFont fontWithName:kFontBold size:14.0];
    self.recTimeInSecs.minimumValue = kMinRecTimeInSecs;
    self.recTimeInSecs.maximumValue = kMaxRecTimeInSecs;
    self.recTimeInSecs.value = kInitialRecTimeInSecs;
    self.sliderMinLabel.font = [UIFont fontWithName:kFontThin size:10.0];
    self.sliderMaxLabel.font = [UIFont fontWithName:kFontThin size:10.0];
    self.sliderMinLabel.text = [NSString stringWithFormat:@"%d", kMinRecTimeInSecs];
    self.sliderMaxLabel.text = [NSString stringWithFormat:@"%d", kMaxRecTimeInSecs];
    isTwitter_BtnOn = NO;
    isViewTwitter_BtnOn = NO;
    isInstagram_BtnOn = NO;
    isViewInstagram_BtnOn = NO;
    isInstagramLoggedIn = NO;
    self.viewLabel.hidden=YES;
    self.viewUser_Facebook_Label.hidden=YES;
    self.viewUser_Twitter_Label.hidden=YES;
    self.viewUser_Instagram_Label.hidden=YES;
    self.viewUser_Facebook_Switch.hidden=YES;
    self.viewUser_Twitter_Switch.hidden=YES;
    self.viewUser_Instagram_Switch.hidden=YES;

    
    PFUser *currentUser = [PFUser currentUser];
    
    if ([[[currentUser valueForKey:@"ShareSettings"]objectAtIndex:0] isEqualToString:@"1"])
    {
        [user_Twitter_Switch setOn:YES];
    }
    
    if ([[[currentUser valueForKey:@"ShareSettings"]objectAtIndex:1]isEqualToString:@"1"])
    {
        [user_Facebook_Switch setOn:YES];
    }
    
    if ([[[currentUser valueForKey:@"ShareSettings"]objectAtIndex:2]isEqualToString:@"1"])
    {
        [user_Instagram_Switch setOn:YES];
    }

    if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:0] isEqualToString:@"1"])
    {
        [viewUser_Twitter_Switch setOn:YES];
    }
    
    if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:1]isEqualToString:@"1"])
    {
        [viewUser_Facebook_Switch setOn:YES];
    }
    
    if ([[[currentUser valueForKey:@"ViewFriends"]objectAtIndex:2]isEqualToString:@"1"])
    {
        [viewUser_Instagram_Switch setOn:YES];
    }

    [user_Contacts_Switch setOn:YES];
    [viewUser_Contacts_Switch setOn:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    if (tM.gPostRecordingTimeInSecs) {
        self.recTimeInSecs.value = [tM.gPostRecordingTimeInSecs intValue];
    } else {
        self.recTimeInSecs.value = kInitialRecTimeInSecs;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backAction:(id)sender {
    
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)Twitter_BtnOn:(id)sender {
    TellemGlobals *tM = [TellemGlobals globalsManager];
    if (!tM.gTwitterSharingOK)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tellem has technical issues with Twitter. Please use Instagram to share your posts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [user_Twitter_Switch setOn:NO];
        [self dismissViewControllerAnimated:NO completion:Nil];
        return;
    }

    [PFTwitterUtils initializeWithConsumerKey:kTwitterClientID consumerSecret:kTwitterClientSecret];
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:kTwitterClientID andSecret:kTwitterClientSecret];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];

    isTwitter_BtnOn = YES;
    if (user_Twitter_Switch.isOn)
    //User requested to turn ON Twitter sharing
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Twitter"])
        {
            [self saveSharingSettings];
        }
        else
        {
            UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success)
            {
            if (success)
            {
                [self saveSharingSettings];
            }
            else
            {
                NSLog(success?@"SharingView FHSTwitterEngine login success":@"SharingView FHSTwitterEngine login failure");
            }
            }];
            [self presentViewController:loginController animated:YES completion:nil];
        }
    }
    else
    //User requested to turn OFF Twitter sharing
    {
        [self saveSharingSettings];
    }
}

- (IBAction)viewTwitter_BtnOn:(id)sender {
    TellemGlobals *tM = [TellemGlobals globalsManager];
    if (!tM.gTwitterSharingOK)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tellem has technical issues with Twitter. Please use Instagram or Tellem to search for friends" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [viewUser_Twitter_Switch setOn:NO];
        [self dismissViewControllerAnimated:NO completion:Nil];
        return;
    }

    [PFTwitterUtils initializeWithConsumerKey:kTwitterClientID consumerSecret:kTwitterClientSecret];
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:kTwitterClientID andSecret:kTwitterClientSecret];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    
    isViewTwitter_BtnOn = YES;
    if (viewUser_Twitter_Switch.isOn)
        //User requested to turn ON Twitter sharing
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Twitter"])
        {
            [self saveSharingSettings];
        }
        else
        {
            UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success)
            {
                if (success)
                {
                    [self saveSharingSettings];
                }
                else
                {
                    NSLog(success?@"SharingView FHSTwitterEngine login success":@"SharingView FHSTwitterEngine login failure");
                }
             }];
            [self presentViewController:loginController animated:YES completion:nil];
        }
    }
    else
    //User requested to turn OFF Twitter sharing
    {
        [self saveSharingSettings];
    }
}

- (void)loginOAuth {
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        //NSLog(success?@"SharingView loginOAuth success":@"SharingView loginOAuth failed!");
    }];
    [self presentViewController:loginController animated:YES completion:nil];
}

-(void)twitterEngineControllerDidCancel
{
    if (isTwitter_BtnOn)
        [user_Twitter_Switch setOn:NO];
    if (isViewTwitter_BtnOn)
        [viewUser_Twitter_Switch setOn:NO];
    [self saveSharingSettings];
    isTwitter_BtnOn = NO;
    isViewTwitter_BtnOn = NO;
}

- (void)storeAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
    [[NSUserDefaults standardUserDefaults]synchronize];
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
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (IBAction)Facebook_BtnOn:(id)sender
{
    //TODO FOR V4
//    TellemGlobals *tM = [TellemGlobals globalsManager];
//    if (!tM.gFacebookSharingOK)
//    {
//        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tellem has technical issues with Facebook. Please use Instagram to share your posts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [Alert show];
//        [user_Facebook_Switch setOn:NO];
//        [self dismissViewControllerAnimated:NO completion:Nil];
//        return;
//    }
//    
//    if (user_Facebook_Switch.isOn) {
//         if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"FB"]) {
//            //ApplicationDelegate.session=[PFFacebookUtils session];
//            //[FBSession setActiveSession:[PFFacebookUtils session]];
//            [self saveSharingSettings];
//         } else if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Normal"]) {
//            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
//                {
//                    ApplicationDelegate.session=[FBSession activeSession];
//                    [FBSession setActiveSession:[FBSession activeSession]];
//                }];
//             
//         } else {
//            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
//                {
//                  ApplicationDelegate.session=[FBSession activeSession];
//                  [FBSession setActiveSession:[FBSession activeSession]];
//                  NSString *fbtokendata=[NSString stringWithFormat:@"%@",[FBSession activeSession]];
//                  [[NSUserDefaults standardUserDefaults]setObject:fbtokendata forKey:@"fbAccessData"];
//                  [[NSUserDefaults standardUserDefaults]synchronize];
//                  [self saveSharingSettings];
//                }];
//        }
//    } else {
//        if([[[PFUser currentUser]objectForKey:@"Accounttype"]isEqualToString:@"FB"]) {
//            [self saveSharingSettings];
//        } else {
//            [[FBSession activeSession]closeAndClearTokenInformation];
//            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//            [[FBSession activeSession] closeAndClearTokenInformation];
//            NSArray* fbCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
//            for (NSHTTPCookie* cookie in fbCookies) {
//                [cookies deleteCookie:cookie];
//            }
//            [self saveSharingSettings];
//        }
//    }
}
-(void) saveSharingSettings
{
    NSMutableArray *Arr_temp=[[NSMutableArray alloc]init];
    
    if(user_Twitter_Switch.isOn)
        [Arr_temp addObject:@"1"];
    else
        [Arr_temp addObject:@"0"];
    
    if(user_Facebook_Switch.isOn)
        [Arr_temp addObject:@"1"];
    
    else
        [Arr_temp addObject:@"0"];
    
    if(user_Instagram_Switch.isOn)
        [Arr_temp addObject:@"1"];
    else
        [Arr_temp addObject:@"0"];
    
    if(user_Contacts_Switch.isOn)
        [Arr_temp addObject:@"1"];
    else
        [Arr_temp addObject:@"0"];
    

    NSMutableArray *viewFriends=[[NSMutableArray alloc]init];
    
    if(viewUser_Twitter_Switch.isOn)
        [viewFriends addObject:@"1"];
    else
        [viewFriends addObject:@"0"];
    
    if(viewUser_Facebook_Switch.isOn)
        [viewFriends addObject:@"1"];
    
    else
        [viewFriends addObject:@"0"];
    
    if(viewUser_Instagram_Switch.isOn)
        [viewFriends addObject:@"1"];
    else
        [viewFriends addObject:@"0"];
    
    if(viewUser_Contacts_Switch.isOn)
        [viewFriends addObject:@"1"];
    else
        [viewFriends addObject:@"0"];
    
    
    [[PFUser currentUser] setObject:Arr_temp forKey:@"ShareSettings"];
    [[PFUser currentUser] setObject:viewFriends forKey:@"ViewFriends"];
    [[PFUser currentUser] saveInBackground];
}


- (IBAction)viewFacebook_BtnOn:(id)sender
{
    //TODO FOR V4
//    TellemGlobals *tM = [TellemGlobals globalsManager];
//    if (!tM.gFacebookSharingOK)
//    {
//        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tellem has technical issues with Facebook. Please use Instagram or Tellem to search for friends" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [Alert show];
//        [viewUser_Facebook_Switch setOn:NO];
//        [self dismissViewControllerAnimated:NO completion:Nil];
//        return;
//    }
//    
//    if (viewUser_Facebook_Switch.isOn) {
//        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"FB"]) {
//            //ApplicationDelegate.session=[PFFacebookUtils session];
//            //[FBSession setActiveSession:[PFFacebookUtils session]];
//            [self saveSharingSettings];
//        } else if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Normal"]) {
//            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
//             {
//                 ApplicationDelegate.session=[FBSession activeSession];
//                 [FBSession setActiveSession:[FBSession activeSession]];
//             }];
//            
//        } else {
//            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
//             {
//                 ApplicationDelegate.session=[FBSession activeSession];
//                 [FBSession setActiveSession:[FBSession activeSession]];
//                 
//                 NSString *fbtokendata=[NSString stringWithFormat:@"%@",[FBSession activeSession]];
//                 [[NSUserDefaults standardUserDefaults]setObject:fbtokendata forKey:@"fbAccessData"];
//                 [[NSUserDefaults standardUserDefaults]synchronize];
//                 [self saveSharingSettings];
//                 
//             }];
//        }
//    } else {
//        if([[[PFUser currentUser]objectForKey:@"Accounttype"]isEqualToString:@"FB"]) {
//            [self saveSharingSettings];
//        } else {
//            [[FBSession activeSession]closeAndClearTokenInformation];
//            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//            [[FBSession activeSession] closeAndClearTokenInformation];
//            NSArray* fbCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
//            for (NSHTTPCookie* cookie in fbCookies) {
//                [cookies deleteCookie:cookie];
//            }
//            [self saveSharingSettings];
//        }
//    }
}

- (IBAction)Instagram_BtnOn:(id)sender
{
    isInstagram_BtnOn = YES;
    if ([user_Instagram_Switch isOn])
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Instagram"])
        {
            [self saveSharingSettings];
        }
        else
        {
        webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        webView.delegate=self;
        activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center=webView.center;
        [webView addSubview:activityIndicator];
        [self.view addSubview:webView];
        
        NSString *fullAuthUrlString = [[NSString alloc]
                                       initWithFormat:@"%@/?client_id=%@&redirect_uri=%@&response_type=token",
                                       kAuthUrlString,
                                       kClientID,
                                       kRedirectUri
                                       ];
        NSURL *authUrl = [NSURL URLWithString:fullAuthUrlString];
        NSURLRequest *myRequest = [[NSURLRequest alloc] initWithURL:authUrl];
        [webView loadRequest:myRequest];
        [self saveSharingSettings];

        }
    }
    else
    {
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* instagramCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://instagram.com/"]];
        for (NSHTTPCookie* cookie in instagramCookies)
            [cookies deleteCookie:cookie];
        //NSLog(@"Nothing %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"ShareInstaGramToken"]);
        [self saveSharingSettings];

    }
}

- (IBAction)viewInstagram_BtnOn:(id)sender
{
    isViewInstagram_BtnOn = YES;
    if ([viewUser_Instagram_Switch isOn])
    {
        if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Instagram"])
        {
            [self saveSharingSettings];
        }
        else
        {
            webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
            webView.delegate=self;
            activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center=webView.center;
            [webView addSubview:activityIndicator];
            [self.view addSubview:webView];
            
            NSString *fullAuthUrlString = [[NSString alloc]
                                           initWithFormat:@"%@/?client_id=%@&redirect_uri=%@&response_type=token",
                                           kAuthUrlString,
                                           kClientID,
                                           kRedirectUri
                                           ];
            NSURL *authUrl = [NSURL URLWithString:fullAuthUrlString];
            NSURLRequest *myRequest = [[NSURLRequest alloc] initWithURL:authUrl];
            [webView loadRequest:myRequest];
            [self saveSharingSettings];
            
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"InstaGramToken"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ShareInstaGramToken"];
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* instagramCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://instagram.com/"]];
        for (NSHTTPCookie* cookie in instagramCookies)
            [cookies deleteCookie:cookie];
        [self saveSharingSettings];
        
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
        NSURL *Url = [request URL];
        NSArray *UrlParts = [Url pathComponents];
    
        if ([[UrlParts objectAtIndex:(1)] isEqualToString:@"NeverGonnaFindMe"])
        {
            NSString *urlResources = [Url resourceSpecifier];
            urlResources = [urlResources stringByReplacingOccurrencesOfString:@"?" withString:@""];
            urlResources = [urlResources stringByReplacingOccurrencesOfString:@"#" withString:@""];
            
            NSArray *urlResourcesArray = [urlResources componentsSeparatedByString:@"/"];
            
            NSString *urlParamaters = [urlResourcesArray objectAtIndex:([urlResourcesArray count]-1)];
            
            NSArray *urlParamatersArray = [urlParamaters componentsSeparatedByString:@"&"];
            
            if(urlParamatersArray.count==1)
            {
                Ins_ShareAccesstoken=[[urlParamatersArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
                NSUserDefaults *Defaults=[NSUserDefaults standardUserDefaults];
                [Defaults setObject:Ins_ShareAccesstoken forKey:@"ShareInstaGramToken"];
                [Defaults synchronize];
                if (Ins_ShareAccesstoken.length>0)
                {
                    NSMutableURLRequest *request =
                    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/?access_token=%@",Ins_ShareAccesstoken]]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                        timeoutInterval:10];
                    [request setHTTPMethod:@"GET"];
                    NSData *instReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
                    NSString *instResponse = [[NSString alloc] initWithData:instReturnData encoding:NSUTF8StringEncoding];
                    instResponse = [instResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    isInstagramLoggedIn = YES;
                }
                else
                {
                    //NSLog(@"SharingView webView no accesstoken");
                }
            }
            [ApplicationDelegate.hudd hide:YES];
            [webView removeFromSuperview];
            return NO;
        }
       return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ApplicationDelegate.hudd hide:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    /*
    if (isInstagram_BtnOn) {
        if (isInstagramLoggedIn)
            [user_Instagram_Switch setOn:YES];
        else
            [user_Instagram_Switch setOn:NO];
    }

    if (isViewInstagram_BtnOn) {
        if (isInstagramLoggedIn)
            [viewUser_Instagram_Switch setOn:YES];
        else
            [viewUser_Instagram_Switch setOn:NO];
    }
    
    [self saveSharingSettings];
    isInstagram_BtnOn = NO;
    isViewInstagram_BtnOn = NO;
    isInstagramLoggedIn = NO;
    */
}

- (IBAction)recTimeChanged:(id)sender {
    self.recTimeInSecs = (UISlider *)sender;
    NSInteger intRecTimeInSecs = lround(self.recTimeInSecs.value);
    NSString *strRecTimeInSecs = [NSString stringWithFormat: @"%d", (int)intRecTimeInSecs];
    TellemGlobals *tM = [TellemGlobals globalsManager];
    tM.gPostRecordingTimeInSecs = strRecTimeInSecs;
};

- (IBAction)openEULA:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kEULALink]];
}

@end
