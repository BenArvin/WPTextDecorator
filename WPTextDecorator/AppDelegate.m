//
//  AppDelegate.m
//  WPTextDecorator
//
//  Created by BenArvin on 2017/12/4.
//  Copyright © 2017年 BenArvin. All rights reserved.
//

#import "AppDelegate.h"

NSString *const WPTDMainMenuIndentActionNotification = @"WPTDMainMenuIndentActionNotification";
NSString *const WPTDMainMenuUnindentActionNotification = @"WPTDMainMenuUnindentActionNotification";

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
    [firstMenu addItemWithTitle:@"About WPTextDecorator" action:nil keyEquivalent:@""];
    [firstMenu addItem:[NSMenuItem separatorItem]];
    [firstMenu addItemWithTitle:@"Close" action:@selector(quitAction) keyEquivalent:@"w"];
    [firstMenu addItem:[NSMenuItem separatorItem]];
    [firstMenu addItemWithTitle:@"Quit" action:@selector(quitAction) keyEquivalent:@"q"];
    
    NSMenuItem *firstMenuItem = [[NSMenuItem alloc] init];
    firstMenuItem.submenu = firstMenu;
    
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
    [editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Indent" action:@selector(indentAction) keyEquivalent:@"]"];
    [editMenu addItemWithTitle:@"Unindent" action:@selector(unindentAction) keyEquivalent:@"["];
    
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

- (void)indentAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WPTDMainMenuIndentActionNotification object:nil];
}

- (void)unindentAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WPTDMainMenuUnindentActionNotification object:nil];
}

@end
