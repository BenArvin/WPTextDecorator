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
    
    NSMenu *firstMenu = [[NSMenu alloc] init];
    [firstMenu addItemWithTitle:@"关于WPTextDecorator" action:nil keyEquivalent: @""];
    [firstMenu addItem:[NSMenuItem separatorItem]];
    [firstMenu addItemWithTitle:@"关闭窗口" action:@selector(quitAction) keyEquivalent: @"w"];
    [firstMenu addItem:[NSMenuItem separatorItem]];
    [firstMenu addItemWithTitle:@"退出" action:@selector(quitAction) keyEquivalent:@"q"];
    
    NSMenuItem *firstMenuItem = [[NSMenuItem alloc] init];
    firstMenuItem.submenu = firstMenu;
    
    NSMenu *mainMenu = [[NSMenu alloc] init];
    [mainMenu addItem:firstMenuItem];
    
    [NSApplication sharedApplication].mainMenu = mainMenu;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)quitAction
{
    [NSApp terminate:self];
}

@end
