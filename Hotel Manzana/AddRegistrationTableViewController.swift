//
//  AddRegistrationTableViewController.swift
//  Hotel Manzana
//
//  Created by 김가윤 on 4/5/24.
//

import UIKit

class AddRegistrationTableViewController: UITableViewController, SelectRoomTypeTableViewControllerDelegate {
    func selectRoomTypeTableViewController(_ controller: SelectRoomTypeTableViewController, didSelect roomType: RoomType) {
        self.roomType = roomType
        updateRoomType()
    }
    

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var checkOutDatePicker: UIDatePicker!
    
    @IBOutlet weak var numberOfAdultsLabel: UILabel!
    @IBOutlet weak var numberOfAdultsStepper: UIStepper!
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var numberOfChildrenStepper: UIStepper!
    
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    @IBOutlet weak var roomTypeLabel: UILabel!
        
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    @IBOutlet weak var numberOfNightsLabel: UILabel!
    @IBOutlet weak var numberOfNightsInDetailLabel: UILabel!
    @IBOutlet weak var roomPriceLabel: UILabel!
    @IBOutlet weak var roomPriceInDetailLabel: UILabel!
    @IBOutlet weak var wifiPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
    let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    let checkInDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    let checkOutDateLabelCellIndexPath = IndexPath(row: 2, section: 1)
    
    var isCheckInDatePickerVisible: Bool = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerVisible
        }
    }
    var isCheckOutDatePickerVisible: Bool = false {
        didSet {
            checkOutDatePicker.isHidden = !isCheckOutDatePickerVisible
        }
    }
    
    var roomType: RoomType?
    var registration: Registration? {
        
        guard let roomType = roomType else {return nil}
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        let numberOfAdults = Int(numberOfAdultsStepper.value)
        let numberofChildren = Int(numberOfChildrenStepper.value)
        let hasWifi = wifiSwitch.isOn
        
        return Registration(firstName: firstName, lastName: lastName, emailAddress: email, checkInDate: checkInDate, checkOutDate: checkOutDate, numberofAdults: numberOfAdults, numberOfChildren: numberofChildren, wifi: hasWifi, roomType: roomType)
        
    }
    
    var selectedRegistration: Registration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
        
        updateDateViews()
        updateNumberOfGuests()
        updateRoomType()
        checkSelectedRegistration()
        
        doneButtonUpdate()
        calculateTotalPrice()
        
    }
    
    func calculateTotalPrice() {
        
        guard let totalDays = Calendar.current.dateComponents([.day], from: checkInDatePicker.date, to: checkOutDatePicker.date).day else {return}
        let numberOfDays = totalDays + 1
        
        numberOfNightsLabel.text = String(numberOfDays)
        numberOfNightsInDetailLabel.text = String((checkInDatePicker.date..<checkOutDatePicker.date).formatted(date: .abbreviated, time: .omitted))
        
        roomPriceLabel.text = "$ \(String((roomType?.price ?? 0) * numberOfDays))"
        roomPriceInDetailLabel.text = "\(roomType?.name ?? "") $\(roomType?.price ?? 0)/per night"
        
        if wifiSwitch.isOn {
            
            wifiPriceLabel.text = "$ \(String(numberOfDays * 10))"
            totalPriceLabel.text = "$ \(((roomType?.price ?? 0) * numberOfDays) + (numberOfDays * 10))"
            
        } else {
            
            wifiPriceLabel.text = "$ 0"
            totalPriceLabel.text = "$ \((roomType?.price ?? 0) * numberOfDays)"
            
        }
        
    }
    
    func doneButtonUpdate() {
        
        doneButton.isEnabled = false
        
        
        // first name, last name, email, adults
        if numberOfAdultsStepper.value < 1 || roomTypeLabel.text == "Not Set" || firstNameTextField.text == "" || lastNameTextField.text == "" || emailTextField.text == "" {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
        
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        doneButtonUpdate()
    }
    
    func checkSelectedRegistration() {
        
        guard let selectedRegistration = selectedRegistration  else {return}
        
        firstNameTextField.text = selectedRegistration.firstName
        lastNameTextField.text = selectedRegistration.lastName
        emailTextField.text = selectedRegistration.emailAddress
        
        checkInDateLabel.text = selectedRegistration.checkInDate.formatted(date: .abbreviated, time: .omitted)
        checkOutDateLabel.text = selectedRegistration.checkOutDate.formatted(date: .abbreviated, time: .omitted)
        checkInDatePicker.date = selectedRegistration.checkInDate
        checkOutDatePicker.date = selectedRegistration.checkOutDate
        
        numberOfAdultsLabel.text = String(selectedRegistration.numberofAdults)
        numberOfChildrenLabel.text = String(selectedRegistration.numberOfChildren)
        numberOfAdultsStepper.value = Double(selectedRegistration.numberofAdults)
        numberOfChildrenStepper.value = Double(selectedRegistration.numberOfChildren)
        
        wifiSwitch.isOn = selectedRegistration.wifi
        roomTypeLabel.text = selectedRegistration.roomType.name
        
    }
    
    func updateDateViews() {
        
        checkOutDatePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: checkInDatePicker.date)
        
        checkInDateLabel.text = checkInDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        checkOutDateLabel.text = checkOutDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
        calculateTotalPrice()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
        case checkInDatePickerCellIndexPath where isCheckInDatePickerVisible == false:
            return 0
        case checkOutDatePickerCellIndexPath where isCheckOutDatePickerVisible == false:
            return 0
        default:
            return UITableView.automaticDimension
        }
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
        case checkInDatePickerCellIndexPath:
            return 190
        case checkOutDatePickerCellIndexPath:
            return 190
        default:
            return UITableView.automaticDimension
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath == checkInDateLabelCellIndexPath && isCheckOutDatePickerVisible == false {
            
            isCheckInDatePickerVisible.toggle()
            
        } else if indexPath == checkOutDateLabelCellIndexPath && isCheckInDatePickerVisible == false {
            
            isCheckOutDatePickerVisible.toggle()
            
        } else if indexPath == checkInDateLabelCellIndexPath || indexPath == checkOutDateLabelCellIndexPath {
            
            isCheckInDatePickerVisible.toggle()
            isCheckOutDatePickerVisible.toggle()
            
        } else {
            return
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func updateNumberOfGuests() {
        
        numberOfAdultsLabel.text = "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel.text = "\(Int(numberOfChildrenStepper.value))"
        doneButtonUpdate()
        
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateNumberOfGuests()
    }
    
    
    @IBAction func wifiSwitchChanged(_ sender: UISwitch) {
        calculateTotalPrice()
    }
    
    func updateRoomType() {
        if let roomType = roomType {
            roomTypeLabel.text = roomType.name
            doneButtonUpdate()
        } else {
            roomTypeLabel.text = "Not Set"
        }
        calculateTotalPrice()
    }
    
    @IBSegueAction func selectRoomType(_ coder: NSCoder) -> SelectRoomTypeTableViewController? {
        
        let selectRoomTypeController = SelectRoomTypeTableViewController(coder: coder)
        selectRoomTypeController?.delegate = self
        selectRoomTypeController?.roomType = roomType
        
        return selectRoomTypeController
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
