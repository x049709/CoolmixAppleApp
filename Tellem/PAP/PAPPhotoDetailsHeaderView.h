//
//  PAPPhotoDetailsHeaderView.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

@protocol PAPPhotoDetailsHeaderViewDelegate;

@interface PAPPhotoDetailsHeaderView : UIView<AVAudioPlayerDelegate>

/*! @name Managing View Properties */

/// The photo displayed in the view
@property (nonatomic, strong, readonly) PFObject *photo;

/// The user that took the photo
@property (nonatomic, strong, readonly) PFUser *photographer;

/// Background audio sound player
@property (strong, nonatomic) AVAudioPlayer *soundPlayer;

/// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

/*! @name Delegate */
@property (nonatomic, strong) id<PAPPhotoDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto;
- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;
- (void)homePhotoDetailsWillDisappear;

@end

/*!
 The protocol defines methods a delegate of a PAPPhotoDetailsHeaderView should implement.
 */
@protocol PAPPhotoDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */
- (void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;
/*!
 Sent to the delegate when the photo is swiped
 @param swipe object
 @param photo object
 */
- (void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didSwipePhotoImage:(UISwipeGestureRecognizer *)swipe photo:(PFObject *)photo;

/*!
 Sent to the delegate when the photo is two finger double tapped
 @param photo object
 */
- (void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didLongPress:(UIImage *)photo;


@end