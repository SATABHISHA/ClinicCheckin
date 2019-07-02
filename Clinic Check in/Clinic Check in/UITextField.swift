import Foundation
import UIKit

extension UITextField {
    func loadDropdownData(data: [String]) {
        self.inputView = MedicationPickerView(pickerData: data, dropdownField: self)
    }
    
    func loadDropdownData(data: [String], onSelect selectionHandler : (selectedText: String) -> Void) {
        self.inputView = MedicationPickerView(pickerData: data, dropdownField: self, onSelect: selectionHandler)
    }
}
