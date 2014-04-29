#import <Foundation/Foundation.h>

@class PLYAuditor;
@class PLYPackaging;

@interface PLYProduct : NSObject {

    NSString *Class;
    NSString *Id;
    NSNumber *version;
    
    PLYAuditor *createdBy;
    NSNumber *createdTime;
    
    PLYAuditor *updatedBy;
    NSNumber *updatedTime;
    
    NSString *gtin;
    NSString *name;
    NSString *category;
    NSString *language;
    
    NSString *shortDescription;
    NSString *longDescription;
    
    NSString *brandName;
    NSString *brandOwner;
    
    NSString *homepage;
    NSArray *links;
    
    PLYPackaging *packaging;
    NSNumber *rating;
    
    NSMutableDictionary *characteristics;
    NSMutableDictionary *nutritious;
}

@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *brandOwner;
@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, strong) NSString *shortDescription;
@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PLYPackaging *packaging;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;
@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSMutableDictionary *characteristics;
@property (nonatomic, strong) NSMutableDictionary *nutritious;

+ (NSString *) classIdentifier;

+ (PLYProduct *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;
@end
