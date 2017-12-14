//
//  NSString+WPTDCategory.m
//  WPTextDecorator
//
//  Created by nds on 2017/12/13.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "NSString+WPTDCategory.h"

@implementation NSString (WPTDCategory)

- (NSUInteger)WPTD_countOccurencesOfString:(NSString *)string options:(NSStringCompareOptions)options range:(NSRange)range
{
    NSRange trueRange = range;
    if (trueRange.location == NSNotFound) {
        trueRange = NSMakeRange(0, self.length);
    } else if (trueRange.length == 0) {
        return 0;
    } else if (trueRange.location >= self.length) {
        return 0;
    } else if (trueRange.location + trueRange.length > self.length) {
        trueRange = NSMakeRange(trueRange.location, self.length - trueRange.location);
    }
    
    NSUInteger startLocation = trueRange.location;
    NSUInteger endLocation = trueRange.location + trueRange.length;
    BOOL count = 0;
    BOOL finished = NO;
    do {
        NSRange findResult = [self rangeOfString:string options:options range:NSMakeRange(startLocation, endLocation - startLocation)];
        if (findResult.location == NSNotFound) {
            finished = YES;
        } else {
            count++;
            startLocation = findResult.location + findResult.length;
        }
    } while (!finished);
    
    return count;
}

- (NSArray *)WPTD_rangesOfString:(NSString *)string options:(NSStringCompareOptions)options range:(NSRange)range
{
    NSRange trueRange = range;
    if (trueRange.location == NSNotFound) {
        trueRange = NSMakeRange(0, self.length);
    } else if (trueRange.length == 0) {
        return nil;
    } else if (trueRange.location >= self.length) {
        return nil;
    } else if (trueRange.location + trueRange.length > self.length) {
        trueRange = NSMakeRange(trueRange.location, self.length - trueRange.location);
    }
    
    NSUInteger startLocation = trueRange.location;
    NSUInteger endLocation = trueRange.location + trueRange.length;
    NSMutableArray *result = nil;
    BOOL finished = NO;
    do {
        NSRange findResult = [self rangeOfString:string options:options range:NSMakeRange(startLocation, endLocation - startLocation)];
        if (findResult.location == NSNotFound) {
            finished = YES;
        } else {
            if (!result) {
                result = [[NSMutableArray alloc] init];
            }
            [result addObject:NSStringFromRange(findResult)];
            startLocation = findResult.location + findResult.length;
        }
    } while (!finished);
    return result;
}

- (NSArray <NSTextCheckingResult *> *)WPTD_matchesOfRegexp:(NSString *)regexp options:(NSRegularExpressionOptions)options range:(NSRange)range
{
    if (!regexp || regexp.length == 0) {
        return nil;
    }
    NSRange trueRange = range;
    if (trueRange.location == NSNotFound) {
        trueRange = NSMakeRange(0, self.length);
    } else if (trueRange.length == 0) {
        return nil;
    } else if (trueRange.location >= self.length) {
        return nil;
    } else if (trueRange.location + trueRange.length > self.length) {
        trueRange = NSMakeRange(trueRange.location, self.length - trueRange.location);
    }
    
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexp options:NSRegularExpressionCaseInsensitive error:&error];
    return [expression matchesInString:self options:NSMatchingReportProgress range:trueRange];
}

@end
