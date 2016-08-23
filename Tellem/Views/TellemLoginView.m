//
//  TellemLoginView.m
//  Tellem
//
//  Created by Ed Bayudan on 1/28/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "TellemLoginView.h"


@interface TellemLoginView ()
@end


@implementation TellemLoginView
@synthesize scrollView;
@synthesize inputBackgroundImageView;
@synthesize inputBackgroundImage;
@synthesize removeViewButton;
@synthesize inputUserName;
@synthesize inputPassword;
@synthesize signinButton;
@synthesize registerButton;
@synthesize forgotPasswordButton,guestButton;


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.layer.cornerRadius = 0.0;
        self.layer.borderWidth = 0.0;
        scrollView=[[TPKeyboardAvoidingScrollView alloc]initWithFrame:CGRectMake(30, 60, self.frame.size.width-60, self.frame.size.height-110)];
        scrollView.layer.cornerRadius = 0.0;
        scrollView.layer.masksToBounds = YES;
        scrollView.layer.borderWidth = 0.5;
        [scrollView setScrollEnabled:YES];
        scrollView.backgroundColor = [UIColor whiteColor];
        //To scroll, set the contentsize
        //CGSize scrollViewContentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        //[scrollView setContentSize:scrollViewContentSize];
        [self addSubview:scrollView];
        
        removeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [removeViewButton setFrame:CGRectMake(self.bounds.origin.x+self.bounds.size.width-40, 25.0f, 32.0f, 32.0f)];
        [removeViewButton setBackgroundColor:[UIColor clearColor]];
        [[removeViewButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [removeViewButton setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        [removeViewButton setSelected:NO];
        [self addSubview:removeViewButton];
        
        UILabel *signinLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, scrollView.frame.size.width - 40, 30)];
        [signinLabel setTextColor:[UIColor whiteColor]];
        [signinLabel setBackgroundColor:[UIColor blackColor]];
        [signinLabel setFont:[UIFont fontWithName: kFontBold size: 14.0f]];
        signinLabel.text = @"WELCOME BACK! LOG IN HERE.";
        signinLabel.textAlignment = NSTextAlignmentCenter;
        [scrollView addSubview:signinLabel];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, scrollView.frame.size.width - 40, 20)];
        [userLabel setTextColor:[UIColor blackColor]];
        [userLabel setBackgroundColor:[UIColor clearColor]];
        [userLabel setFont:[UIFont fontWithName: kFontBold size: 10.0f]];
        userLabel.text = @"EMAIL ADDRESS";
        [scrollView addSubview:userLabel];
        
        inputUserName = [[UITextField alloc] initWithFrame:CGRectMake(20, 110, scrollView.frame.size.width - 40, 30)];
        inputUserName.backgroundColor = [UIColor whiteColor];
        inputUserName.layer.borderWidth = 0.5;
        [inputUserName setTextColor:[UIColor blackColor]];
        [inputUserName setFont:[UIFont fontWithName:kFontNormal size:14.0f]];
        inputUserName.delegate=self;
        inputUserName.userInteractionEnabled=YES;
        //inputUserName.placeholder = @"Enter email address";
        //UIToolbar *inputUserNameToolBar = [self configureKeyboardToolbars:inputUserName];
        //inputUserName.inputAccessoryView = inputUserNameToolBar;
        [scrollView addSubview:inputUserName];

        UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, (scrollView.frame.size.width - 40)/2, 20)];
        [passwordLabel setTextColor:[UIColor blackColor]];
        [passwordLabel setBackgroundColor:[UIColor clearColor]];
        [passwordLabel setFont:[UIFont fontWithName: kFontBold size: 10.0f]];
        passwordLabel.text = @"PASSWORD";
        [scrollView addSubview:passwordLabel];
        
        inputPassword = [[UITextField alloc]  initWithFrame:CGRectMake(20, 180, scrollView.frame.size.width - 40, 30)];
        inputPassword.secureTextEntry = YES;
        inputPassword.backgroundColor = [UIColor whiteColor];
        inputPassword.layer.borderWidth = 0.5;
        [inputPassword setTextColor:[UIColor blackColor]];
        [inputPassword setFont:[UIFont fontWithName:kFontNormal size:14.0f]];
        inputPassword.delegate=self;
        inputPassword.userInteractionEnabled=YES;
        //UIToolbar *inputPasswordToolBar = [self configureKeyboardToolbars:inputPassword];
        //inputPassword.inputAccessoryView = inputPasswordToolBar;
        [scrollView addSubview:inputPassword];
        
        forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [forgotPasswordButton setFrame:CGRectMake(inputPassword.frame.size.width - 20, 160, 40, 20)];
        [forgotPasswordButton setBackgroundColor:[UIColor whiteColor]];
        [forgotPasswordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [forgotPasswordButton setTitle:@"FORGOT?" forState:UIControlStateNormal];
        [forgotPasswordButton.titleLabel setFont:[UIFont fontWithName:kFontThin size:10.0f]];
        [forgotPasswordButton setSelected:NO];
        forgotPasswordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [scrollView addSubview:forgotPasswordButton];
        
        signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [signinButton setFrame:CGRectMake(inputPassword.frame.size.width - 40, 230, 60, 25)];
        [signinButton setBackgroundColor:[UIColor blackColor]];
        [signinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [signinButton setTitle:@"LOGIN" forState:UIControlStateNormal];
        [signinButton.titleLabel setFont:[UIFont fontWithName:kFontBold size:14.0f]];
        [signinButton setSelected:NO];
        signinButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [scrollView addSubview:signinButton];
        
        registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [registerButton setFrame:CGRectMake(30, scrollView.frame.size.height +80, scrollView.frame.size.width, 30.0)];
        [registerButton setBackgroundColor:[UIColor blackColor]];
        [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerButton setTitle:@"NEW TO COOLMIX? LET'S SIGN YOU UP!" forState:UIControlStateNormal];
        [registerButton.titleLabel setFont:[UIFont fontWithName:kFontBold size:14.0f]];
        [registerButton setSelected:NO];
        [self addSubview:registerButton];
        
    }
    
    return self;
}

-(UIToolbar*)configureKeyboardToolbars: (UITextField*) textField
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.window.frame.size.width, 40.0f)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        toolBar.barTintColor = [UIColor grayColor];
        toolBar.tintColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.64f alpha:1.0f];
    }
    else
    {
        toolBar.barTintColor = [UIColor grayColor];
        toolBar.tintColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.64f alpha:1.0f];
    }
    toolBar.translucent = NO;
    toolBar.items =   @[ [[UIBarButtonItem alloc] initWithTitle:@"."
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"@"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"_"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"#"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"$"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"("
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@")"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"_"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"*"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"+"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         ];
    
    return toolBar;
}

-(IBAction)barButtonAddText:(UIBarButtonItem*)sender
{
    if (self.inputUserName.isFirstResponder)
    {
        [self.inputUserName insertText:sender.title];
    }
    else if (self.inputPassword.isFirstResponder)
    {
        [self.inputPassword insertText:sender.title];
    }
}



@end
