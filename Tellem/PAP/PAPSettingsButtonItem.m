//
//  PAPSettingsButtonItem.m
//  Anypic
//
//  Created by prateek sahrma on 17/12/20145..
//

#import "PAPSettingsButtonItem.h"

@implementation PAPSettingsButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self = [super initWithCustomView:settingsButton];
    if (self) {
        [settingsButton setBackgroundImage:[UIImage imageNamed:@"setting-icon.png"] forState:UIControlStateNormal];
       [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        [settingsButton setImage:[UIImage imageNamed:@"setting-icon.png"] forState:UIControlStateNormal];
        [settingsButton setImage:[UIImage imageNamed:@"setting-icon.png"] forState:UIControlStateHighlighted];
    }
    
    return self;
}
@end
