/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The app's main view controller.
 */

import Cocoa
import SceneKit

class GameViewControllerMacOS: NSViewController {
    var gameView: GameViewMacOS {
        guard let gameView = view as? GameViewMacOS else {
            fatalError("Expected \(GameViewMacOS.self) from Main.storyboard.")
        }
        return gameView
    }

    var gameController: GameController?

    override func viewDidLoad() {
        super.viewDidLoad()

        gameController = GameController(scnView: gameView)

        // Configure the view
        gameView.backgroundColor = NSColor.black

        // Link view and controller
        gameView.viewController = self
    }

    func keyDown(_: NSView, event theEvent: NSEvent) -> Bool {
        var characterDirection = gameController!.characterDirection
        var cameraDirection = gameController!.cameraDirection

        var updateCamera = false
        var updateCharacter = false

        switch theEvent.keyCode {
        case 126:
            // Up
            if !theEvent.isARepeat {
                characterDirection.y = -1
                updateCharacter = true
            }
        case 125:
            // Down
            if !theEvent.isARepeat {
                characterDirection.y = 1
                updateCharacter = true
            }
        case 123:
            // Left
            if !theEvent.isARepeat {
                characterDirection.x = -1
                updateCharacter = true
            }
        case 124:
            // Right
            if !theEvent.isARepeat {
                characterDirection.x = 1
                updateCharacter = true
            }
        case 13:
            // Camera Up
            if !theEvent.isARepeat {
                cameraDirection.y = -1
                updateCamera = true
            }
        case 1:
            // Camera Down
            if !theEvent.isARepeat {
                cameraDirection.y = 1
                updateCamera = true
            }
        case 0:
            // Camera Left
            if !theEvent.isARepeat {
                cameraDirection.x = -1
                updateCamera = true
            }
        case 2:
            // Camera Right
            if !theEvent.isARepeat {
                cameraDirection.x = 1
                updateCamera = true
            }
        case 49:
            // Space
            if !theEvent.isARepeat {
                gameController!.controllerJump(true)
            }
            return true
        case 8:
            // c
            if !theEvent.isARepeat {
                gameController!.controllerAttack()
            }
            return true
        default:
            return false
        }

        if updateCharacter {
            gameController?.characterDirection = characterDirection.allZero() ? characterDirection : simd_normalize(characterDirection)
        }

        if updateCamera {
            gameController?.cameraDirection = cameraDirection.allZero() ? cameraDirection : simd_normalize(cameraDirection)
        }

        return true
    }

    func keyUp(_: NSView, event theEvent: NSEvent) -> Bool {
        var characterDirection = gameController!.characterDirection
        var cameraDirection = gameController!.cameraDirection

        var updateCamera = false
        var updateCharacter = false

        switch Keycode(rawValue: theEvent.keyCode) {
        case .delete:
            if !theEvent.isARepeat {
                gameController!.resetPlayerPosition()
            }
            return true
        case .upArrow:
            // Up
            if !theEvent.isARepeat, characterDirection.y < 0 {
                characterDirection.y = 0
                updateCharacter = true
            }
        case .downArrow:
            // Down
            if !theEvent.isARepeat, characterDirection.y > 0 {
                characterDirection.y = 0
                updateCharacter = true
            }
        case .leftArrow:
            // Left
            if !theEvent.isARepeat, characterDirection.x < 0 {
                characterDirection.x = 0
                updateCharacter = true
            }
        case .rightArrow:
            // Right
            if !theEvent.isARepeat, characterDirection.x > 0 {
                characterDirection.x = 0
                updateCharacter = true
            }
        case .w:
            // Camera Up
            if !theEvent.isARepeat, cameraDirection.y < 0 {
                cameraDirection.y = 0
                updateCamera = true
            }
        case .s:
            // Camera Down
            if !theEvent.isARepeat, cameraDirection.y > 0 {
                cameraDirection.y = 0
                updateCamera = true
            }
        case .a:
            // Camera Left
            if !theEvent.isARepeat, cameraDirection.x < 0 {
                cameraDirection.x = 0
                updateCamera = true
            }
        case .d:
            // Camera Right
            if !theEvent.isARepeat, cameraDirection.x > 0 {
                cameraDirection.x = 0
                updateCamera = true
            }

        case .space:
            // Space
            if !theEvent.isARepeat {
                gameController!.controllerJump(false)
            }
            return true
        default:
            break
        }

        if updateCharacter {
            gameController?.characterDirection = characterDirection.allZero() ? characterDirection : simd_normalize(characterDirection)
            return true
        }

        if updateCamera {
            gameController?.cameraDirection = cameraDirection.allZero() ? cameraDirection : simd_normalize(cameraDirection)
            return true
        }

        return false
    }
}

