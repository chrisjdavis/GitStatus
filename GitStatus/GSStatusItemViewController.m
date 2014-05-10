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

@synthesize statusText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *lastStatus = [prefs stringForKey:@"gitStatus.status"];
    
    if( [lastStatus isEqualToString:@"good"] ) {
        [statusText setStringValue:@"Looking Good."];
    } else if ( [lastStatus isEqualToString:@"minor"] ) {
        [statusText setStringValue:@"Uh Oh, there seems to be an issue."];
    } else if( [lastStatus isEqualToString:@"major"] ) {
        [statusText setStringValue:@"Danger Will Robinson! Danger!"];
    }
}

- (IBAction)showPrefs:(id)sender {
    [(GSAppDelegate *) [[NSApplication sharedApplication] delegate] showPrefs];
}

@end
