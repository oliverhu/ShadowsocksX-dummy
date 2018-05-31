//
//  ProxyConfHelper.h
//  ShadowsocksX-NG
//
//  Created by 邱宇舟 on 16/6/10.
//  Copyright © 2016年 qiuyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProxyConfHelper : NSObject

+ (void)install;

+ (void)enableGlobalProxy;

+ (void)disableProxy;
+ (void)enablePACProxy;
@end
