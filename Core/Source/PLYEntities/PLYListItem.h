//
//  PLYListItem.h
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLYListItem : NSObject {
    NSString *Id;
    NSString *gtin;
    NSString *note;
    NSNumber *qty;
    NSNumber *prio;
}

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSNumber *qty;
@property (nonatomic, strong) NSNumber *prio;


+ (NSString *) classIdentifier;
+ (PLYListItem *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

@end
