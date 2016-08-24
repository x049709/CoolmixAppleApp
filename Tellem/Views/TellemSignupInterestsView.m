//
//  TellemSignupInterestsView.m
//  Tellem
//
//  Created by Ed Bayudan on 1/28/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "TellemSignupInterestsView.h"


@interface TellemSignupInterestsView ()
@end


@implementation TellemSignupInterestsView
@synthesize scrollView;
@synthesize inputBackgroundImageView;
@synthesize inputBackgroundImage;
@synthesize removeViewButton;
@synthesize inputUserName, inputFirstName, inputLastName;
@synthesize inputPassword,retypePassword;
@synthesize continueButton;
@synthesize alreadyButton;
@synthesize forgotPasswordButton;
@synthesize sportsButton, newsButton, musicButton;
@synthesize entertainmentButton, lifestyleButton, techscienceButton;
@synthesize artButton, gamingButton, foodButton;
@synthesize fashionButton, outdoorsadventureButton;

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
        signupLabel.text = @"WHAT ARE YOU INTERESTED IN?";
        signupLabel.textAlignment = NSTextAlignmentCenter;
        [scrollView addSubview:signupLabel];
        
        UILabel *interestLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, scrollView.frame.size.width - 40, 15)];
        [interestLabel setTextColor:[UIColor blackColor]];
        [interestLabel setBackgroundColor:[UIColor lightGrayColor]];
        [interestLabel setFont:[UIFont fontWithName: kFontBold size: 8.0f]];
        interestLabel.text = @"Add your unique interests";
        [scrollView addSubview:interestLabel];
        
        sportsButton = [self createButtonWithFrame:CGRectMake(20, 90, 60, 15) andTitle:@"SPORTS +"];
        newsButton = [self createButtonWithFrame:CGRectMake(90, 90, 50, 15) andTitle:@"NEWS +"];
        musicButton = [self createButtonWithFrame:CGRectMake(150, 90, 50, 15) andTitle:@"MUSIC +"];
        entertainmentButton = [self createButtonWithFrame:CGRectMake(20, 110, 110, 15) andTitle:@"ENTERTAINMENT +"];
        lifestyleButton = [self createButtonWithFrame:CGRectMake(140, 110, 80, 15) andTitle:@"LIFESTYLE +"];
        techscienceButton = [self createButtonWithFrame:CGRectMake(20, 130, 150, 15) andTitle:@"TECHNOLOGY & SCIENCE +"];
        artButton = [self createButtonWithFrame:CGRectMake(180, 130, 40, 15) andTitle:@"ART +"];
        gamingButton = [self createButtonWithFrame:CGRectMake(20, 150, 60, 15) andTitle:@"GAMING +"];
        foodButton = [self createButtonWithFrame:CGRectMake(90, 150, 50, 15) andTitle:@"FOOD +"];
        fashionButton = [self createButtonWithFrame:CGRectMake(20, 170, 60, 15) andTitle:@"FASHION +"];
        outdoorsadventureButton = [self createButtonWithFrame:CGRectMake(90, 170, 150, 15) andTitle:@"OUTDOORS & ADVENTURE +"];

        continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [continueButton setFrame:CGRectMake(scrollView.frame.size.width - 70, scrollView.frame.size.height - 40, 60, 25)];
        [continueButton setBackgroundColor:[UIColor whiteColor]];
        [continueButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [continueButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
        [continueButton.titleLabel setFont:[UIFont fontWithName:kFontNormal size:10.0f]];
        [continueButton setSelected:NO];
        continueButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [scrollView addSubview:continueButton];
        
        alreadyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [alreadyButton setFrame:CGRectMake(30, scrollView.frame.size.height +80, scrollView.frame.size.width, 30.0)];
        [alreadyButton setBackgroundColor:[UIColor blackColor]];
        [alreadyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [alreadyButton setTitle:@"ALREADY A MIXER? LOG IN HERE." forState:UIControlStateNormal];
        [alreadyButton.titleLabel setFont:[UIFont fontWithName:kFontBold size:14.0f]];
        [alreadyButton setSelected:NO];
        [self addSubview:alreadyButton];
        
    }
    
    return self;
}

- (UIButton*)createButtonWithFrame:(CGRect)frame andTitle:(NSString*)btnTitle
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frame];
    btn.layer.borderWidth = 0.5;
    btn.tag = 0;
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:btnTitle forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:kFontBold size:12.0f]];
    [btn setSelected:NO];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn addTarget:self action:@selector(changeButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    
    
    return btn;
}

- (void)changeButtonColor:(id)sender {
    
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == 0) {
        btn.tag = 1;
        [btn setBackgroundColor:[UIColor blackColor]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        continueButton.tag++;
    } else {
        btn.tag = 0;
        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        continueButton.tag--;
    }
    
    if (continueButton.tag>0) {
        [continueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        [continueButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
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
