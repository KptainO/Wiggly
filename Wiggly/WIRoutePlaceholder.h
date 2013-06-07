//
// This file is part of  Wiggly project
//
// Created by JC on 03/31/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

/**
 * Contain information about a route parameter
 */
@interface WIRoutePlaceholder : NSObject

@property(nonatomic, copy, readonly)NSString    *name;
@property(nonatomic, strong)NSString            *conditions;
@property(nonatomic)BOOL                        required;

- (id)initWithName:(NSString *)name;

/**
 * Check that value respect the conditions
 *
 * @param value the value to check conditions on
 * @return YES if conditions are fulfilled, NO otherwise
 */
- (BOOL)matchConditions:(NSString *)value;

@end
