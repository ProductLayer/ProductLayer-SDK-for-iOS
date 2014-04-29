#import <Foundation/Foundation.h>

@interface PLYAuditor : NSObject {

    NSString *userId;
    NSString *appId;
    NSString *userNickname;

}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *userNickname;

+ (PLYAuditor *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

@end
