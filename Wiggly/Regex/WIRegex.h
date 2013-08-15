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

@property(nonatomic, strong)WIRoute               *route;
@property(nonatomic, strong)NSRegularExpression   *pattern;

@property(nonatomic, strong)NSString              *path;
@property(nonatomic, strong)NSString              *atomicPath;

@property(nonatomic, strong)NSString              *segmentFormat;
@property(nonatomic, strong)NSMutableArray        *segments;

- (id)initWithRoute:(WIRoute *)route format:(NSString *)segmentFormat;

- (NSString *)generate;
- (NSString *)generate:(NSDictionary *)values;
- (NSDictionary *)match:(NSString *)pattern;

- (void)setStringPattern:(NSString *)pattern;

@end
