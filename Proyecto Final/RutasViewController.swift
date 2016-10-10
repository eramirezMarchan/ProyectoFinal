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

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class RutasViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    var selectedPin:MKPlacemark? = nil
    private var origen: MKMapItem!
    private var destino: MKMapItem!
    private var aux: MKMapItem!
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var startLocation :CLLocation!
    var pointLocation :CLLocation!
    var count = 1;
    
    @IBOutlet weak var mapaRuta: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Rutas"
        mapaRuta.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        
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