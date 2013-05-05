//
// This file is part of  Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

#import "WIRoutable.h"

@interface WIRoute : NSObject<WIRoutable>

@property(nonatomic, strong, readonly)NSString            *path;
@property(nonatomic, strong, readonly)NSMutableDictionary *requirements;
@property(nonatomic, strong, readonly)NSMutableDictionary *defaults;

+ (id)routeWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

@end