class GameViewMacOS: SCNView {
    weak var viewController: GameViewControllerMacOS?

    // MARK: - EventHandler

    override func keyDown(with theEvent: NSEvent) {
        if viewController?.keyDown(self, event: theEvent) == false {
            super.keyDown(with: theEvent)
        }
    }

    override func keyUp(with theEvent: NSEvent) {
        if viewController?.keyUp(self, event: theEvent) == false {
            super.keyUp(with: theEvent)
        }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        (overlaySKScene as? Overlay)?.layout2DOverlay()
    }

    override func viewDidMoveToWindow() {
        // disable retina
        layer?.contentsScale = 1.0
    }
}

enum Keycode: UInt16 {
    typealias RawValue = UInt16

    // Layout-independent Keys
    // eg.These key codes are always the same key on all layouts.
    case returnKey = 0x24
    case tab = 0x30
    case space = 0x31
    case delete = 0x33
    case escape = 0x35
    case command = 0x37
    case shift = 0x38
    case capsLock = 0x39
    case option = 0x3A
    case control = 0x3B
    case rightShift = 0x3C
    case rightOption = 0x3D
    case rightControl = 0x3E
    case leftArrow = 0x7B
    case rightArrow = 0x7C
    case downArrow = 0x7D
    case upArrow = 0x7E
    case volumeUp = 0x48
    case volumeDown = 0x49
    case mute = 0x4A
    case help = 0x72
    case home = 0x73
    case pageUp = 0x74
    case forwardDelete = 0x75
    case end = 0x77
    case pageDown = 0x79
    case function = 0x3F
    case f1 = 0x7A
    case f2 = 0x78
    case f4 = 0x76
    case f5 = 0x60
    case f6 = 0x61
    case f7 = 0x62
    case f3 = 0x63
    case f8 = 0x64
    case f9 = 0x65
    case f10 = 0x6D
    case f11 = 0x67
    case f12 = 0x6F
    case f13 = 0x69
    case f14 = 0x6B
    case f15 = 0x71
    case f16 = 0x6A
    case f17 = 0x40
    case f18 = 0x4F
    case f19 = 0x50
    case f20 = 0x5A

    // US-ANSI Keyboard Positions
    // eg. These key codes are for the physical key (in any keyboard layout)
    // at the location of the named key in the US-ANSI layout.
    case a = 0x00
    case b = 0x0B
    case c = 0x08
    case d = 0x02
    case e = 0x0E
    case f = 0x03
    case g = 0x05
    case h = 0x04
    case i = 0x22
    case j = 0x26
    case k = 0x28
    case l = 0x25
    case m = 0x2E
    case n = 0x2D
    case o = 0x1F
    case p = 0x23
    case q = 0x0C
    case r = 0x0F
    case s = 0x01
    case t = 0x11
    case u = 0x20
    case v = 0x09
    case w = 0x0D
    case x = 0x07
    case y = 0x10
    case z = 0x06

    case zero = 0x1D
    case one = 0x12
    case two = 0x13
    case three = 0x14
    case four = 0x15
    case five = 0x17
    case six = 0x16
    case seven = 0x1A
    case eight = 0x1C
    case nine = 0x19

    case equals = 0x18
    case minus = 0x1B
    case semicolon = 0x29
    case apostrophe = 0x27
    case comma = 0x2B
    case period = 0x2F
    case forwardSlash = 0x2C
    case backslash = 0x2A
    case grave = 0x32
    case leftBracket = 0x21
    case rightBracket = 0x1E

    case keypadDecimal = 0x41
    case keypadMultiply = 0x43
    case keypadPlus = 0x45
    case keypadClear = 0x47
    case keypadDivide = 0x4B
    case keypadEnter = 0x4C
    case keypadMinus = 0x4E
    case keypadEquals = 0x51
    case keypad0 = 0x52
    case keypad1 = 0x53
    case keypad2 = 0x54
    case keypad3 = 0x55
    case keypad4 = 0x56
    case keypad5 = 0x57
    case keypad6 = 0x58
    case keypad7 = 0x59
    case keypad8 = 0x5B
    case keypad9 = 0x5C
}
