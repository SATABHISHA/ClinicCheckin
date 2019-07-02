import Foundation
class MedicationPickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var pickerData : [String]!
    var pickerTextField : UITextField!
    var selectionHandler : ((_ selectedText: String) -> Void)?
    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: CGRectZero)
        self.pickerData = pickerData
        self.pickerTextField = dropdownField
        self.delegate = self
        self.dataSource = self
        dispatch_async(dispatch_get_main_queue(), {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData[0]
                self.pickerTextField.enabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.enabled = false
            }
        })
        if (self.pickerTextField.text != nil && self.selectionHandler != nil) {
            selectionHandler(selectedText: self.pickerTextField.text!)
        }
    }
    init(pickerData: [String], dropdownField: UITextField, onSelect selectionHandler : (_ selectedText: String) -> Void) {
        self.selectionHandler = selectionHandler
        self.init(pickerData, dropdownField)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Sets number of columns in picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
    }
    // Sets the number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
    }
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
    }
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]
        if (self.pickerTextField.text != nil && self.selectionHandler != nil) {
            selectionHandler(selectedText: self.pickerTextField.text!)
        }
    }
    
}
