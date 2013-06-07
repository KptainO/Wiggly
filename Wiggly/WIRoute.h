//
// This file is part of  Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

#import "WIRoutable.h"

/**
 * Container object which hold all information about a route.
 *
 * **A route is** just a URL path ('/slash') with a leading slash""
 * and which can contain parameters ('/slash/:titan').
 *
 * **A parameter** start with a semicolon and denote a dynamic information inside your URL.
 * You can then change/get its value when generating/getting the URL path. @see WIRouter class for more
 * information about routing mechanism
 */
@interface WIRoute : NSObject<WIRoutable>

/// route path
/// example: \code @"/say/:hello/world" \endcode
@property(nonatomic, strong, readonly)NSString            *path;

/**
 * **Regex** rules that each path parameter must respect to be matchable
 * Note that paremeter names must not include leading semicolon character!
 
 * Example:
 * \code
 * @{ @"hello": @"\\d+" } // meaning :hello parameter must must only 1+ digits
 * \endcode
 */
@property(nonatomic, strong, readonly)NSMutableDictionary *requirements;

/**
 * Parameter default values
 * Note that those default values **must** match requirements
 */
@property(nonatomic, strong, readonly)NSMutableDictionary *defaults;

+ (id)routeWithPath:(NSString *)path;

/*
 * @param path the route path
 */
- (id)initWithPath:(NSString *)path;

@end
