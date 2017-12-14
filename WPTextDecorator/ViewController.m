//
//  ViewController.m
//  WPTextDecorator
//
//  Created by BenArvin on 2017/12/4.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "NSString+WPTDCategory.m"
#import "NSMutableString+WPTDCategory.h"

#define WIDTH_BUTTON                 40

#define HEIGHT_BUTTON                20
#define HEIGHT_TAGLABEL              20

#define MARGIN_BORDER_TOP            10
#define MARGIN_BORDER                20
#define MARGIN_SCROLLVIEWS_X         20
#define MARGIN_SCROLLVIEW_TAGLABEL_Y 10

static NSString *const headString = @"<p style=\"text-indent: 2em; margin:0px 0px 0px 0px;\">";
static NSString *const tailString = @"</p>";

@interface ViewController() <NSTextViewDelegate>

@property (weak) IBOutlet NSScrollView *originalScrollView;
@property (unsafe_unretained) IBOutlet NSTextView *originalTextView;
@property (weak) IBOutlet NSTextField *originalTagLabel;

@property (weak) IBOutlet NSScrollView *decoratedScrollView;
@property (unsafe_unretained) IBOutlet NSTextView *decoratedTextView;
@property (weak) IBOutlet NSTextField *decoratedTagLabel;

@end

@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    self.originalTextView.delegate = self;
    [self setElementsStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIndentAction) name:WPTDMainMenuIndentActionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuUnindentAction) name:WPTDMainMenuUnindentActionNotification object:nil];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    [self setElementsFrame];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

#pragma mark - selector method
- (void)menuIndentAction
{
    NSString *originalString = self.originalTextView.textStorage.mutableString.copy;
    NSRange originalSelectedRange = self.originalTextView.selectedRange;
    BOOL successed = [self indentWithSelectedRange:NSStringFromRange(self.originalTextView.selectedRange)];
    if (successed) {
        [self textDidChangeAction];
        [self.originalTextView.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
            if ([target respondsToSelector:@selector(resetContext:selectedRange:)]) {
                [target resetContext:originalString selectedRange:originalSelectedRange];
            }
            if ([target respondsToSelector:@selector(textDidChangeAction)]) {
                [target textDidChangeAction];
            }
        }];
    }
}

- (void)menuUnindentAction
{
    NSString *originalString = self.originalTextView.textStorage.mutableString.copy;
    NSRange originalSelectedRange = self.originalTextView.selectedRange;
    BOOL successed = [self unindentWithSelectedRange:NSStringFromRange(self.originalTextView.selectedRange)];
    if (successed) {
        [self textDidChangeAction];
        [self.originalTextView.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
            if ([target respondsToSelector:@selector(resetContext:selectedRange:)]) {
                [target resetContext:originalString selectedRange:originalSelectedRange];
            }
            if ([target respondsToSelector:@selector(textDidChangeAction)]) {
                [target textDidChangeAction];
            }
        }];
    }
}

#pragma mark - NSTextDelegate
- (void)textDidChange:(NSNotification *)notification
{
    [self textDidChangeAction];
}

#pragma mark - private method
#pragma mark elements method
- (void)setElementsFrame
{
    CGRect bounds = self.view.bounds;
    CGFloat scrollViewWidth = floor((bounds.size.width - MARGIN_BORDER * 2 - MARGIN_SCROLLVIEWS_X) / 2);
    CGFloat scrollViewHeight = bounds.size.height - MARGIN_BORDER - MARGIN_BORDER_TOP - HEIGHT_TAGLABEL - MARGIN_SCROLLVIEW_TAGLABEL_Y;
    
    self.originalScrollView.frame = CGRectMake(MARGIN_BORDER, MARGIN_BORDER, scrollViewWidth, scrollViewHeight);
    self.originalTagLabel.frame = CGRectMake(CGRectGetMinX(self.originalScrollView.frame), CGRectGetMaxY(self.originalScrollView.frame) + MARGIN_SCROLLVIEW_TAGLABEL_Y, scrollViewWidth, HEIGHT_TAGLABEL);
    
    self.decoratedScrollView.frame = CGRectMake(bounds.size.width - MARGIN_BORDER - scrollViewWidth, MARGIN_BORDER, scrollViewWidth, scrollViewHeight);
    self.decoratedTagLabel.frame = CGRectMake(CGRectGetMinX(self.decoratedScrollView.frame), CGRectGetMaxY(self.decoratedScrollView.frame) + MARGIN_SCROLLVIEW_TAGLABEL_Y, scrollViewWidth, HEIGHT_TAGLABEL);
}

