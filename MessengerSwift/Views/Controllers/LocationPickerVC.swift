//
//  LocationPickerVC.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 2.08.2023.
//

import UIKit
import CoreLocation
import MapKit

final class LocationPickerVC: UIViewController {
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?

    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    private var isPickable = true
    private var coordinates: CLLocationCoordinate2D?
    
    
    init (coordinates: CLLocationCoordinate2D?) {
        super.init(nibName: nil, bundle: nil)
        self.coordinates = coordinates
        self.isPickable = coordinates == nil
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonTapped))
            
            map.isUserInteractionEnabled = true

            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        } else {
            // Just Showing Location
            guard let coordinates = self.coordinates else {
                return
            }
            
            
            // Drop a pin on that location
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
            
        }
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButton))
        
        view.addSubview(map)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = CGRect(x: 0, y: view.height/16, width: view.width, height: view.height-view.height/16)
        
//        map.frame = view.bounds
    }
    
    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        completion?(coordinates)
        
        dismiss(animated: true)
    }

    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {

        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }

        // Drop a pin on that location

        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)

    }
    
    @objc func cancelButton() {
        print("Hakan")
        dismiss(animated: true)
    }
}
