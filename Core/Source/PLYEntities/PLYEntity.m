//
//  PLYEntity.m
//  PL
//
//  Created by Oliver Drobnik on 08.07.14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"
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

- (NSDictionary *)dictionaryRepresentation
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

@end
