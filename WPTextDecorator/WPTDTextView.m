//
//  WPTDTextView.m
//  WPTextDecorator
//
//  Created by nds on 2017/12/19.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "WPTDTextView.h"

NSString *const WPTDTextViewDidBecomeFirstResponder = @"WPTDTextViewDidBecomeFirstResponder";

@implementation WPTDTextView

- (BOOL)becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WPTDTextViewDidBecomeFirstResponder object:self];
    }
    return result;
}

@end
