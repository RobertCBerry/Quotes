//
//  ViewController.swift
//  Quotes
//
//  Created by Robert Berry on 2/28/18.
//  Copyright © 2018 Robert Berry. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    private let persistentContainer = NSPersistentContainer(name: "Quotes")
    
    private let segueAddQuoteViewController = "SegueAddQuoteViewController"
    
    private let segueEditQuoteViewController = "SegueEditQuoteViewController"
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Quote> = {
        
        // Create Fetch Request
        
        let fetchRequest: NSFetchRequest<Quote> = Quote.fetchRequest()
        
        // Configure Fetch Request
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "author", ascending: true)]
        
        // Create Fetched Results Controller
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    private func setUpMessageLabel() {
        
        messageLabel.text = "You don't have any quotes yet."
    }
    
    fileprivate func updateView() {
        
        var hasQuotes = false
        
        if let quotes = fetchedResultsController.fetchedObjects {
            
            hasQuotes = quotes.count > 0 
        }
        
        tableView.isHidden = !hasQuotes
        messageLabel.isHidden = hasQuotes
        
        // Hide the activity indicator view.
        
        activityIndicatorView.stopAnimating() 
    }
    
    private func setUpView() {
        
        setUpMessageLabel()
        updateView()
    }
    
    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the persistent store to the persistent store coordinator.
        
        // loadPersistentStores(completionHandler:) loads the persistent store(s) and adds it to the persistent store coordinator. 
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            
            if let error = error {
                
                print("Unable to load Persistent Store")
                print("\(error), \(error.localizedDescription)")
            
            } else {
                
                self.setUpView()
                
                do {
                    
                    try self.fetchedResultsController.performFetch()
                
                } catch {
                    
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request.")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
                self.updateView()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notification Handling
    
    // Method tells the view mananged object context of the persistent container to save its changes. 
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        
        do {
            
            try persistentContainer.viewContext.save()
        
        } catch {
            
            print("Unable to save changes.")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    // MARK: Navigation
    
    // Passses a reference of the view managed object context of the persistent container to the add quote view controller.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationViewController = segue.destination as? AddQuoteViewController else { return }
        
        // Configure View Controller
        
        destinationViewController.managedObjectContext = persistentContainer.viewContext
        
        if let indexPath = tableView.indexPathForSelectedRow, segue.identifier == segueEditQuoteViewController {
            
            // Configure View Controller
            
            destinationViewController.quote = fetchedResultsController.object(at: indexPath)
        }
        
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let quotes = fetchedResultsController.fetchedObjects else { return 0 }
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuoteTableViewCell.reuseIdentifier, for: indexPath) as? QuoteTableViewCell else {
            
                fatalError("Unexpected Index Path")
        }
        
        // Configure Cell
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Fetch quote that corresponds with the value of indexPath.
            
            let quote = fetchedResultsController.object(at: indexPath)
            
            // Delete quote from the managed object context it belongs to.
            
            quote.managedObjectContext?.delete(quote)
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
        
        // Update the user interface.
        
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
            
        case .insert:
            
            if let newIndexPath = newIndexPath {
                
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
            
        case .delete:
            
            if let indexPath = indexPath {
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
            
        case .update:
            
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? QuoteTableViewCell {
                
                configure(cell, at: indexPath)
            }
            break;
            
        case .move:
            
            if let indexPath = indexPath {
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func configure(_ cell: QuoteTableViewCell, at indexPath: IndexPath) {
        
        // Fetch Quote
        
        let quote = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        
        cell.authorLabel.text = quote.author
        cell.contentsLabel.text = quote.contents
    }
}

