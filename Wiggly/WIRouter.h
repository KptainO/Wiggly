//
// This file is part of  Wiggly project
//
// Created by JC on 04/06/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

@class WIRoute;
@class WIRouteBuilder;

/**
 * Allow to interact with a WIRoute object:
 * - route it, i.e. generate a the WIRoute object URL path based on its properties
 * - extract data from a matching URL path
 */
@interface WIRouter : NSObject

- (id)initWithRoute:(WIRoute *)route;
- (id)initWithRoute:(WIRoute *)route builder:(Class)builder;

/**
 * Route initial route object
 * @param the object used to extract route parameters. This class implementation only supports NSDictionary
 * @return NSString the resulting URL once everything route parameters have been replaced with their value inside the route
 */
- (NSString *)route:(id)object;

/**
 * @param path a URL path
 * @return nil if URL didn't match route, a NSDictionary with all parameter values otherwise
 */
- (id)match:(NSString *)path;

@end
