//
//  ViewController.swift
//  MapaLocaliza
//
//  Created by Fernando Rojas Hidalgo on 7/16/18.
//  Copyright © 2018 Rohisa. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController , CLLocationManagerDelegate, MKMapViewDelegate{

    
    var inicio = false
    var latitud : Double = 0
    var longitud : Double = 0
    var ultimoPunto = CLLocation()
    var primerPunto = CLLocation()
    var distanciaTotal : Double = 0
    @IBOutlet weak var mapa: MKMapView!
    
    private let manejador = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest //LA MEJOR SENAL DISPONIBLE
        manejador.requestWhenInUseAuthorization()

    }
    
    func mapa(_ mapa: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapa.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse){
            manejador.startUpdatingLocation()
            manejador.startUpdatingHeading()
            mapa.showsUserLocation = true
           
            
        }else{
            manejador.stopUpdatingLocation()
            manejador.stopUpdatingHeading()
            mapa.showsUserLocation = false

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let norteMagnetico = "\(newHeading.magneticHeading)"
        let norteGeografico = "\(newHeading.trueHeading)"
        
        print(norteMagnetico)
        print(norteGeografico)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitud = manager.location!.coordinate.latitude
        longitud = manager.location!.coordinate.longitude
        let rango = "\(manager.location!.horizontalAccuracy)"

        var punto = CLLocationCoordinate2D()
        punto.longitude = longitud
        punto.latitude = latitud
        let pin = MKPointAnnotation()
        pin.title = "Lat: \(latitud), Lon: \(longitud)"

        if (inicio == false){
            ultimoPunto = CLLocation(
                latitude:  latitud,
                longitude: longitud
            )
            
            primerPunto = CLLocation(
                latitude:  latitud,
                longitude: longitud
            )
            pin.subtitle = "0"
            pin.coordinate = punto
            mapa.addAnnotation(pin)
            mapa.setCenter(punto, animated: false)
            inicio = true
        }
        
        let positionActual = CLLocation(
            latitude:  latitud,
            longitude: longitud
        )

        let distancia = ultimoPunto.distance(from: positionActual)
        if (distancia > 50 ) {
            distanciaTotal = distanciaTotal + distancia
            ultimoPunto = CLLocation(
                latitude:  latitud,
                longitude: longitud
            )
            
            pin.subtitle = String(distanciaTotal)
            pin.coordinate = punto
            mapa.addAnnotation(pin)
        }
    }

    /// Returns the distance (in meters) from the
    /// user's location to the specified point.
    private func userDistance(from point: MKPointAnnotation) -> Double? {
        guard let userLocation = mapa.userLocation.location else {
            return nil // User location unknown!
        }
        let pointLocation = CLLocation(
            latitude:  point.coordinate.latitude,
            longitude: point.coordinate.longitude
        )
        return userLocation.distance(from: pointLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alerta = UIAlertController(title: "Error", message: "Error en la localización \(error.localizedDescription)", preferredStyle: .alert)
        
        let accionOK = UIAlertAction(title: "OK", style: .default, handler: {accion in
            //..
        })
        
        alerta.addAction(accionOK)
        self.present(alerta, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var btnNormalO: UIButton!
    @IBAction func btnNormal(_ sender: UIButton) {
        if (btnNormalO.currentTitle == "Normal"){
            mapa.mapType = MKMapType.satellite
            btnNormalO.setTitle("Satelite", for: UIControlState.normal)
        }else if (btnNormalO.currentTitle == "Satelite"){
            mapa.mapType = MKMapType.hybrid
            btnNormalO.setTitle("Hibrido", for: UIControlState.normal)
        }else if (btnNormalO.currentTitle == "Hibrido"){
            mapa.mapType = MKMapType.standard
            btnNormalO.setTitle("Normal", for: UIControlState.normal)
        }

    }
    
    
    @IBAction func btnMasZoom(_ sender: UIButton) {
        var region: MKCoordinateRegion = mapa.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapa.setRegion(region, animated: false)
    }
    
    @IBAction func btnMenosZoom(_ sender: UIButton) {
        var region: MKCoordinateRegion = mapa.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapa.setRegion(region, animated: false)
    }
    
    
 
    
}

