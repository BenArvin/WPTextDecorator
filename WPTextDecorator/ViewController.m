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
#import "WPTDTextView.h"

#define WIDTH_BUTTON             40
#define WIDTH_FIND_BUTTON        60
#define WIDTH_REPLACE_BUTTON     75
#define WIDTH_REPLACE_ALL_BUTTON 95

#define HEIGHT_BUTTON            20

#define MARGIN_BORDER_TOP        15
#define MARGIN_BORDER            17
#define MARGIN_SCROLLVIEWS_X     20
#define MARGIN_CHECKBOX_FIND     25
#define MARGIN_FIND_TEXT_BUTTON  0
#define MARGIN_FIND_REPLACE      20

static NSString *const headString = @"<p style=\"text-indent: 2em; margin:0px 0px 0px 0px;\">";
static NSString *const tailString = @"</p>";

@interface ViewController() <NSTextViewDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet NSScrollView *originalScrollView;
@property (unsafe_unretained) IBOutlet WPTDTextView *originalTextView;

@property (weak) IBOutlet NSScrollView *decoratedScrollView;
@property (unsafe_unretained) IBOutlet NSTextView *decoratedTextView;

@property (nonatomic) BOOL findElementsDisplaying;
@property (nonatomic) BOOL shouldRefind;
@property (nonatomic) BOOL currentHighlightedIndex;
@property (nonatomic) NSInteger currentSelectedLocation;
@property (nonatomic) NSMutableArray *findResultRanges;

@property (weak) IBOutlet NSButton *caseSensitiveCheckBox;
@property (weak) IBOutlet NSButton *regularExpressionCheckBox;

@property (weak) IBOutlet NSTextField *findContextTextField;
@property (weak) IBOutlet NSButton *findButton;

@property (weak) IBOutlet NSTextField *replaceContextTextField;
@property (weak) IBOutlet NSButton *replaceButton;
@property (weak) IBOutlet NSButton *replaceAllButton;

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
    self.shouldRefind = YES;
    
    self.originalTextView.delegate = self;
    [self.originalScrollView becomeFirstResponder];
    [self setElementsStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIndentAction) name:WPTDMainMenuIndentActionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuUnindentAction) name:WPTDMainMenuUnindentActionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuFindAction) name:WPTDMainMenuFindActionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuReplaceAction) name:WPTDMainMenuReplaceActionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChangeAction:) name:NSControlTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBecomeFirstResponderAction:) name:WPTDTextViewDidBecomeFirstResponder object:nil];
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

- (void)menuFindAction
{
    [self showFindElements];
}

- (void)menuReplaceAction
{
    [self showFindElements];
}

- (IBAction)caseSensitiveCheckBoxAction:(id)sender
{
    self.shouldRefind = YES;
}

- (IBAction)regularExpressionCheckBoxAction:(id)sender
{
    self.shouldRefind = YES;
}

- (IBAction)findButtonAction:(id)sender
{
    [self findAndSetContextStyle];
}

- (IBAction)replaceButtonAction:(id)sender
{
    
}

- (IBAction)replaceAllButtonAction:(id)sender
{
    NSString *originalString = self.originalTextView.textStorage.mutableString.copy;
    NSRange originalSelectedRange = self.originalTextView.selectedRange;
    
    [self.originalTextView.textStorage.mutableString WPTD_replaceCharactersInAscendingRanges:self.findResultRanges withString:self.replaceContextTextField.stringValue];
    [self cleanAllContextStyle];
    [self.originalTextView setSelectedRange:NSMakeRange(0, 0)];
    self.shouldRefind = YES;
    self.findResultRanges = nil;
    self.currentHighlightedIndex = 0;
    self.currentSelectedLocation = 0;
    
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

- (void)controlTextDidChangeAction:(NSNotification *)notification
{
    if (notification.object == self.findContextTextField) {
        self.shouldRefind = YES;
    }
}

- (void)textViewDidBecomeFirstResponderAction:(NSNotification *)notification
{
    if (notification.object == self.originalTextView) {
        [self cleanAllContextStyle];
    }
}

#pragma mark - NSTextDelegate
- (void)textDidChange:(NSNotification *)notification
{
    self.shouldRefind = YES;
    [self textDidChangeAction];
}

#pragma mark - NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(cancelOperation:)) {
        if (control == self.findContextTextField || control == self.replaceContextTextField) {
            [self hideFindElements];
            return YES;
        }
    } else if (commandSelector == @selector(insertNewline:)) {
        if (control == self.findContextTextField || control == self.replaceContextTextField) {
            [self findAndSetContextStyle];
            return YES;
        }
    }
    return NO;
}

