//
// This file is part of  Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

@class WIRoute;

@interface WIRoutePattern : NSObject
@property(nonatomic, strong, readonly)NSDictionary  *placeholders;
@property(nonatomic, strong, readonly)NSString      *pattern;
@property(nonatomic, strong, readonly)WIRoute       *route;

- (id)initWithRoute:(WIRoute *)route;

//- (void)generate:(WIRoute *)route;

- (NSString *)generate:(NSDictionary *)variables;
- (NSArray *)matches:(NSString *)routePath;
@end
