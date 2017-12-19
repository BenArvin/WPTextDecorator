//
//  NSMutableString+WPTDCategory.h
//  WPTextDecorator
//
//  Created by nds on 2017/12/14.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (WPTDCategory)

- (void)WPTD_replaceCharactersInAscendingRanges:(NSArray *)ranges withString:(NSString *)replacement;
- (void)WPTD_replaceOccurrencesOfRegexp:(NSString *)regexp withString:(NSString *)replacement options:(NSRegularExpressionOptions)options range:(NSRange)range;

@end
