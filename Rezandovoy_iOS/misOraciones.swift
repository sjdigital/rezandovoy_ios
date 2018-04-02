//
//  misOraciones.swift
//  Rezandovoy
//
//  Created by Rodrigo on 14/3/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

import UIKit

class misOraciones: UITableViewController {
    
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
    var oraciones = [Oracion]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let atributos: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name: "Aleo-Regular", size: 15)!]
        self.navigationController?.navigationBar.titleTextAttributes = atributos as? [NSAttributedStringKey : Any]
        self.navigationController?.navigationBar.topItem!.title = "Mis Oraciones"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
        
        self.tableView.reloadData()
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return oraciones.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "celdaOracion"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! celdaOracion
        let oracion = oraciones[indexPath.row]
        if let aux_fecha = oracion.fecha {
            cell.titulo.text = "\(aux_fecha) - \(oracion.titulo!)"
        }
        else {
            cell.titulo.text = "Especial - \(oracion.titulo!)"
        }

        if oracion.tipo == 1 {
            cell.logoOracion.image = UIImage(named: "ic_rv_blanco")
            cell.logoOracion.contentMode = UIViewContentMode.scaleAspectFit
            cell.fondo.backgroundColor = UIColor(red: 168/255, green: 41/255, blue: 57/255, alpha: 1.0)
        } else if oracion.tipo == 2 {
            cell.logoOracion.image = UIImage(named: "ic_rv_blanco")
            cell.logoOracion.contentMode = UIViewContentMode.scaleAspectFit
            cell.fondo.backgroundColor = UIColor(red: 168/255, green: 41/255, blue: 57/255, alpha: 1.0)
        } else if oracion.tipo == 3 {
            cell.logoOracion.image = UIImage(named: "ic_rvn_blanco")
            cell.logoOracion.contentMode = UIViewContentMode.scaleAspectFit
            cell.fondo.backgroundColor = UIColor(red: 233/255, green: 98/255, blue: 26/255, alpha: 1.0)
        } else if oracion.tipo == 4 {
            cell.logoOracion.image = UIImage(named: "ic_rvn_blanco")
            cell.logoOracion.contentMode = UIViewContentMode.scaleAspectFit
            cell.fondo.backgroundColor = UIColor(red: 233/255, green: 98/255, blue: 26/255, alpha: 1.0)
        }

        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        id = oraciones[indexPath.row].id
        tipo = oraciones[indexPath.row].tipo
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "audioPlayer") as UIViewController
        self.show(nextViewController, sender: self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            do {
                try FileManager.default.removeItem(atPath: Oracion.DocumentsDirectory.appendingPathComponent("\(oraciones[indexPath.row].mp3!)").path)
                try FileManager.default.removeItem(atPath: Oracion.DocumentsDirectory.appendingPathComponent("\(oraciones[indexPath.row].id)").path)
                if let _ = oraciones[indexPath.row].icono {
                    try FileManager.default.removeItem(atPath: Oracion.DocumentsDirectory.appendingPathComponent("\(oraciones[indexPath.row].icono!)").path)
                }
                oraciones.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            catch {
                print("i dunno")
            }
        } else if editingStyle == .insert {
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

    func loadOracion(_ aux_id: Int) -> Oracion? {
        let aux = NSKeyedUnarchiver.unarchiveObject(withFile: Oracion.DocumentsDirectory.appendingPathComponent("\(aux_id)").path) as? Oracion
        print(aux!.id)
        return aux
    }
    
    func loadData() {
        oraciones.removeAll()
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: "\(self.documentsUrl.path)")
            for item in items {
                if item.hasSuffix("mp3") || item == ".DS_Store" || item.hasSuffix("png") {
                    print(item)
                } else {
                    let aux = loadOracion(Int(item)!)
                    oraciones.append(aux!)
                }
            }
            oraciones = oraciones.reversed()
        } catch let error as NSError {
            print("Fallo al leer el directorio \(error)")
        }
        catch {
            print("i dunno")
        }
    }
    
}
