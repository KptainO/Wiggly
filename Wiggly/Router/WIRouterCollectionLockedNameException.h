//
// This file is part of  Wiggly project
//
// Created by JC on 06/09/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

@class WIRouterCollection;

/**
 * Exception indicating a WIRouter name is already reserved inside a WIRouterCollection
 */
@interface WIRouterCollectionLockedNameException : NSException

@property(nonatomic, strong, readonly)NSString            *routeName;
@property(nonatomic, strong, readonly)WIRouterCollection  *routerCollection;


+ (id)exceptionWithCollection:(WIRouterCollection *)routerCollection routeName:(NSString *)routeName;
- (id)initWithCollection:(WIRouterCollection *)routerCollection routeName:(NSString *)routeName;

@end
