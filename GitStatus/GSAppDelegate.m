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

@interface GSAppDelegate () {
    AXStatusItemPopup *_statusItemPopup;
}

@property (nonatomic, strong) NSMutableArray *response;

@end

@implementation GSAppDelegate

NSArray *_items;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    GSStatusItemViewController *contentViewController = [[GSStatusItemViewController alloc] initWithNibName:@"GSStatusItemViewController" bundle:nil];
    
    NSImage *image = [NSImage imageNamed:@"getStatusIcon"];
    NSImage *alternateImage = [NSImage imageNamed:@"getStatusIcon-alt"];
    
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:image alternateImage:alternateImage];
    contentViewController.statusItemPopup = _statusItemPopup;
}

- (void) awakeFromNib {
    [super awakeFromNib];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"gitStatus.status"];
    [self checkStatus];
    
    NSDate *d = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimer *t = [[NSTimer alloc] initWithFireDate:d interval:60 target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
    
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
    
    if( notify == 1 ) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        
        notification.title = @"Github Status";
        notification.informativeText = [NSString stringWithFormat:@"%@", status.body];
        
        [self showNotification:notification];
    }
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

@end
