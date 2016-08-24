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
#import "TellemUtility.h"


@interface LoginViewController ()
{
    NSMutableArray *twitterrInfo_arr;
}

@end

@implementation LoginViewController

@synthesize tabBarController,titleLbl,titlImg,textfielImg;
@synthesize isLogin,tellemLoginView,tellemSignupView,tellemSignupInterestsView,resetPasswordView;
@synthesize user_id;
@synthesize mixSigninButton,shopSigninButton;

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
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName:[UIFont fontWithName:kFontNormal size:22.0] }];
    NSString *userId=[[PFUser currentUser] valueForKey:@"username"];
    NSString *userName=[[PFUser currentUser] valueForKey:@"displayName"];
    
    if ([[PFUser currentUser]isAuthenticated])
    {
        [self.view.window addSubview:ApplicationDelegate.hudd];
        [ApplicationDelegate.hudd show:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
        [ApplicationDelegate.hudd hide:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //MWLogDebug(@"\nLoginViewController viewWillAppear: Started.");
   [super viewWillAppear:YES];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"landingbackground.png"]];
}

- (IBAction)mixSigninTouched:(id)sender
{
    tellemLoginView=[[TellemLoginView alloc]initWithFrame:CGRectMake(4, 0, self.view.frame.size.width-8, self.view.frame.size.height-10)];
    [tellemLoginView.removeViewButton addTarget:self action:@selector(removeView:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.signinButton addTarget:self action:@selector(submitSignIn:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.registerButton addTarget:self action:@selector(showRegisterNewUser:) forControlEvents:UIControlEventTouchUpInside];
    [tellemLoginView.forgotPasswordButton addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tellemLoginView];
}

- (IBAction)shopSigninTouched:(id)sender
{
    [self mixSigninTouched:sender];
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

- (void)removeView:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewController];
}

- (void)submitPasswordReset:(id)sender {
    if ([self isEmailValid:resetPasswordView.inputUserName.text])
    {
        PFUser* pfUser = [TellemUtility getPFUserWithUserId:resetPasswordView.inputUserName.text];
        BOOL isValid = pfUser ? YES:NO;
        
        if (isValid) {
            [PFUser requestPasswordResetForEmailInBackground:resetPasswordView.inputUserName.text];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Coolmix" message:@"A link to reset your password was emailed to you. Please follow the reset instructions. Thank you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:@"Email not found in Tellem" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
            [ApplicationDelegate.hudd hide:YES];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:@"Email must be in valid format" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
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
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:@"Error logging in. Please check your userid and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
                        RestClient *restClient = [[RestClient alloc] init];
                        [restClient postToMix];
                });
             }
             else
             {
                 [ApplicationDelegate.hudd hide:YES];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:@"Error logging in. Please check yoour userid and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:msgText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
                 //[user save];

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
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:msgText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
         }
     }];
}

- (void)showSigninUser:(id)sender {
    
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    [self.tellemSignupView removeFromSuperview];
    [self.view addSubview:tellemLoginView];
    [ApplicationDelegate.hudd hide:YES];
    
}

- (void)showRegisterNewUser:(id)sender {
    
    tellemSignupView=[[TellemSignupView alloc]initWithFrame:CGRectMake(4, 0, self.view.frame.size.width-8, self.view.frame.size.height-10)];
    [tellemSignupView.removeViewButton addTarget:self action:@selector(removeView:) forControlEvents:UIControlEventTouchUpInside];
    [tellemSignupView.signinButton addTarget:self action:@selector(showSigninUser:) forControlEvents:UIControlEventTouchUpInside];
    [tellemSignupView.registerButton addTarget:self action:@selector(showSignupInterests:) forControlEvents:UIControlEventTouchUpInside];
    //[tellemSignupView.registerButton addTarget:self action:@selector(registerNewUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    [self.view addSubview:tellemSignupView];
    [ApplicationDelegate.hudd hide:YES];

}

- (void)showSignupInterests:(id)sender {
    
    tellemSignupInterestsView=[[TellemSignupInterestsView alloc]initWithFrame:CGRectMake(4, 0, self.view.frame.size.width-8, self.view.frame.size.height-10)];
    [tellemSignupInterestsView.removeViewButton addTarget:self action:@selector(removeView:) forControlEvents:UIControlEventTouchUpInside];
    [tellemSignupInterestsView.continueButton addTarget:self action:@selector(showSignupProfilePicture:) forControlEvents:UIControlEventTouchUpInside];
    [tellemSignupInterestsView.alreadyButton addTarget:self action:@selector(showSigninUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    [self.view addSubview:tellemSignupInterestsView];
    [ApplicationDelegate.hudd hide:YES];
    
}

- (void)showSignupProfilePicture:(id)sender {
    
    NSString * msgText = @"Yo man";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:msgText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

- (void)registerNewUser:(id)sender {
    
    if (![self areInputsValid:tellemSignupView.inputUserName.text andPassword:tellemSignupView.inputPassword.text])
    {
        return;
    }
    
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    
    PFUser *user = [PFUser user];
    user.username=tellemSignupView.inputUserName.text;
    user.password=tellemSignupView.inputPassword.text;
    [user setObject:tellemSignupView.inputUserName.text forKey:@"displayName"];
    if ([self isEmailValid:tellemSignupView.inputUserName.text]) {
        user.email = tellemSignupView.inputUserName.text;
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
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Coolmix" message:@"Congrats! You were successfully signed up!" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
             [alert show];
             [self dismissViewControllerAnimated:YES completion:nil];
             [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
             [ApplicationDelegate.hudd hide:YES];
             
         }
         else
         {
             [ApplicationDelegate.hudd hide:YES];
             NSString *errorString = [[error userInfo] objectForKey:@"error"];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    if ([self isEmailValid:userId])
    {
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:@"Email must be in valid format" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [ApplicationDelegate.hudd hide:YES];
        return NO;
    }
    
    if (![self isPasswordValid:password])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coolmix" message:@"Password must have big and small letters and numbers" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
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
