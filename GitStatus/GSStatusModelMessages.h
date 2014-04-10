//
//  GSStatusModel.h
//  GitStatus
//
//  Created by Chris J. Davis on 4/9/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSStatusModelMessages : NSObject

@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *created_on;

@end
