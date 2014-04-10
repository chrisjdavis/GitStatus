//
//  GSStatusMappingProvider.h
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface GSStatusMappingProvider : NSObject

+ (RKMapping *)statusMappingLastMessage;
+ (RKMapping *)statusMappingCurrentStatus;
+ (RKMapping *)statusMappingMessages;

@end
