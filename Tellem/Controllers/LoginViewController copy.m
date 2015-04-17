//
//  LoginViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 24/03/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterUser.h"
#import "AppDelegate.h"
#import "PAPUtility.h"
#import "HomeViewController.h"
#import "NetworkViewController.h"
#import "PostViewController.h"
#import "AppDelegate.h"
#import "JSON.h"
#import <Parse/PFUser.h>
#import "PAPCache.h"
#import "FHSTwitterEngine.h"
#import "TellemUtility.h"

static NSString *const twitterClientID = @"COPyKvw1MdFFIEYL5CQMfJhub";
static NSString *const twitterClientSecret = @"oLZyYZhseImGU00SnVgTVTqUXOgidEnxr0Ylh1xrrwjCFXBbb2";
static NSString *const instagramAuthUrlString = @"https://instagram.com/oauth/authorize";
static NSString *const instagramClientID = @"38501cdada074d42990b0d433d513df6";
static NSString *const instagramClientSecret = @"0368e7aecdc341bb94072d3e268506aa";
static NSString *const instagramRedirectUri = @"http://mydomain.com/NeverGonnaFindMe/";
NSString *callback = @"http://codegerms.com/callback";


@interface LoginViewController ()
{
    NSMutableArray *twitterrInfo_arr;
}

@end

@implementation LoginViewController

NSString *screen_name ;
NSString *name;

