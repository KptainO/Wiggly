//
// This file is part of  Wiggly project
//
// Created by JC on 04/21/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//
//

#import <Foundation/Foundation.h>

@protocol WIRoutable <NSObject>

@property(nonatomic, strong, readonly)NSString            *path;
@property(nonatomic, strong, readonly)NSDictionary        *requirements;
@property(nonatomic, strong, readonly)NSDictionary        *defaults;

@end
