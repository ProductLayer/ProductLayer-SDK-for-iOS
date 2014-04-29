#import <Foundation/Foundation.h>

@class PLYAuditor;

@interface PLYProductImage : NSObject {

    NSString *Class;
    NSString *Id;
    NSNumber *version;
    
    PLYAuditor *createdBy;
    NSNumber *createdTime;
    
    PLYAuditor *updatedBy;
    NSNumber *updatedTime;
    
    NSString *name;
    NSString *gtin;

    NSString *fileId;
    
    NSNumber *height;
    NSNumber *width;
    
    NSString *url;
    NSNumber *votingScore;
}

@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSNumber *version;

@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;

@property (nonatomic, strong) NSString *fileId;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *votingScore;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSString *gtin;



+ (NSString *) classIdentifier;
+ (PLYProductImage *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

- (NSString *)getUrlForWidth:(CGFloat)maxWidth andHeight:(CGFloat)maxHeight crop:(BOOL)crop;

@end
