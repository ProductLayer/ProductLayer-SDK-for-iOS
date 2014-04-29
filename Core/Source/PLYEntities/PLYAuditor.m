#import "PLYAuditor.h"

@implementation PLYAuditor

@synthesize userId;
@synthesize appId;
@synthesize userNickname;

+ (PLYAuditor *)instanceFromDictionary:(NSDictionary *)aDictionary {

    PLYAuditor *instance = [[PLYAuditor alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"pl-usr-id"]) {
        [self setValue:value forKey:@"userId"];
    } else if ([key isEqualToString:@"pl-app-id"]) {
        [self setValue:value forKey:@"appId"];
    } else if ([key isEqualToString:@"pl-usr-nickname"]) {
        [self setValue:value forKey:@"userNickname"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

- (NSDictionary *) getDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (userId != nil) {
        [dict setObject:userId forKey:@"pl-usr-id"];
    }
    if (appId != nil) {
        [dict setObject:appId forKey:@"pl-app-id"];
    }
    if (userNickname != nil) {
        [dict setObject:userNickname forKey:@"pl-usr-nickname"];
    }
    
    return dict;
}



@end
