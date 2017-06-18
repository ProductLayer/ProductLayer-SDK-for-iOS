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
@objc(PLYCategoryManager) open class CategoryManager: NSObject
{
    fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    override init()
    {
        super.init()
        setupCoreDataStack()
    }
    
    fileprivate func addManagedCategory(_ category: PLYCategory, parentCategory: NSManagedObject? = nil, path: String = "", level: Int = 1, inContext context: NSManagedObjectContext)
    {
        let newEntry = NSEntityDescription.insertNewObject(forEntityName: "ManagedCategory", into: context)
        newEntry.setValue(category.key, forKey: "key")
        newEntry.setValue(category.localizedName, forKey: "localizedName")
        
        newEntry.setValue(parentCategory, forKey: "parent")
        
        var currentPath = path
        
        if currentPath.isEmpty
        {
            currentPath = category.localizedName
        }
        else
        {
            currentPath = currentPath + "/" + category.localizedName
        }
        
        newEntry.setValue(currentPath, forKey: "localizedPath")
        newEntry.setValue(level, forKey: "level")
        
        if let subCategories = category.subCategories as? [PLYCategory]
        {
            for subCategory in subCategories
            {
                addManagedCategory(subCategory, parentCategory: newEntry, path: currentPath, level: level+1, inContext: context)
            }
        }
    }
    
    open func mergeCategories(_ categories: [PLYCategory]) throws
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCategory")
        try persistentStoreCoordinator.batchDelete(fetchRequest)
        
        let workerContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        workerContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        var retError: NSError!
        
