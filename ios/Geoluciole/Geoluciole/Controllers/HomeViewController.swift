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

import UIKit

class HomeViewController: ParentViewController {

    fileprivate var showLevelView: ShowLevelView!
    fileprivate var lastTrophyView: LastTrophyView!
    fileprivate var collectDataSwitchView: CollectDataSwitchView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let dhDeb = UserPrefs.shared.string(forKey: .startDateEngagement)
        let dhFin = UserPrefs.shared.string(forKey: .endDateEngagement)
        if dhDeb == "" || dhFin == "" {
            let currentDate = Date()
            let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)
            UserPrefs.shared.setPrefs(key: .startDateEngagement, value: Tools.convertDate(currentDate))
            UserPrefs.shared.setPrefs(key: .endDateEngagement, value: Tools.convertDate(dateEnd!))
        }

        // LevelView
        self.showLevelView = ShowLevelView()
        self.showLevelView.onProgressBarFinish = {
            self.collectDataSwitchView.setSwitch(value: false)
        }
        self.showLevelView.translatesAutoresizingMaskIntoConstraints = false
        self.rootView.addSubview(self.showLevelView)

        // LastTrophyView
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        self.rootView.addSubview(wrap)
        self.lastTrophyView = LastTrophyView()
        self.lastTrophyView.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(self.lastTrophyView)

        // CollectDataSwitch
        self.collectDataSwitchView = CollectDataSwitchView()
        self.collectDataSwitchView.translatesAutoresizingMaskIntoConstraints = false
        self.rootView.addSubview(self.collectDataSwitchView)

        // Constraints ShowLevelView
        NSLayoutConstraint.activate([
            self.showLevelView.topAnchor.constraint(equalTo: self.titleBar.bottomAnchor, constant: Constantes.FIELD_SPACING_VERTICAL),
            self.showLevelView.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: Constantes.PAGE_PADDING),
            self.showLevelView.rightAnchor.constraint(equalTo: self.rootView.rightAnchor, constant: -Constantes.PAGE_PADDING)
        ])

        // Constraints LastTrophyView
        NSLayoutConstraint.activate([
            wrap.topAnchor.constraint(equalTo: self.showLevelView.bottomAnchor, constant: Constantes.FIELD_SPACING_VERTICAL),
            wrap.bottomAnchor.constraint(equalTo: self.collectDataSwitchView.topAnchor, constant: -Constantes.FIELD_SPACING_VERTICAL),
            wrap.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: Constantes.PAGE_PADDING),
            wrap.rightAnchor.constraint(equalTo: self.rootView.rightAnchor, constant: -Constantes.PAGE_PADDING),

            self.lastTrophyView.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            self.lastTrophyView.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            self.lastTrophyView.widthAnchor.constraint(equalTo: wrap.widthAnchor)
        ])

        // Constraints CollectDataSwitchView
        NSLayoutConstraint.activate([
            self.collectDataSwitchView.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: -Constantes.FIELD_SPACING_VERTICAL),
            self.collectDataSwitchView.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: Constantes.PAGE_PADDING),
            self.collectDataSwitchView.rightAnchor.constraint(equalTo: self.rootView.rightAnchor, constant: -Constantes.PAGE_PADDING)
        ])
    }

    func calcProgress() {
        let date = Date()
        let stringDate = Tools.convertDate(date)
        let currentDate = Tools.convertDateGMT01(stringDate)

        let dateDebut = Tools.convertDateGMT01(UserPrefs.shared.string(forKey: .startDateEngagement))
        let dateFin = Tools.convertDateGMT01(UserPrefs.shared.string(forKey: .endDateEngagement))

        let pct: Float = Float((100 * currentDate.timeIntervalSince(dateDebut) / (dateFin.timeIntervalSince(dateDebut))) / 100)
        if Constantes.DEBUG {
            print("ProgressBar : \(pct)")
        }
        self.showLevelView.progress = pct
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // On cache le switch si le consentement du GPS a été refusé
        self.collectDataSwitchView.isHidden = !UserPrefs.shared.bool(forKey: .rgpdConsent)

        let send = UserPrefs.shared.bool(forKey: .sendData)
        self.collectDataSwitchView.setSwitch(value: send)
        self.calcProgress()

        if let _ = UserPrefs.shared.object(forKey: .lastBadgeObtained) {
            self.lastTrophyView.setImage(name: UserPrefs.shared.string(forKey: .lastBadgeObtained))
        } else {
            self.lastTrophyView.setImage(name: "no-badge")
        }
        
        self.collectDataSwitchView.isUserInteractionEnabled = send
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            Tools.checkConsent(viewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

