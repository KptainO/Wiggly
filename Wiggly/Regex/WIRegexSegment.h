//
// This file is part of Wiggly project
//
// Created by JC on 06/14/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

#import "WIRouteParameter.h"

@interface WIRegexSegment : WIRouteParameter

@property(nonatomic, assign)BOOL          required;
@property(nonatomic, assign)NSUInteger    order;
//@property(nonatomic, strong)WIRouteParameter  *parameter;

@end