@synthesize stringInstagram;
@synthesize tabBarController,titleLbl,titlImg,textfielImg;
@synthesize isLogin,accessToken,tellemLoginView,resetPasswordView;
@synthesize oauth_token,oauth_token_secret,user_id,screen_name;
@synthesize fbSigninButton,twSigninButton,instSigninButton,tellemSigninButton;

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
    //MWLogDebug(@"\nLoginViewController viewDidLoad: Started.");
    [super viewDidLoad];
    self.navigationItem.title=@"LOGIN";
    self.twSigninButton.hidden=NO;
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    [PFTwitterUtils initializeWithConsumerKey:twitterClientID consumerSecret:twitterClientSecret];
    NSString *userId=[[PFUser currentUser] valueForKey:@"username"];
    NSString *userName=[[PFUser currentUser] valueForKey:@"displayName"];
    
    if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"FB"])
    {
        NSString *timeInSecs = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        [TellemUtility tellemLog:@"LoginViewController viewDidLoad: " andMsgInfo:@[userId,userName, @"user is FB", timeInSecs]];
        if ([[PFUser currentUser]isAuthenticated])
        {
            [self.view.window addSubview:ApplicationDelegate.hudd];
            [ApplicationDelegate.hudd show:YES];
            [PFFacebookUtils logInWithPermissions:@[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"] block:^(PFUser *user, NSError *error)
             {
                 [FBSession setActiveSession:[FBSession activeSession]];
                 [self dismissViewControllerAnimated:NO completion:Nil];
                 [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                 [ApplicationDelegate.hudd hide:YES];
            }];
        }
    }else if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Instagram"])
    {
        NSString *timeInSecs = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        [TellemUtility tellemLog:@"LoginViewController viewDidLoad: " andMsgInfo:@[userId,userName, @"user is Instagram", timeInSecs]];
        if ([[PFUser currentUser]isAuthenticated])
        {
                [self.view.window addSubview:ApplicationDelegate.hudd];
                [ApplicationDelegate.hudd show:YES];
                [self InstaGramUpdateImage];
                [self dismissViewControllerAnimated:YES completion:nil];
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                [ApplicationDelegate.hudd hide:YES];
        }
    }
    else if ([[[PFUser currentUser]valueForKey:@"Accounttype"]isEqualToString:@"Twitter"])
    {
        if ([[PFUser currentUser]isAuthenticated])
        {
            [self.view.window addSubview:ApplicationDelegate.hudd];
            [ApplicationDelegate.hudd show:YES];
            [self dismissViewControllerAnimated:YES completion:Nil];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
            [ApplicationDelegate.hudd hide:YES];
        }
    }
    else
    {
        if ([[PFUser currentUser]isAuthenticated])
        {
            [self.view.window addSubview:ApplicationDelegate.hudd];
            [ApplicationDelegate.hudd show:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
            [ApplicationDelegate.hudd hide:YES];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //MWLogDebug(@"\nLoginViewController viewWillAppear: Started.");
   [super viewWillAppear:YES];
    titleLbl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"title-bg.png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loginview-bg.png"]];
}

- (IBAction)tellemSigninTouched:(id)sender
{
    tellemLoginView = Nil;
    resetPasswordView = Nil;
    tellemLoginView=[[TellemLoginView alloc]initWithFrame:CGRectMake(4, 35, self.view.frame.size.width-8, self.view.frame.size.height-45)];    
    [tellemLoginView.removeViewButton addTarget:self action:@selector(removeLoginViewFromView:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.signinButton addTarget:self action:@selector(submitSignIn:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.registerButton addTarget:self action:@selector(registerNewUser:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.forgotPasswordButton addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.guestButton addTarget:self action:@selector(submitGuestSignIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tellemLoginView];
}

- (IBAction)fbSigninTouched:(id)sender
{
    TellemGlobals *tM = [TellemGlobals globalsManager];
    if (!tM.gFacebookOK)
    {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tellem has technical issues with Facebook. Please use Instagram or Tellem to sign in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [Alert show];
        [self dismissViewControllerAnimated:NO completion:Nil];
        return;
    }
    [self.view.window addSubview:ApplicationDelegate.hudd];

    [ApplicationDelegate.hudd show:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [PFFacebookUtils logInWithPermissions:@[@"user_about_me", @"user_relationships",  @"user_birthday", @"user_location",@"publish_actions", @"publish_stream",] block:^(PFUser *user, NSError *error)
     {
         if(!error)
         {
             [FBSession setActiveSession:[PFFacebookUtils session]];
             [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)
              {
                  if (!error)
                  {
                      NSString *FB_userName=[user valueForKey:@"id"];
                      NSString *FB_Profile=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",[user valueForKey:@"id"]];
                      NSString *str=[user valueForKey:@"name"];
                      [PFUser logInWithUsernameInBackground:[user valueForKey:@"id"] password:[user valueForKey:@"id"] block:^(PFUser *user, NSError *error)
                       {
                           PFUser *usernew = [PFUser currentUser];
                           if (usernew[@"ShareSettings"]==nil)
                           {
                               [usernew setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
                           }else{}
                           if (usernew[@"ViewFriends"]==nil)
                           {
                               [usernew setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ViewFriends"];
                           }else{}
                           usernew.username=FB_userName;
                           usernew.password=FB_userName;
                           [usernew setObject:str forKey:@"displayName"];
                           [usernew setObject:@"FB" forKey:@"Accounttype"];
                           NSData *newdata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",FB_Profile]]];
                           NSString *imgName = [ApplicationDelegate findUniqueSavePath];
                           PFFile *imageFile = [PFFile fileWithName:imgName data:newdata];
                           [usernew setObject:imageFile forKey:@"profilePictureMedium"];
                           [usernew saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                            {
                                if(succeeded)
                                {
                                    [self dismissViewControllerAnimated:NO completion:Nil];
                                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                                    [ApplicationDelegate.hudd hide:YES];
                                }
                                else
                                {
                                    [ApplicationDelegate.hudd hide:YES];
                                }
                            }];
                       }];
                  }
                  else
                  {
                      [ApplicationDelegate.hudd hide:YES];
                      UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                      [Alert show];
                      [self dismissViewControllerAnimated:NO completion:Nil];
                  }
              }];
         }
         else
         {
             [FBSession setActiveSession:[PFFacebookUtils session]];
             [ApplicationDelegate.hudd hide:YES];
             [self dismissViewControllerAnimated:NO completion:Nil];
         }
     }];
}

- (IBAction)instButtonTouched:(id)sender
{
    stringInstagram=@"instagramBtn";
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(4, 35, self.view.frame.size.width-8, self.view.frame.size.height-45)];
    webView.layer.cornerRadius = 8.0;
    webView.layer.masksToBounds = YES;
    webView.layer.borderWidth = 1.0;
    webView.delegate=self;
    activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center=webView.center;
    [webView addSubview:activityIndicator];
    [self.view addSubview:webView];
    
    UIButton *removePicture = [UIButton buttonWithType:UIButtonTypeCustom];
    [removePicture addTarget:self action:@selector(removeInstagramLoginViewFromView:) forControlEvents:UIControlEventTouchUpInside];
    [removePicture setFrame:CGRectMake(webView.frame.origin.x+webView.frame.size.width-37, 8.0f, 30.0f, 30.0f)];
    [removePicture setBackgroundColor:[UIColor clearColor]];
    [[removePicture titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [removePicture setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [removePicture setSelected:NO];
    [webView addSubview:removePicture];
    
    NSString *fullAuthUrlString = [[NSString alloc] initWithFormat:@"%@/?client_id=%@&redirect_uri=%@&response_type=token",instagramAuthUrlString,instagramClientID,instagramClientSecret];
    NSURL *authUrl = [NSURL URLWithString:fullAuthUrlString];
    NSURLRequest *myRequest = [[NSURLRequest alloc] initWithURL:authUrl];
    [webView loadRequest:myRequest];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([stringInstagram isEqualToString:@"instagramBtn"])
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
                str_Accesstoken=[[urlParamatersArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
                NSUserDefaults *Defaults=[NSUserDefaults standardUserDefaults];
                [Defaults setObject:str_Accesstoken forKey:@"InstaGramToken"];
                [Defaults synchronize];
                if (str_Accesstoken.length>0)
                {
                    NSMutableURLRequest *request =
                    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/?access_token=%@",str_Accesstoken]]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                        timeoutInterval:10];
                    [request setHTTPMethod:@"GET"];
                    
                    NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
                    NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
                    Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    instagramUserDetails=[Response JSONValue];
                    instagramId=[[instagramUserDetails valueForKey:@"data"]valueForKey:@"id"];
                    instagramDisplayName=[[instagramUserDetails valueForKey:@"data"]valueForKey:@"username"];
                    
                    [PFUser logInWithUsernameInBackground:instagramId password:instagramId block:^(PFUser *user, NSError *error)
                     {
                         if(error)
                         {
                             PFUser *user = [PFUser user];
                             user.username=instagramId;
                             user.password=instagramId;
                             [user setObject:instagramDisplayName forKey:@"displayName"];
                             [user setObject:@"Instagram" forKey:@"Accounttype"];
                             NSData *newdata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[[instagramUserDetails valueForKey:@"data"]valueForKey:@"profile_picture"]]];
                             NSString *imgname1 = [ApplicationDelegate findUniqueSavePath];
                             PFFile *imageFile1 = [PFFile fileWithName:imgname1 data:newdata];
                             [user setObject:imageFile1 forKey:@"profilePictureMedium"];
                             if (user[@"ShareSettings"]==nil)
                             {
                                 [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
                             }else{}
                             if (user[@"ViewFriends"]==nil)
                             {
                                 [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ViewFriends"];
                             }else{}

                             [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                              {
                                  if(succeeded)
                                  {
                                      //[self instagramFollow];
                                      [self InstaGramImage];
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                      [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                                      [ApplicationDelegate.hudd hide:YES];
                                  }
                                  else
                                  {
                                      [ApplicationDelegate.hudd hide:YES];
                                      UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                      [Alert show];
                                  }
                              }];
                         }
                         else
                         {
                             [self InstaGramUpdateImage];
                             [self dismissViewControllerAnimated:YES completion:nil];
                             [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                             [ApplicationDelegate.hudd hide:YES];

                         }
                     }];
                }
            }
            [webView removeFromSuperview];
            [activityIndicator removeFromSuperview];
            return NO;
        }
    }
    
    return YES;
}

-(void)instagramFollow{
    
    str_Accesstoken=[[NSUserDefaults standardUserDefaults]objectForKey:@"InstaGramToken"];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@",str_Accesstoken]]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
    NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
    Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    followedByInstagram=[Response JSONValue];
    NSArray *instgram_arr=[[followedByInstagram valueForKey:@"data"]valueForKey:@"id"];
    NSMutableArray *Arr_tempids=[[NSMutableArray alloc]init];
    NSError *error = nil;
    PFQuery *query = [PFUser query];
    
    for (int x=0; x<instgram_arr.count; x++) {
        
        [Arr_tempids addObject:[NSString stringWithFormat:@"%d",[[instgram_arr objectAtIndex:x] intValue]]];
        
    }
    [query whereKey:@"username" containedIn:Arr_tempids];
    NSArray *followingArray = [query findObjects];
    
    if (!error) {
        
        for (int i=0; i<followingArray.count; i++) {
            
            PFUser *user_temp=(PFUser *)[followingArray objectAtIndex:i];
            // check if the currentUser is following this user
            PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
            [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:user_temp];
            [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
            [queryIsFollowing setCachePolicy:kPFCachePolicyNetworkOnly];
            int number=[queryIsFollowing countObjects];
            if (number == 0) {
                [PAPUtility followUserEventually:user_temp block:^(BOOL succeeded, NSError *error) {
                    if (!error)
                    {
                    }
                }];
            }
            else
            {
            }
        }
    }
}
-(void)InstaGramUpdateImage
{
    str_Accesstoken=[[NSUserDefaults standardUserDefaults]objectForKey:@"InstaGramToken"];
    PFQuery *query = [PFQuery queryWithClassName:@"UserNetwork"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(objects.count==1)
         {
             PFObject *obj_Temp=(PFObject *)[objects objectAtIndex:0];
             NSMutableURLRequest *request =
             [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@",str_Accesstoken]]
                                     cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                 timeoutInterval:10];
             [request setHTTPMethod:@"GET"];
             
             NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
             NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
             Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             instagramImageArray=[Response JSONValue];
             
             instagramFriendsArray =[[[[instagramImageArray valueForKey:@"data"]valueForKey:@"images"]valueForKey:@"low_resolution"]valueForKey:@"url"];
             instagramId=[[instagramUserDetails valueForKey:@"data"]valueForKey:@"id"];
             [obj_Temp setObject:instagramFriendsArray forKey:@"Instagram"];
             [obj_Temp saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if(!error)
                  {
                      [ApplicationDelegate.hudd hide:YES];
                      [self dismissViewControllerAnimated:NO completion:Nil];
                  }
                  else
                  {
                      UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Error occured while posting to Instagram" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                      [alert show];
                  }
              }];
         }
     }];
}

-(void)InstaGramImage
{
    str_Accesstoken=[[NSUserDefaults standardUserDefaults]objectForKey:@"InstaGramToken"];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@",str_Accesstoken]]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
    NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
    Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    instagramImageArray=[Response JSONValue];
    
    instagramFriendsArray =[[[[instagramImageArray valueForKey:@"data"]valueForKey:@"images"]valueForKey:@"low_resolution"]valueForKey:@"url"];
    instagramId=[[instagramUserDetails valueForKey:@"data"]valueForKey:@"id"];
    
    PFObject *userPost = [PFObject objectWithClassName:@"UserNetwork"];
    [userPost setObject:instagramFriendsArray forKey:@"Instagram"];
    [userPost setObject:[PFUser currentUser].objectId forKey:@"userId"];
    
    [userPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if(!error)
         {
             [ApplicationDelegate.hudd hide:YES];
             [self dismissViewControllerAnimated:NO completion:Nil];
         }
         else
         {
             [ApplicationDelegate.hudd hide:YES];
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Error occured while posting to Instagram" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
     }];
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

- (void)removeLoginViewFromView:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewController];
}


- (void)removeInstagramLoginViewFromView:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewController];
}

- (void)submitPasswordReset:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    //if ([self isEmailValid:resetPasswordView.inputUserName.text] || [self isPhoneValidInUS:resetPasswordView.inputUserName.text])
    if ([self isEmailValid:resetPasswordView.inputUserName.text])
    {
        PFUser* pfUser = [TellemUtility getPFUserWithUserId:resetPasswordView.inputUserName.text];
        BOOL isValid = pfUser ? YES:NO;
        
        if (isValid) {
            [PFUser requestPasswordResetForEmailInBackground:resetPasswordView.inputUserName.text];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"A link to reset your password was emailed to you. Please follow the reset instructions. Thank you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            //[self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:0];
            /* Password resets are done via emails ONLY!
            if ([self isEmailValid:resetPasswordView.inputCelllNumber.text])
            {
                [PFUser requestPasswordResetForEmailInBackground:resetPasswordView.inputCelllNumber.text];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"A link to reset your password was emailed to you. Please follow the reset instructions. Thank you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                //[self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:0];
            }
            else
                if ([self isPhoneValidInUS:resetPasswordView.inputCelllNumber.text])
                {
                    [self sendTemporaryPassword];
                    //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"A temporary password was emailed/texted to you. Please use it to log in next time. Thank you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    //[alert show];
                    //[self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:0];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Cell number is invalid" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alert show];
                    [ApplicationDelegate.hudd hide:YES];
                }
            */
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Email not found in Tellem" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
            [ApplicationDelegate.hudd hide:YES];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Email must be in valid format" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [ApplicationDelegate.hudd hide:YES];
    }
}

- (void)sendTemporaryPassword {
    //NSLog (@"TODO email/text password and update user status");
    [PFInstallation currentInstallation][@"userId"] = resetPasswordView.inputCelllNumber.text;
    [PFInstallation currentInstallation][@"accountType"] = @"Normal";
    [PFInstallation currentInstallation].channels = @[@"Global"];
    [[PFInstallation currentInstallation] saveInBackground];    
    [TellemUtility sendForgottenPasswordToUser:resetPasswordView.inputCelllNumber.text];
}

-(void)dismissAlertView:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
    
}

- (void)submitSignIn:(id)sender {
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    
    if (![self areInputsValid:tellemLoginView.inputUserName.text andPassword:tellemLoginView.inputPassword.text])
    {
        return;
    }
    
    [PFUser logInWithUsernameInBackground:tellemLoginView.inputUserName.text password:tellemLoginView.inputPassword.text
        block:^(PFUser *user, NSError *error)
     {
         if(error!=nil)
         {
             [ApplicationDelegate.hudd hide:YES];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Error logging in. Please check your userid and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return ;
         }
         else
         {
             if (user)
             {
                 double delayInSeconds = 0.1;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                    {
                        [self dismissViewControllerAnimated:YES completion:Nil];
                        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                        [ApplicationDelegate.hudd hide:YES];
                });
             }
             else
             {
                 [ApplicationDelegate.hudd hide:YES];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Error logging in. Please check yoour userid and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
         }
     }];
}



- (void)submitGuestSignIn:(id)sender {
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error)
     {
         if(error!=nil)
         {
             [ApplicationDelegate.hudd hide:YES];
             NSString * msgText = @"Error signing in as guest. Error details:";
             [msgText stringByAppendingString:error.localizedDescription];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:msgText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return ;
         }
         else
         {
             if (user)
             {
                 [user setObject:@"Guest" forKey:@"displayName"];
                 if ([self isEmailValid:tellemLoginView.inputUserName.text]) {
                     user.email = tellemLoginView.inputUserName.text;
                 }                 
                 UIImage *defaultImg=[UIImage imageNamed:@"user.png"];
                 NSData *imageDataMed= UIImageJPEGRepresentation(defaultImg, 0.5);
                 PFFile *imageFileMed = [PFFile fileWithName:@"user.png" data:imageDataMed];
                 [user setObject:imageFileMed forKey:kPAPUserProfilePicMediumKey];
                 [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
                 [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ViewFriends"];
                 [user setObject:@"Normal" forKey:@"Accounttype"];
                 
                 UIImage *newImage = [self resizeImage:defaultImg toWidth:100.0f andHeight:100.0f];
                 NSData *imageDataSmall = UIImageJPEGRepresentation(newImage, 00.5);
                 PFFile *imageFileSmall= [PFFile fileWithName:@"user.png"  data:imageDataSmall];
                 [user setObject:imageFileSmall forKey:kPAPUserProfilePicSmallKey];
                 [user save];

                 double delayInSeconds = 0.1;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                {
                                    [self dismissViewControllerAnimated:YES completion:Nil];
                                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                                    [ApplicationDelegate.hudd hide:YES];
                                });
             }
             else
             {
                 [ApplicationDelegate.hudd hide:YES];
                 NSString * msgText = @"Error signing in as guest. Error details:";
                 [msgText stringByAppendingString:error.localizedDescription];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:msgText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
         }
     }];
}


- (void)registerNewUser:(id)sender {
    
    if (![self areInputsValid:tellemLoginView.inputUserName.text andPassword:tellemLoginView.inputPassword.text])
    {
        return;
    }
    
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    
    PFUser *user = [PFUser user];
    user.username=tellemLoginView.inputUserName.text;
    user.password=tellemLoginView.inputPassword.text;
    [user setObject:tellemLoginView.inputUserName.text forKey:@"displayName"];
    if ([self isEmailValid:tellemLoginView.inputUserName.text]) {
        user.email = tellemLoginView.inputUserName.text;
    }
    
    UIImage *defaultImg=[UIImage imageNamed:@"user.png"];
    NSData *imageDataMed= UIImageJPEGRepresentation(defaultImg, 0.5);
    PFFile *imageFileMed = [PFFile fileWithName:@"user.png" data:imageDataMed];
    [user setObject:imageFileMed forKey:kPAPUserProfilePicMediumKey];
    [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
    [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ViewFriends"];
    [user setObject:@"Normal" forKey:@"Accounttype"];
    
    UIImage *newImage = [self resizeImage:defaultImg toWidth:100.0f andHeight:100.0f];
    NSData *imageDataSmall = UIImageJPEGRepresentation(newImage, 00.5);
    PFFile *imageFileSmall= [PFFile fileWithName:@"user.png"  data:imageDataSmall];
    [user setObject:imageFileSmall forKey:kPAPUserProfilePicSmallKey];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             [ApplicationDelegate.hudd hide:YES];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Congrats! You were successfully signed up!" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
             [alert show];
             [self dismissViewControllerAnimated:YES completion:nil];
             [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
             [ApplicationDelegate.hudd hide:YES];

         }
         else
         {
             [ApplicationDelegate.hudd hide:YES];
             NSString *errorString = [[error userInfo] objectForKey:@"error"];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
     }];

}

- (void)resetPassword:(id)sender {
    resetPasswordView = Nil;
    resetPasswordView=[[TellemForgotPasswordView alloc]initWithFrame:CGRectMake(4, 35, self.view.frame.size.width-8, self.view.frame.size.height-45)];
    [resetPasswordView.removeViewButton addTarget:self action:@selector(removeLoginViewFromView:) forControlEvents:UIControlEventTouchUpInside];
    [resetPasswordView.signinButton addTarget:self action:@selector(submitPasswordReset:) forControlEvents:UIControlEventTouchUpInside];
    [resetPasswordView.returnToSigninButton addTarget:self action:@selector(returnToSignin:) forControlEvents:UIControlEventTouchUpInside];
    resetPasswordView.inputUserName.text = tellemLoginView.inputUserName.text;
    [self.view addSubview:resetPasswordView];
    tellemLoginView = Nil;
}

- (void)returnToSignin:(id)sender {
    tellemLoginView = Nil;
    tellemLoginView=[[TellemLoginView alloc]initWithFrame:CGRectMake(4, 35, self.view.frame.size.width-8, self.view.frame.size.height-45)];
    [tellemLoginView.removeViewButton addTarget:self action:@selector(removeLoginViewFromView:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.signinButton addTarget:self action:@selector(submitSignIn:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.registerButton addTarget:self action:@selector(registerNewUser:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.forgotPasswordButton addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.guestButton addTarget:self action:@selector(submitGuestSignIn:) forControlEvents:UIControlEventTouchUpInside];
    tellemLoginView.inputUserName.text = resetPasswordView.inputUserName.text;
    [self.view addSubview:tellemLoginView];
    resetPasswordView = Nil;
}

-(BOOL) areInputsValid:(NSString *)userId andPassword: (NSString *) password
{
    //if ([self isEmailValid:userId] || [self isPhoneValidInUS:userId])
    if ([self isEmailValid:userId])
    {
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Email must be in valid format" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [ApplicationDelegate.hudd hide:YES];
        return NO;
    }
    
    if (![self isPasswordValid:password])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tellem" message:@"Password must have big and small letters and numbers" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [ApplicationDelegate.hudd hide:YES];
        return NO;
    }
    
    return YES;
}

-(BOOL) isPhoneValidInUS:(NSString *)checkString
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet characterSetWithCharactersInString:@"01234567890"] invertedSet];
    NSRange r = [checkString rangeOfCharacterFromSet: nonNumbers];
    if (r.location == NSNotFound && checkString.length == 10)
    {
        return YES;
    } else
    {
        return NO;
    }
}

-(BOOL) isEmailValid:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid=[emailTest evaluateWithObject:checkString];
    return isValid;
}

-(BOOL) isPasswordValid:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @"^[a-zA-Z0-9]{7,32}$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid=[emailTest evaluateWithObject:checkString];
    return isValid;
}

- (IBAction)twSigninTouched:(id)sender
{
    TellemGlobals *tM = [TellemGlobals globalsManager];
    if (!tM.gTwitterOK)
    {
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Tellem has technical issues with Twitter. Please use Instagram or Tellem to sign in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [Alert show];
        [self dismissViewControllerAnimated:NO completion:Nil];
        return;
    }
    
    //UTellem via x083492
    [PFTwitterUtils initializeWithConsumerKey:@"COPyKvw1MdFFIEYL5CQMfJhub" consumerSecret:@"oLZyYZhseImGU00SnVgTVTqUXOgidEnxr0Ylh1xrrwjCFXBbb2"];
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"COPyKvw1MdFFIEYL5CQMfJhub" andSecret:@"COPyKvw1MdFFIEYL5CQMfJhub"];
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [self getTwitterUserInfo];
        } else {
            NSLog(@"User logged in with Twitter!");
            [self getTwitterUserInfo];
        }
    }];
    /*
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"COPyKvw1MdFFIEYL5CQMfJhub" andSecret:@"COPyKvw1MdFFIEYL5CQMfJhub"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        [self logTimeline];
        [self twitterFollow];
        [self TwitterUpdateImage];
    }];
    [self presentViewController:loginController animated:YES completion:nil];
    */
}

