//
//  WPTDIntroductionViewController.m
//  WPTextDecorator
//
//  Created by nds on 2017/12/19.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "WPTDIntroductionViewController.h"

@interface WPTDIntroductionViewController()

@property (nonatomic) NSTextField *titleTextField;
@property (nonatomic) NSTextField *authorTextField;
@property (nonatomic) NSTextField *versionTextField;
@property (nonatomic) NSTextField *sourceCodeTextField;

@end

@implementation WPTDIntroductionViewController

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self addElements];
    [self setElementsFrame];
}

- (void)addElements
{
    self.titleTextField = [[NSTextField alloc] init];
    self.titleTextField.font = [NSFont boldSystemFontOfSize:30];
    self.titleTextField.alignment = NSTextAlignmentCenter;
    self.titleTextField.editable = NO;
    self.titleTextField.selectable = NO;
    self.titleTextField.bordered = NO;
    self.titleTextField.backgroundColor = [NSColor clearColor];
    [self.titleTextField setStringValue:@"WPTextDecorator"];
    [self.view addSubview:self.titleTextField];
    
    self.authorTextField = [[NSTextField alloc] init];
    self.authorTextField.font = [NSFont systemFontOfSize:15];
    self.authorTextField.alignment = NSTextAlignmentCenter;
    self.authorTextField.editable = NO;
    self.authorTextField.selectable = YES;
    self.authorTextField.bordered = NO;
    self.authorTextField.backgroundColor = [NSColor clearColor];
    [self.authorTextField setStringValue:@"Author: BenArvin"];
    [self.view addSubview:self.authorTextField];
    
    self.versionTextField = [[NSTextField alloc] init];
    self.versionTextField.font = [NSFont systemFontOfSize:15];
    self.versionTextField.alignment = NSTextAlignmentCenter;
    self.versionTextField.editable = NO;
    self.versionTextField.selectable = YES;
    self.versionTextField.bordered = NO;
    self.versionTextField.backgroundColor = [NSColor clearColor];
    [self.versionTextField setStringValue:@"Version: 1.1"];
    [self.view addSubview:self.versionTextField];
    
    self.sourceCodeTextField = [[NSTextField alloc] init];
    self.sourceCodeTextField.font = [NSFont systemFontOfSize:15];
    self.sourceCodeTextField.maximumNumberOfLines = 0;
    self.sourceCodeTextField.alignment = NSTextAlignmentCenter;
    self.sourceCodeTextField.editable = NO;
    self.sourceCodeTextField.selectable = YES;
    self.sourceCodeTextField.bordered = NO;
    self.sourceCodeTextField.backgroundColor = [NSColor clearColor];
    [self.sourceCodeTextField setStringValue:@"Source code: https://github.com/BenArvin/WPTextDecorator"];
    [self.view addSubview:self.sourceCodeTextField];
}

- (void)setElementsFrame
{
    CGRect bounds = self.view.bounds;
    self.titleTextField.frame = CGRectMake(0, 150, bounds.size.width, 35);
    self.authorTextField.frame = CGRectMake(0, CGRectGetMinY(self.titleTextField.frame) - 30, bounds.size.width, 20);
    self.versionTextField.frame = CGRectMake(0, CGRectGetMinY(self.authorTextField.frame) - 20, bounds.size.width, 20);
    self.sourceCodeTextField.frame = CGRectMake(0, CGRectGetMinY(self.versionTextField.frame) - 40, bounds.size.width, 40);
}

+ (CGRect)defaultBounds
{
    return CGRectMake(0, 0, 300, 200);
}

@end
