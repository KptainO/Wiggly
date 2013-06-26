//
//  WIRegex.h
//  Wiggly
//
//  Created by JC on 6/15/13.
//  Copyright (c) 2013 kptaino. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WIRegexSegment;
@class WIRoute;

@interface WIRegex : NSObject

@property(nonatomic, strong)WIRoute   *route;
@property(nonatomic, strong)NSString  *regex;

@property(nonatomic, strong)NSString  *shortRegex;
@property(nonatomic, strong)NSString  *longRegex;

@property(nonatomic, strong)NSString      *segmentFormat;
@property(nonatomic, strong)NSDictionary  *segments;

- (id)initWithRoute:(WIRoute *)route format:(NSString *)segmentFormat;

- (NSString *)generate:(NSDictionary *)values;
- (NSDictionary *)match:(NSString *)pattern;

@end
