//
//  TellemSignupInterestsView.h
//  Tellem
//
//  Created by Ed Bayudan on 1/28/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "TPKeyboardAvoidingScrollView.h"

@interface TellemSignupInterestsView : UIView<UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) UIImageView *inputBackgroundImageView;
@property (nonatomic, strong) UIImage *inputBackgroundImage;
@property (nonatomic, strong) UIButton *removeViewButton;
@property (nonatomic, strong) UITextField *inputFirstName, *inputLastName;
@property (nonatomic, strong) UITextField *inputUserName;
@property (nonatomic, strong) UITextField *inputPassword,*retypePassword;
@property (nonatomic, strong) UIButton *alreadyButton;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) UIButton *sportsButton, *newsButton,*musicButton;
@property (nonatomic, strong) UIButton *entertainmentButton, *lifestyleButton,*techscienceButton;
@property (nonatomic, strong) UIButton *artButton, *gamingButton,*foodButton;
@property (nonatomic, strong) UIButton *fashionButton, *outdoorsadventureButton;

- (id)initWithFrame:(CGRect)frame;
- (UIToolbar*)configureKeyboardToolbars: (UITextField*) textField;


@end
