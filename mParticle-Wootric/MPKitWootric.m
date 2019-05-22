#import "MPKitWootric.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import <WootricSDK/WootricSDK.h>

@implementation MPKitWootric

+ (NSNumber *)kitCode {
    return @90;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Wootric" className:@"MPKitWootric"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    
    NSString *accountToken = configuration[@"accountToken"];
    NSString *clientSecret = configuration[@"clientSecret"];
    NSString *clientId = configuration[@"clientId"];
    BOOL validConfiguration = accountToken != nil && clientSecret != nil && clientId != nil;
    
    if (!validConfiguration) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }
    
    [Wootric configureWithClientID:clientId clientSecret:clientSecret accountToken:accountToken];
    
    _configuration = configuration;
    _started = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
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
        if (!newProperties) {
            newProperties = [NSMutableDictionary dictionary];
        }
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
