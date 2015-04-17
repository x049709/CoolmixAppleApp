//
//  PAPSettingsActionSheetDelegate.h
//  Anypic
//
//  Created by prateek sahrma on 17/12/2014 .9/12.
//

#import <Foundation/Foundation.h>

@interface PAPSettingsActionSheetDelegate : NSObject <UIActionSheetDelegate>
{
    NSUserDefaults *Defaults;
}

// Navigation controller of calling view controller
@property (nonatomic, strong) UINavigationController *navController;

- (id)initWithNavigationController:(UINavigationController *)navigationController;

@end
