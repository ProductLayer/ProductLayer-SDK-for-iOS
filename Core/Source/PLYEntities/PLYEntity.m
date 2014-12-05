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
- (void)setValue:(id)value forKey:(NSString *)key
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
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.createdBy = [[PLYUser alloc] initWithDictionary:value];
		}
	}
	else if ([key isEqualToString:@"pl-created-time"])
	{
		NSTimeInterval interval = [value doubleValue];
		self.createdTime = [NSDate dateWithTimeIntervalSince1970:interval];
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.updatedBy = [[PLYUser alloc] initWithDictionary:value];
		}
	}
	else if ([key isEqualToString:@"pl-upd-time"])
	{
		NSTimeInterval interval = [value doubleValue];
		self.updatedTime = [NSDate dateWithTimeIntervalSince1970:interval];
	}
	else if ([key isEqualToString:@"pl-version"])
	{
		[self setValue:value forKey:@"version"];
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	NSLog(@"Unknown key '%@'", key);
}

// create dict representation with basic common values
- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if (_Class)
	{
		dict[@"pl-class"] = _Class;
	}
	
	if (_Id)
	{
		dict[@"pl-id"] = _Id;
	}
	
	if (_createdBy)
	{
		dict[@"pl-created-by"] = [_createdBy dictionaryRepresentation];
	}
	
	if (_createdTime)
	{
		dict[@"pl-created-time"] = @([_createdTime timeIntervalSince1970]);
	}
	
	if (_updatedBy)
	{
		dict[@"pl-upd-by"] = [_updatedBy dictionaryRepresentation];
	}
	
	if (_updatedTime)
	{
		dict[@"pl-upd-time"] = @([_updatedTime timeIntervalSince1970]);
	}
	
	if (_version)
	{
		dict[@"pl-version"] = @(_version);
	}
	
	// return immutable
	return [dict copy];
}

- (NSDictionary *)objectReference
{
	if (!_Class || !_Id)
	{
		return nil;
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	dict[@"pl-class"] = _Class;
	dict[@"pl-id"] = _Id;
	
	return dict;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
}

@end
