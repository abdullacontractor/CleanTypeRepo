//
//  Catboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 9/24/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

/*
This is the demo keyboard. If you're implementing your own keyboard, simply follow the example here and then
set the name of your KeyboardViewController subclass in the Info.plist file.
*/

let kCatTypeEnabled = "kCatTypeEnabled"

class Catboard: KeyboardViewController {
    
    let takeDebugScreenshot: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        NSUserDefaults.standardUserDefaults().registerDefaults([kCatTypeEnabled: true])
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPressed(key: Key) {
        if let textDocumentProxy = self.textDocumentProxy as? UITextDocumentProxy {
            let keyOutput = key.outputForCase(self.shiftState.uppercase())
            
            if !NSUserDefaults.standardUserDefaults().boolForKey(kCatTypeEnabled) {
                textDocumentProxy.insertText(keyOutput)
                currentString += keyOutput
                self.changeInCurrentString()
                return
            }
            
            if key.type == .Character || key.type == .SpecialCharacter {
                let context = textDocumentProxy.documentContextBeforeInput
                if context != nil {
                    if context!.characters.count < 2 {
                        textDocumentProxy.insertText(keyOutput)
                        currentString += keyOutput
                        self.changeInCurrentString()
                        return
                    }
                    
                    var index = context!.endIndex
                    
                    index = index.predecessor()
                    if (context as String!)[index] != " " {
                        textDocumentProxy.insertText(keyOutput)
                        currentString += keyOutput
                        self.changeInCurrentString()
                        return
                    }
                    
                    index = index.predecessor()
                    if (context as String!)[index] == " " {
                        textDocumentProxy.insertText(keyOutput)
                        currentString += keyOutput
                        self.changeInCurrentString()
                        return
                    }

                    textDocumentProxy.insertText("\(randomCat())")
                    textDocumentProxy.insertText(" ")
                    textDocumentProxy.insertText(keyOutput)
                    currentString += keyOutput
                    self.changeInCurrentString()
                    return
                }
                else {
                    textDocumentProxy.insertText(keyOutput)
                    currentString += keyOutput
                    self.changeInCurrentString()
                    return
                }
            }
            else {
                textDocumentProxy.insertText(keyOutput)
                currentString += keyOutput
                self.changeInCurrentString()
                return
            }
        }
    }
    
    override func setupKeys() {
        super.setupKeys()
        
        if takeDebugScreenshot {
            if self.layout == nil {
                return
            }
            
            for page in keyboard.pages {
                for rowKeys in page.rows {
                    for key in rowKeys {
                        if let keyView = self.layout!.viewForKey(key) {
                            keyView.addTarget(self, action: "takeScreenshotDelay", forControlEvents: .TouchDown)
                        }
                    }
                }
            }
        }
    }
    
    override func createBanner() -> ExtraView? {
        let banner =  SearchResultBanner(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        banner.results = suggestions
        return banner
//        return nil
    }
    
    func takeScreenshotDelay() {
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("takeScreenshot"), userInfo: nil, repeats: false)
    }
    
    func takeScreenshot() {
        if !CGRectIsEmpty(self.view.bounds) {
            UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
            
            let oldViewColor = self.view.backgroundColor
            self.view.backgroundColor = UIColor(hue: (216/360.0), saturation: 0.05, brightness: 0.86, alpha: 1)
            
            var rect = self.view.bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
            var context = UIGraphicsGetCurrentContext()
            self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
            var capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let name = (self.interfaceOrientation.isPortrait ? "Screenshot-Portrait" : "Screenshot-Landscape")
            var imagePath = "/Users/archagon/Documents/Programming/OSX/RussianPhoneticKeyboard/External/tasty-imitation-keyboard/\(name).png"
            UIImagePNGRepresentation(capturedImage)!.writeToFile(imagePath, atomically: true)
            
            self.view.backgroundColor = oldViewColor
        }
    }
}

func randomCat() -> String {
    let cats = "🐱😺😸😹😽😻😿😾😼🙀"
    
    let numCats = cats.characters.count
    let randomCat = arc4random() % UInt32(numCats)
    
    let index = cats.startIndex.advancedBy(Int(randomCat))
    let character = cats[index]
    
    return String(character)
}
