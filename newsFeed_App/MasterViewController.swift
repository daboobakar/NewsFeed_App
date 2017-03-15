//
//  MasterViewController.swift
//  newsFeed_App
//
//  Created by Danyal Aboobakar on 08/03/2017.
//  Copyright © 2017 Danyal Aboobakar. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var articles = [Article]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News"
        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.leftBarButtonItem = self.editButtonItem
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadArticles()
    }
    
    func loadArticles() {
        independentAPIManager.sharedInstance.fetchArticles() {
            result in
            guard result.error == nil else {
                self.handleLoadArticlesError(result.error!)
                return
            }
            if let fetchedArticles = result.value {
                self.articles = fetchedArticles
            }
            self.tableView.reloadData()
        }
        
        
        self.tableView.reloadData()
    }
    
    func handleLoadArticlesError(_ error: Error) {
        // TODO: show error
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title: "Not Implemented",
                                      message: "Can't create new gists yet, will implement later",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let article = articles[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = article
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let article = articles[indexPath.row]
        cell.textLabel!.text = article.headline
        cell.textLabel?.font = UIFont(name: "Baskerville-Bold", size: 14)
        cell.textLabel?.numberOfLines = 4
        
        cell.detailTextLabel?.text = article.section
        cell.detailTextLabel?.font = UIFont(name: "AvenirNext-Italic", size: 12)
//                cell.detailTextLabel?.text = article.authorNames.joined(separator: ", ")
        //set image to nil in case cell is being reused
        cell.imageView?.image = nil
        
        //check we have urlString for image
        if let urlString = article.imageURL {
            independentAPIManager.sharedInstance.imageFrom(urlString: urlString) {
                //check if errors exist, if so print error
                (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                //set cell's image if no error exists
                if let cellToUpdate = self.tableView?.cellForRow(at: indexPath) {
                    
                    cellToUpdate.imageView?.image = image // will work fine even if image is nil
                    //need to reload the view, which won't happen otherwise
                    // since this is in an async call
                    cellToUpdate.setNeedsLayout()
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            articles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}