#pragma mark - private method
#pragma mark elements method
- (void)setElementsFrame
{
    CGRect bounds = self.view.bounds;
    
    CGFloat scrollViewOriginY = MARGIN_BORDER + (self.findElementsDisplaying ? 22 : 0);
    CGFloat scrollViewWidth = floor((bounds.size.width - MARGIN_BORDER * 2 - MARGIN_SCROLLVIEWS_X) / 2);
    CGFloat scrollViewHeight = bounds.size.height - scrollViewOriginY - MARGIN_BORDER_TOP;
    
    self.originalScrollView.frame = CGRectMake(MARGIN_BORDER, scrollViewOriginY, scrollViewWidth, scrollViewHeight);
    
    self.decoratedScrollView.frame = CGRectMake(bounds.size.width - MARGIN_BORDER - scrollViewWidth, scrollViewOriginY, scrollViewWidth, scrollViewHeight);

    self.caseSensitiveCheckBox.frame = CGRectMake(18, 5, 110, 30);
    self.regularExpressionCheckBox.frame = CGRectMake(CGRectGetMaxX(self.caseSensitiveCheckBox.frame) + 10, 5, 135, 30);
    
    self.replaceAllButton.frame = CGRectMake(bounds.size.width - 14 - WIDTH_REPLACE_ALL_BUTTON, 4, WIDTH_REPLACE_ALL_BUTTON, 30);
    self.replaceButton.frame = CGRectMake(CGRectGetMinX(self.replaceAllButton.frame) - WIDTH_REPLACE_BUTTON, 4, WIDTH_REPLACE_BUTTON, 30);
    
    CGFloat textFieldWidth = floor((CGRectGetMinX(self.replaceButton.frame) - CGRectGetMaxX(self.regularExpressionCheckBox.frame) - WIDTH_FIND_BUTTON - MARGIN_CHECKBOX_FIND - MARGIN_FIND_TEXT_BUTTON - MARGIN_FIND_REPLACE) / 2);
    
    self.findContextTextField.frame = CGRectMake(CGRectGetMaxX(self.regularExpressionCheckBox.frame) + MARGIN_CHECKBOX_FIND, 10, textFieldWidth, 20);
    self.findButton.frame = CGRectMake(CGRectGetMaxX(self.findContextTextField.frame) + MARGIN_FIND_TEXT_BUTTON, 4, WIDTH_FIND_BUTTON, 30);
    
    self.replaceContextTextField.frame = CGRectMake(CGRectGetMaxX(self.findButton.frame) + MARGIN_FIND_REPLACE, 10, textFieldWidth, 20);

    self.caseSensitiveCheckBox.hidden = !self.findElementsDisplaying;
    self.regularExpressionCheckBox.hidden = !self.findElementsDisplaying;
    self.findContextTextField.hidden = !self.findElementsDisplaying;
    self.findButton.hidden = !self.findElementsDisplaying;
    self.replaceContextTextField.hidden = !self.findElementsDisplaying;
    self.replaceButton.hidden = !self.findElementsDisplaying;
    self.replaceAllButton.hidden = !self.findElementsDisplaying;
}

