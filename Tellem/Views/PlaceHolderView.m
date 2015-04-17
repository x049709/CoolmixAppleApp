//
//  PlaceHolderView.m
//  Tellem
//
//  Created by Ed Bayudan on 1/28/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "PlaceHolderView.h"
@interface PlaceHolderView ()
@end

@implementation PlaceHolderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Create placeholder
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 15)];
        _placeholderLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:_placeholderLabel];
        
        // Add text changed notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)setPlaceholder:(NSString *)inPlaceholder {
    _placeholderLabel.text = inPlaceholder;
}

- (NSString*)placeholder {
    return _placeholderLabel.text;
}

#pragma mark UITextViewTextDidChangeNotification

- (void)textChanged:(NSNotification *)notification {
    _placeholderLabel.hidden = ([self.text length] == 0);
}

@end