        workerContext.performAndWait {
            for category in categories
            {
                self.addManagedCategory(category, inContext: workerContext)
            }
            
            do {
                try workerContext.save()
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
    
    open func localizedCategoryPathForKey(_ categoryKey: String) -> String?
    {
        let workerContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        workerContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCategory")
        fetchRequest.predicate = NSPredicate(format: "key == %@", categoryKey)
        fetchRequest.fetchLimit = 1
        
        guard let results = try? workerContext.fetch(fetchRequest) as! [NSManagedObject], results.count > 0 else
        {
            return nil
        }
        
        if let firstObject = results.first
        {
            return firstObject.value(forKey: "localizedPath") as? String
        }
        else
        {
            return nil
        }
    }
    
    open func categoriesMatchingSearch(_ search: String) throws -> [PLYCategory]
    {
        let workerContext = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        workerContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCategory")
        
        if !search.isEmpty
        {
            fetchRequest.predicate = predicateForSearch(search)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "localizedPath", ascending: true)]
        
        let results = try workerContext.fetch(fetchRequest) as! [NSManagedObject]
        return categoryObjectsStructureFromManagedObjects(results, addParents: !search.isEmpty)
    }
    
    // MARK: - Helpers
    
    fileprivate func predicateForSearch(_ search: String) -> NSPredicate
    {
        let separators = CharacterSet.alphanumerics.inverted
        let parts = search.components(separatedBy: separators)
        
        var subPredicates = [NSPredicate]()
        
        for part in parts
        {
            // skip empty parts
            guard !part.isEmpty else { continue }
            
            let predicate = NSPredicate(format: "localizedName MATCHES[cd] %@", ".*\\b\(part).*")
            subPredicates.append(predicate)
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
    }
    
    fileprivate func categoryObjectsStructureFromManagedObjects(_ managedObjects: [NSManagedObject], addParents: Bool = false) -> [PLYCategory]
    {
        let allObjectsAndParents = NSMutableSet()
        
        for managedObject in managedObjects
        {
            allObjectsAndParents.add(managedObject)
            
            if !addParents
            {
                continue;
            }
            
            // add all missing parents
            var object = managedObject
            
            while let parent = object.value(forKey: "parent") as? NSManagedObject
            {
                allObjectsAndParents.add(parent)
                
                object = parent
            }
        }
        
        let sort = NSSortDescriptor(key: "localizedPath", ascending: true)
        let sorted = allObjectsAndParents.sortedArray(using: [sort]) as! [NSManagedObject]
        
        return sorted.map({ (object) -> PLYCategory in
            
            return PLYCategoryFromManagedCategory(object)
        })
    }
    
    
    fileprivate func appendflattenedStructure(_ structure: [PLYCategory], toArray array: inout [PLYCategory])
    {
        for category in structure
        {
            array.append(category)
            
            if let subCategories = category.subCategories as? [PLYCategory]
            {
                appendflattenedStructure(subCategories, toArray: &array)
            }
        }
    }
    
    fileprivate func PLYCategoryFromManagedCategory(_ managedCategory: NSManagedObject) -> PLYCategory
    {
        let category = PLYCategory()
        
        let key = managedCategory.value(forKey: "key")
        let localizedName = managedCategory.value(forKey: "localizedName")
        let localizedPath = managedCategory.value(forKey: "localizedPath")
        
        // set it via setValue because they are read-only
        category.setValue(key, forKey: "key")
        category.setValue(localizedName, forKey: "localizedName")
        category.setValue(localizedPath, forKey: "localizedPath")
        
        category.level =  managedCategory.value(forKey: "level") as! UInt
        
        return category
    }
    
    fileprivate var managedObjectModel: NSManagedObjectModel = {
        
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
        keyAttribute.attributeType = .stringAttributeType
        keyAttribute.isOptional = false
        keyAttribute.isIndexed = true
        properties.append(keyAttribute)
        
        // category name
        var nameAttribute = NSAttributeDescription()
        nameAttribute.name = "localizedName"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false
        nameAttribute.isIndexed = true
        properties.append(nameAttribute)
        
        // localizedPath
        var pathAttribute = NSAttributeDescription()
        pathAttribute.name = "localizedPath"
        pathAttribute.attributeType = .stringAttributeType
        pathAttribute.isOptional = false
        pathAttribute.isIndexed = true
        properties.append(pathAttribute)
        
        // localizedPath
        var levelAttribute = NSAttributeDescription()
        levelAttribute.name = "level"
        levelAttribute.attributeType = .integer16AttributeType
        levelAttribute.isOptional = false
        levelAttribute.isIndexed = true
        properties.append(levelAttribute)
        
        // parent
        var parentRelation = NSRelationshipDescription()
        var childrenRelation = NSRelationshipDescription()
        
        parentRelation.name = "parent"
        parentRelation.destinationEntity = entity
        parentRelation.maxCount = 1
        parentRelation.minCount = 0
        parentRelation.inverseRelationship = childrenRelation
        childrenRelation.deleteRule = .nullifyDeleteRule
        properties.append(parentRelation)
        
        // children
        childrenRelation.name = "children"
        childrenRelation.destinationEntity = entity
        childrenRelation.maxCount = 0
        childrenRelation.minCount = 0
        childrenRelation.inverseRelationship = parentRelation
        childrenRelation.deleteRule = .cascadeDeleteRule
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
        
        let cachesURL = URL(fileURLWithPath: NSString.cachesPath())
        let storeURL = cachesURL.appendingPathComponent("PLYCategoryDB.cache")
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do
        {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        }
        catch let error as NSError
        {
            NSLog("%@", error.localizedDescription)
        }
    }
}


extension NSPersistentStoreCoordinator
{
    func batchDelete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) throws
    {
        // create a worker
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self
        
        var retError: NSError!
        
        context.performAndWait
            {
                do
                {
                    if #available(iOS 9.0, OSX 10.11, *)
                    {
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        try self.execute(deleteRequest, with: context)
                    }
                    else // Fallback on earlier versions
                    {
                        // make copy of request with some modifications
                        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: fetchRequest.entityName!)
                        deleteRequest.predicate = fetchRequest.predicate
                        deleteRequest.includesPropertyValues = false
                        
                        // fetch all
                        let result = try context.fetch(deleteRequest) as! [NSManagedObject]
                        
                        // delete
                        for object in result
                        {
                            context.delete(object)
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
