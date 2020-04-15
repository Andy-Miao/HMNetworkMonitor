//
//  HMNetworkMonitor.h
//  GlassAssist
//
//  Created by humiao on 2019/1/12.
//  Copyright © 2019年 Ingenic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// 监听下载的速度
extern NSString *const HMDownloadNetworkSpeedNotificationKey;
// 监听上传的速度
extern NSString *const HMUploadNetworkSpeedNotificationKey;


@interface HMNetworkMonitor : NSObject

// 下载速度
@property (nonatomic, copy, readonly) NSString *downloadNetworkSpeed;
//  上传速度
@property (nonatomic, copy, readonly) NSString *uploadNetworkSpeed;
//  单例
+ (instancetype)shareNetworkMonitor;

- (void)startNetworkSpeedMonitoring;
- (void)stopNetworkSpeedMonitoring;

- (void)networkMonitorOnView:(UIView *)view;
- (void)netViewRemoveFromSupView;
@end
