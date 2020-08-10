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

class LanguageSelectorView: UIView {

    fileprivate var frenchOption: CheckBoxFieldView!
    fileprivate var englishOption: CheckBoxFieldView!
    var onChange: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let titleLabel = YUILabel()
        titleLabel.style = .subtitleBold
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = Tools.getTranslate(key: "app_language")
        self.addSubview(titleLabel)

        self.frenchOption = CheckBoxFieldView()
        self.frenchOption.titleOption = Tools.getTranslate(key: "french_language")
        self.frenchOption.translatesAutoresizingMaskIntoConstraints = false
        self.frenchOption.onCheckChange = { [weak self] checkBox in
            guard let strongSelf = self else { return }
            strongSelf.valueChange(checkBox)
        }
        self.addSubview(self.frenchOption)

        self.englishOption = CheckBoxFieldView()
        self.englishOption.titleOption = Tools.getTranslate(key: "english_language")

        self.englishOption.translatesAutoresizingMaskIntoConstraints = false
        self.englishOption.onCheckChange = { [weak self] checkBox in
            guard let strongSelf = self else { return }
            strongSelf.valueChange(checkBox)
        }
        self.addSubview(self.englishOption)

        let languageSelected = (UserPrefs.shared.object(forKey: .appleLanguage) as! NSArray).firstObject as! String

        if languageSelected.contains("fr") {
            self.frenchOption.checked = true
        } else {
            self.englishOption.checked = true
        }

        NSLayoutConstraint.activate([

            self.bottomAnchor.constraint(equalTo: self.frenchOption.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor),

            self.frenchOption.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constantes.FIELD_SPACING_VERTICAL),
            self.frenchOption.leftAnchor.constraint(equalTo: self.leftAnchor),

            self.englishOption.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constantes.FIELD_SPACING_VERTICAL),
            self.englishOption.leftAnchor.constraint(equalTo: self.frenchOption.rightAnchor, constant: Constantes.FIELD_SPACING_HORIZONTAL)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    fileprivate func valueChange(_ checkBox: CheckBoxFieldView) {
        let isFrench = checkBox == self.frenchOption
        self.saveLanguageChoice(isFrench: isFrench)
        if Constantes.DEBUG {
            let lang = isFrench ? "FRANÇAIS" : "ANGLAIS"
            print("Changement de langue : " + lang + " ACTIVÉ")
        }
        self.onChange?()
    }

    fileprivate func saveLanguageChoice(isFrench: Bool) {
        self.englishOption.checked = !isFrench
        self.frenchOption.checked = isFrench

        let value = isFrench ? "fr_FR" : "en_EN"

        UserPrefs.shared.setPrefs(key: .appleLanguage, value: value)
    }
}
