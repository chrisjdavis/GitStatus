//
//  GSStatusMappingProvider.m
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import "GSStatusMappingProvider.h"
#import "GSStatusModelCurrentStatus.h"
#import "GSStatusModelLastMessage.h"
#import "GSStatusModelMessages.h"

@implementation GSStatusMappingProvider

+ (RKMapping *)statusMappingMessages {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[GSStatusModelMessages class]];
    return mapping;
}

+ (RKMapping *)statusMappingCurrentStatus {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[GSStatusModelCurrentStatus class]];
    
    [mapping addAttributeMappingsFromArray:@[@"status", @"last_updated"]];
    
    return mapping;
}

+ (RKMapping *)statusMappingLastMessage {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[GSStatusModelLastMessage class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"body", @"last_updated"]];
    
    return mapping;
}

@end
