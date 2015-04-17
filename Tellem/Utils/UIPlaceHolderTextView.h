//
//  UIPlaceHolderTextView.m
//  Tellem
//
//  Created by Ed Bayudan on 11/5/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIPlaceholderTextView : UITextView

@property (nonatomic, readonly) BOOL showsPlaceholder;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
// Default color is the same as in UITextField

@end