//
//  TellemForgotPasswordView.m
//  Tellem
//
//  Created by Ed Bayudan on 1/28/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "TellemForgotPasswordView.h"


@interface TellemForgotPasswordView ()
@end


@implementation TellemForgotPasswordView
@synthesize scrollView;
@synthesize inputBackgroundImageView;
@synthesize inputBackgroundImage;
@synthesize removeViewButton;
@synthesize inputUserName;
@synthesize inputCelllNumber;
@synthesize signinButton;
@synthesize registerButton;
@synthesize forgotPasswordButton;
@synthesize inputTemporaryPassword,returnToSigninButton;


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor grayColor]];
        self.layer.cornerRadius = 8.0;
        self.layer.borderWidth = 1.0;
        scrollView=[[TPKeyboardAvoidingScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        scrollView.layer.cornerRadius = 8.0;
        scrollView.layer.masksToBounds = YES;
        scrollView.layer.borderWidth = 1.0;
        [scrollView setScrollEnabled:YES];
        scrollView.backgroundColor = [UIColor grayColor];
        CGSize scrollViewContentSize = CGSizeMake(self.frame.size.width, self.frame.size.height+20);
        [scrollView setContentSize:scrollViewContentSize];
        [self addSubview:scrollView];
        
        removeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [removeViewButton setFrame:CGRectMake(self.bounds.origin.x+self.bounds.size.width-37, 8.0f, 30.0f, 30.0f)];
        [removeViewButton setBackgroundColor:[UIColor clearColor]];
        [[removeViewButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [removeViewButton setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        [removeViewButton setSelected:NO];
        [self addSubview:removeViewButton];
        

        inputBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register-inputs.png"]];
        inputBackgroundImageView.layer.cornerRadius = 8.0;
        inputBackgroundImageView.layer.masksToBounds = YES;

        inputBackgroundImageView.frame=CGRectMake(30, 130, 260, 80);
        inputBackgroundImageView.userInteractionEnabled = YES;
        [scrollView addSubview:inputBackgroundImageView];
        

        inputUserName = [[UITextField alloc] initWithFrame:CGRectMake(46, 5, 200, 30)];
        inputUserName.backgroundColor = [UIColor whiteColor];
        [inputUserName setFont:[UIFont fontWithName:kFontBold size:12.0f]];
        inputUserName.borderStyle=UITextBorderStyleRoundedRect;
        inputUserName.delegate=self;
        inputUserName.userInteractionEnabled=YES;
        inputUserName.placeholder = @"Enter email address";
        UIToolbar *inputUserNameToolBar = [self configureKeyboardToolbars:inputUserName];
        inputUserName.inputAccessoryView = inputUserNameToolBar;
        [inputBackgroundImageView addSubview:inputUserName];

        inputCelllNumber = [[UITextField alloc]  initWithFrame:CGRectMake(46, 45, 200, 30)];
        inputCelllNumber.backgroundColor = [UIColor whiteColor];
        [inputCelllNumber setFont:[UIFont fontWithName:kFontBold size:10.0f]];
        inputCelllNumber.borderStyle=UITextBorderStyleRoundedRect;
        inputCelllNumber.delegate=self;
        inputCelllNumber.userInteractionEnabled=YES;
        inputCelllNumber.placeholder = @"Enter email or cell number to reset password";
        UIToolbar *inputPasswordToolBar = [self configureKeyboardToolbars:inputCelllNumber];
        inputCelllNumber.inputAccessoryView = inputPasswordToolBar;
        inputCelllNumber.hidden = YES;
        
        [inputBackgroundImageView addSubview:inputCelllNumber];
        
        
        signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [signinButton setFrame:CGRectMake(60, 225, 200, 30.0)];
        [signinButton setBackgroundColor:[UIColor clearColor]];
        [signinButton setTitle:@"Reset password" forState:UIControlStateNormal];
        [signinButton setSelected:NO];
        [scrollView addSubview:signinButton];
        
        returnToSigninButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [returnToSigninButton setFrame:CGRectMake(30, 260, 100, 30)];
        [returnToSigninButton setBackgroundColor:[UIColor clearColor]];
        [returnToSigninButton setTitle:@"Return to sign in" forState:UIControlStateNormal];
        [returnToSigninButton.titleLabel setFont:[UIFont fontWithName:kFontThin size:12.0f]];
        [returnToSigninButton setSelected:NO];
        returnToSigninButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [scrollView addSubview:returnToSigninButton];
        

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
    else if (self.inputCelllNumber.isFirstResponder)
    {
        [self.inputCelllNumber insertText:sender.title];
    }
}



@end