- (void)setElementsStyle
{
    self.originalTagLabel.alignment = NSTextAlignmentLeft;
    [self.originalTagLabel setStringValue:@"original text"];
    
    self.decoratedTagLabel.alignment = NSTextAlignmentRight;
    [self.decoratedTagLabel setStringValue:@"decorated text"];
    
    self.originalTextView.richText = NO;
    self.originalTextView.editable = YES;
    self.originalTextView.selectable = YES;
    self.decoratedTextView.richText = NO;
    self.decoratedTextView.editable = NO;
    self.decoratedTextView.selectable = YES;
    self.decoratedTextView.backgroundColor = [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
}

#pragma mark textView method
- (void)textDidChangeAction
{
    NSMutableString *originalText = self.originalTextView.textStorage.mutableString;
    if (!originalText) {
        [self.decoratedTextView setString:@""];
        return;
    } else {
        __block NSString *result = [NSString stringWithString:originalText];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            result = [strongSelf decorateText:result];
            __weak typeof(strongSelf) weakSelf2 = strongSelf;
            dispatch_async(dispatch_get_main_queue(), ^(){
                __strong typeof(weakSelf2) strongSelf2 = weakSelf2;
                [strongSelf2.decoratedTextView setString:result];
            });
        });
    }
}

- (void)resetContext:(NSString *)context selectedRange:(NSRange)selectedRange
{
    NSString *originalString = self.originalTextView.textStorage.mutableString.copy;
    NSRange originalSelectedRange = self.originalTextView.selectedRange;
    
    [self.originalTextView setString:context];
    [self.originalTextView setSelectedRange:selectedRange];
    
    [self.originalTextView.undoManager registerUndoWithTarget:self handler:^(id  _Nonnull target) {
        if ([target respondsToSelector:@selector(resetContext:selectedRange:)]) {
            [target resetContext:originalString selectedRange:originalSelectedRange];
        }
        if ([target respondsToSelector:@selector(textDidChangeAction)]) {
            [target textDidChangeAction];
        }
    }];
}

- (BOOL)indentWithSelectedRange:(NSString *)selectedRangeString
{
    if (!selectedRangeString || selectedRangeString.length == 0) {
        return NO;
    }
    NSRange selectedRange = NSRangeFromString(selectedRangeString);
    if (selectedRange.location == NSNotFound || selectedRange.length == 0) {
        return NO;
    }
    NSMutableString *resultText = self.originalTextView.textStorage.mutableString;
    NSRange paragraphRange = [self convertToParagraphRange:selectedRange text:resultText];
    
    NSArray <NSTextCheckingResult *> *matchesBeforeSelected = [resultText WPTD_matchesOfRegexp:@"(^|\n)" options:NSRegularExpressionCaseInsensitive range:NSMakeRange(paragraphRange.location, selectedRange.location - paragraphRange.location)];
    NSArray <NSTextCheckingResult *> *matchesInSelected = [resultText WPTD_matchesOfRegexp:@"(\n)" options:NSRegularExpressionCaseInsensitive range:selectedRange];
    
    [resultText replaceOccurrencesOfString:@"\n" withString:@"\n\t" options:NSLiteralSearch range:paragraphRange];
    [resultText insertString:@"\t" atIndex:paragraphRange.location];
    
    [self.originalTextView setString:resultText];
    [self.originalTextView setSelectedRange:NSMakeRange(selectedRange.location + matchesBeforeSelected.count, selectedRange.length + matchesInSelected.count)];

    return YES;
}

