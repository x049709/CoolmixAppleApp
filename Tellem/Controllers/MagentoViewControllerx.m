//
//  MagentoViewController
//  WebViewDemo
//
//  Created by SourceFreeze on 02/07/14.
//  Copyright (c) 2014 Test. All rights reserved.
//

#import "MagentoViewController.h"

@interface MagentoViewController ()

@end

@implementation MagentoViewController

- (void)viewDidLoad
{
    MWLogDebug(@"\nMagentoViewController viewDidLoad started.");
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    MWLogDebug(@"\nMagentoViewController viewWillAppear started.");
    [super viewWillAppear:animated];
    UIWebView *webView = [[UIWebView alloc]init];
    NSString *urlString = @"http://edition.cnn.com/world";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:urlRequest];
    [self.view addSubview:webView];
}

@end
