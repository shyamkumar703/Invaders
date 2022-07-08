// Copyright © TriumphSDK. All rights reserved.

import UIKit
import Network

public enum NetworkSpeedStatus {
    case poor
    case good
    case disconnected
    case pingError(String)
}

public protocol NetworkCheckerDelegate: AnyObject {
    func networkCheckerAlertDidFinish()
}

public protocol NetworkChecker {
    var delegate: NetworkCheckerDelegate? { get set }

    func start()
    func startTestConnectionSpeed()
    func testDownloadSpeed() async -> NetworkSpeedStatus
    func isConnectionGood() async -> Bool
    func stop()
}

// MARK: Network Checker Implementation

final class NetworkCheckerService: NetworkChecker {

    weak var delegate: NetworkCheckerDelegate?

    private var dependencies: Dependencies
    private var isAlertPresented: Bool = false
    private var timer: Timer?
    private let queue = DispatchQueue(label: "com.triumph.networkChecker")
    private let monitor: NWPathMonitor

    private(set) var isConnected = false
    private(set) var isExpensive = false
    private(set) var currentConnectionType: NWInterface.InterfaceType?
    let notificationCenter = NotificationCenter.default
    
    private var testUrl: String = "https://www.triumpharcade.com"

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.monitor = NWPathMonitor()
    }
    
    deinit {
        stop()
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        monitor.cancel()
        timer?.invalidate()
        timer = nil
        isAlertPresented = false
    }
    
    func start() {
        isAlertPresented = false // The service always in memory, so this prop should be always false when started check
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.isExpensive = path.isExpensive
            self?.currentConnectionType = NWInterface.InterfaceType.allCases.filter { path.usesInterfaceType($0) }.first
            self?.handleNetworkChange()
        }
        monitor.start(queue: queue)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(testNetworkSpeed),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func startTestConnectionSpeed() {
        timer = Timer.scheduledTimer(
            timeInterval: Configuration.NetworkConnection.timeInterval,
            target: self, selector: #selector(testNetworkSpeed),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func testNetworkSpeed() {
        guard isConnected else { return }
        
        Task {
            let result = await testDownloadSpeed(url: testUrl, timeout: Configuration.NetworkConnection.timeout)
            await MainActor.run {
                switch result {
                case .poor:
                    dependencies.logger.log("Connection is poor", .warning)
                    if isAlertPresented == true { return }
                    showAlert()
                case .good:
                    dependencies.logger.log("Connection is good")
                    if isAlertPresented == false { return }
                    self.dependencies.alertFabric.dismissAlert {
                        self.isAlertPresented = false
                    }
                case .disconnected:
                    dependencies.logger.log("Connection lost", .warning)
                case .pingError(let message):
                    dependencies.logger.log(message, .warning)
                }
            }
        }
    }
    
    func handleNetworkChange() {
        Task {
            await MainActor.run {
                if isConnected == false {
                    dependencies.logger.log("Connection lost", .warning)
                    NotificationCenter.default.post(name: .networkChecker, object: nil)
                    showAlert()
                } else {
                    guard isAlertPresented == true && timer == nil else { return }
                    dependencies.alertFabric.dismissAlert { [weak self] in
                        self?.isAlertPresented = false
                    }
                }
            }
        }
    }

    private func showAlert() {
        let alertModel = AlertModel(
            title: "Network Issue",
            message: "We noticed network connection issue. Try again later.",
            okButtonTitle: "Close",
            okHandler: { [weak self] _ in
                self?.delegate?.networkCheckerAlertDidFinish()
            }
        )
        dependencies.alertFabric.showAlert(alertModel, completion: nil)
        isAlertPresented = true
    }
    
    func testDownloadSpeed(url: String, timeout: TimeInterval) async -> NetworkSpeedStatus {
        guard let url = URL(string: url) else { return .pingError("Ping url is nil") }

        var config = NetworkSpeedConfig()
        config.startTime = CFAbsoluteTimeGetCurrent()
        config.bytesReceived = 0

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration)

        do {
            let (data, _) = try await session.data(from: url)
            config.bytesReceived += Float(data.count)
            config.stopTime = CFAbsoluteTimeGetCurrent()
            return config.speed < Configuration.NetworkConnection.lowSpeed ? .poor : .good
        } catch {
            let errorCode = (error as NSError?)?.code
            let isDomainError = (error as NSError?)?.domain == NSURLErrorDomain
            let isTimeOutError = errorCode == NSURLErrorTimedOut
            let isDisconnected = errorCode == -1009 || errorCode == -1020

            if isDomainError && isTimeOutError {
                return .poor
            } else if isDisconnected {
                return .disconnected
            } else {
                return .pingError(error.localizedDescription)
            }
        }
    }
    
    func testDownloadSpeed() async -> NetworkSpeedStatus {
        return await testDownloadSpeed(url: testUrl, timeout: Configuration.NetworkConnection.timeout)
    }
    
    func isConnectionGood() async -> Bool {
        switch await testDownloadSpeed() {
        case .good:
            return true
        default:
            return false
        }
    }
}

// MARK: - NWInterface.InterfaceType

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet
    ]
}

// MARK: - NetworkSpeedConfig

struct NetworkSpeedConfig {
    var startTime = CFAbsoluteTime() {
        didSet {
            stopTime = startTime
        }
    }

    var stopTime = CFAbsoluteTime()
    var bytesReceived: Float = 0
    
    var speed: Float {
        let elapsed = stopTime - startTime
        if elapsed != 0 {
            return bytesReceived / (Float(CFAbsoluteTimeGetCurrent() - startTime)) / 1024.0
        } else {
            return -1.0
        }
    }
}
