//
//  ViewController.swift
//  HaritalarUygulamasi
//
//  Created by Beyza Gürbüz on 9.10.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
    
    var locationManager = CLLocationManager()
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //konum sinyalini alma işlemi her zaman en iyisini kullanmak bataryayı verimi düşürebilir
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        if secilenIsim != "" {
            //core datadan verileri çek
            
            if let uuidString = secilenId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch (fetchRequest)
                    
                    if sonuclar.count > 0 {
                        
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                annotationTitle=isim
                                
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle=not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                        annotationLatitude=latitude
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                            annotationLongitude=longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            isimTextField.text=annotationTitle
                                            notTextField.text=annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch { print("hata")
                    
                }
                
            } else{
                //yeni veri eklemeye geldi
                
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
         
        }
        let reuseId = "benimAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            //pinview a istediğimiz tüm özellikleri vermek için bunu yaptık.
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true //annotasyon buton falan eksta şeyler gösterir mi
            pinView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if secilenIsim != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            //güncellokasyon
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placeMarkDizisi, hata) in
                if let placemarks = placeMarkDizisi{
                    if placemarks.count > 0 {
                        
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
            }
        }
    }
    
   
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer){
        
        if gestureRecognizer.state  == .began {
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = notTextField.text
            mapView.addAnnotation(annotation)
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print( locations[0].coordinate.latitude) enlem
       // print (locations[0].coordinate.longitude) boylam
       if secilenIsim == "" {
           let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
           let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
           let region = MKCoordinateRegion(center: location, span: span)
           mapView.setRegion(region, animated: true)
            
        }
    }

    @IBAction func kaydetTiklandi(_ sender: Any) {
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelagate.persistentContainer.viewContext
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        yeniYer.setValue(secilenLatitude , forKey:"latitude")
        yeniYer.setValue(secilenLongitude , forKey:"longitude")
        yeniYer.setValue(UUID(), forKey:"id")
        
        do{
            try context.save()
            print("kayıt edildi")
        } catch
        {
                print("Hata")
            }
        NotificationCenter.default.post(name: NSNotification.Name.init("yeniYerOlusturuldu"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
}

