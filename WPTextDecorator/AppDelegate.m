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
NSString *const WPTDMainMenuFindActionNotification = @"WPTDMainMenuFindActionNotification";
NSString *const WPTDMainMenuReplaceActionNotification = @"WPTDMainMenuReplaceActionNotification";

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
    
    NSMenu *selectionMenu = [[NSMenu alloc] initWithTitle:@"Selection"];
    [selectionMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
    
    NSMenuItem *selectionMenuItem = [[NSMenuItem alloc] init];
    selectionMenuItem.submenu = selectionMenu;
    
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
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
    
    NSMenu *findMenu = [[NSMenu alloc] initWithTitle:@"Find"];
    [findMenu addItemWithTitle:@"Find" action:@selector(findAction) keyEquivalent:@"f"];
    NSMenuItem *replaceItem = [[NSMenuItem alloc] initWithTitle:@"Replace" action:@selector(replaceAction) keyEquivalent:@"f"];
    replaceItem.keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagOption;
    [findMenu addItem:replaceItem];
    
    NSMenuItem *findMenuItem = [[NSMenuItem alloc] init];
    findMenuItem.submenu = findMenu;
    
    NSMenu *mainMenu = [[NSMenu alloc] init];
    [mainMenu addItem:firstMenuItem];
    [mainMenu addItem:selectionMenuItem];
    [mainMenu addItem:editMenuItem];
    [mainMenu addItem:findMenuItem];
    
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

- (void)findAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WPTDMainMenuFindActionNotification object:nil];
}

- (void)replaceAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WPTDMainMenuReplaceActionNotification object:nil];
}

@end
