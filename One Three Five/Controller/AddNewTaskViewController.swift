//
//  AddNewTaskViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/3/20.
//

import UIKit
import Combine
import Loaf

class AddNewTaskViewController: UIViewController {
    
    //  MARK: Properties
    @Published private var taskString: String? ///Observe this variable because this is what will be updated as we type into the textfield
    private var currentTasktype: TaskType = .one
    private var subscribers = Set<AnyCancellable>() /// a publisher have to have a subscriber.
    weak var delegate: NewTaskVCDelegate?
    var taskToEdit: Task?
    
    //  MARK: IBProperties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var BottomContainerView: UIView!
    @IBOutlet weak var TaskTextfield: UITextField!
    @IBOutlet weak var TaskPickerView: UIPickerView!
    @IBOutlet weak var errorMsgLabel: UILabel! = {
        let lbl = UILabel()
        lbl.textColor = Constants.orangeTintColorFDB903
        return lbl
    }()
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let taskString = self.taskString else {return}
        var task = Task(title: taskString, taskType: currentTasktype)
        /// make sure user doesn't add more than 9 tasks or more than 1/1, 3/3, 5/5
        
        if let id = taskToEdit?.id{
            task.id = id
        }
        if taskToEdit == nil{
            /// creating new task
            delegate?.didAddTask(for: task)
        } else {
            /// update task with new info
            delegate?.didEditTask(for: task)
        }
    }
    
    //  MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGesture()
        observeKeyboard()
        observeForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        TaskTextfield.becomeFirstResponder()
    }
    
    //  MARK: Selectors
    @objc func tapToDismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut) {[weak self] in
            /// pushes the bottomVC up by keyboardHeight but down by 20, which is the space of bottom between stackview and container)
            self?.containerViewBottomConstraint.constant = keyboardHeight - 40
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        containerViewBottomConstraint.constant = -BottomContainerView.frame.height
    }
    
    //  MARK: Privates
    private func configureUI(){
        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        
        BottomContainerView.layer.cornerRadius = 35
        BottomContainerView.layer.borderWidth = 3
        BottomContainerView.layer.borderColor = Constants.bottomContainerBorder?.cgColor
        BottomContainerView.backgroundColor = UIColor(named: "viewbackgroundWhitesmoke")
        
        containerViewBottomConstraint.constant = -BottomContainerView.frame.height
        
        TaskTextfield.backgroundColor = .clear
        TaskTextfield.borderStyle = .none
        TaskTextfield.textColor =  Constants.blackWhite
        TaskTextfield.font = UIFont(name: Constants.fontMedium, size: 20)
        
        TaskPickerView.delegate = self
        TaskPickerView.dataSource = self
        /// customize pickerview
        
        TaskPickerView.backgroundColor = .clear
        TaskPickerView.layer.borderWidth = 3
        TaskPickerView.layer.borderColor = Constants.innerYellowFCD12A.cgColor
        TaskPickerView.layer.cornerRadius = 20
        
        saveButton.tintColor = Constants.blackWhite
        saveButton.layer.cornerRadius = 10
        saveButton.titleLabel?.font = UIFont(name: Constants.fontMedium, size: 19)
        
        if let taskToEdit = taskToEdit {
            TaskTextfield.text = taskToEdit.title
            taskString = taskToEdit.title
            currentTasktype = taskToEdit.taskType
            switch currentTasktype{
            case .one:
                TaskPickerView.selectRow(0, inComponent: 0, animated: false)
            case.three:
                TaskPickerView.selectRow(1, inComponent: 0, animated: false)
            case.five:
                TaskPickerView.selectRow(2, inComponent: 0, animated: false)
            }
            saveButton.setTitle("Update", for: .normal)
            /// update time  created to time updated
        }
    }
    
    private func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismissViewController))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func observeKeyboard(){
        /// to observe when the keyboard is available and push the bottom card up or down
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //  MARK: Combine
    private func observeForm() {
        let notificationName = UITextField.textDidChangeNotification
        NotificationCenter.default.publisher(for: notificationName).map { (notification) -> String? in
            return (notification.object as? UITextField)?.text
        }.sink {[unowned self] (text) in
            self.taskString = text
        }.store(in: &subscribers)
        
        /// change button enable status based on taskString is empty or not
        $taskString.sink { (text) in
            self.saveButton.isEnabled = text?.isEmpty == false
        }.store(in: &subscribers)
    }
}

//  MARK: Extensions
extension AddNewTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource, Animatable{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TaskType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let textColor = Constants.blackYellow
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: Constants.fontMedium, size: 18)
            pickerLabel?.textAlignment = .center
            pickerLabel?.backgroundColor = Constants.pickerLabelBackground
        }
        pickerLabel?.text = TaskType.allCases[row].rawValue
        pickerLabel?.textColor = textColor
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row{
        case 0:
            currentTasktype = .one
        case 1:
            currentTasktype = .three
        case 2:
            currentTasktype = .five
        default:
            break
        }
    }
    
    
}
