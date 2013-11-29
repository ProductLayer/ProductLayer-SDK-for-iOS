//
//  DTImageCache.m
//  PL
//
//  Created by Oliver Drobnik on 29.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTImageCache.h"
#import "DTManagedImage.h"
#import "DTLog.h"

#import "NSString+DTPaths.h"
#import "UIImage+DTFoundation.h"
#import "DTCachedFile.h"
#import "DTCoreGraphicsUtils.h"

#import <CoreData/CoreData.h>

static DTImageCache *_sharedInstance = nil;

@implementation DTImageCache
{
	NSManagedObjectModel *_managedObjectModel;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
	NSManagedObjectContext *_writerContext;
	NSManagedObjectContext *_workerContext;
}


+ (DTImageCache *)sharedCache
{
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[DTImageCache alloc] init];
	});
	
	return _sharedInstance;
}

- (instancetype)init
{
	self = [super init];
	
	if (self)
	{
		[self _setupCoreDataStack];
	}
	
	return self;
}

#pragma mark - Internal Helpers

// returned objects can only be used from the same context
- (DTManagedImage *)_mangedImageForUniqueIdentifier:(NSString *)uniqueIdentifier variantIdentifier:(NSString *)variantIdentifier inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DTManagedImage"];
	
	if (variantIdentifier)
	{
		request.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@ AND variantIdentifier == %@", uniqueIdentifier, variantIdentifier];
	}
	else
	{
		request.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@ AND variantIdentifier == nil", uniqueIdentifier];
	}
	request.fetchLimit = 1;
	
	NSError *error;
	NSArray *results = [context executeFetchRequest:request error:&error];
	
	if (!results)
	{
		NSLog(@"error occured fetching %@", [error localizedDescription]);
	}
	
   return [results lastObject];
}

- (void)_commit
{
	NSError *error;
	if (![_workerContext save:&error])
	{
		DTLogError(@"Unable to save worker context: %@", [error localizedDescription]);
	}
	
	[_writerContext performBlock:^{
		
		NSError *error;
		if (![_writerContext save:&error])
		{
			DTLogError(@"Unable to save writer context: %@", [error localizedDescription]);
		}
	}];
}

#pragma mark - Public API

- (void)addImage:(UIImage *)image forUniqueIdentifier:(NSString *)uniqueIdentifier variantIdentifier:(NSString *)variantIdentifier
{
	NSParameterAssert(uniqueIdentifier);
	NSParameterAssert(image);
	
	[_workerContext performBlock:^{

		DTManagedImage *managedImage = [self _mangedImageForUniqueIdentifier:uniqueIdentifier variantIdentifier:variantIdentifier inContext:_workerContext];
		
		if (managedImage)
		{
			DTLogInfo(@"Managed Image already exists in cache");
			return;
		}
		
		managedImage = (DTManagedImage *)[NSEntityDescription insertNewObjectForEntityForName:@"DTManagedImage" inManagedObjectContext:_workerContext];
		
		NSData *imageData = UIImagePNGRepresentation(image);
		
		managedImage.uniqueIdentifier = uniqueIdentifier;
		managedImage.variantIdentifier = variantIdentifier;
		managedImage.fileSize = @(imageData.length);
		managedImage.lastAccessDate = [NSDate date];
		managedImage.fileData = imageData;
		managedImage.imageSize = image.size;
		
		[self _commit];

	}];
}

- (UIImage *)imageForUniqueIdentifier:(NSString *)uniqueIdentifier variantIdentifier:(NSString *)variantIdentifier
{
	__block UIImage *image = nil;
	
	NSParameterAssert(uniqueIdentifier);
	
	[_workerContext performBlockAndWait:^{
		
		DTManagedImage *managedImage = [self _mangedImageForUniqueIdentifier:uniqueIdentifier variantIdentifier:variantIdentifier inContext:_workerContext];
		
		if (managedImage.fileData)
		{
			image = [UIImage imageWithData:managedImage.fileData];
		}
		
		managedImage.lastAccessDate = [NSDate date];
		[self _commit];
	}];
	
	return image;
}

