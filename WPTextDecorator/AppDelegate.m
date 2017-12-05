//
//  AppDelegate.m
//  WPTextDecorator
//
//  Created by BenArvin on 2017/12/4.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self setMenu];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)setMenu
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    NSMenu *firstMenu = [[NSMenu alloc] init];
    [firstMenu addItemWithTitle:@"关于WPTextDecorator" action:@selector(aboutAction) keyEquivalent:@""];
    [firstMenu addItem:[NSMenuItem separatorItem]];
    [firstMenu addItemWithTitle:@"关闭窗口" action:@selector(quitAction) keyEquivalent:@"w"];
    [firstMenu addItem:[NSMenuItem separatorItem]];
    [firstMenu addItemWithTitle:@"退出" action:@selector(quitAction) keyEquivalent:@"q"];
    
    NSMenuItem *firstMenuItem = [[NSMenuItem alloc] init];
    firstMenuItem.submenu = firstMenu;
    
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    [editMenu addItemWithTitle:@"全选" action:@selector(selectAll:) keyEquivalent:@"a"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"撤销" action:@selector(undo:) keyEquivalent:@"z"];
    [editMenu addItemWithTitle:@"重做" action:@selector(redo:) keyEquivalent:@"Z"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"剪切" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"复制" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"粘贴" action:@selector(paste:) keyEquivalent:@"v"];
    
    NSMenuItem *editMenuItem = [[NSMenuItem alloc] init];
    editMenuItem.submenu = editMenu;
    
    NSMenu *mainMenu = [[NSMenu alloc] init];
    [mainMenu addItem:firstMenuItem];
    [mainMenu addItem:editMenuItem];
    
    [NSApplication sharedApplication].mainMenu = mainMenu;
#pragma clang diagnostic pop
}

- (void)quitAction
{
    [NSApp terminate:self];
}

- (void)aboutAction
{
    
}

@end
