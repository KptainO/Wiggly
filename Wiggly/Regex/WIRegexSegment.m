//
// This file is part of Wiggly project
//
// Created by JC on 06/14/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//


#import "WIRegexSegment.h"

NSString  *const WIRegexDefaultConditions = @"[0-9a-z-._%;,*+$!)(]+";

@implementation WIRegexSegment

@synthesize conditions  = _conditions;

- (id)init {
  return [self initWithName:nil];
}

- (id)initWithName:(NSString *)name {
  if (!(self = [super initWithName:name]))
    return nil;
  
  self.required = YES;
  
  return self;
}

- (NSString *)conditions {
  return _conditions ?: WIRegexDefaultConditions;
}

@end
