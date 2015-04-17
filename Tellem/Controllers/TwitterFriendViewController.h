//
//  TwitterFriendViewController.h
//  Tellem
//
//  Created by Ed Bayudan on 23/04/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterFriendViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UIImageView *profileImg;

}
- (IBAction)doneclicked:(id)sender;
@property(nonatomic,retain)IBOutlet UIImageView *profileImg;
@property(nonatomic,retain)IBOutlet NSString *ImgString;
@property(nonatomic,retain)IBOutlet UIImage *Img;
@end