- (BOOL)unindentWithSelectedRange:(NSString *)selectedRangeString
{
    if (!selectedRangeString || selectedRangeString.length == 0) {
        return NO;
    }
    NSRange selectedRange = NSRangeFromString(selectedRangeString);
    if (selectedRange.location == NSNotFound || selectedRange.length == 0) {
        return NO;
    }
    
    NSMutableString *resultText = self.originalTextView.textStorage.mutableString;
    NSRange paragraphRange = [self convertToParagraphRange:selectedRange text:resultText];
    
    NSArray <NSTextCheckingResult *> *matches = [resultText WPTD_matchesOfRegexp:@"(^ |^\t|\n |\n\t)" options:NSRegularExpressionCaseInsensitive range:paragraphRange];
    
    NSInteger countBeforeSelected = 0;
    NSInteger countInSelected = 0;
    NSInteger reduction = 0;
    for (NSTextCheckingResult *result in matches) {
        if (result.range.location < selectedRange.location) {
            countBeforeSelected++;
        } else if (result.range.location >= selectedRange.location && result.range.location < selectedRange.location + selectedRange.length) {
            countInSelected++;
        }
        if (result.range.length == 1) {
            [resultText replaceCharactersInRange:NSMakeRange(result.range.location - reduction, 1) withString:@""];
            reduction++;
        } else if (result.range.length == 2) {
            [resultText replaceCharactersInRange:NSMakeRange(result.range.location + 1 - reduction, 1) withString:@""];
            reduction++;
        }
    }
    [self.originalTextView setString:resultText];
    [self.originalTextView setSelectedRange:NSMakeRange(selectedRange.location - countBeforeSelected, selectedRange.length - countInSelected)];
    return YES;
}

#pragma mark text method
- (NSRange)convertToParagraphRange:(NSRange)range text:(NSString *)text
{
    if (range.location == NSNotFound || range.length == 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSUInteger firstFlagLocation = [text rangeOfString:@"\n" options:NSLiteralSearch | NSBackwardsSearch range:NSMakeRange(0, range.location)].location;
    if (firstFlagLocation == NSNotFound) {
        firstFlagLocation = 0;
    } else {
        firstFlagLocation = firstFlagLocation + 1;
    }
    NSUInteger lastFlagLocation = [text rangeOfString:@"\n" options:NSLiteralSearch range:NSMakeRange(range.location + range.length, text.length - range.location - range.length)].location;
    if (lastFlagLocation == NSNotFound) {
        lastFlagLocation = text.length;
    }
    return NSMakeRange(firstFlagLocation, lastFlagLocation - firstFlagLocation);
}

- (NSString *)decorateText:(NSString *)originalText
{
    if (!originalText || originalText.length == 0) {
        return @"";
    }
    
    NSMutableString *result = [NSMutableString stringWithString:originalText];
    if (result.length >= 1) {
        [result replaceOccurrencesOfString:@"\t" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 1)];
    }
    if (result.length >= 4) {
        [result replaceOccurrencesOfString:@"    " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 4)];
    }
    [result replaceOccurrencesOfString:@"\n\t" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\n    " withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    if ([originalText rangeOfString:@"\n"].location != NSNotFound) {
        [result replaceOccurrencesOfString:@"\n" withString:[NSString stringWithFormat:@"%@\n%@", tailString, headString] options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    }
    [result replaceOccurrencesOfString:[NSString stringWithFormat:@"%@%@", headString, tailString] withString:@"<br/>" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result insertString:@"<p style=\"text-indent: 2em; margin:0px 0px 0px 0px;\">" atIndex:0];
    [result appendString:@"</p>"];
    [result replaceOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}

@end
