//
// This file is part of Wiggly project
//
// Created by JC on 03/31/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRoutePlaceholder.h"

@implementation WIRoutePlaceholder

#pragma mark -
#pragma mark Initialization

- (id)init {
  if (!(self = [super init]))
    return nil;

  //@FIXME

  return self;
}

#pragma mark -
#pragma mark Methods

- (NSString *)description {
  return self.pattern;
}

@end
