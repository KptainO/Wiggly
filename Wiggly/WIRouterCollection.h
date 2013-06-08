//
// This file is part of  Wiggly project
//
// Created by JC on 06/08/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

@class WIRouter;
@class WIRoute;

/**
 * Collection which allow you to handle multiple WIRouter objects at a time.
 * Each router will have a name that you reference to when using route:with: method.
 */
@interface WIRouterCollection : NSObject

@property(nonatomic, strong, readonly)NSDictionary    *routes;

+ (id)collection;

/**
 * Add a router to collection
 *
 * @param routeName router unique identifier
 * @param router
 *
 * @throw WIRouterNameAlreadyExistException if routerName is already present
 */
- (void)add:(NSString *)routeName router:(WIRouter *)router;

- (void)add:(NSString *)routeName route:(WIRoute *)route;

/**
 * Import all routes from collection inside current one
 *
 * @param collection the collection to import routes from
 * @throw WIRouterNameAlreadyExistException if any collection router has a name already present
 */
- (void)add:(WIRouterCollection *)collection;

- (NSString *)route:(NSString *)routeName;

/**
 * Route referenced router with object as parameters data
 *
 * @param routeName name of a route present into the collection
 * @param object an object which will be passed to the route router to extract parameters values
 */
- (NSString *)route:(NSString *)routeName with:(id)object;

- (id)match:(NSString *)path;

@end
