#import <Foundation/Foundation.h>

@interface PLYPackaging : NSObject {

    NSString *contains;
    NSString *name;
    NSString *description;
    NSNumber *unit;

}

@property (nonatomic, copy) NSString *contains;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSNumber *unit;

+ (PLYPackaging *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;
@end
