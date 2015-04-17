//
//  Common.h
//  CoolTable
//
//  Created by Ed Bayudan on 3/14/14.
//  Copyright (c) 2014 Tellem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
CGRect rectFor1PxStroke(CGRect rect);
void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
@end
