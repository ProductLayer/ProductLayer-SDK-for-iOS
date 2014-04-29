#import <Foundation/Foundation.h>

@class PLYAuditor;

@interface PLYReview : NSObject {
    
    NSString *Class;
    NSString *Id;
    NSNumber *version;
    
    PLYAuditor *createdBy;
    NSNumber *createdTime;
    
    PLYAuditor *updatedBy;
    NSNumber *updatedTime;
    
    NSString *gtin;
    NSString *subject;
    NSString *body;
    NSNumber *rating;
    NSString *language;
    
    NSNumber *votingScore;
    NSArray *upVoter;
    NSArray *downVoter;
}

@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSNumber *version;

@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;

@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *language;

@property (nonatomic, strong) NSNumber *votingScore;
@property (nonatomic, strong) NSArray *upVoter;
@property (nonatomic, strong) NSArray *downVoter;



+ (NSString *) classIdentifier;
+ (PLYReview *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

@end
