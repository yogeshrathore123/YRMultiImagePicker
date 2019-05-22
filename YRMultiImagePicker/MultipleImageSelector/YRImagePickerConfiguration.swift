//
//  YRImagePickerConfiguration.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import Foundation

/// Configuration. Optionally change localized strings.
public class YRImagePickerConfiguration: NSObject {
    
    var updateStrings: ((YRImagePickerConfiguration) -> Void)?
    
    /// Localized navigation title. Defaults to "Photos".
    public var navigationTitle: String? {
        didSet {
            updateStrings?(self)
        }
    }
    
    /// Localized library segment title. Only displays when using external URLs in `UISegmentedControl`.
    public var librarySegmentTitle: String? {
        didSet {
            updateStrings?(self)
        }
    }
    
    /// Localized 'Cancel' button text.
    public var cancelButtonTitle: String? {
        didSet {
            updateStrings?(self)
        }
    }
    
    /// Localized 'Done' button text.
    public var doneButtonTitle: String? {
        didSet {
            updateStrings?(self)
        }
    }
    
    /// Localized maximum selections allowed error message displayed to the user.
    public var maximumSelectionsAllowedMessage: String?
    
    /// Localized "OK" string.
    public var okayString: String?
}
