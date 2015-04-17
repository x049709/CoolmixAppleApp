//
//  RegisterUser.m
//  Tellem
//
//  Created by Ed Bayudan on 24/03/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import "RegisterUser.h"
#import <Parse/PFUser.h>
#import <Parse/PFFile.h>
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface RegisterUser ()

@end

@implementation RegisterUser

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbar.png"]];
   // UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]]];
   // self.navigationItem.rightBarButtonItem = item;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

}

-(IBAction)Btn_Register:(id)sender
{
    [self.view.window addSubview:ApplicationDelegate.hudd];
    [ApplicationDelegate.hudd show:YES];
    if ([Text_UserName.text isEqualToString:@""] || [Text_Password.text isEqualToString:@""]|| [Text_DisplayName.text isEqualToString:@""] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register" message:@"Please Enter Complete Details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [ApplicationDelegate.hudd hide:YES];
        return;
    }
    
    if ([Text_Password.text length] < 4)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password" message:@"Password is Short" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [ApplicationDelegate.hudd hide:YES];
        return;
    }
    
    PFUser *user = [PFUser user];
    user.username=Text_UserName.text;
    user.password=Text_Password.text;
    [user setObject:Text_DisplayName.text forKey:@"displayName"];

    NSData *imageData1= UIImageJPEGRepresentation(Profile_Pic.image, 0.5);
    NSString *imgname1 = [ApplicationDelegate findUniqueSavePath];
    PFFile *imageFile1 = [PFFile fileWithName:imgname1 data:imageData1];
    [user setObject:imageFile1 forKey:@"profilePictureMedium"];
    [user setObject:[NSArray arrayWithObjects:@"0",@"0",@"0",nil] forKey:@"ShareSettings"];
    [user setObject:@"Normal" forKey:@"Accounttype"];

     UIImage *newImage = [self resizeImage:self.image toWidth:100.0f andHeight:100.0f];
     NSData *imageData2 = UIImageJPEGRepresentation(newImage, 00.5);
     NSString *imgname2=[ApplicationDelegate findUniqueSavePath];
     PFFile *imagefile2= [PFFile fileWithName:imgname2 data:imageData2];
     [user setObject:imagefile2 forKey:@"profilePictureMedium"];//profilePictureSmall
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             //NSLog(@"Register");
             [ApplicationDelegate.hudd hide:YES];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Register" message:@"Successfully Register" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
             [alert show];
             [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
         }
         else
         {
             [ApplicationDelegate.hudd hide:YES];
             //NSLog(@"Failure");
             NSString *errorString = [[error userInfo] objectForKey:@"error"];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
     }];
}

-(IBAction)Btn_Profile_Pic:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Select image"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel Button"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Photo FromCamera",@"Photo From Gallery", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self photoFromCamera];
            break;
        case 1:
            [self photoFromGallery];
            break;
        default:
            break;
    }
}

-(void)photoFromCamera
{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:Nil];
}
-(void)photoFromGallery
{
    UIImagePickerController *Image_Picker=[[UIImagePickerController alloc]init];
    Image_Picker.delegate=self;
    Image_Picker.allowsEditing=YES;
    Image_Picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:Image_Picker animated:YES completion:Nil];
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *New_Image = [info objectForKey:UIImagePickerControllerOriginalImage];
    Profile_Pic.image = New_Image;
    
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

-(IBAction)Btn_Back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
