//
//  ZoomViewController.m
//  Tellem
//
//  Created by Ed Bayudan on 29/02/2012.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "ZoomViewController.h"
#import "AppDelegate.h"

@interface ZoomViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *doneViewButton;


- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;
@end

@implementation ZoomViewController

@synthesize scrollView, imageView, photoToZoom, doneViewButton;

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set a nice title
    self.title = @"PHOTO";
    
    // Set up the image we want to scroll & zoom and add it to the scroll view
    if (!self.photoToZoom) {
        return;
    }
    
    self.imageView = [[UIImageView alloc] initWithImage:self.photoToZoom];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.photoToZoom.size};
    [self.scrollView addSubview:self.imageView];
    
    // Tell the scroll view the size of the contents
    self.scrollView.contentSize = self.photoToZoom.size;
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self allowRotation:YES];
    
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.5f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
    [self addDoneButton];
}

- (BOOL)shouldAutorotate {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait)
    {
        [self.doneViewButton setFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-37, 20.0f, 30.0f, 30.0f)];
    } else
    {
        [self.doneViewButton setFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-37, 10.0f, 30.0f, 30.0f)];
    }
    
    [self centerScrollViewContents];
    return YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.photoToZoom = nil;
    [self allowRotation:NO];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.photoToZoom = nil;
    [self allowRotation:NO];
    // Release any retained subviews of the main view.
}


- (void)addDoneButton
{
    self.doneViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneViewButton setFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-37, 20.0f, 30.0f, 30.0f)];
    [self.doneViewButton setBackgroundColor:[UIColor clearColor]];
    [[self.doneViewButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [self.doneViewButton setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [self.doneViewButton setSelected:NO];
    [self.doneViewButton addTarget:self action:@selector(removeLoginViewFromView:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.doneViewButton];
    
}

- (void)removeLoginViewFromView:(id)sender {
    [self allowRotation:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

-(void) allowRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = restriction;
}

@end
