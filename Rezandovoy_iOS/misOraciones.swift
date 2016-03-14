//
//  misOraciones.swift
//  Rezandovoy
//
//  Created by Rodrigo on 14/3/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

import UIKit

class misOraciones: UITableViewController {
    
    let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
    var oraciones = [Oracion]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let atributos: NSDictionary = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont(name: "Aleo-Regular", size: 15)!]
        self.navigationController?.navigationBar.titleTextAttributes = atributos as? [String : AnyObject]
        self.navigationController?.navigationBar.topItem!.title = "Mis Oraciones"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        self.loadData()
        
        self.tableView.reloadData()
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return oraciones.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "celdaOracion"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! celdaOracion
        let oracion = oraciones[indexPath.row]
        cell.titulo.text = "\(oracion.fecha!) - \(oracion.titulo!)"

        // Configure the cell...

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        id = oraciones[indexPath.row].id
        tipo = oraciones[indexPath.row].tipo
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("audioPlayer") as UIViewController
        self.showViewController(nextViewController, sender: self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            do {
                try NSFileManager.defaultManager().removeItemAtPath(Oracion.DocumentsDirectory.URLByAppendingPathComponent("\(oraciones[indexPath.row].mp3!)").path!)
                try NSFileManager.defaultManager().removeItemAtPath(Oracion.DocumentsDirectory.URLByAppendingPathComponent("\(oraciones[indexPath.row].id)").path!)
                oraciones.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            catch {
                print("i dunno")
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func loadOracion(aux_id: Int) -> Oracion? {
        let aux = NSKeyedUnarchiver.unarchiveObjectWithFile(Oracion.DocumentsDirectory.URLByAppendingPathComponent("\(aux_id)").path!) as? Oracion
        print(aux!.id)
        return aux
    }
    
    func loadData() {
        oraciones.removeAll()
        do {
            let items = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("\(self.documentsUrl.path!)")
            for item in items {
                if item.hasSuffix("mp3") || item == ".DS_Store" {
                    print(item)
                } else {
                    let aux = loadOracion(Int(item)!)
                    oraciones.append(aux!)
                }
            }
        } catch let error as NSError {
            print("Fallo al leer el directorio \(error)")
        }
        catch {
            print("i dunno")
        }
    }
    
}
