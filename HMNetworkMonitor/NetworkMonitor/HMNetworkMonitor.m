//
//  HMNetworkMonitor.m
//  GlassAssist
//
//  Created by humiao on 2019/1/12.
//  Copyright © 2019年 Ingenic. All rights reserved.
//

#import "HMNetworkMonitor.h"

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

NSString* const HMDownloadNetworkSpeedNotificationKey = @"HMDownloadNetworkSpeedNotificationKey";
NSString* const HMUploadNetworkSpeedNotificationKey = @"HMUploadNetworkSpeedNotificationKey";

typedef NS_ENUM(NSInteger, NetType) {
    HMNetTypeWithWiFi,//默认从0开始
    HMNetTypeWithWWAN,
};

@interface HMNetworkMonitor () {
    
    //总网速
    uint32_t _iBytes;
    uint32_t _oBytes;
    uint32_t _allFlow;
    
    //wifi网速
    uint32_t _wifiIBytes;
    uint32_t _wifiOBytes;
    uint32_t _wifiFlow;
    
    //3G网速
    uint32_t _wwanIBytes;
    uint32_t _wwanOBytes;
    uint32_t _wwanFlow;
    
    NetType _netType;
    
    UILabel *downL;
    UILabel *upL;
    UIView *netView;
}

@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSString *netTyepStr;

@end


@implementation HMNetworkMonitor

static HMNetworkMonitor* instance = nil;

#pragma mark - 单例
+ (instancetype)shareNetworkMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone*)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _iBytes = _oBytes = _allFlow = _wifiIBytes = _wifiOBytes = _wifiFlow = _wwanIBytes = _wwanOBytes = _wwanFlow = 0;
    }
    return self;
}

#pragma mark - 开始监听网速
- (void)startNetworkSpeedMonitoring {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkSpeedMonitoring) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

#pragma mark - 停止监听网速
- (void)stopNetworkSpeedMonitoring {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}


#pragma mark - 网速
- (NSString*)stringWithbytes:(int)bytes {
    
    if (bytes < 1024) // B
    {
        return [NSString stringWithFormat:@"%dB", bytes];
    }
    else if (bytes >= 1024 && bytes < 1024 * 1024) // KB
    {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if (bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) // MB
    {
        return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
    }
    else // GB
    {
        return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}


#pragma mark - 检查 网速 循环
- (void)networkSpeedMonitoring {
    
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return;
    }
    //     总网速
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    uint32_t allFlow = 0;
    
    //     WiFi 网速
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow = 0;
    
    //     3G网速
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        // network
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }
        //wifi
        if (!strcmp(ifa->ifa_name, "en0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow = wifiIBytes + wifiOBytes;
            _netType = HMNetTypeWithWiFi;
        }
        //3G or gprs
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow = wwanIBytes + wwanOBytes;
            _netType = HMNetTypeWithWWAN;
        }
    }
    freeifaddrs(ifa_list);
    if (_netType == HMNetTypeWithWiFi) {
        self.netTyepStr = @"WiFi";
    } else {
        self.netTyepStr = @"WWAN";
    }
    if (_iBytes != 0) {
        _downloadNetworkSpeed = [[self stringWithbytes:iBytes - _iBytes] stringByAppendingString:@"/s"];
        NSDictionary *dic = @{
                              @"NetSpeed" : _downloadNetworkSpeed,
                              @"netType" : self.netTyepStr
                              };
        [[NSNotificationCenter defaultCenter] postNotificationName:HMDownloadNetworkSpeedNotificationKey object:nil userInfo:dic];
//        NSLog(@"_downloadNetworkSpeed : %@",_downloadNetworkSpeed);
        [self checkDownloadNetSpeed:dic];
    }
    _iBytes = iBytes;
    if (_oBytes != 0) {
        _uploadNetworkSpeed = [[self stringWithbytes:oBytes - _oBytes] stringByAppendingString:@"/s"];
        NSDictionary *dic = @{
                              @"NetSpeed" : _uploadNetworkSpeed,
                              @"netType" : self.netTyepStr
                              };
        [[NSNotificationCenter defaultCenter] postNotificationName:HMUploadNetworkSpeedNotificationKey object:nil userInfo:dic];
//        NSLog(@"_uploadNetworkSpeed  :%@",_uploadNetworkSpeed);
        [self checkUploadNetSpeed:dic];
    }
    _oBytes = oBytes;
}

#pragma mark - 网络监测
- (void)networkMonitorOnView:(UIView *)view {
    
    netView = [[UIView alloc] initWithFrame:CGRectMake(0, 54, 100, 26)];
    [view addSubview:netView];
    
    downL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 13)];
    downL.font = [UIFont systemFontOfSize:11];
    downL.textColor = [UIColor whiteColor];
    [netView addSubview:downL];
    upL = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 100, 13)];
    upL.font = [UIFont systemFontOfSize:11];
    upL.textColor = [UIColor whiteColor];
    [netView addSubview:upL];
    
    [self startNetworkSpeedMonitoring];
    // 需要获取值，添加
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkDownloadNetSpeed:) name:HMDownloadNetworkSpeedNotificationKey object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUploadNetSpeed:) name:HMUploadNetworkSpeedNotificationKey object:nil];
}
/** 下行速度 */
-(void)checkDownloadNetSpeed:(NSDictionary *)dic {
    
    downL.text = [NSString stringWithFormat:@"下行：%@ ",dic[@"NetSpeed"]];
    
}
/** 上行速度 */
-(void)checkUploadNetSpeed:(NSDictionary *)dic {
    upL.text = [NSString stringWithFormat:@"上行：%@ ",dic[@"NetSpeed"]];
}

- (void)netViewRemoveFromSupView {
    [netView removeFromSuperview];
}
@end
