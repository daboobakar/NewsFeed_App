//
//  MasterViewController.swift
//  newsFeed_App
//
//  Created by Danyal Aboobakar on 08/03/2017.
//  Copyright © 2017 Danyal Aboobakar. All rights reserved.
//

import UIKit
import PINRemoteImage

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var articles = [Article]()
    var dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Top Stories"
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        
        // add refresh control for pull to refresh
        if (self.refreshControl == nil) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self,
                                           action: #selector(refresh(sender:)),
                                           for: .valueChanged)
//            self.dateFormatter.dateStyle = .short
            self.dateFormatter.timeStyle = .medium
        }
        
        super.viewWillAppear(animated)
    }
    
    func loadArticles() {
        independentAPIManager.sharedInstance.fetchArticles() {
            result in
            
            // tell refresh control it can stop showing up now
            if self.refreshControl != nil,
                self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            
            guard result.error == nil else {
                self.handleLoadArticlesError(result.error!)
                return
            }
            if let fetchedArticles = result.value {
                self.articles = fetchedArticles
            }
            
            let now = Date()
            let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
            self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
            
            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - Pull to Refresh
    func refresh(sender: Any) {
        independentAPIManager.sharedInstance.clearCache()
        loadArticles()
    }
    
    func handleLoadArticlesError(_ error: Error) {
        // TODO: show error
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        // MARK: - TITLE
        
        cell.textLabel!.text = article.headline
        cell.textLabel?.font = UIFont(name: "Baskerville-Bold", size: 14)
        cell.textLabel?.numberOfLines = 4
        
        // MARK: - SUBTITLE
        
        cell.detailTextLabel?.text = article.section
        cell.detailTextLabel?.font = UIFont(name: "AvenirNext-Italic", size: 12)
        //set image to nil in case cell is being reused
        cell.imageView?.image = nil
        
        //check we have urlString for image
        if let urlString = article.imageURL,
            let url = URL(string: urlString) {
            cell.imageView?.pin_setImage(from: url, placeholderImage:
            UIImage(named: "placeholder.png")) {
                result in
                if let cellToUpdate = self.tableView?.cellForRow(at: indexPath) {
                    cellToUpdate.setNeedsLayout()
                }
            }
        } else {
            cell.imageView?.image = UIImage(named: "placeholder.png")
        }
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
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
