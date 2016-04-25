//
//  CategoryManager.swift
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 24/04/16.
//  Copyright © 2016 Cocoanetics. All rights reserved.
//

import CoreData
import DTFoundation

/// Manages product categories
@objc(PLYCategoryManager) public class CategoryManager: NSObject
{
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    override init()
    {
        super.init()
        setupCoreDataStack()
    }
    
    public func mergeCategories(categories: [PLYCategory])
    {
        let fetchRequest = NSFetchRequest(entityName: "ManagedCategory")
        try! persistentStoreCoordinator.batchDelete(fetchRequest)
        
        let workerContext = NSManagedObjectContext(concurrencyType:.PrivateQueueConcurrencyType)
        workerContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        workerContext.performBlockAndWait
        {
            for category in categories
            {
                let newEntry = NSEntityDescription.insertNewObjectForEntityForName("ManagedCategory", inManagedObjectContext: workerContext)
                newEntry.setValue(category.key, forKey: "key")
                newEntry.setValue(category.localizedName, forKey: "localizedName")
            }
            
            try! workerContext.save()
        }
    }
    
    public func categoriesMatchingSearch(search: String) throws -> [PLYCategory]
    {
        let workerContext = NSManagedObjectContext(concurrencyType:.MainQueueConcurrencyType)
        workerContext.persistentStoreCoordinator = persistentStoreCoordinator

        let fetchRequest = NSFetchRequest(entityName: "ManagedCategory")
        fetchRequest.predicate = predicateForSearch(search)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "localizedName", ascending: true)]
        
        let results = try workerContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        return categoryObjectsFromManagedObjects(results)
    }
    
    // MARK: - Helpers
    
    private func predicateForSearch(search: String) -> NSPredicate
    {
        let separators = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let parts = search.componentsSeparatedByCharactersInSet(separators)
        
        var subPredicates = [NSPredicate]()
        
        for part in parts
        {
            // skip empty parts
            guard !part.isEmpty else { continue }
            
            let predicate = NSPredicate(format: "localizedName MATCHES[cd] %@", ".*\\b\(part).*")
            subPredicates.append(predicate)
        }
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: subPredicates)
    }
    
    private func categoryObjectsFromManagedObjects(managedObjects: [NSManagedObject]) -> [PLYCategory]
    {
        var tmpArray = [PLYCategory]()
        
        for managedObject in managedObjects
        {
            let category = PLYCategory()
            
            let key = managedObject.valueForKey("key")
            let localizedName = managedObject.valueForKey("localizedName")
            
            // set it via setValue because they are read-only
            category.setValue(key, forKey: "key")
            category.setValue(localizedName, forKey: "localizedName")
            
            tmpArray.append(category)
        }
        
        return tmpArray
    }
    
    private var managedObjectModel: NSManagedObjectModel = {
        
        // create model
        let model = NSManagedObjectModel()
        
        // create entity
        var entity = NSEntityDescription()
        entity.name = "ManagedCategory"
        //entity.managedObjectClassName = "PLYManagedCategory"
  
        // create attributes for entity
        
        var properties = [NSPropertyDescription]()
        
        // key
        var keyAttribute = NSAttributeDescription()
        keyAttribute.name = "key"
        keyAttribute.attributeType = .StringAttributeType
        keyAttribute.optional = false
        keyAttribute.indexed = true
        properties.append(keyAttribute)
        
        // category name
        var nameAttribute = NSAttributeDescription()
        nameAttribute.name = "localizedName"
        nameAttribute.attributeType = .StringAttributeType
        nameAttribute.optional = false
        nameAttribute.indexed = true
        properties.append(nameAttribute)
        
        // parent
        var parentRelation = NSRelationshipDescription()
        parentRelation.name = "parent"
        parentRelation.destinationEntity = entity
        parentRelation.maxCount = 1
        parentRelation.minCount = 0
        parentRelation.optional = true
        parentRelation.indexed = true
        properties.append(parentRelation)
        
        // children
        var childrenRelation = NSRelationshipDescription()
        childrenRelation.name = "children"
        childrenRelation.destinationEntity = entity
        childrenRelation.maxCount = 0
        childrenRelation.minCount = 0
        childrenRelation.optional = true
        childrenRelation.indexed = true
        properties.append(childrenRelation)
        
        // set properties on entity
        entity.properties = properties
        
        // add the entity to the model
        model.entities = [entity]
        
        // return model
        return model
    }()
    
    func setupCoreDataStack()
    {
        let managedObjectModel = self.managedObjectModel
        
        let cachesURL = NSURL(fileURLWithPath: NSString.cachesPath())
        let storeURL = cachesURL.URLByAppendingPathComponent("PLYCategoryDB.cache")
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do
        {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        }
        catch let error as NSError
        {
           NSLog("%@", error.localizedDescription)
        }
    }
    
    
    /*

     addPersistentStoreWithType(_ storeType: String,
     configuration configuration: String?,
     URL storeURL: NSURL?,
     options options: [NSObject : AnyObject]?) throws
     
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
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
 */
 
 
 
    /*
 - (NSManagedObjectModel *)_model
 {
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
	
	// create the entity
	NSEntityDescription *entity = [[NSEntityDescription alloc] init];
	[entity setName:@"DTCachedFile"];
	[entity setManagedObjectClassName:@"DTCachedFile"];
	
	// create the attributes
	NSMutableArray *properties = [NSMutableArray array];
	
	NSAttributeDescription *remoteURLAttribute = [[NSAttributeDescription alloc] init];
	[remoteURLAttribute setName:@"remoteURL"];
	[remoteURLAttribute setAttributeType:NSStringAttributeType];
	[remoteURLAttribute setOptional:NO];
	[remoteURLAttribute setIndexed:YES];
	[properties addObject:remoteURLAttribute];
	
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
	
	NSAttributeDescription *lastModifiedDateAttribute = [[NSAttributeDescription alloc] init];
	[lastModifiedDateAttribute setName:@"lastModifiedDate"];
	[lastModifiedDateAttribute setAttributeType:NSDateAttributeType];
	[lastModifiedDateAttribute setOptional:YES];
	[properties addObject:lastModifiedDateAttribute];
	
	NSAttributeDescription *expirationDateAttribute = [[NSAttributeDescription alloc] init];
	[expirationDateAttribute setName:@"expirationDate"];
	[expirationDateAttribute setAttributeType:NSDateAttributeType];
	[expirationDateAttribute setOptional:NO];
	[properties addObject:expirationDateAttribute];
	
	NSAttributeDescription *contentTypeAttribute = [[NSAttributeDescription alloc] init];
	[contentTypeAttribute setName:@"contentType"];
	[contentTypeAttribute setAttributeType:NSStringAttributeType];
	[contentTypeAttribute setOptional:YES];
	[properties addObject:contentTypeAttribute];
	
	NSAttributeDescription *fileSizeAttribute = [[NSAttributeDescription alloc] init];
	[fileSizeAttribute setName:@"fileSize"];
	[fileSizeAttribute setAttributeType:NSInteger32AttributeType];
	[fileSizeAttribute setOptional:YES];
	[properties addObject:fileSizeAttribute];
	
	NSAttributeDescription *forceLoadAttribute = [[NSAttributeDescription alloc] init];
	[forceLoadAttribute setName:@"forceLoad"];
	[forceLoadAttribute setAttributeType:NSBooleanAttributeType];
	[forceLoadAttribute setOptional:YES];
	[properties addObject:forceLoadAttribute];
	
	NSAttributeDescription *abortAttribute = [[NSAttributeDescription alloc] init];
	[abortAttribute setName:@"abortDownloadIfNotChanged"];
	[abortAttribute setAttributeType:NSBooleanAttributeType];
	[abortAttribute setOptional:YES];
	[properties addObject:abortAttribute];
	
	NSAttributeDescription *loadingAttribute = [[NSAttributeDescription alloc] init];
	[loadingAttribute setName:@"isLoading"];
	[loadingAttribute setAttributeType:NSBooleanAttributeType];
	[loadingAttribute setOptional:NO];
	[properties addObject:loadingAttribute];
	
	NSAttributeDescription *entityTagIdentifierAttribute = [[NSAttributeDescription alloc] init];
	[entityTagIdentifierAttribute setName:@"entityTagIdentifier"];
	[entityTagIdentifierAttribute setAttributeType:NSStringAttributeType];
	[entityTagIdentifierAttribute setOptional:YES];
	[properties addObject:entityTagIdentifierAttribute];
	
	NSAttributeDescription *priorityAttribute = [[NSAttributeDescription alloc] init];
	[priorityAttribute setName:@"priority"];
	[priorityAttribute setAttributeType:NSInteger32AttributeType];
	[priorityAttribute setOptional:YES];
	[properties addObject:priorityAttribute];
	
	// add attributes to entity
	[entity setProperties:properties];
	
	// add entity to model
	[model setEntities:[NSArray arrayWithObject:entity]];
	
	return model;
 }
*/
 
    
}


extension NSPersistentStoreCoordinator
{
    func batchDelete(fetchRequest: NSFetchRequest) throws
    {
        // create a worker
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self
        
        var retError: NSError!
        
        context.performBlockAndWait
        {
            do
            {
                if #available(iOS 9.0, *)
                {
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    
                    try self.executeRequest(deleteRequest, withContext: context)
                }
                else // Fallback on earlier versions
                {
                    // make copy of request with some modifications
                    let deleteRequest = NSFetchRequest(entityName: fetchRequest.entityName!)
                    deleteRequest.predicate = fetchRequest.predicate
                    deleteRequest.includesPropertyValues = false
                    
                    // fetch all
                    let result = try context.executeFetchRequest(deleteRequest) as! [NSManagedObject]
                    
                    // delete
                    for object in result
                    {
                        context.deleteObject(object)
                    }
                    
                    // save context
                    try context.save()
                }
            }
            catch let error as NSError
            {
                retError = error
            }
        }
        
        if retError != nil
        {
            throw retError
        }
    }
}