#pragma mark - Core Data Stack

- (NSManagedObjectModel *)_model
{
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
	
	// create the entity
	NSEntityDescription *entity = [[NSEntityDescription alloc] init];
	[entity setName:@"DTManagedImage"];
	[entity setManagedObjectClassName:@"DTManagedImage"];
	
	// create the attributes
	NSMutableArray *properties = [NSMutableArray array];
	
	NSAttributeDescription *uniqueIdentifierAttribute = [[NSAttributeDescription alloc] init];
	[uniqueIdentifierAttribute setName:@"uniqueIdentifier"];
	[uniqueIdentifierAttribute setAttributeType:NSStringAttributeType];
	[uniqueIdentifierAttribute setOptional:NO];
	[uniqueIdentifierAttribute setIndexed:YES];
	[properties addObject:uniqueIdentifierAttribute];

	NSAttributeDescription *variantIdentifierAttribute = [[NSAttributeDescription alloc] init];
	[variantIdentifierAttribute setName:@"variantIdentifier"];
	[variantIdentifierAttribute setAttributeType:NSStringAttributeType];
	[variantIdentifierAttribute setOptional:YES];
	[variantIdentifierAttribute setIndexed:YES];
	[properties addObject:variantIdentifierAttribute];
	
	NSAttributeDescription *fileDataAttribute = [[NSAttributeDescription alloc] init];
	[fileDataAttribute setName:@"fileData"];
	[fileDataAttribute setAttributeType:NSBinaryDataAttributeType];
	[fileDataAttribute setOptional:YES];
	[fileDataAttribute setAllowsExternalBinaryDataStorage:YES];
	[properties addObject:fileDataAttribute];
	
	NSAttributeDescription *lastAccessDateAttribute = [[NSAttributeDescription alloc] init];
	[lastAccessDateAttribute setName:@"lastAccessDate"];
	[lastAccessDateAttribute setAttributeType:NSDateAttributeType];
	[lastAccessDateAttribute setOptional:NO];
	[properties addObject:lastAccessDateAttribute];
	
	NSAttributeDescription *fileSizeAttribute = [[NSAttributeDescription alloc] init];
	[fileSizeAttribute setName:@"fileSize"];
	[fileSizeAttribute setAttributeType:NSInteger32AttributeType];
	[fileSizeAttribute setOptional:YES];
	[properties addObject:fileSizeAttribute];

	NSAttributeDescription *imageSizeWidthAttribute = [[NSAttributeDescription alloc] init];
	[imageSizeWidthAttribute setName:@"imageSizeWidth"];
	[imageSizeWidthAttribute setAttributeType:NSInteger32AttributeType];
	[imageSizeWidthAttribute setOptional:NO];
	[properties addObject:imageSizeWidthAttribute];
	
	NSAttributeDescription *imageSizeHeightAttribute = [[NSAttributeDescription alloc] init];
	[imageSizeHeightAttribute setName:@"imageSizeHeight"];
	[imageSizeHeightAttribute setAttributeType:NSInteger32AttributeType];
	[imageSizeHeightAttribute setOptional:NO];
	[properties addObject:imageSizeHeightAttribute];
	
	// add attributes to entity
	[entity setProperties:properties];
	
	// add entity to model
	[model setEntities:[NSArray arrayWithObject:entity]];
	
	return model;
}

- (void)_setupCoreDataStack
{
	// setup managed object model
	
	/*
     NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DTDownloadCache" withExtension:@"momd"];
     _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	 */
	
	// in code
    _managedObjectModel = [self _model];
	
	// setup persistent store coordinator
	NSURL *storeURL = [NSURL fileURLWithPath:[[NSString cachesPath] stringByAppendingPathComponent:@"DTImageCache.cache"]];
	
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
		DTLogWarning(@"Inconsistent %@ Store, attempting to fix by removing it", NSStringFromClass([self class]));
		
		// inconsistent model/store
		[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
		
		// retry once
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
    
    // create writer MOC
    _writerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	[_writerContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
    // create worker MOC for background operations
    _workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _workerContext.parentContext = _writerContext;
}

@end
