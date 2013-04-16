//
// This file is part of  Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

@class WIRoute;

@interface WIRouteBuilder : NSObject
@property(nonatomic, strong, readonly)NSDictionary  *placeholders;
@property(nonatomic, strong, readonly)NSString      *pattern;
@property(nonatomic, strong, readonly)NSString      *path;
@property(nonatomic, strong, readonly)NSString      *shortPath;

- (id)initWithRoute:(WIRoute *)route;

@end
