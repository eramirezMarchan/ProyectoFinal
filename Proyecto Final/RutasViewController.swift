//
//  RutasViewController.swift
//  Proyecto Final
//
//  Created by Faktos on 08/10/16.
//  Copyright © 2016 ERM. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class RutasViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate, ARDataSource {
    
    var contexto  : NSManagedObjectContext? = nil
    
    var ip = -1

    var selectedPin:MKPlacemark? = nil
    private var origen: MKMapItem!
    private var origen2: MKMapItem!
    private var destino: MKMapItem!
    private var aux: MKMapItem!
    private var aux2: MKMapItem!
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var startLocation :CLLocation!
    var pointLocation :CLLocation!
    var count = 1;
    var arrCoordinates : [CLLocationCoordinate2D] = []
    
    
    @IBOutlet weak var mapaRuta: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        self.title = "Rutas"
        mapaRuta.delegate = self
        
        
        if(ip == -1){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        
        else{
            let locValue:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: rutas[ip].puntos[0].latitud, longitude: rutas[ip].puntos[0].longitud)
            let puntoLugar = MKPlacemark(coordinate: locValue, addressDictionary: nil)
            aux2 = MKMapItem(placemark: puntoLugar)
            aux2.name = "Punto no. 1"
            origen = aux2

            var i = 2
            for punto in rutas[ip].puntos{
                
                let locValue:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: punto.latitud, longitude: punto.longitud)
                let puntoLugar = MKPlacemark(coordinate: locValue, addressDictionary: nil)
                destino = MKMapItem(placemark: puntoLugar)
                destino.name = "Punto no. \(i)"
                
                let anota = MKPointAnnotation()
                anota.coordinate = destino.placemark.coordinate
                anota.title = destino.name
                mapaRuta.addAnnotation(anota)
                self.obtenerRuta(aux2!,destino: destino!)
                aux2 = destino
                
                i += 1

            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
            mapaRuta.showsUserLocation = true
        }
        else{
            locationManager.stopUpdatingLocation()
            mapaRuta.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapaRuta.setRegion(region, animated: true)
        }
        
        if startLocation == nil {
            startLocation = locations.first! as CLLocation
            let locValue:CLLocationCoordinate2D = startLocation.coordinate
            let puntoLugar = MKPlacemark(coordinate: locValue, addressDictionary: nil)
            origen = MKMapItem(placemark: puntoLugar)
            origen.name = "Current Location"
            aux = origen
        }
        
        pointLocation = locations.last! as CLLocation
        let locValue:CLLocationCoordinate2D = pointLocation.coordinate
        let puntoLugar = MKPlacemark(coordinate: locValue, addressDictionary: nil)
        destino = MKMapItem(placemark: puntoLugar)
        destino.name = "Punto no. \(count)"
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    

    func anotaPunto(punto: MKMapItem){
        let anota = MKPointAnnotation()
        anota.coordinate = punto.placemark.coordinate
        anota.title = punto.name
        mapaRuta.addAnnotation(anota)
        count += 1;
        self.obtenerRuta(aux!,destino: destino!)
        aux = destino
        arrCoordinates.append(punto.placemark.coordinate)
    }
    
    func obtenerRuta (origen: MKMapItem, destino: MKMapItem){
        let solicitud = MKDirectionsRequest()
        solicitud.source = origen
        solicitud.destination = destino
        solicitud.transportType = .Walking
        let indicaciones = MKDirections(request: solicitud)
        indicaciones.calculateDirectionsWithCompletionHandler({
            (respuesta: MKDirectionsResponse?, error: NSError?) in
            if error != nil{
                print("Error obteniendo ruta")
            }
            else{
                self.muestraRuta(respuesta!)
            }
        })
    }
    
    func muestraRuta(respuesta: MKDirectionsResponse){
        for ruta in respuesta.routes{
            mapaRuta.addOverlay(ruta.polyline, level: MKOverlayLevel.AboveRoads)
            
        }
        
        let centro = origen.placemark.coordinate
        let region = MKCoordinateRegionMakeWithDistance(centro, 3000, 3000)
        mapaRuta.setRegion(region, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        return renderer
    }

    @IBAction func btn_marcar() {
        self.anotaPunto(destino)
    }
    
    @IBAction func takePhoto() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {
            action in
            
            if UIImagePickerController.isSourceTypeAvailable(.Camera){
                picker.sourceType = .Camera
                self.presentViewController(picker, animated: true, completion: nil)
            }
            else{
                let alertCamera = UIAlertController(title: "Error", message: "Camara no disponible", preferredStyle: .Alert)
                alertCamera.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alertCamera, animated: true, completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: {
            action in
            picker.sourceType = .PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func guardar_rutas() {
        
        
        let alertController = UIAlertController(title: "Nombre Ruta", message: "Nombre de Ruta", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField) -> Void in
            textField.placeholder = "Nombre"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            
            var arrPuntoForRuta : [Punto] = []
            
            for punto in self.arrCoordinates{
                let puntoForRuta : Punto = Punto(longitud:punto.longitude, latitud: punto.latitude)
                arrPuntoForRuta.append(puntoForRuta)
            }
            
            let ruta = Rutas(nombre:(alertController.textFields?.first?.text)!, puntos: arrPuntoForRuta)
            let rutaEntidad = NSEntityDescription.insertNewObjectForEntityForName("Rutas", inManagedObjectContext: self.contexto!)
            rutaEntidad.setValue((alertController.textFields?.first?.text)!, forKey: "nombre")
            rutaEntidad.setValue(self.crearPuntosEntidad(ruta.puntos), forKey: "tiene")
            
            do {
                try self.contexto?.save()
            }
            catch  {
                print("Hubo un errror al guardar")
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        let alertControllerError = UIAlertController(title: "Error", message: "Al menos debes de agregar un punto para guardar la ruta", preferredStyle: UIAlertControllerStyle.Alert)

        let okActionError = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertControllerError.addAction(okActionError)
        
        if(arrCoordinates.count == 0){
          self.presentViewController(alertControllerError, animated: true, completion: nil)
        }
        else{
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    func crearPuntosEntidad(puntos : [Punto]) -> Set<NSObject> {
        var entidades = Set <NSObject>()
        
        for pto in puntos {
            let puntoEntidad = NSEntityDescription.insertNewObjectForEntityForName("Punto", inManagedObjectContext: self.contexto!)
            puntoEntidad.setValue(pto.latitud, forKey: "latitud")
            puntoEntidad.setValue(pto.longitud, forKey: "longitud")
            entidades.insert(puntoEntidad)
        }
        
        return entidades
    }
    
    func ar(arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let vista = TestAnnotationView()
        vista.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        vista.frame = CGRect(x:0,y: 0, width: 150, height: 60)
        return vista
    }
    
    func iniciaRAG(){
        
        for punto in rutas[ip].puntos{
            let latitde = punto.latitud
            let longitude = punto.longitud
            
            let puntosDeInteres = obtenerAnotaciones(latitud: latitde, longitud: longitude)
            
            let arViewController = ARViewController()
            arViewController.debugEnabled = true
            arViewController.dataSource = self
            arViewController.maxDistance = 0
            arViewController.maxVisibleAnnotations = 100
            arViewController.maxVerticalLevel = 5
            arViewController.trackingManager.userDistanceFilter = 25
            arViewController.trackingManager.reloadDistanceFilter = 75
            
            arViewController.setAnnotations(puntosDeInteres)
            self.presentViewController(arViewController, animated: true, completion: nil)
        }
        
        
    }
    
    private func obtenerAnotaciones(latitud latitud: Double, longitud: Double) -> Array<ARAnnotation>{
        
        var anotaciones : [ARAnnotation] = []
        srand48(3)
        
        

            let anotacion = ARAnnotation()
            anotacion.location = self.obtenerPosiciones(latitud: latitud, longitud: longitud)
            anotacion.title = "Punto de Interés"
            anotaciones.append(anotacion)
        
        return anotaciones
        
    }
    
    private func obtenerPosiciones(latitud latitud: Double, longitud: Double) -> CLLocation{
        
        let lat = latitud
        let lon = longitud
        
        return CLLocation(latitude: lat, longitude: lon)
        
    }

    @IBAction func launchRA() {
        
        iniciaRAG()
    }
    
    @IBAction func compartir(sender: UIBarButtonItem) {
        
        var textoFijo : String = ""
        if (ip == -1){
            for punto in arrCoordinates{
                textoFijo.appendContentsOf("Punto, latitud: \(punto.latitude), longitud:\(punto.longitude)")
            }
        }
        
        else{
            for punto in rutas[ip].puntos{
                textoFijo.appendContentsOf("Punto, latitud: \(punto.latitud), longitud:\(punto.longitud)")
            }
        }
        
        
        if let miSitio = NSURL(string:"http://google.com"){
            let objetosCompartir = [textoFijo,miSitio]
            let actividad = UIActivityViewController(activityItems: objetosCompartir, applicationActivities: nil)
            self.presentViewController(actividad, animated: true, completion: nil)
        }
    }
}

extension RutasViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        //use image here!
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}