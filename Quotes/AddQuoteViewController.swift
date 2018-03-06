//
//  AddQuoteViewController.swift
//  Quotes
//
//  Created by Robert Berry on 3/6/18.
//  Copyright © 2018 Robert Berry. All rights reserved.
//

import UIKit
import CoreData

class AddQuoteViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet var authorTextField: UITextField!
    
    @IBOutlet var contentsTextView: UITextView!
    
    var managedObjectContext: NSManagedObjectContext?
    
    var quote: Quote?
    
    // MARK: Actions
    
    @IBAction func save(sender: UIBarButtonItem) {
        
        guard let managedObjectContext = managedObjectContext else { return }
        
        // Creating New Quote
        
        if quote == nil {
            
            // Create Quote
            
            let newQuote = Quote(context: managedObjectContext)
            
            // Configure Quote
            
            newQuote.createdAt = Date().timeIntervalSince1970
            
            // Set Quote
            
            quote = newQuote
            
        }
        
        // Edit existing quote
        
        if let quote = quote {
            
            // Configure Quote
            
            quote.author = authorTextField.text
            quote.contents = contentsTextView.text
            
        }
        
        // Pop View Controller
        
        _ = navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Quote"
        
        // Populate the text field and text view if the quote property has a value.
        
        if let quote = quote {
            
            authorTextField.text = quote.author
            contentsTextView.text = quote.contents
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
