//
//  GSStatusModelStatus.h
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSStatusModelCurrentStatus : NSObject

@property (nonatomic, weak) NSString *status;
@property (nonatomic, weak) NSString *last_updated;

@end
