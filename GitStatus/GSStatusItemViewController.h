//
//  GSStatusItemViewController.h
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AXStatusItemPopup.h"

@interface GSStatusItemViewController : NSViewController

@property(weak, nonatomic) AXStatusItemPopup *statusItemPopup;

@end
