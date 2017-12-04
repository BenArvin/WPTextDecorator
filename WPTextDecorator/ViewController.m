//
//  ViewController.m
//  WPTextDecorator
//
//  Created by BenArvin on 2017/12/4.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "ViewController.h"

#define WIDTH_BUTTON                 40

#define HEIGHT_BUTTON                20
#define HEIGHT_TAGLABEL              20

#define MARGIN_BORDER_TOP            10
#define MARGIN_BORDER                20
#define MARGIN_BUTTONS_Y             50
#define MARGIN_SCROLLVIEW_BUTTON_X   20
#define MARGIN_SCROLLVIEW_TAGLABEL_Y 10

@interface ViewController()

@property (weak) IBOutlet NSScrollView *originalScrollView;
@property (unsafe_unretained) IBOutlet NSTextView *originalTextView;
@property (weak) IBOutlet NSTextField *originalTagLabel;

@property (weak) IBOutlet NSScrollView *decoratedScrollView;
@property (unsafe_unretained) IBOutlet NSTextView *decoratedTextView;
@property (weak) IBOutlet NSTextField *decoratedTagLabel;

@property (weak) IBOutlet NSButton *decorateButton;
@property (weak) IBOutlet NSButton *recoverButton;

@property (weak) IBOutlet NSImageView *maskImageView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self setElementsStyle];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    [self setElementsFrame];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - selector method

- (IBAction)decorateButtonAction:(id)sender
{
    NSMutableString *originalText = self.originalTextView.textStorage.mutableString;
    if (!originalText || originalText.length == 0) {
        return;
    }
    [self showProgressIndicator];
    __block NSString *result = [NSString stringWithString:originalText];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSDate *startDate = [NSDate date];
        result = [strongSelf decorateText:result];
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        if (duration < 1000) {
            sleep(round((1000 - duration) / 1000));
        }
        __weak typeof(strongSelf) weakSelf2 = strongSelf;
        dispatch_async(dispatch_get_main_queue(), ^(){
            __strong typeof(weakSelf2) strongSelf2 = weakSelf2;
            [strongSelf2.decoratedTextView setString:result];
            [strongSelf2 hideProgressIndicator];
        });
    });
}

- (IBAction)recoverButtonAction:(id)sender
{
    NSMutableString *decoratedText = self.decoratedTextView.textStorage.mutableString;
    if (!decoratedText || decoratedText.length == 0) {
        return;
    }
    [self showProgressIndicator];
    __block NSString *result = [NSString stringWithString:decoratedText];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSDate *startDate = [NSDate date];
        result = [strongSelf recoverText:result];
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        if (duration < 1000) {
            sleep(round((1000 - duration) / 1000));
        }
        __weak typeof(strongSelf) weakSelf2 = strongSelf;
        dispatch_async(dispatch_get_main_queue(), ^(){
            __strong typeof(weakSelf2) strongSelf2 = weakSelf2;
            [strongSelf2.originalTextView setString:result];
            [strongSelf2 hideProgressIndicator];
        });
    });
}

#pragma mark - private method
#pragma mark elements method
- (void)setElementsFrame
{
    CGRect bounds = self.view.bounds;
    
    CGFloat buttonOriginX = floor((bounds.size.width - WIDTH_BUTTON) / 2);
    CGFloat buttonOriginY = floor((bounds.size.height - HEIGHT_BUTTON * 2 - MARGIN_BUTTONS_Y) / 2);
    self.recoverButton.frame = CGRectMake(buttonOriginX, buttonOriginY, WIDTH_BUTTON, HEIGHT_BUTTON);
    self.decorateButton.frame = CGRectMake(buttonOriginX, CGRectGetMaxY(self.recoverButton.frame) + MARGIN_BUTTONS_Y, WIDTH_BUTTON, HEIGHT_BUTTON);
    
    CGFloat scrollViewWidth = (bounds.size.width - WIDTH_BUTTON - MARGIN_BORDER * 2 - MARGIN_SCROLLVIEW_BUTTON_X * 2) / 2;
    CGFloat scrollViewHeight = bounds.size.height - MARGIN_BORDER - MARGIN_BORDER_TOP - HEIGHT_TAGLABEL - MARGIN_SCROLLVIEW_TAGLABEL_Y;
    
    self.originalScrollView.frame = CGRectMake(MARGIN_BORDER, MARGIN_BORDER, scrollViewWidth, scrollViewHeight);
    self.originalTagLabel.frame = CGRectMake(CGRectGetMinX(self.originalScrollView.frame), CGRectGetMaxY(self.originalScrollView.frame) + MARGIN_SCROLLVIEW_TAGLABEL_Y, scrollViewWidth, HEIGHT_TAGLABEL);
    
    self.decoratedScrollView.frame = CGRectMake(bounds.size.width - MARGIN_BORDER - scrollViewWidth, MARGIN_BORDER, scrollViewWidth, scrollViewHeight);
    self.decoratedTagLabel.frame = CGRectMake(CGRectGetMinX(self.decoratedScrollView.frame), CGRectGetMaxY(self.decoratedScrollView.frame) + MARGIN_SCROLLVIEW_TAGLABEL_Y, scrollViewWidth, HEIGHT_TAGLABEL);
    
    self.progressIndicator.frame = CGRectMake(floor((bounds.size.width - self.progressIndicator.bounds.size.width) / 2), floor((bounds.size.height - self.progressIndicator.bounds.size.height) / 2), self.progressIndicator.bounds.size.width, self.progressIndicator.bounds.size.height);
    
    self.maskImageView.frame = CGRectZero;
}

