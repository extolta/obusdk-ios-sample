
import UIKit
import OBUSDK

class ViewController: UIViewController {
    var selectedOBU: OBU!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    weak var tableController: TableViewController?

    override func viewDidLoad() {
        // Conform to the delegates of the OBU SDK
        OBUSDKManager.shared.dataDelegate = self
        OBUSDKManager.shared.connectionStatusDelegate = self
       
        // Step 1: SDK Initialization
        // Developers must register at https://datamall.lta.gov.sg/content/datamall/en/request-for-api.html
        // to obtain the SDK account key for the OBU SDK. Initialization is mandatory before calling any other methods.
        initialiseOBUSdk()

        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func getPairedDevices() {
        OBUSDKManager.shared.getPairedDevices { result in
            switch result {
            case .success(let obus):
                print("Number of OBUs paired: \(String(describing: obus?.count))")
            case .failure(let error):
                print(error.code)
            }
        }
    }

     func initialiseOBUSdk() {
        OBUSDKManager.shared.initializeSDK(with: "<SDK Account Key>") { result in
            switch result {
            case .success:
                print("Init Success")
            case .failure(let error):
                print(error.code)
                print("Init Failure: \(error.code)")
            }
        }
    }

    // Step 2: Request OBU Data Permission
    // The SDK requires one-time permission from the motorist to access OBU data.
    // This method presents a popup to the motorist for granting the permission.
    // It's necessary to complete this step before calling other APIs.
    // You can check the permission status by calling OBUSDKManager.shared.isDataPermissionGranted().

    @IBAction func obuDataPermission() {
        OBUSDKManager.shared.requestOBUDataAccessPermission { result in
            switch result {
            case .success:
                print("Permission Granted")

            case .failure(let error):
                print(error.code)
                print("Permission not Granted : \(error.code)")

            }
        }
    }
    
    // Initiates a search for nearby OBUs.
    // Call `startSearch()` to search for OBUs.
    // The method 'onOBUFound' in the delegate will return a list of OBUs found during the search. In the case of the Mock Manager, onOBUFound will return a mock OBU automatically.
    // The search runs for one minute.
    
    @IBAction func searchOBU() {
        OBUSDKManager.shared.startSearch()

        tableController?.obuSelectedClosure = { [weak self] (obu: OBU) in
            self?.selectedOBU = obu
            // stop search
            OBUSDKManager.shared.stopSearch()
            
            DispatchQueue.main.async {
                self?.statusLabel.text = obu.name
            }
        }
    }

    @IBAction func connectOBU() {
        if let obu = selectedOBU {
            OBUSDKManager.shared.connectOBU(obu: obu)
           self.loaderView.startAnimating()
            statusLabel.text = "Connecting..."
        }
    }

    // Disconnect the connection
    @IBAction func disconnectOBU() {
        OBUSDKManager.shared.disconnectOBU()
        statusLabel.text = "Disconnected"
    }

    // Enable Mock Manager
    @IBAction func enableMockManager() {
        // This will start the Mock search and connection
        let settings = MockBuilder()
            .setCardBalance(100)
            .setTimeInterval(2)
            .setCyclicMode(true)
            .setSequence([MockEvent(electronicEventList: [PointBasedCharging()], tdcidEvent: nil)])
            .build()

        OBUSDKManager.shared.enableMockSetting(settings)
    }

     func connectViaVehicleNumber() {
        let alertController = UIAlertController(title: "Connect to OBU", message: "Please enter your vehicle number", preferredStyle: .alert)
        let connectAction = UIAlertAction(title: "Connect", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let vehicleID = txtField.text {

                if !OBUSDKManager.shared.isSDKInitialised() {
                    print("SDK not initilaised")
                }
                if !OBUSDKManager.shared.isDataPermissionGranted() {
                    print("OBU data permission not granted")
                }

                OBUSDKManager.shared.connectToOBU(vehicleId: vehicleID)
                print("Connecting to \(vehicleID)...")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Vehicle Number" }

        alertController.addAction(connectAction)
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is TableViewController {
            tableController = segue.destination as? TableViewController
        }
    }
}

// MARK: - Connection delegate methods

extension ViewController: OBUConnectionDelegate {
    func onSearchFinished() {
        print("search finished")
    }

    func onOBUConnected(_ device: OBU) {
        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            self.statusLabel.text = "Connected:" + device.name
        }
    }

    func onOBUDisconnected(_ device: OBU, error: NSError?) {
        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            self.statusLabel.text = "Disconnected"
        }
    }

    func onOBUFound(_ device: [OBU]) {
        print("OBUs Found: \(device.count)")

        if !device.isEmpty {
            DispatchQueue.main.async {
                self.tableController?.reloadTableView(device)
            }
        }
    }

    func onOBUConnectionFailure(_ error: NSError) {

        print("onOBUConnectionFailure: \(error.code)")

        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            self.statusLabel.text = "Connection Failed"
        }
    }

    func onBluetoothStateUpdated(_ state: BluetoothState) {
        print("onBluetoothStateUpdated")
    }
}

// MARK: - Data delegate methods

extension ViewController: OBUDataDelegate {

    func onVelocityInformation(_ velocity: Double) {
        print("onVelocityInformation: \(velocity)")
    }

    func onAccelerationInformation(_ acceleration: OBUAcceleration) {
        print("onAccelerationInformation: \(acceleration)")
    }

    func onErpCharging(_ erp: [OBUChargingInformation]) {
        print("onErpCharging : \(erp.description)")
    }

    func onTrafficInformation(_ traffic: OBUTrafficInfo) {
        print("onTrafficInformation: \(traffic)")
    }

    func onErpChargingAndTrafficInfo(trafficInfo: OBUTrafficInfo?, chargingInfo: [OBUChargingInformation]?) {
        
    }

    func onPaymentHistories(_ history: [OBUPaymentHistory]) {
        print("onPaymentHistories: \(history)")
    }

    func onTravelSummary(_ travelSummary: OBUTravelSummary) {
        print("onTravelSummary: \(travelSummary)")
    }

    func onTotalTripCharged(_ totalCharged: OBUTotalTripCharged) {
        print("onTotalTripCharged: \(totalCharged)")
    }

    func onError(_ errorCode: NSError) {
        print("onError: \(errorCode.code)")
    }

    func onCardInformation(_ status: OBUCardStatus?, paymentMode: OBUPaymentMode?, chargingPaymentMode: OBUChargingPaymentMode?, balance: Int) {
    }
}

