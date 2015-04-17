//
//  TellemForgotPasswordView.h
//  Tellem
//
//  Created by Ed Bayudan on 1/28/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "TPKeyboardAvoidingScrollView.h"

@interface TellemForgotPasswordView : UIView<UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) UIImageView *inputBackgroundImageView;
@property (nonatomic, strong) UIImage *inputBackgroundImage;
@property (nonatomic, strong) UIButton *removeViewButton;
@property (nonatomic, strong) UITextField *inputUserName;
@property (nonatomic, strong) UITextField *inputCelllNumber;
@property (nonatomic, strong) UIButton *signinButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) UITextField *inputTemporaryPassword;
@property (nonatomic, strong) UIButton *returnToSigninButton;

- (id)initWithFrame:(CGRect)frame;
- (UIToolbar*)configureKeyboardToolbars: (UITextField*) textField;


@end
