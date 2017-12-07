//
//  ViewController.m
//  WPTextDecorator
//
//  Created by BenArvin on 2017/12/4.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    self.originalTextView.delegate = self;
    [self setElementsStyle];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    [self setElementsFrame];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

#pragma mark - NSTextDelegate
- (void)textDidChange:(NSNotification *)notification
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
    self.decoratedTextView.editable = YES;
    self.decoratedTextView.selectable = YES;
}

#pragma mark text method
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
