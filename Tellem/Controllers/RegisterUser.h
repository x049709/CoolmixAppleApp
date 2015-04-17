//
//  RegisterUser.h
//  Tellem
//
//  Created by Ed Bayudan on 24/03/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RegisterUser : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIImageView *Profile_Pic;
    UIImageView *Second_Pic;
    UIImageView *Pic_Pic;
    
    IBOutlet UITextField *Text_UserName;
    IBOutlet UITextField *Text_Password;
    IBOutlet UITextField *Text_DisplayName;

    MBProgressHUD *HUD;
}

-(IBAction)Btn_Profile_Pic:(id)sender;

-(IBAction)Btn_Register:(id)sender;

-(IBAction)Btn_Back:(id)sender;

@property (nonatomic, strong) UIImage *image;


@end
