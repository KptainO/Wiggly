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

@interface WIRouting : NSObject

- (id)initWithRoute:(WIRoute *)route;
- (id)initWithRoute:(WIRoute *)route builder:(Class)builder;

- (NSString *)route:(id)data;

- (id)matches:(NSString *)pattern;

@end
