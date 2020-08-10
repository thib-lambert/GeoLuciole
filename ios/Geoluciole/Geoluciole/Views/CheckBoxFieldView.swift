//    Copyright (c) 2020, Martin Allusse and Alexandre Baret and Jessy Barritault and Florian
//    Bertonnier and Lisa Fougeron and François Gréau and Thibaud Lambert and Antoine
//    Orgerit and Laurent Rayez
//    All rights reserved.
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the University of California, Berkeley nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ''AS IS'' AND ANY
//    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
import Foundation
import UIKit

class CheckBoxFieldView: UIView, UIGestureRecognizerDelegate {

    fileprivate var checkbox: CheckBoxView!
    var optionLabel: YUILabel!
    var onCheckChange: ((CheckBoxFieldView) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.checkbox = CheckBoxView()
        self.checkbox.style = .circle
        self.checkbox.borderStyle = .rounded
        self.checkbox.isUserInteractionEnabled = false
        self.checkbox.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.checkbox)

        self.optionLabel = YUILabel()
        self.optionLabel.numberOfLines = 0
        self.optionLabel.textAlignment = .justified
        self.optionLabel.style = .bodyItalic
        self.optionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.optionLabel.text = ""
        self.addSubview(self.optionLabel)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckBoxFieldView.touchOnCheckBox))
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.delegate = self
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapRecognizer)

        NSLayoutConstraint.activate([

            self.topAnchor.constraint(equalTo: self.optionLabel.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.optionLabel.bottomAnchor),
            self.leftAnchor.constraint(equalTo: self.checkbox.leftAnchor),
            self.rightAnchor.constraint(equalTo: self.optionLabel.rightAnchor),

            self.checkbox.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.checkbox.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.checkbox.heightAnchor.constraint(equalToConstant: 25),
            self.checkbox.widthAnchor.constraint(equalTo: self.checkbox.heightAnchor),

            self.optionLabel.leftAnchor.constraint(equalTo: self.checkbox.rightAnchor, constant: Constantes.FIELD_SPACING_HORIZONTAL),
            self.optionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var checked: Bool {
        get {
            return self.checkbox.isChecked
        }

        set {
            self.checkbox.isChecked = newValue
        }
    }

    var titleOption: String {
        get {
            return self.optionLabel!.text ?? ""
        }

        set(titleOption) {
            self.optionLabel.text = titleOption
        }
    }

    @objc fileprivate func touchOnCheckBox() {
        self.checked = !self.checked
        self.onCheckChange?(self)
    }

    var style: CheckBoxView.Style {
        get {
            return self.checkbox.style
        }
        set {
            self.checkbox.style = newValue
        }
    }

    var borderStyle: CheckBoxView.BorderStyle {
        get {
            return self.checkbox.borderStyle
        }
        set {
            self.checkbox.borderStyle = newValue
        }
    }

    var checkmarkColor: UIColor {
        get {
            return self.checkbox.checkmarkColor
        }
        set {
            self.checkbox.checkmarkColor = newValue
        }
    }

    var checkedBorderColor: UIColor {
        get {
            return self.checkbox.checkedBorderColor
        }
        set {
            self.checkbox.checkedBorderColor = newValue
        }
    }

    var uncheckedBorderColor: UIColor {
        get {
            return self.checkbox.uncheckedBorderColor
        }
        set {
            self.checkbox.uncheckedBorderColor = newValue
        }
    }
}
