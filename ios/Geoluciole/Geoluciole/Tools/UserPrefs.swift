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

class UserPrefs {

    enum UPKeys: String {
        case durationOfEngagement = "duree_engagement"
        case engagementType = "type_engagement"
        case sendData = "send_data"
        case lastPosition = "last_point"
        case distanceTraveled = "distance"
        case identifier = "identifier"
        case rgpdConsent = "rgpd_consent"
        case consentForm = "formulaire_consent"
        case startDateEngagement = "date_start_engagement"
        case endDateEngagement = "date_end_engagement"
        case appleLanguage = "AppleLanguages"
        case lastBadgeObtained = "last_badge"
        case completedForm = "formulaire_accepte"
        case dataGPSConsent = "data_gps_consent"
        case dataFormConsent = "data_form_consent"
        case startDayOfStay = "date_debut_sejour"
        case endDayOfStay = "date_fin_sejour"
        case consentAsk = "consent_ask"
    }

    public static var shared = UserPrefs()
    fileprivate var userPrefs = UserDefaults.standard

    fileprivate init() {
        //initialisation par defaut des dates de séjour pour le cas de refus des consentement GPS

        if self.userPrefs.object(forKey: UPKeys.startDayOfStay.rawValue) == nil {
            self.setPrefs(key: .startDayOfStay, value: Tools.convertDate(Date()))
        }

        if self.userPrefs.object(forKey: UPKeys.endDayOfStay.rawValue) == nil {
            self.setPrefs(key: .endDayOfStay, value: Tools.convertDate(Date()))
        }

        // si la durée d'engagement est renseigné
        if self.userPrefs.object(forKey: UPKeys.durationOfEngagement.rawValue) == nil {
            self.setPrefs(key: .durationOfEngagement, value: 1)
        }

        // si le type d'engagement est renseigné 0:heure 1:jour
        if self.userPrefs.object(forKey: UPKeys.engagementType.rawValue) == nil {
            self.setPrefs(key: .engagementType, value: 0)
        }

        // Par défaut, on active pas la collecte de données
        if self.userPrefs.object(forKey: UPKeys.sendData.rawValue) == nil {
            self.setPrefs(key: .sendData, value: false)
        }

        // Si la langue n'est pas définit, on prend la langue du système par défaut
        if self.userPrefs.object(forKey: UPKeys.appleLanguage.rawValue) == nil {
            // on récupère la langue du système
            let languageCode = Locale.current.regionCode?.lowercased()

            var language = ""

            if languageCode != nil {
                // Si le français est défini, on le prend
                if languageCode == "fr" {
                    language = Tools.getTranslate(key: "french_language")
                    // Sinon on met anglais par défaut
                } else {
                    language = Tools.getTranslate(key: "english_language")
                }
            }
            self.setPrefs(key: .appleLanguage, value: language)
        }

        // indique si l'on a affiché le consentement GPS au moins une fois au démarrage de l'application
        if self.userPrefs.object(forKey: UPKeys.consentAsk.rawValue) == nil {
            self.setPrefs(key: .consentAsk, value: false)
        }
    }

    func setPrefs(key: UPKeys, value: Any) {
        self.userPrefs.set(value, forKey: key.rawValue)
        self.userPrefs.synchronize()
    }

    func removePrefs(key: UPKeys) {
        self.userPrefs.removeObject(forKey: key.rawValue)
        self.userPrefs.synchronize()
    }

    func bool(forKey key: UPKeys, defaultValue: Bool = false) -> Bool {
        if self.userPrefs.object(forKey: key.rawValue) != nil {
            return self.userPrefs.bool(forKey: key.rawValue)
        }
        return defaultValue
    }

    func string(forKey key: UPKeys, defaultValue: String = "") -> String {
        if self.userPrefs.object(forKey: key.rawValue) != nil {
            return self.userPrefs.string(forKey: key.rawValue)!
        }
        return defaultValue
    }

    func int(forKey key: UPKeys, defaultValue: Int = 0) -> Int {
        if self.userPrefs.object(forKey: key.rawValue) != nil {
            return self.userPrefs.integer(forKey: key.rawValue)
        }
        return defaultValue
    }

    func object(forKey key: UPKeys) -> Any? {
        return self.userPrefs.object(forKey: key.rawValue)
    }

    func double(forKey key: UPKeys, defaultValue: Double = 0) -> Double {
        if self.userPrefs.object(forKey: key.rawValue) != nil {
            return self.userPrefs.double(forKey: key.rawValue)
        }
        return defaultValue
    }
}