- (void)setElementsStyle
{
    self.originalTagLabel.alignment = NSTextAlignmentLeft;
    [self.originalTagLabel setStringValue:@"original text"];
    
    self.decoratedTagLabel.alignment = NSTextAlignmentRight;
    [self.decoratedTagLabel setStringValue:@"decorated text"];
    
    self.maskImageView.wantsLayer = YES;
    self.maskImageView.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.45].CGColor;
    [self.maskImageView setAlphaValue:0.0];
    
    self.progressIndicator.hidden = YES;
    [self.progressIndicator stopAnimation:nil];
    self.progressIndicator.controlSize = NSControlSizeRegular;
    
    self.originalTextView.editable = YES;
    self.originalTextView.selectable = YES;
    self.decoratedTextView.editable = YES;
    self.decoratedTextView.selectable = YES;
}

#pragma mark text method
- (NSString *)decorateText:(NSString *)originalText
{
    if (!originalText || originalText.length == 0) {
        return @"";
    }
    
    if ([originalText rangeOfString:@"\n"].location == NSNotFound) {
        return originalText;
    }
    
    NSMutableString *result = [NSMutableString stringWithString:originalText];
    [result replaceOccurrencesOfString:@"\n" withString:@"</p>\n<p style=\"text-indent: 2em\">" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result insertString:@"<p style=\"text-indent: 2em\">" atIndex:0];
    [result appendString:@"</p>"];
    return result;
}

- (NSString *)recoverText:(NSString *)decoratedText
{
    if (!decoratedText || decoratedText.length == 0) {
        return @"";
    }
    
    NSMutableString *result = [NSMutableString stringWithString:decoratedText];
    if ([result rangeOfString:@"</p>"].location != NSNotFound) {
        [result replaceOccurrencesOfString:@"</p>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    }
    if ([result rangeOfString:@"<p style=\"text-indent: 2em\">"].location != NSNotFound) {
        [result replaceOccurrencesOfString:@"<p style=\"text-indent: 2em\">" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    }
    return result;
}

#pragma mark progress indicator method
- (void)showProgressIndicator
{
    self.decorateButton.enabled = NO;
    self.recoverButton.enabled = NO;
    self.originalTextView.editable = NO;
    self.originalTextView.selectable = NO;
    self.decoratedTextView.editable = NO;
    self.decoratedTextView.selectable = NO;
    [self.progressIndicator startAnimation:nil];
    self.maskImageView.frame = self.view.bounds;
    [self.maskImageView setAlphaValue:1.0];
    self.progressIndicator.hidden = NO;
}

- (void)hideProgressIndicator
{
    self.decorateButton.enabled = YES;
    self.recoverButton.enabled = YES;
    self.originalTextView.editable = YES;
    self.originalTextView.selectable = YES;
    self.decoratedTextView.editable = YES;
    self.decoratedTextView.selectable = YES;
    [self.progressIndicator stopAnimation:nil];
    self.maskImageView.frame = CGRectZero;
    [self.maskImageView setAlphaValue:0.0];
    self.progressIndicator.hidden = YES;
}

@end
