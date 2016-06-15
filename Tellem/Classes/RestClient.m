//
//  RestClient.h
//  Tellem
//
//  Created by Ed Bayudan on 1/31/15.
//  Copyright (c) 2015 Tellem, LLC All rights reserved.
//

#import "RestClient.h"

@implementation RestClient
@synthesize circleLabel;
@synthesize nameLabel;
@synthesize circleName;
@synthesize circleType;
@synthesize pfCircle;
@synthesize circleImage;
@synthesize circleButton;

- (void)loginToMix
{
    
    //NSString *requestURL = @"http://localhost:8080/userApi/user/";
    NSString *requestURL = @"http://162.243.212.149:8080/v1.0/userApi/user/";
    //NSString *requestURL = @"http://98.109.52.18:8080";
    NSString *requestUser = @"Martin";
    NSString *requestPassword = @"Roseland00";
    
    //fullRequest = [requestUser stringByAppendingString:requestColon];
    //fullRequest = [fullRequest stringByAppendingString:requestPassword];
    //fullRequest = [fullRequest stringByAppendingString:requestAt];
    //fullRequest = [fullRequest stringByAppendingString:requestURL];
    
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullRequest]];
    
    //NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullRequest] cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    //[request setHTTPMethod:@"GET"];
    
    NSString *escapedURL = [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"escapedURL: %@", escapedURL);
    
    
    NSURL *url = [NSURL URLWithString:escapedURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:requestUser andPassword:requestPassword];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         NSLog(@"data: %@", data);
         NSLog(@"connectionError: %@", connectionError);
         
         if (data.length > 0 && connectionError == nil)
         {
             NSLog(@"data: %@", data);
             NSString *decodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"data: %@", decodedData);
             
             NSArray *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
             
             //NSArray *items =[userData objectAtIndex:0];
             for (NSDictionary *item in userData) {
                 NSString *id = [item objectForKey:@"id"];
                 NSLog(@"id: %@",id);
                 NSString *age = [item objectForKey:@"age"];
                 NSLog(@"age: %@",age);
                 NSString *email = [item objectForKey:@"email"];
                 NSLog(@"email: %@",email);
                 NSString *name = [item objectForKey:@"name"];
                 NSLog(@"name: %@",name);
             }
         }
     }];
    
}

- (void)getImageFromMix
{
    
    NSString *requestURL = @"http://162.243.212.149:8080/v1.0/userApi/getImage/test11-uploaded.jpg/";
    NSString *requestUser = @"Martin";
    NSString *requestPassword = @"Roseland00";
    NSString *escapedURL = [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"escapedURL: %@", escapedURL);
    
    NSURL *url = [NSURL URLWithString:escapedURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:requestUser andPassword:requestPassword];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         NSLog(@"data: %@", data);
         NSLog(@"connectionError: %@", connectionError);
         
         if (data.length > 0 && connectionError == nil)
         {
             NSLog(@"data: %@", data);
             UIImage *img = [UIImage imageWithData:data];
             NSString *decodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"data: %@", decodedData);
             
             NSArray *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
             
             for (NSDictionary *item in userData) {
                 NSString *id = [item objectForKey:@"id"];
                 NSLog(@"id: %@",id);
                 NSString *age = [item objectForKey:@"age"];
                 NSLog(@"age: %@",age);
                 NSString *email = [item objectForKey:@"email"];
                 NSLog(@"email: %@",email);
                 NSString *name = [item objectForKey:@"name"];
                 NSLog(@"name: %@",name);
             }
         }
     }];
    
}

- (void)postToMix
{
    
    NSString *requestURL = @"http://162.243.212.149:8080/v1.0/userApi/uploadImage/";
    NSString *requestUser = @"Martin";
    NSString *requestPassword = @"Roseland00";
    NSString *boundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSString* fileParamConstant = @"file";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryConstant];
    
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* bodyParams = [[NSMutableDictionary alloc] init];
    [bodyParams setObject:@"1.0" forKey:@"ver"];
    [bodyParams setObject:@"en" forKey:@"lan"];
    [bodyParams setObject:[NSString stringWithFormat:@"%@", requestUser] forKey:@"userId"];
    [bodyParams setObject:[NSString stringWithFormat:@"%@",@"image"] forKey:@"title"];
    
    
    NSString *escapedURL = [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"escapedURL: %@", escapedURL);
    
    NSURL *url = [NSURL URLWithString:escapedURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:requestUser andPassword:requestPassword];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *requestBody = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in bodyParams) {
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[[NSString stringWithFormat:@"%@\r\n", [bodyParams objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"custom_gift_circle.png"], 1.0);
    NSData *encodedImage = [imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if (imageData) {
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", fileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:encodedImage];
        [requestBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [requestBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:requestBody];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBody length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         NSLog(@"data: %@", data);
         NSLog(@"connectionError: %@", connectionError);
         
         if (data.length > 0 && connectionError == nil)
         {
             NSLog(@"data: %@", data);
             NSString *decodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"data: %@", decodedData);
             
             NSArray *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
             
             for (NSDictionary *item in userData) {
                 NSString *id = [item objectForKey:@"id"];
                 NSLog(@"id: %@",id);
                 NSString *age = [item objectForKey:@"age"];
                 NSLog(@"age: %@",age);
                 NSString *email = [item objectForKey:@"email"];
                 NSLog(@"email: %@",email);
                 NSString *name = [item objectForKey:@"name"];
                 NSLog(@"name: %@",name);
             }
         }
     }];
    
}

- (UIImage*)getTestImageFromMix
{
    UIImage *imgToReturn = nil;
    NSString *requestURL = @"http://162.243.212.149:8080/v1.0/userApi/getImage/test11-uploaded.jpg/";
    NSString *requestUser = @"Martin";
    NSString *requestPassword = @"Roseland00";
    NSString *escapedURL = [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:escapedURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:requestUser andPassword:requestPassword];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        NSData *decodedData = [[NSData alloc]initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *img = [UIImage imageWithData:decodedData];
        imgToReturn = img;
    }
    
    return imgToReturn;
    
}

- (UIImage*)getImageFromMix: (NSString *) serverURL andServerUser: (NSString*) serverUser andServerPassword: (NSString*) serverPassword andImageFilePath: (NSString *) imageFilePath andImageFileName: (NSString *) imageFileName
{
    UIImage *imgToReturn = nil;
    NSString *requestURL = [NSString stringWithFormat: @"%@%@%@/", serverURL, @"/userApi/getImage/", imageFileName];

    NSString *requestUser = serverUser;
    NSString *requestPassword = serverPassword;
    NSString *escapedURL = [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:escapedURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [NSMutableURLRequest basicAuthForRequest:request withUsername:requestUser andPassword:requestPassword];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        //NSData *decodedData = [[NSData alloc]initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *img = [UIImage imageWithData:data];
        imgToReturn = img;
    }
    
    return imgToReturn;
    
}


@end
