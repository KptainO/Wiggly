//
// This file is part of  Wiggly project
//
// Created by JC on 06/09/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

@protocol WIRouteConstraintURL <NSObject>

@property(nonatomic, strong, readonly)NSString                    *path;

@end

@interface WIRouteConstraintURL : NSObject<WIRouteConstraintURL>

@property(nonatomic, strong)NSString                    *path;

@end