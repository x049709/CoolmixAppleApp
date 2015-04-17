//
//  NSString+WordAt.m
//  Tellem
//
//  Created by Sanjay on 02/07/14.
//  Copyright (c) 2014 Tellem, LLC. All rights reserved.
//

#import "NSString+WordAt.h"

@implementation NSString (WordAt)
- (NSString *) wordAtIndex:(NSInteger) index {
    if (index < 0 || index >= self.length)
        [NSException raise:NSInvalidArgumentException
                    format:@"Index out of range"];
    
    // This definition considers all punctuation as word characters, but you
    // can define the set exactly how you like
    NSCharacterSet *wordCharacterSet =
    [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
    
    // 1. If [self characterAtIndex:index] is not a word character, find
    // the previous word. If there is no previous word, find the next word.
    // If there are no words at all, return nil.
    NSInteger adjustedIndex = index;
    while (adjustedIndex < self.length &&
           ![wordCharacterSet characterIsMember:
             [self characterAtIndex:adjustedIndex]])
        ++adjustedIndex;
    if (adjustedIndex == self.length) {
        do
            --adjustedIndex;
        while (adjustedIndex >= 0 &&
               ![wordCharacterSet characterIsMember:
                 [self characterAtIndex:adjustedIndex]]);
        if (adjustedIndex == -1)
            return nil;
    }
    
    // 2. Starting at adjustedIndex which is a word character, find the
    // beginning and end of the word
    NSInteger beforeBeginning = adjustedIndex;
    while (beforeBeginning >= 0 &&
           [wordCharacterSet characterIsMember:
            [self characterAtIndex:beforeBeginning]])
        --beforeBeginning;
    
    NSInteger afterEnd = adjustedIndex;
    while (afterEnd < self.length &&
           [wordCharacterSet characterIsMember:
            [self characterAtIndex:afterEnd]])
        ++afterEnd;
    
    NSRange range = NSMakeRange(beforeBeginning + 1,
                                afterEnd - beforeBeginning - 1);
    return [self substringWithRange:range];
}
@end
