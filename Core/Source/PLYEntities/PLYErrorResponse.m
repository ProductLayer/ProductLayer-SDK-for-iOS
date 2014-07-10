//
//  PLYErrorResponse.m
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYErrorResponse.h"
#import "PLYErrorMessage.h"

@implementation PLYErrorResponse

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"errors"])
	 {
        if ([value isKindOfClass:[NSArray class]])
		  {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
			  
            for (id valueMember in value)
				{
                [myMembers addObject:[[PLYErrorMessage alloc] initWithDictionary:valueMember]];
            }
            
            self.errors = myMembers;
        }
    }
	 else
	 {
        [super setValue:value forKey:key];
    }
}

@end