-(NSString *)loadAccessToken
{
        NSString *str=[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@&user_id=%@&screen_name=%@",[PFTwitterUtils twitter].authToken,[PFTwitterUtils twitter].authTokenSecret,[PFTwitterUtils twitter].userId,[PFTwitterUtils twitter].screenName];
        return str;
}

-(void)getTwitterUserInfo
{
    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    NSData *ReturnData =[NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
    NSString *Response = [[NSString alloc] initWithData:ReturnData encoding:NSUTF8StringEncoding];
    Response = [Response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *twResponseArray=[Response JSONValue];

}




//
- (void)logTimeline
{
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    FHSTwitterEngine *twitterEngine = [FHSTwitterEngine sharedEngine];
                    //NSArray *TWData=[twitterEngine getProfileForUsername:[twitterEngine authenticatedUsername] and]  ;
                    NSArray *TWData=[twitterEngine getTimelineForUser:[twitterEngine authenticatedUsername] isID:YES count:1];
                    NSString *uID = [twitterEngine authenticatedID];
                    //NSLog (@"LoginViewController logTimeline TWData: %@", TWData);
                    NSArray *userArray = [(NSDictionary *)TWData valueForKey:@"user"];
                    //NSLog (@"LoginViewController logTimeline userArray: %@", userArray);
                    screen_name = [userArray valueForKey:@"screen_name"];
                    //NSLog (@"LoginViewController logTimeline screen_name: %@", screen_name);
                    NSString *name = [userArray valueForKey:@"name"][0];
                    //NSLog (@"LoginViewController logTimeline name: %@", name);
                    NSString *twitter_Int;
                    twitter_Int=[TWData valueForKey:@"id"];
                    NSString *twitter_Id = [NSString stringWithFormat: @"%@", twitter_Int];
                    //NSLog (@"LoginViewController logTimeline Twitter_Id: %@", Twitter_Id);
                    twitterToken=@"Yes";
                    if([[PFUser currentUser]isAuthenticated])
                    {
                        PFUser *user=[PFUser currentUser];
                        user.username=twitter_Id;
                        user.password=@"123";
                        NSString *profile_image_url_https = [userArray valueForKey:@"profile_image_url_https"][0];
                        //NSLog (@"LoginViewController logTimeline profile_image_url_https: %@", profile_image_url_https);
                        [user setObject:@"Twitter" forKey:@"Accounttype"];
                        [user setObject:name forKey:@"displayName"];
                        NSData *newdata=[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_image_url_https]];
                        NSString *imgName = [ApplicationDelegate findUniqueSavePath];
                        PFFile *imageFilename = [PFFile fileWithName:imgName data:newdata];
                        [user setObject:imageFilename forKey:@"profilePictureMedium"];
                        if (user[@"ShareSettings"]==nil)
                        {
                            [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
                        }
                        if (user[@"ViewFriends"]==nil)
                        {
                            [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ViewFriends"];
                        }
                        
                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                        {
                        if (succeeded)
                        {
                                [self twitterFollow];
                                [self TwitterImage];
                                [self dismissViewControllerAnimated:YES completion:Nil];
                                [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                               [ApplicationDelegate.hudd hide:YES];
                            }
                            else{
                                [ApplicationDelegate.hudd hide:YES];
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert show];
                            }
                        }];
                    }
                    else
                    {
                        [PFUser logInWithUsernameInBackground:twitter_Id password:@"123"
                                                        block:^(PFUser *user, NSError *error)
                         {
                             if(error)
                             {
                                 PFUser *user = [PFUser user];
                                 user.username=twitter_Id;
                                 user.password=@"123";
                                 
                                 [user setObject:@"Twitter" forKey:@"Accounttype"];
                                 [user setObject:[TWData valueForKey:@"name"] forKey:@"displayName"];
                                 NSData *newdata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[TWData valueForKey:@"profile_image_url_https"]]];
                                 NSString *imgname1 = [ApplicationDelegate findUniqueSavePath];
                                 PFFile *imageFile1 = [PFFile fileWithName:imgname1 data:newdata];
                                 [user setObject:imageFile1 forKey:@"profilePictureMedium"];
                                 if (user[@"ShareSettings"]==nil) {
                                     [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
                                 }
                                 if (user[@"ViewFriends"]==nil) {
                                     [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",@"0",nil] forKey:@"ViewFriends"];
                                 }
                                 
                                 [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                  {
                                      if(succeeded)
                                      {
                                          //[self twitterFollow];
                                          //[self TwitterImage];
                                          [self dismissViewControllerAnimated:YES completion:Nil];
                                          [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                                          //[PFTwitterUtils linkUser:[PFUser currentUser]];
                                          [ApplicationDelegate.hudd hide:YES];

                                      }
                                      else
                                      {
                                          [ApplicationDelegate.hudd hide:YES];
                                          UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Error occured while posting to Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                          [alert show];
                                      }
                                      
                                  }];
                             }
                             else
                             {
                                 //[self twitterFollow];
                                 //[self TwitterUpdateImage];
                                 [self dismissViewControllerAnimated:YES completion:Nil];
                                 [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                                 [ApplicationDelegate.hudd hide:YES];

                             }
                         }];
                    }
                }
            });
        }
    });
}
//
- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

