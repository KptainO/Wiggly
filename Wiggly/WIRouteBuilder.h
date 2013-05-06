//
// This file is part of  Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

#import "WIRoutable.h"

@class WIRoute;
@class WIRouteBuilder;
@class WIRoutePlaceholder;

@protocol WIRouteBuilderMarkerDelegate <NSObject>

- (NSString *)builderMarkerRegex:(WIRouteBuilder *)builder;
- (NSString *)builder:(WIRouteBuilder *)builder markerForPlaceholder:(WIRoutePlaceholder *)placeholder;

@end

@protocol WIRouteBuilderDelegate <NSObject>
- (NSDictionary *)builder:(WIRouteBuilder *)builder willUseValues:(NSDictionary *)values;
- (NSDictionary *)builder:(WIRouteBuilder *)builder didReceivedValues:(NSDictionary *)values;

@end

@interface WIRouteBuilder : NSObject<WIRoutable, WIRouteBuilderMarkerDelegate>
@property(nonatomic, strong, readonly)NSArray               *placeholders;
@property(nonatomic, strong, readonly)NSDictionary          *requirements;
@property(nonatomic, strong, readonly)NSString              *path;
@property(nonatomic, strong, readonly)NSDictionary          *defaults;

@property(nonatomic, strong, readonly)NSString              *regex;
@property(nonatomic, weak)id<WIRouteBuilderMarkerDelegate>  markerDelegate;
@property(nonatomic, weak)id<WIRouteBuilderDelegate>        delegate;

- (id)initWithRoute:(WIRoute *)route;

- (NSString *)generate:(NSDictionary *)values;
- (NSDictionary *)match:(NSString *)path;

@end
