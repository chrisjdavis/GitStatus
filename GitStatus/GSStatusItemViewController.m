//
//  GSStatusItemViewController.m
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import "GSStatusItemViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GSAppDelegate.h"

@interface GSStatusItemViewController () <NSMenuDelegate> {}

@end

@implementation GSStatusItemViewController

NSArray *browsers = nil;

@synthesize otherBrowsers;
@synthesize saving;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setUpExternalBrowsers];
}

- (void)setUpExternalBrowsers {
    browsers = CFBridgingRelease(LSCopyAllHandlersForURLScheme(CFSTR("https")));
    NSFileManager *fileManager	= [NSFileManager defaultManager];
    
    for (int i = 0; i < [browsers count]; i++ ) {
        NSDictionary *row = [browsers objectAtIndex:i];
        
        NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:[NSString stringWithFormat:@"%@", row]];
        
        if ([fileManager fileExistsAtPath:path]) {
            NSString *appName = [[path componentsSeparatedByString:@"/"] lastObject];
            NSString *name = [appName stringByReplacingOccurrencesOfString:@".app" withString:@""];
            [otherBrowsers addItemWithTitle:name];
        }
    }
}

- (IBAction)chooseExternalBrowser:(id)sender {    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *name = [browsers objectAtIndex:otherBrowsers.indexOfSelectedItem - 1];
    NSString *appid = [NSString stringWithFormat:@"%@", name];
    [prefs setObject:appid forKey:@"gitStatus.browser"];

    [saving setHidden:NO];
}

@end
