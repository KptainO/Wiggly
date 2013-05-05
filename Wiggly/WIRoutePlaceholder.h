//
// This file is part of  Wiggly project
//
// Created by JC on 03/31/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <Foundation/Foundation.h>

@interface WIRoutePlaceholder : NSObject

@property(nonatomic, copy, readonly)NSString    *name;
@property(nonatomic, strong)NSString            *conditions;
@property(nonatomic)BOOL                        required;

- (id)initWithName:(NSString *)name;

- (BOOL)matchConditions:(NSString *)value;

@end
