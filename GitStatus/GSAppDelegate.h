//
//  GSAppDelegate.h
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GSStatusItemViewController.h"

@interface GSAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *startAtLogin;
@property (assign) IBOutlet NSButton *doNotify;

- (void)showPrefs;

@end