- (void)setElementsStyle
{
    self.originalTextView.richText = NO;
    self.originalTextView.editable = YES;
    self.originalTextView.selectable = YES;
    self.decoratedTextView.richText = NO;
    self.decoratedTextView.editable = NO;
    self.decoratedTextView.selectable = YES;
    self.decoratedTextView.backgroundColor = [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    self.findContextTextField.delegate = self;
    self.findContextTextField.editable = YES;
    self.replaceContextTextField.delegate = self;
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

#pragma mark find elements method
- (void)showFindElements
{
    if (!self.findElementsDisplaying) {
        self.findElementsDisplaying = YES;
        [self setElementsFrame];
    }
    self.currentSelectedLocation = self.originalTextView.selectedRange.location;
    self.findContextTextField.enabled = YES;
    self.replaceContextTextField.enabled = YES;
    [self.findContextTextField becomeFirstResponder];
}

- (void)hideFindElements
{
    if (!self.findElementsDisplaying) {
        return;
    }
    [self cleanAllContextStyle];
    [self.originalScrollView becomeFirstResponder];
    [self.originalTextView setSelectedRange:NSMakeRange(self.currentSelectedLocation, 0)];
    self.findContextTextField.enabled = NO;
    self.replaceContextTextField.enabled = NO;
    self.findElementsDisplaying = NO;
    [self setElementsFrame];
}

- (void)findAndSetContextStyle
{
    if (self.shouldRefind) {
        [self getFindActionResult];
        self.currentHighlightedIndex = 0;
        self.shouldRefind = NO;
    } else {
        self.currentHighlightedIndex++;
        if (self.currentHighlightedIndex == self.findResultRanges.count) {
            self.currentHighlightedIndex = 0;
        }
    }
    [self styleFindResultWithHighlightedIndex:self.currentHighlightedIndex];
}

- (void)getFindActionResult
{
    NSString *findContext = self.findContextTextField.stringValue;
    NSString *originalContext = self.originalTextView.textStorage.mutableString;
    if (!findContext || findContext.length == 0 || !originalContext || originalContext.length == 0) {
        return;
    }
    NSArray *ranges = nil;
    if (self.regularExpressionCheckBox.cell.state == NSOnState) {
        ranges = [originalContext WPTD_rangesOfRegexp:findContext options:self.caseSensitiveCheckBox.cell.state == NSOnState ? 0 : NSRegularExpressionCaseInsensitive range:NSMakeRange(0, originalContext.length)];
    } else {
        ranges = [originalContext WPTD_rangesOfString:findContext options:self.caseSensitiveCheckBox.cell.state == NSOnState ? NSLiteralSearch : NSCaseInsensitiveSearch range:NSMakeRange(0, originalContext.length)];
    }
    self.findResultRanges = ranges.mutableCopy;
}

- (void)styleFindResultWithHighlightedIndex:(NSInteger)index
{
    NSMutableAttributedString *styledContext = [[NSMutableAttributedString alloc] initWithString:self.originalTextView.textStorage.mutableString];
    for (NSInteger i=0; i<self.findResultRanges.count; i++) {
        NSRange range = NSRangeFromString([self.findResultRanges objectAtIndex:i]);
        if (i == index) {
            [styledContext addAttribute:NSBackgroundColorAttributeName value:[self greenColor] range:range];
            self.currentSelectedLocation = range.location;
        } else {
            [styledContext addAttribute:NSBackgroundColorAttributeName value:[self grayColor] range:range];
        }
    }
    [self.originalTextView.textStorage setAttributedString:styledContext];
}

- (void)cleanAllContextStyle
{
    [self.originalTextView.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.originalTextView.textStorage.mutableString.length)];
}

#pragma mark others
- (NSColor *)grayColor
{
    return [NSColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1];
}

- (NSColor *)greenColor
{
    return [NSColor colorWithRed:0.64 green:0.8 blue:0.99 alpha:1];
}

@end
