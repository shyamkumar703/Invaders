// Copyright © TriumphSDK. All rights reserved.

import Foundation
import CoreLocation
import MapKit
import GEOSwift

public enum CheckEligibilityStatus {
    case undefined, notEligable, eligable
}

struct LocationConfiguration {
    static let locationRetriesAllowed = 3
    static let timeBetweenRetries = DispatchTimeInterval.seconds(1)
}

public protocol LocationManagerDelegate: AnyObject {
    /// Called when the user changes the authorization status that Triumph has to access their location
    func locationAuthStatusDidChange(_ isValidStatus: Bool)
}

public protocol LocationManagerCoordinatorDelegate: AnyObject {
    /// Called when the user changes the authorization status that Triumph has to access their location
    func locationAuthStatusDidChange(_ isValidStatus: Bool)
}

public protocol Location: CLLocationManagerDelegate {
    var delegate: LocationManagerDelegate? { get set }
    var coordinatorDelegate: LocationManagerCoordinatorDelegate? { get set }
    var dependencies: Dependencies { get }
    var isNotDetermined: Bool { get }
    var isValidToContinue: Bool { get }
    var isEligable: Bool? { get set }
    var locationManager: CLLocationManager { get }
    var pendingEligibilityCallback: (Int, (CheckEligibilityStatus) -> Void)? { get set }
    
    /// Show system alert to request location permissions
    func requestAuthorization()
    
    /// Get the state that the user is currently in
    func getStateName() -> String?
    
    /// Check whether the user's current location is supported by Triumph
    func checkEligibility(tries: Int, status: @escaping (CheckEligibilityStatus) -> Void)
    
    /// Check user eligiblity given current coordinates
    func handleCoordinates(latitude: Double, longitude: Double, completion: @escaping () -> Void)
}

public extension Location {

    func checkEligibility(tries: Int = 0, status: @escaping (CheckEligibilityStatus) -> Void) {
        Task { [weak self] in
            if await self?.dependencies.sharedSession.user?.disableLocationCheck ?? false {
                self?.isEligable = true
                status(.eligable)
                return
            }
            
            // If we failed cheating detection, return not eligible
            if !(self?.dependencies.cheatingPreventionService.passedCheatingDetection() == true) {
                self?.isEligable = false
                status(.notEligable)
                return
            }

            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                if let location = locationManager.location {
                    self?.handleCoordinates(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    ) {
                        self?.handleIsEligible(completion: status)
                    }
                } else {
                    if tries == LocationConfiguration.locationRetriesAllowed {
                        status(.undefined)
                        self?.pendingEligibilityCallback = nil
                    } else {
                        self?.requestAuthorization()
                        self?.pendingEligibilityCallback = (tries + 1, status)
                    }
                }
            case .restricted, .denied:
                self?.dependencies.logger.log("authorizationStatus: \(locationManager.authorizationStatus)", .warning)
                status(.notEligable)
                self?.isEligable = false
            default:
                if tries == LocationConfiguration.locationRetriesAllowed {
                    status(.undefined)
                    self?.pendingEligibilityCallback = nil
                } else {
                    self?.requestAuthorization()
                    self?.pendingEligibilityCallback = (tries + 1, status)
                }
            }
        }
    }
    
    func handleIsEligible(completion: @escaping (CheckEligibilityStatus) -> Void) {
        switch isEligable {
        case nil:
            completion(.undefined)
        case false:
            completion(.notEligable)
        case true:
            completion(.eligable)
        case .some:
            completion(.undefined)
        }
    }
}

// MARK: - Implementation

public class LocationManager: NSObject, Location {
    public var dependencies: Dependencies
    public weak var delegate: LocationManagerDelegate?
    
    // TODO: - What is this for?
    // In the future we will figure out a way to use user defaults to make this better
    public weak var coordinatorDelegate: LocationManagerCoordinatorDelegate?
    
    public lazy var locationManager = CLLocationManager()
    private let notificationCenter = NotificationCenter.default
        
    public var isEligable: Bool? {
        didSet {
            NotificationCenter.default.post(name: .locationUpdated, object: nil)
            Task { [weak self] in
                if let newEligable = await self?.dependencies.sharedSession.user?.isInSupportedLocation {
                    if newEligable != isEligable {
                        try await self?.dependencies.sharedSession.updateUserLocationEligability(isEligable ?? false)
                    }
                }
            }
        }
    }
    
