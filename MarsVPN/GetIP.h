//
//  GetIP1.h
//  GOGOVPN
//
//  Created by Justin on 2022/10/20.
//

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

NS_ASSUME_NONNULL_BEGIN

@interface GetIP : NSObject
+ (NSString *)getLocalIPAddress:(BOOL)preferIPv4;
+ (NSString *)getIPAddress1;
+ (NSString *)nextIP:(NSString *)ipAddress;
@end


NS_ASSUME_NONNULL_END
