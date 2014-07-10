//
//  PLYEntity.m
//  PL
//
//  Created by Oliver Drobnik on 08.07.14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"
#import "PLYUser.h"
#import <objc/runtime.h>

// lookup table mapping class strings to objc classes
NSDictionary *_entityClassLookup;

@implementation PLYEntity

// helper function to get all sub-classes of PLYEntity
NSArray *PLYAllEntityClasses()
{
	int numClasses = objc_getClassList(NULL, 0);
	Class *classes = NULL;
	Class parentClass = [PLYEntity class];
	
	classes = (Class *)malloc(sizeof(Class) * numClasses);
	numClasses = objc_getClassList(classes, numClasses);
	
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSInteger i = 0; i < numClasses; i++) {
		Class superClass = classes[i];
		
		do
		{
			superClass = class_getSuperclass(superClass);
		}
		while (superClass && superClass != parentClass);
		
		if (!superClass)
		{
			continue;
		}
		
		[result addObject:classes[i]];
	}
	free(classes);
	return result;
}


+ (void)initialize
{
	if ([self class] != [PLYEntity class])
	{
		return;
	}

	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	for (Class oneClass in PLYAllEntityClasses())
	{
		NSString *type = [oneClass entityTypeIdentifier];
		
		if (type)
		{
			tmpDict[type] = oneClass;
		}
	}
	
	_entityClassLookup = [tmpDict copy];
}

+ (NSString *)entityTypeIdentifier
{
	return nil;
}

+ (PLYEntity *)entityFromDictionary:(NSDictionary *)dictionary
{
	NSString *objectType = dictionary[@"pl-class"];
	Class entityClass = _entityClassLookup[objectType];
	
	if (!entityClass)
	{
		NSLog(@"Unknown object type identifier '%@'", objectType);
		return nil;
	}
	
	return [[entityClass alloc] initWithDictionary:dictionary];
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	// should not instantiate PLYEntity directy
	if ([self class] == [PLYEntity class])
	{
		NSLog(@"PLYEntity is an abstract superclass, instantiate a subclass instead");
		return nil;
	}
	
	self = [super init];
	
	if (self)
	{
		[self setValuesForKeysWithDictionary:dictionary];
	}
	
	return self;
}

#pragma mark - Value Getting/Setting

// setting common values from dictionary
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-class"])
	{
		[self setValue:value forKey:@"Class"];
	}
	else if ([key isEqualToString:@"pl-id"])
	{
		[self setValue:value forKey:@"Id"];
	}
	else if ([key isEqualToString:@"pl-created-by"])
	{
		[self setValue:value forKey:@"createdBy"];
	}
	else if ([key isEqualToString:@"pl-created-time"])
	{
		[self setValue:value forKey:@"createdTime"];
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		[self setValue:value forKey:@"updatedBy"];
	}
	else if ([key isEqualToString:@"pl-upd-time"])
	{
		[self setValue:value forKey:@"updatedTime"];
	}
	else if ([key isEqualToString:@"pl-version"])
	{
		[self setValue:value forKey:@"version"];
	}
}

// create dict representation with basic common values
- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if (self.Class)
	{
		[dict setObject:self.Class forKey:@"pl-class"];
	}
	
	if (self.Id)
	{
		[dict setObject:self.Id forKey:@"pl-id"];
	}
	
	if (self.createdBy)
	{
		[dict setObject:[self.createdBy dictionaryRepresentation] forKey:@"pl-created-by"];
	}
	
	if (self.createdTime)
	{
		[dict setObject:self.createdTime forKey:@"pl-created-time"];
	}
	
	if (self.updatedBy)
	{
		[dict setObject:[self.updatedBy dictionaryRepresentation] forKey:@"pl-upd-by"];
	}
	
	if (self.updatedTime)
	{
		[dict setObject:self.updatedTime forKey:@"pl-upd-time"];
	}
	
	if (self.version)
	{
		[dict setObject:self.version forKey:@"pl-version"];
	}
	
	// return immutable
	return [dict copy];
}

@end
