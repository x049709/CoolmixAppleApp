//
//  TellemSignupView.m
//  Tellem
//
//  Created by Ed Bayudan on 1/28/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "TellemSignupView.h"


@interface TellemSignupView ()
@end


@implementation TellemSignupView
@synthesize scrollView;
@synthesize inputBackgroundImageView;
@synthesize inputBackgroundImage;
@synthesize removeViewButton;
@synthesize inputUserName, inputFirstName, inputLastName;
@synthesize inputPassword,retypePassword;
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
        [self addSubview:scrollView];
        
        removeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [removeViewButton setFrame:CGRectMake(self.bounds.origin.x+self.bounds.size.width-40, 25.0f, 32.0f, 32.0f)];
        [removeViewButton setBackgroundColor:[UIColor clearColor]];
        [[removeViewButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [removeViewButton setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        [removeViewButton setSelected:NO];
        [self addSubview:removeViewButton];
        
        UILabel *signupLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, scrollView.frame.size.width - 40, 30)];
        [signupLabel setTextColor:[UIColor whiteColor]];
        [signupLabel setBackgroundColor:[UIColor blackColor]];
        [signupLabel setFont:[UIFont fontWithName: kFontBold size: 14.0f]];
        signupLabel.text = @"HEY COOLMIXER! SIGN UP HERE.";
        signupLabel.textAlignment = NSTextAlignmentCenter;
        [scrollView addSubview:signupLabel];
        
        float nameWidth = scrollView.frame.size.width - 40;
        UILabel *fNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, nameWidth/2 - 2.5, 20)];
        [fNameLabel setTextColor:[UIColor blackColor]];
        [fNameLabel setBackgroundColor:[UIColor clearColor]];
        [fNameLabel setFont:[UIFont fontWithName: kFontBold size: 10.0f]];
        fNameLabel.text = @"FIRST NAME";
        [scrollView addSubview:fNameLabel];
        
        inputFirstName = [[UITextField alloc] initWithFrame:CGRectMake(20, 90, nameWidth/2 - 2.5, 30)];
        inputFirstName.backgroundColor = [UIColor whiteColor];
        inputFirstName.layer.borderWidth = 0.5;
        [inputFirstName setTextColor:[UIColor blackColor]];
        [inputFirstName setFont:[UIFont fontWithName:kFontNormal size:14.0f]];
        inputFirstName.delegate=self;
        inputFirstName.userInteractionEnabled=YES;
        [scrollView addSubview:inputFirstName];
        
        UILabel *lNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5 + nameWidth/2, 70, nameWidth/2 - 2.5, 20)];
        [lNameLabel setTextColor:[UIColor blackColor]];
        [lNameLabel setBackgroundColor:[UIColor clearColor]];
        [lNameLabel setFont:[UIFont fontWithName: kFontBold size: 10.0f]];
        lNameLabel.text = @"LAST NAME";
        [scrollView addSubview:lNameLabel];
        
        inputLastName = [[UITextField alloc] initWithFrame:CGRectMake(22.5 + nameWidth/2, 90, nameWidth/2 - 2.5, 30)];
        inputLastName.backgroundColor = [UIColor whiteColor];
        inputLastName.layer.borderWidth = 0.5;
        [inputLastName setTextColor:[UIColor blackColor]];
        [inputLastName setFont:[UIFont fontWithName:kFontNormal size:14.0f]];
        inputLastName.delegate=self;
        inputLastName.userInteractionEnabled=YES;
        [scrollView addSubview:inputLastName];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, scrollView.frame.size.width - 40, 20)];
        [userLabel setTextColor:[UIColor blackColor]];
        [userLabel setBackgroundColor:[UIColor clearColor]];
        [userLabel setFont:[UIFont fontWithName: kFontBold size: 10.0f]];
        userLabel.text = @"EMAIL ADDRESS";
        [scrollView addSubview:userLabel];
        
        inputUserName = [[UITextField alloc] initWithFrame:CGRectMake(20, 150, scrollView.frame.size.width - 40, 30)];
        inputUserName.backgroundColor = [UIColor whiteColor];
        inputUserName.layer.borderWidth = 0.5;
        [inputUserName setTextColor:[UIColor blackColor]];
        [inputUserName setFont:[UIFont fontWithName:kFontNormal size:14.0f]];
        inputUserName.delegate=self;
        inputUserName.userInteractionEnabled=YES;
        [scrollView addSubview:inputUserName];

        UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, (scrollView.frame.size.width - 40)/2, 20)];
        [passwordLabel setTextColor:[UIColor blackColor]];
        [passwordLabel setBackgroundColor:[UIColor clearColor]];
        [passwordLabel setFont:[UIFont fontWithName: kFontBold size: 10.0f]];
        passwordLabel.text = @"PASSWORD";
        [scrollView addSubview:passwordLabel];
        
        inputPassword = [[UITextField alloc]  initWithFrame:CGRectMake(20, 210, scrollView.frame.size.width - 40, 30)];
        inputPassword.secureTextEntry = YES;
        inputPassword.backgroundColor = [UIColor whiteColor];
        inputPassword.layer.borderWidth = 0.5;
        [inputPassword setTextColor:[UIColor blackColor]];
        [inputPassword setFont:[UIFont fontWithName:kFontNormal size:14.0f]];
        inputPassword.delegate=self;
        inputPassword.userInteractionEnabled=YES;
        [scrollView addSubview:inputPassword];
        
        UILabel *retypePasswordLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 250, (scrollView.frame.size.width - 40)/2, 20)];
        [retypePasswordLabel setTextColor:[UIColor blackColor]];
        [retypePasswordLabel setBackgroundColor:[UIColor clearColor]];
        [retypePasswordLabel setFont:[UIFont fontWithName: kFontBold size: 10.0f]];
        retypePasswordLabel.text = @"REPEAT PASSWORD";
        [scrollView addSubview:retypePasswordLabel];
        
        retypePassword = [[UITextField alloc]  initWithFrame:CGRectMake(20, 270, scrollView.frame.size.width - 40, 30)];
        retypePassword.secureTextEntry = YES;
        retypePassword.backgroundColor = [UIColor whiteColor];
        retypePassword.layer.borderWidth = 0.5;
        [retypePassword setTextColor:[UIColor blackColor]];
        [retypePassword setFont:[UIFont fontWithName:kFontNormal size:14.0f]];
        retypePassword.delegate=self;
        retypePassword.userInteractionEnabled=YES;
        [scrollView addSubview:retypePassword];
        
        registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [registerButton setFrame:CGRectMake(inputPassword.frame.size.width - 40, 310, 60, 25)];
        [registerButton setBackgroundColor:[UIColor blackColor]];
        [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        [registerButton.titleLabel setFont:[UIFont fontWithName:kFontBold size:14.0f]];
        [registerButton setSelected:NO];
        registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [scrollView addSubview:registerButton];
        
        signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [signinButton setFrame:CGRectMake(30, scrollView.frame.size.height +80, scrollView.frame.size.width, 30.0)];
        [signinButton setBackgroundColor:[UIColor blackColor]];
        [signinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [signinButton setTitle:@"ALREADY A MIXER? LOG IN HERE." forState:UIControlStateNormal];
        [signinButton.titleLabel setFont:[UIFont fontWithName:kFontBold size:14.0f]];
        [signinButton setSelected:NO];
        [self addSubview:signinButton];
        
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
