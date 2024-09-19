#Requires AutoHotkey v2+
#Include <Includes\ObjectTypeExtensions>

class Clip {
    static defaultEndChar := ''
    static defaultIsClipReverted := true
    static defaultUntilRevert := 500

    ; static __New(input?, endChar := '', isClipReverted := true, untilRevert := 500) {
    ;     this.Send(input?, endChar, isClipReverted, untilRevert)
    ; }

    /**
     * @param {String|Array|Map|Object|Class} input The content to send
     * @param {String} endChar The ending character(s) to append
     * @param {Boolean} isClipReverted Whether to revert the clipboard
     * @param {Integer} untilRevert Time in ms before reverting the clipboard
     * @returns {String} The sent content
     */
    static Send(input?, endChar := '', isClipReverted := true, untilRevert := 500) {
        prevClip := '', content := ''
        SendMode('Event')

        if (!IsSet(input)) {
            input := this
        }

        content := this.ConvertToString(input)

        isClipReverted ? (prevClip := ClipboardAll()) : 0
        this.EmptyClipboard()

        A_Clipboard := content . endChar

        Loop {
            Sleep(10)
        } until !this.GetOpenClipboardWindow() || A_Index = 1000

        SetTimer(() => Send('{sc2A Down}{sc152}{sc2A Up}'), -500)

        Sleep(300)

        isClipReverted ? SetTimer((*) => A_Clipboard := prevClip, -untilRevert) : 0

        return content
    }

    /**
     * @param {Any} input The input to convert to string
     * @returns {String} The converted string
     */
    static ConvertToString(input) {
        switch Type(input) {
            case 'String':
                return input
            case 'Array':
                return input.Join('')
            case 'Map':
                return input.ToString()
            case 'Object':
                return jsongo.Stringify(input)
			case 'Initializable':
				return jsongo.Stringify(input)
				GetClipboardData()
            ; default:
            ;     if (input is Initializable) {
            ;         return jsongo.Stringify(input)
            ;     } else {
            ;         throw TypeError('Unsupported input type: ' . Type(input))
            ;     }
        }
    }

    static EmptyClipboard() 		=> (*) => DllCall('User32.dll\EmptyClipboard', 'Int')

    static GetOpenClipboardWindow() => (*) => DllCall('GetOpenClipboardWindow', 'Ptr')

}
