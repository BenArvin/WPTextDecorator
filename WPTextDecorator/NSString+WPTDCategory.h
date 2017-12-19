//
//  NSString+WPTDCategory.h
//  WPTextDecorator
//
//  Created by nds on 2017/12/13.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WPTDCategory)

- (NSArray *)WPTD_rangesOfString:(NSString *)string options:(NSStringCompareOptions)options range:(NSRange)range;
- (NSArray *)WPTD_rangesOfRegexp:(NSString *)regexp options:(NSRegularExpressionOptions)options range:(NSRange)range;
- (NSArray <NSTextCheckingResult *> *)WPTD_matchesOfRegexp:(NSString *)regexp options:(NSRegularExpressionOptions)options range:(NSRange)range;

@end