-(void)twitterFollow{
    // Check if there is some response data
    NSError *error = nil;
    NSArray *results=[[FHSTwitterEngine sharedEngine]getFriendsIDs];
    NSArray *friendIds_tw =[(NSDictionary *)results objectForKey:@"ids"];
    NSMutableArray *Arr_tempids=[[NSMutableArray alloc]init];
    PFQuery *query = [PFUser query];
    
    for (int x=0; x<friendIds_tw.count; x++) {
        [Arr_tempids addObject:[NSString stringWithFormat:@"%d",[[friendIds_tw objectAtIndex:x] intValue]]];
    }

    [query whereKey:@"username" containedIn:Arr_tempids];
    NSArray *followingArray = [query findObjects];
    if (!error)
    {
        for (int i=0; i<followingArray.count; i++) {
            
            PFUser *user_temp=(PFUser *)[followingArray objectAtIndex:i];
            // Check if the currentUser is following this user
            PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
            [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:user_temp];
            [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
            [queryIsFollowing setCachePolicy:kPFCachePolicyNetworkOnly];
            int number=[queryIsFollowing countObjects];
            if (number == 0) {
                [PAPUtility followUserEventually:user_temp block:^(BOOL succeeded, NSError *error)
                 {
                     if (!error)
                     {
                     }
                 }];
            }
            else
            {
            }
        }
    }
    else{
    }
}
- (void) TwitterImage
{
    // Request access to the Twitter accounts
    NSArray *TWData = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[FHSTwitterEngine sharedEngine].authenticatedUsername isID:NO count:1000];
    twitterPictureArray=[[[TWData valueForKey:@"entities"] valueForKey:@"media"] valueForKey:@"media_url"];
    
    NSMutableArray *mainArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < [twitterPictureArray count]; i++)
    {
        id obj = [twitterPictureArray objectAtIndex:i];
        if (![obj  isKindOfClass:[NSNull class]])
        {
            [mainArray addObject:obj];
        }
    }
    PFObject *userPost = [PFObject objectWithClassName:@"UserNetwork"];
    [userPost setObject:mainArray forKey:@"Twitter"];
    [userPost setObject:[PFUser currentUser].objectId forKey:@"userId"];
    [userPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if(!error)
        {
        }
        else
        {
        }
     }];
    
}
- (void) TwitterUpdateImage
{
    PFObject *obj_Temp;
    NSArray *TWData = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[FHSTwitterEngine sharedEngine].authenticatedUsername isID:NO count:1000];
    
    twitterPictureArray=[[[TWData valueForKey:@"entities"] valueForKey:@"media"] valueForKey:@"media_url"];
    
    NSMutableArray *mainArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < [twitterPictureArray count]; i++)
    {
        id obj = [twitterPictureArray objectAtIndex:i];
        if (![obj  isKindOfClass:[NSNull class]])
        {
            [mainArray addObject:obj];
        }
    }
    
    [obj_Temp setObject:mainArray forKey:@"Twitter"];
    
    [obj_Temp saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if(!error)
         {
             [self dismissViewControllerAnimated:NO completion:Nil];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tellem" message:@"Error occured while posting to Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
     }];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