    private var stateName: String? {
        didSet {
            if let stateName = stateName {
                if validStates.contains(stateName) {
                    isEligable = !dependencies.cheatingPreventionService.isUsingVPN()
                    return
                }
            }
            isEligable = false
        }
    }
    
    private let dispatchQueue = DispatchQueue(label: "LocationMangerQueue", qos: .default)

    public func getStateName() -> String? {
        stateName
    }

    private var validStates = ["Alabama", "Alaska", "California", "District of Columbia", "Georgia", "Hawaii", "Idaho", "Illinois", "Iowa", "Indiana", "Kansas", "Massachusetts", "Michigan", "Minnesota", "Missouri", "Nevada", "New Jersey", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Dakota", "Texas", "Utah", "Vermont", "Virginia", "West Virgina", "Wisconsin", "Wyoming"]

    public var pendingEligibilityCallback: (Int, (CheckEligibilityStatus) -> Void)?

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init()
        setupCommon()
        
        notificationCenter.addObserver(
            self, selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
 
    deinit {
        self.locationManager.stopUpdatingLocation()
        NotificationCenter.default.removeObserver(self)
    }
    
    // Stop updating location if we move to background
    @objc func appMovedToBackground() {
        locationManager.stopUpdatingLocation()
    }
    
    @objc func appWillEnterForeground() {
        // FIXME: - Should be implemented using only location manager
        locationManager.startUpdatingLocation()
        coordinatorDelegate?.locationAuthStatusDidChange(isValidToContinue)
        checkEligibility { _ in }
    }

    public func setupCommon() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    public func requestLocation() {
        locationManager.requestLocation()
    }

    public func startUpdatingLocation() {
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let isValidStatus = (status == .authorizedAlways || status == .authorizedWhenInUse)
        
        if isValidStatus {
            self.setupCommon()
        }
        
        self.coordinatorDelegate?.locationAuthStatusDidChange(isValidStatus)
        self.delegate?.locationAuthStatusDidChange(isValidStatus)
    }

    // MARK: - Requsting Authorization
    
    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public var isNotDetermined: Bool {
        let authState = CLLocationManager.authorizationStatus()
        return authState == .notDetermined
    }
    
    public var isValidToContinue: Bool {
        let authState = CLLocationManager.authorizationStatus()
        return authState == .authorizedAlways || authState == .authorizedWhenInUse
    }

    // MARK: - Location delegate method
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if let callback = pendingEligibilityCallback {
            DispatchQueue.main.asyncAfter(deadline: .now() + LocationConfiguration.timeBetweenRetries) {
                self.checkEligibility(tries: callback.0, status: callback.1)
            }
        }
        if let location = locationManager.location {
            handleCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) {
                if let delegate = self.delegate {
                    delegate.locationAuthStatusDidChange(self.isEligable ?? false)
                }
                NotificationCenter.default.post(name: .locationUpdated, object: nil)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dependencies.logger.log(error.localizedDescription, .error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        handleCoordinates(latitude: locValue.latitude, longitude: locValue.longitude)
    }
    
    // Looks up coordinates in a geoJSON (from the 2010 census) to determine the state
    // https://eric.clst.org/tech/usgeojson/
    public func handleCoordinates(latitude: Double, longitude: Double, completion: @escaping () -> Void = {}) {
        dispatchQueue.async {
            let bundle = TriumphCommon.bundle
            guard let path = bundle.url(forResource: "usGeoJson", withExtension: "geojson"),
                  let data = try? Data(contentsOf: path) else {
                      completion()
                      return
                  }

            switch try? JSONDecoder().decode(GeoJSON.self, from: data) {
            case .featureCollection(let features):
                let location = Point(x: longitude, y: latitude)
                self.handleLocationIn(featureCollection: features, location: location)
                completion()
                return
            default:
                completion()
                return
            }
        }
    }

    public func handleLocationIn(featureCollection: (FeatureCollection), location: Point) {
        for stateJSON in featureCollection.features {
            let featureContains = try? stateJSON.geometry?.contains(location)
            if featureContains == true {
                guard let props = stateJSON.properties,
                      let stateName = props["NAME"]?.untypedValue else { return }
                self.stateName = stateName as? String
                return
            }
        }
        stateName = nil
    }
}
