//
//  NSMutableString+WPTDCategory.m
//  WPTextDecorator
//
//  Created by nds on 2017/12/14.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "NSMutableString+WPTDCategory.h"
#import "NSString+WPTDCategory.h"

@implementation NSMutableString (WPTDCategory)

- (void)WPTD_replaceCharactersInAscendingRanges:(NSArray *)ranges withString:(NSString *)replacement
{
    if (!replacement || !ranges || ranges.count == 0) {
        return;
    }
    NSInteger shiftingCount = 0;
    for (NSString *rangeString in ranges) {
        NSRange range = NSRangeFromString(rangeString);
        range = NSMakeRange(range.location + shiftingCount, range.length);
        if (range.location >= self.length || range.location + range.length > self.length) {
            continue;
        }
        [self replaceCharactersInRange:range withString:replacement];
        shiftingCount = shiftingCount + (replacement.length - range.length);
    }
}

- (void)WPTD_replaceOccurrencesOfRegexp:(NSString *)regexp withString:(NSString *)replacement options:(NSRegularExpressionOptions)options range:(NSRange)range
{
    if (!replacement) {
        return;
    }
    NSArray <NSTextCheckingResult *> *matches = [self WPTD_matchesOfRegexp:regexp options:options range:range];
    if (!matches || matches.count == 0) {
        return;
    }
    NSInteger shiftingCount = 0;
    for (NSTextCheckingResult *matche in matches) {
        NSRange trueRange = NSMakeRange(shiftingCount + matche.range.location, matche.range.length);
        [self replaceCharactersInRange:trueRange withString:replacement];
        shiftingCount = shiftingCount + (replacement.length - matche.range.length);
    }
}

@end
