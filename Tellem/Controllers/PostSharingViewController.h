//
//  PostSharingViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 09/05/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PostSharingViewController : UIViewController<CLLocationManagerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    
     CLLocationManager *locationManager;
    NSMutableArray *pastUrls;
    NSMutableArray *autocompleteUrls;
    UIImage *IMagePicked;
    NSString *TemporaryString;
    NSMutableArray *savedSearches;
    NSRange rangeat;
    int lengthOfString;

}

@property (nonatomic, retain) NSMutableArray *suggestionArray;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *autocompleteUrls;
@property (nonatomic, retain) UITableView *autocompleteTableView;

@property(nonatomic,retain)IBOutlet NSString *selectedUserAccountType;
@property(nonatomic,retain)IBOutlet NSString *fb_userId;
@property(nonatomic,retain)IBOutlet NSString *tw_userId;
@property(nonatomic,retain)IBOutlet NSString *tw_ScreenName;

@property (strong, nonatomic) IBOutlet UIButton *ShareButton;
- (IBAction)shareButton_clicked:(id)sender;
- (IBAction)SharePhotoSelectButton:(id)sender;
- (IBAction)removeSelectPic:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *postTextView;
@property (strong, nonatomic) IBOutlet UIImageView *SelectImageView;

@end
