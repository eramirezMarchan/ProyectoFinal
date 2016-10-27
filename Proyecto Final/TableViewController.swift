//
//  TableViewController.swift
//  Proyecto Final
//
//  Created by Faktos on 27/10/16.
//  Copyright © 2016 ERM. All rights reserved.
//

import UIKit
import CoreData

struct Rutas {
    var nombre:String
    var puntos : [Punto]
    
    init (nombre: String, puntos:[Punto]){
        self.nombre = nombre
        self.puntos = puntos
    }
}

struct Punto {
    var longitud : Double
    var latitud : Double
    init(longitud: Double, latitud: Double){
        self.latitud = latitud
        self.longitud = longitud
    }
    
}

var rutas = [Rutas]()

class TableViewController: UITableViewController {
    

    var contexto  : NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self

        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let rutaEntidad = NSEntityDescription.entityForName("Rutas", inManagedObjectContext: self.contexto!)
        let peticion = rutaEntidad?.managedObjectModel.fetchRequestTemplateForName("petRutas")
        do {
            let rutasEntidad = try self.contexto?.executeFetchRequest(peticion!)
            for rutaEntidad2 in rutasEntidad! {
                let nombre = rutaEntidad2.valueForKey("nombre") as! String
                let puntosEntidad = rutaEntidad2.valueForKey("tiene") as! Set<NSObject>
                var puntos2 = [Punto]()
                for puntosEntidad2 in puntosEntidad {
                    let longitud = puntosEntidad2.valueForKey("longitud") as! Double
                    let latitud = puntosEntidad2.valueForKey("latitud") as! Double
                    let punto : Punto = Punto(longitud: longitud, latitud: latitud)
                    puntos2.append(punto)
                }
                rutas.append(Rutas(nombre:nombre, puntos: puntos2))
            }
        }
        catch{
            
        }

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
        return rutas.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        cell.textLabel?.text = rutas[indexPath.row].nombre
        
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        
        
        if segue.identifier == "showMap"{
            _ = segue.destinationViewController as! RutasViewController
        }
        else if segue.identifier == "showRuta" {
            let rvc = segue.destinationViewController as! RutasViewController
            let ip = self.tableView.indexPathForSelectedRow
            
            rvc.ip = (ip?.item)!
        }
        
    }

}
