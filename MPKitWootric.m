//
//  MPKitWootric.m
//
//  Copyright 2016 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MPKitWootric.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import <WootricSDK/WootricSDK.h>

@implementation MPKitWootric

+ (NSNumber *)kitCode {
    return @90;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Wootric" className:@"MPKitWootric" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    NSAssert(configuration != nil, @"Required parameter. It cannot be nil.");
    self = [super init];
    if (!self) {
        return nil;
    }

    NSString *accountToken = configuration[@"accountToken"];
    NSString *clientSecret = configuration[@"clientSecret"];
    NSString *clientId = configuration[@"clientId"];

    BOOL validConfiguration = accountToken != nil && clientSecret != nil && clientId != nil;
    if (!validConfiguration) {
        return nil;
    }

    [Wootric configureWithClientID:clientId clientSecret:clientSecret accountToken:accountToken];

    _configuration = configuration;
    _started = startImmediately;

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode],
                                   mParticleEmbeddedSDKInstanceKey:[[self class] kitCode]};

        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];

        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleEmbeddedSDKDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });

    return self;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    MPKitReturnCode returnCode;

    if (identityType == MPUserIdentityCustomerId || identityType == MPUserIdentityEmail) {
        [Wootric setEndUserEmail:identityString];
        returnCode = MPKitReturnCodeSuccess;
    } else {
        returnCode = MPKitReturnCodeUnavailable;
    }

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceWootric) returnCode:returnCode];
    return execStatus;
}

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    MPKitReturnCode returnCode;

    if (value != nil) {
        NSMutableDictionary *newProperties = [[Wootric endUserProperties] mutableCopy];
        newProperties[key] = value;
        [Wootric setEndUserProperties:newProperties];
        returnCode = MPKitReturnCodeSuccess;
    } else {
        returnCode = MPKitReturnCodeFail;
    }

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceWootric) returnCode:returnCode];
    return execStatus;
}

@end
