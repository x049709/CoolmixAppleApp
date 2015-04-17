//
//  twitterFriendViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 23/04/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import "TwitterFriendViewController.h"
#import "FHSTwitterEngine.h"
@interface TwitterFriendViewController ()
{
    NSMutableArray *twitt_friends;
    UILabel *Profilename;
    NSMutableArray *TwitterFrnds_name;
    NSMutableArray *arr_Friends;
    NSMutableArray *Frinds_info;
}
@end

@implementation TwitterFriendViewController
@synthesize profileImg,Img;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"data.....%@",Img);
    arr_Friends=[[FHSTwitterEngine sharedEngine]listFriendsForUser:[FHSTwitterEngine sharedEngine].authenticatedID isID:YES withCursor:@"-1"];
    TwitterFrnds_name= [(NSDictionary *)arr_Friends objectForKey:@"users"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    //NSLog(@"data.....%@",Img);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return TwitterFrnds_name.count;;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@",indexPath]];
        profileImg=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 55, 60)];
        [cell addSubview:profileImg];
        
        Profilename =[[UILabel alloc]initWithFrame:CGRectMake(70, 5, 300, 40)];
        [cell addSubview:Profilename];
    }
    Profilename.text = [[TwitterFrnds_name valueForKey:@"name"]objectAtIndex:indexPath.row];
    
//    NSMutableArray *url_arr=[[TwitterFrnds_name valueForKey:@"profile_image_url_https"]objectAtIndex:indexPath.row];
//    
//    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",url_arr]];
//    NSLog(@"url %@",url);
//    NSURLRequest* request = [NSURLRequest requestWithURL:url];
//    
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse * response,
//                                               NSData * data,
//                                               NSError * error) {
//                               if (!error){
//                                   profileImg.image = [UIImage imageWithData:data];
//                                   // do whatever you want with image
//                               }
//                               
//                           }];
    return cell;
}
- (IBAction)doneclicked:(id)sender {
    
    NSString *authId=[Frinds_info valueForKey:@"screen_name"];
    NSData *dataObj = UIImageJPEGRepresentation(Img, 1.0);
    NSMutableArray *twitPic_res= [[FHSTwitterEngine sharedEngine]uploadImageToTwitPic:dataObj withMessage:@"message" twitPicAPIKey:@"c1d12f3924baff015704f6861e44a18b"];
    NSString *twittStr=[twitPic_res valueForKey:@"url"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSString *tweet = twittStr;
             //NSError *returnCode = [[FHSTwitterEngine sharedEngine]postTweet:theWholeString withImageData:imageData];
            id returned = [[FHSTwitterEngine sharedEngine]sendDirectMessage:tweet toUser:authId isID:NO];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSString *message = nil;
            
            if ([returned isKindOfClass:[NSError class]]) {
                NSError *error = (NSError *)returned;
                message = [NSString stringWithFormat:@"Error %ld ",(long)error.code];
                message = [message stringByAppendingString:error.localizedDescription];
            } else {
                message = tweet;
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Tellem" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
            });
        }
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i=0; i<TwitterFrnds_name.count; i++)
    {
        if (indexPath.row==i)
        {
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                Frinds_info= [[(NSDictionary *)arr_Friends objectForKey:@"users"]objectAtIndex:indexPath.row];
            }
        }
    }
}

@end
