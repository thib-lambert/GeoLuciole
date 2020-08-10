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
import CoreLocation

class Tools {

    /// Permet de trouver le chemin pour le fichier passé en paramètre
    ///
    /// - Parameters:
    ///     - filename: Le nom du fichier à trouver
    ///     - ext: L'extension du fichier à trouver
    ///
    /// - Returns: Le chemin du fichier
    static func getPath(_ fileName: String, ext: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let file = fileName + "." + ext
        let fileURL = documentsURL.appendingPathComponent(file)

        return fileURL.path
    }

    /// Permet de copier un fichier du Bundle de l'application vers le dossier Documents de l'application
    ///
    /// - Parameters:
    ///     - filename: Le nom du fichier à copier
    ///     - ext: L'extension du fichier à copier
    static func copyFile(_ fileName: String, ext: String) {
        let dbPath = Tools.getPath(fileName, ext: ext)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {

            let documentsURL = Bundle.main.resourceURL!
            let fromPath = documentsURL.appendingPathComponent(fileName)

            var error: NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let e as NSError {
                error = e
            }

            if let error = error {
                if Constantes.DEBUG {
                    print("Error Occured : \(error.localizedDescription)")
                }
            } else {
                if Constantes.DEBUG {
                    print("Successfully Copy : \(fileName) copy successfully")
                }
            }
        }
    }

    static func joinWithCharacter(_ separator: String, _ values: [String]) -> String {
        return Tools.joinWithCharacter(nil, separator, values)
    }

    static func joinWithCharacter(_ beforeWord: String?, _ separator: String, _ values: [String]) -> String {
        var s = ""
        let endIndex = values.count - 1

        for i in 0...endIndex {

            if let before = beforeWord {
                s += before
            }

            s += values[i]


            if i != endIndex {
                s += ", "
            }
        }

        return s
    }

    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }

    static var appName: String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }

    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    /// Retourne l'identifiant de l'utilisateur
    static var userIdentifier: Int {
        var identifier: Int

        // On vérifie si on a un identifiant de généré
        let id = UserPrefs.shared.int(forKey: .identifier)

        // Si oui, on le récupère
        if id != 0 {
            identifier = id

            // Sinon, on en génère un
        } else {
            if Constantes.DEBUG {
                print("Aucun identifiant existant ! Génération en cours ...")
            }


            // pour ne pas identifier directement le terminal, on génère un identifier à partir de l'uuid
            let uuid = UIDevice.current.identifierForVendor?.uuidString

            // on récupère le hashCode de notre uuid pour masquer l'identité du terminal
            identifier = Int(abs(uuid!.hashCode()))

            // et on sauvegarde le paramètre
            UserPrefs.shared.setPrefs(key: .identifier, value: identifier)
        }

        return identifier
    }

    static func convertDate(_ date: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        return df.date(from: date)!
    }

    static func convertDateGMT01(_ date: String) -> Date {
        let df = DateFormatter()
        df.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        var regionCode = Locale.current.regionCode

        if regionCode == nil {
            regionCode = "fr"
        }
        df.locale = Locale(identifier: regionCode!)
        df.dateFormat = "dd/MM/yyyy HH:mm"
        return df.date(from: date)!
    }

    static func convertDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        return df.string(from: date)
    }

    // Retourne une date au format date du serveur pour faciliter la lecture
    static func convertDateToServerDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return df.string(from: date)
    }

    static var statisticalDistance: Double {
        guard let dist_parcourue = UserPrefs.shared.object(forKey: .distanceTraveled) as? Double else {
            return 0
        }

        if Constantes.DEBUG {
            print("Distance parcourue :\(dist_parcourue)")
        }

        return Tools.roundDist(dist_parcourue, precision: 2)
    }

    static func roundDist(_ value: Double, precision: Int) -> Double {
        let divisor = pow(10.0, Double(precision))

        return round(value * divisor) / divisor
    }

    static var preferredLocale: Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }

    static func getTranslate(key: String) -> String {
        return NSLocalizedString(key, comment: key)
    }

    /// Vérifie que les consentements ont été acceptés et lance le processus de consentement si non effectué
    static func checkConsent(viewController: ParentViewController) {
        let consentGPS = UserPrefs.shared.object(forKey: .rgpdConsent)

        // On affiche le consentement de RGPD pour le GPS
        if consentGPS == nil {
            let rgpdController = GPSConsentRGPDViewController()
            rgpdController.modalPresentationStyle = .fullScreen
            viewController.present(rgpdController, animated: true)
        } else {
            if consentGPS as! Bool {
                // On affiche ensuite le constement pour le formulaire
                if UserPrefs.shared.object(forKey: .consentForm) == nil {
                    let formRgpdController = FormConsentRGPDViewController()
                    formRgpdController.modalPresentationStyle = .fullScreen
                    viewController.present(formRgpdController, animated: true)
                } else {
                    // On affiche le formulaire
                    if UserPrefs.shared.object(forKey: .completedForm) == nil {
                        let formulaire = FormPageViewController()
                        formulaire.modalPresentationStyle = .fullScreen
                        viewController.present(formulaire, animated: true)
                    }
                }
            }
        }
    }

}
