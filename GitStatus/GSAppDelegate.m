//
//  GSAppDelegate.m
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import "GSAppDelegate.h"
#import "AXStatusItemPopup.h"
#import <RestKit/RestKit.h>
#import "GSStatusModelCurrentStatus.h"
#import "GSStatusModelLastMessage.h"
#import "GSStatusMappingProvider.h"
#import "GSStatusItemViewController.h"

@interface GSAppDelegate () {
    AXStatusItemPopup *_statusItemPopup;
}

@property (nonatomic, strong) NSMutableArray *response;

@end

@implementation GSAppDelegate

@synthesize window;
@synthesize doNotify;
@synthesize startAtLogin;

NSString *loginItem = nil;
NSString *notify = nil;

NSArray *_items;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    GSStatusItemViewController *contentViewController = [[GSStatusItemViewController alloc] initWithNibName:@"GSStatusItemViewController" bundle:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"gitStatus.status"];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    NSImage *image = [NSImage imageNamed:@"getStatusIcon"];
    NSImage *alternateImage = [NSImage imageNamed:@"getStatusIcon"];
    
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:image alternateImage:alternateImage];
    contentViewController.statusItemPopup = _statusItemPopup;
    
    loginItem = [prefs stringForKey:@"gitStatus.loginItem"];
    notify = [prefs stringForKey:@"gitStatus.doNotifications"];
    
    if( [loginItem isEqualToString:@"YES"] ) {
        [startAtLogin setState:NSOnState];
    } else {
        [startAtLogin setState:NSOffState];
    }
    
    if( [notify isEqualToString:@"YES"] ) {
        [doNotify setState:NSOnState];
    } else {
        [doNotify setState:NSOffState];
    }
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self checkStatus];
    
    NSDate *d = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimer *t = [[NSTimer alloc] initWithFireDate:d interval:120 target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:t forMode: NSDefaultRunLoopMode];
}

-(void)checkStatus {
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [GSStatusMappingProvider statusMappingLastMessage];
    
    NSString *pattern = [NSString stringWithFormat:@"/api/last-message.json"];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:pattern keyPath:@"" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://status.github.com%@", pattern]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.response addObjectsFromArray: mappingResult.array];
        GSStatusModelLastMessage *status = mappingResult.array[0];
        [self updateStatus:status];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    [operation start];
}

-(void)updateStatus:(GSStatusModelLastMessage *)status {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *lastStatus = [prefs stringForKey:@"gitStatus.status"];
    NSInteger notify = 0;
    
    if( !lastStatus ) {
        [prefs setObject:status.status forKey:@"gitStatus.status"];
        notify = 1;
    } else if( ![lastStatus isEqualToString:status.status] ) {
        [prefs setObject:status.status forKey:@"gitStatus.status"];
        notify = 1;
    }

    if( [status.status isEqualToString:@"good"] ) {
        [self updateIcon:1];
    } else if ( [status.status isEqualToString:@"minor"] ) {
        [self updateIcon:2];
    } else if( [status.status isEqualToString:@"major"] ) {
        [self updateIcon:3];
    }
    
    NSString *doNotifs = [prefs stringForKey:@"gitStatus.doNotifications"];
    
    if( notify == 1 && [doNotifs isEqualToString:@"YES"] ) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        
        notification.title = @"Github Status";
        notification.informativeText = [NSString stringWithFormat:@"%@", status.body];
        
        [self showNotification:notification];
    }
}

-(void)showPrefs {
    [window makeKeyAndOrderFront:self];
}

-(void)updateIcon:(int)code {
    NSImage *image = nil;
    switch( code ) {
        case 1 :
            image = [NSImage imageNamed:@"getStatusIconGreen"];
            _statusItemPopup.image = image;
            break;
        case 2 :
            image = [NSImage imageNamed:@"getStatusIconYellow"];
            _statusItemPopup.image = image;
            break;
        case 3 :
            image = [NSImage imageNamed:@"getStatusIconRed"];
            _statusItemPopup.image = image;
            break;
        default :
            image = [NSImage imageNamed:@"getStatusIconGreen"];
            _statusItemPopup.image = image;
            break;
    }
}

- (void)showNotification:notif {
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notif];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://status.github.com"]];
}

-(void)addAsLoginItem {
    NSLog(@"Adding item");
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
    
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

-(void) deleteFromLoginItems {
    NSLog(@"Removing item");
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for( int i = 0; i < [loginItemsArray count]; i++ ) {
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray objectAtIndex:i]);
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
                if ([urlPath isEqualToString:appPath]) {
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSInteger startState = [startAtLogin state];
    NSInteger notifsState = [doNotify state];
    
    if( startState == 1 ) {
        [prefs setObject:@"YES" forKey:@"gitStatus.loginItem"];
        [self addAsLoginItem];
    } else {
        [prefs setObject:@"NO" forKey:@"gitStatus.loginItem"];
        [self deleteFromLoginItems];
    }
    
    if( notifsState == 1 ) {
        [prefs setObject:@"YES" forKey:@"gitStatus.doNotifications"];
    } else {
        [prefs setObject:@"NO" forKey:@"gitStatus.doNotifications"];
    }
    
    return NSTerminateNow;
}

@end
