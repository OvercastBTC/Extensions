#Requires AutoHotkey v2.0+
#Include <Includes\ObjectTypeExtensions>



; Modify Object prototype
Object.Prototype.DefineProp("ToString", {Call: (this) => Object2.ToString(this)})
Object.Prototype.DefineProp("Has", {Call: (this, key) => this.HasOwnProp(key)})
Object.Prototype.DefineProp("Get", {Call: (this, key, default := "") => this.Has(key) ? this.%key% : default})
Object.Prototype.DefineProp("ToArray", {Call: (this) => Object2.ToArray(this)})
Object.Prototype.DefineProp("ToMap", {Call: (this) => Object2.ToMap(this)})

class Object2 extends Object {

	; Define a Length property that counts the number of properties
	Length {
		get => ObjOwnPropCount(this)
	}

	static ToString(toPrint) {
		toPrint_string := ''
		switch Type(toPrint) {
			case "Map", "Array", "Object":
				toPrint_string := cJSON.Stringify(toPrint)
			default:
				try toPrint_string := String(toPrint)
		}
		; try FileAppend(toPrint_string "`n", "*", "utf-8")
		; try Infos(toPrint_string)
		return toPrint_string
	}

	static ToArray(obj?) {
        return this._ObjectToArray(IsSet(obj) ? obj : this)
    }

    static _ObjectToArray(obj) {
        arr := []
        for key, value in obj.OwnProps() {
            if IsObject(value) {
                arr.Push({key: key, value: this._ObjectToArray(value)})
            } else {
                arr.Push({key: key, value: value})
            }
        }
        return arr
    }

    static ToMap(obj?) {
        return this._ObjectToMap(IsSet(obj) ? obj : this)
    }

    static _ObjectToMap(obj) {
        map := Map()
        for key, value in obj.OwnProps() {
            if IsObject(value) {
                map[key] := this._ObjectToMap(value)
            } else {
                map[key] := value
            }
        }
        return map
    }
    
	/**
     * @returns {Integer} The number of own properties in the object
     */
    static Length => (*) => ObjOwnPropCount(this)

    /**
     * @param {Integer} start Index to start from (default: 1)
     * @param {Integer} end Index to end at (default: 0, meaning last element)
     * @param {Integer} step Increment value (default: 1)
     * @returns {Object} Modified object
     */
    Slice(start := 1, end := 0, step := 1) {
        len := this.Length, i := (start < 1) ? len + start : start
        j := Min((end < 1) ? len + end : end, len)
        r := {}

        if (len = 0) {
            return {}
        }

        i := Max(i, 1)
        if (step = 0) {
            throw ValueError('Slice: step cannot be 0', -1)
        }

        if (step < 0) {
            while (i >= j) {
                r.Push(this[i])
                i += step
            }
        } else {
            while (i <= j) {
                r.Push(this[i])
                i += step
            }
        }

        return this := r
    }

    /**
     * @param {Integer} a First index to swap
     * @param {Integer} b Second index to swap
     * @returns {Object} Modified object
     */
    Swap(a, b) {
        temp := this[b]
        this[b] := this[a]
        this[a] := temp
        return this
    }

    /**
     * @param {Function} func Mapping function
     * @param {Object*} objects Additional objects for mapping
     * @returns {Object} Modified object
     */
    Map(func, objects*) {
        if (!HasMethod(func)) {
            throw ValueError('Map: func must be a function', -1)
        }

        for i, v in this {
            bf := func.Bind(v?)
            for _, obj in objects {
                bf := bf.Bind(obj.Has(i) ? obj[i] : unset)
            }
            try {
                this[i] := bf()
            }
        }
        return this
    }

    /**
     * @param {Function} func Callback function
     * @returns {Object} Original object
     */
    ForEach(func) {
        if (!HasMethod(func)) {
            throw ValueError('ForEach: func must be a function', -1)
        }

        for i, v in this {
            func(v, i, this)
        }
        return this
    }

    /**
     * @param {Function} func Filter function
     * @returns {Object} Filtered object
     */
    Filter(func) {
        if (!HasMethod(func)) {
            throw ValueError('Filter: func must be a function', -1)
        }

        r := {}
        for v in this {
            if (func(v)) {
                r.Push(v)
            }
        }
        return this := r
    }

    /**
     * @param {Function} func Reducer function
     * @param {Any} initialValue Starting value (optional)
     * @returns {Any} Reduced value
     */
    Reduce(func, initialValue?) {
        if (!HasMethod(func)) {
            throw ValueError('Reduce: func must be a function', -1)
        }

        len := Object2.length + 1
        if (len = 1) {
            return IsSet(initialValue) ? initialValue : ''
        }

        out := IsSet(initialValue) ? (initialValue, i := 0) : (this[1], i := 1)

        while (++i < len) {
            out := func(out, this[i])
        }
        return out
    }

    /**
     * @param {Any} value Value to search for
     * @param {Integer} start Starting index (default: 1)
     * @returns {Integer} Index of the value, or 0 if not found
     */
    IndexOf(value, start := 1) {
        if (!IsInteger(start)) {
            throw ValueError('IndexOf: start value must be an integer')
        }

        for i, v in this {
            if (i < start) {
                continue
            }
            if (v == value) {
                return i
            }
        }
        return 0
    }

    /**
     * @param {Function} func Condition function
     * @param {Any&} match Reference to store the matched value
     * @param {Integer} start Starting index (default: 1)
     * @returns {Integer} Index of the matching value, or 0 if not found
     */
    Find(func, &match?, start := 1) {
        if (!HasMethod(func)) {
            throw ValueError('Find: func must be a function', -1)
        }

        for i, v in this {
            if (i < start) {
                continue
            }
            if (func(v)) {
                match := v
                return i
            }
        }
        return 0
    }

    /**
     * @returns {Object} Reversed object
     */
    Reverse() {
        len := Object2.length + 1
        max := (len // 2)
        i := 0
        while (++i <= max) {
            this.Swap(i, len - i)
        }
        return this
    }

    /**
     * @param {Any} value Value to count (can be a function)
     * @returns {Integer} Number of occurrences
     */
    Count(value) {
        count := 0
        if (HasMethod(value)) {
            for _, v in this {
                if (value(v?)) {
                    count++
                }
            }
        } else {
            for _, v in this {
                if (v == value) {
                    count++
                }
            }
        }
        return count
    }

    /**
     * @param {String|Function} optionsOrCallback Sorting options or callback function
     * @param {String} key Key to sort by (for objects)
     * @returns {Object} Sorted object
     */
    Sort(optionsOrCallback := 'N', key?) {
        ; ... (existing implementation)
    }

    /**
     * @returns {Object} Shuffled object
     */
    Shuffle() {
        len := Object2.length
        Loop len - 1 {
            this.Swap(A_Index, Random(A_Index, len))
        }
        return this
    }

    /**
     * @returns {Object} Object with unique values
     */
    Unique() {
        munique := Map()
        for v in this {
            munique[v] := 1
        }
        return munique
    }

	; Print(toPrint) {
	; 	toPrint_string := ""
	; 	switch Type(toPrint) {
	; 		case "Map", "Array", "Object":
	; 			toPrint_string := Json.stringify(toPrint)
	; 			; str := cJson.fnCastString(toPrint_string)
	; 		; default:
	; 		; 	try toPrint_string := String(toPrint)
	; 			this := toPrint_string
	; 	}

	; 	; try FileAppend(toPrint_string "`n", "*", "utf-8")
	; 	return this
	; 	; return toPrint_string
	; }

    /**
     * @param {String} delim Delimiter (default: newline)
     * @returns {String} Joined string
     */
    Join(delim := '`n') {
		; Print(this)
        result := ''
        for v in this {
            result .= v . delim
        }
        return (len := StrLen(delim)) ? SubStr(result, 1, -len) : result
    }

    /**
     * @returns {Object} Flattened object
     */
    Flat() {
        r := {}
        for v in this {
            if (Type(v) = 'Object') {
                r.Extend(v.Flat())
            } else {
                r.Push(v)
            }
        }
        return this := r
    }

    /**
     * @param {Object*} enums Enumerables to extend with
     * @returns {Object} Extended object
     */
    Extend(enums*) {
        for enum in enums {
            if (!Object.DefineProp(enum, '__Enum')) {
                throw ValueError('Extend: Obj must be an iterable')
            }
            for _, v in enum {
                this.Set(v)
            }
        }
        return this
    }

    /**
     * @param {Object} obj Object to convert (optional)
     * @param {String|Integer} depth Maximum depth to recurse (default: 'all')
     * @param {String} indentLevel Current indentation level (default: '')
     * @returns {String} String representation of the object
     */
    _ToString(obj := unset, depth := 'all', indentLevel := '') {
        if (!IsSet(obj)) {
            obj := this
        }
        list := ''
        if (Type(obj) = 'Object') {
            obj := obj.OwnProps()
        }
        for k, v in obj {
            list .= (indentLevel = '' ? '' : indentLevel . '[' . k . ']')
            if (IsObject(v) && (depth = 'all' || depth > 1)) {
                list .= '`n' . this._ToString(v, (depth = 'all' ? 'all' : depth - 1), indentLevel . '    ')
            } else {
                list .= v
            }
            list .= '`n'
        }
        return Trim(list)
    }

    /**
     * @param {Any} valueToFind Value to search for
     * @returns {Any|False} Found value or False if not found
     */
    ; HasValue(valueToFind) {
    ;     for _, propertyValue in this {
    ;         if (propertyValue = valueToFind) {
    ;             return propertyValue
    ;         }
    ;     }
    ;     return false
    ; }

    /**
     * @param {Any} v Value to set
     */
    Set(v := unset) {
        if (!IsSet(v)) {
            v := this
        }
        this.DefineProp('value', {Value: v})
    }

    /**
     * @param {Any} v Value to set safely
     */
    SafeSet(v) {
        if (!this.HasOwnProp(v)) {
            this.Set(v)
        }
    }

    /**
     * @param {Object} obj Object containing values to set
     */
    SafeSetObj(obj) {
        for _, value in obj {
            this.SafeSet(value)
        }
    }

    /**
     * @returns {Object} Reversed object
     */
    aReverse() {
        reversedObject := {}
        for each, value in this {
            reversedObject.Set(value, each)
        }
        return reversedObject
    }

    /**
     * @param {Any*} options Options to choose from
     * @returns {Any} Chosen option
     */
    Choose(options*) {
        if (options.Length = 1) {
            return options[1]
        }

        infoObjs := [Infos('')]
        for index, option in options {
            if (infoObjs.Length >= Infos.maximumInfos) {
                break
            }
            infoObjs.Push(Infos(option))
        }
        
        loop {
            for index, infoObj in infoObjs {
                if (WinExist(infoObj.hwnd)) {
                    continue
                }
                text := infoObj.text
                break 2
            }
        }
        
        for _, infoObj in infoObjs {
            infoObj.Destroy()
        }
        return text
    }

    /**
     * @param {String} valueName Name of the value to choose
     * @returns {Any} Chosen value
     */
    _ChooseObject(valueName) {
        if (Object2.Prototype.Base.Has(valueName)) {
            return this[valueName]
        }
        options := []
        for _, value in this {
            if (InStr(value, valueName)) {
                options.Push(value)
            }
        }
        chosen := this.Choose(options*)
        return chosen ? this[chosen] : 0
    }

    /**
     * @param {String} delimiter Delimiter for string conversion
     * @returns {String} String representation of the object
     */
    ObjectToStr(delimiter := '') {
        str := ''
        for key, value in this {
            if (key = Object2.Prototype.Base.Length) {
                str .= value
                break
            }
            str .= value . delimiter
        }
        return str
    }

    /**
     * @param {Integer} indexes Number of indexes to generate
     * @param {Integer} variation Variation factor (default: 7)
     * @returns {Object} Generated random object
     */
    GenerateRandomObject(indexes, variation := 7) {
        Loop indexes {
            this.Set(Random(1, indexes * variation))
        }
        return this
    }

    /**
     * @param {Integer} indexes Number of indexes to generate
     * @returns {Object} Generated rising object
     */
    GenerateRisingObject(indexes) {
        i := 1
        Loop indexes {
            this.Set(i++)
        }
        return this
    }

    /**
     * @param {Integer} indexes Number of indexes to generate
     * @returns {Object} Generated shuffled object
     */
    GenerateShuffledObject(indexes) {
        return this.GenerateRisingObject(indexes).FisherYatesShuffle()
    }

    /**
     * @returns {Object} Shuffled object using Fisher-Yates algorithm
     */
    FisherYatesShuffle() {
        shufflerIndex := 0
        while (--shufflerIndex > -Object2.length) {
            randomIndex := Random(-Object2.length, shufflerIndex)
            if (this[randomIndex] != this[shufflerIndex]) {
                this.Swap(shufflerIndex, randomIndex)
            }
        }
        return this
    }

    /**
     * @returns {Object} Sorted object using Bubble Sort algorithm
     */
    BubbleSort() {
        len := Object2.length
        Loop len - 1 {
            swapped := false
            Loop len - A_Index {
                if (this[A_Index] > this[A_Index + 1]) {
                    this.Swap(A_Index, A_Index + 1)
                    swapped := true
                }
            }
            if (!swapped) {
                break
            }
        }
        return this
    }

    /**
     * @returns {Object} Sorted object using Selection Sort algorithm
     */
    SelectionSort() {
        len := Object2.length
        Loop len - 1 {
            minIndex := A_Index
            innerIndex := A_Index + 1
            Loop len - A_Index {
                if (this[innerIndex] < this[minIndex]) {
                    minIndex := innerIndex
                }
                innerIndex++
            }
            if (minIndex != A_Index) {
                this.Swap(A_Index, minIndex)
            }
        }
        return this
    }

    /**
     * @returns {Object} Sorted object using Insertion Sort algorithm
     */
    InsertionSort() {
        len := Object2.length
        Loop len - 1 {
            key := this[A_Index + 1]
            j := A_Index
            while (j > 0 && this[j] > key) {
                this[j + 1] := this[j]
                j--
            }
            this[j + 1] := key
        }
        return this
    }

    /**
     * @returns {Object} Sorted object using Merge Sort algorithm
     */
    MergeSort() {
        if (Object2.Length <= 1) {
            return this
        }

        mid := Object2.Length // 2
        left := this.Slice(1, mid)*
        right := this.Slice(mid + 1)*

        left := left.MergeSort()
        right := right.MergeSort()

        return this := this.Merge(left, right)
    }

    /**
     * @param {Object} left Left sub-array
     * @param {Object} right Right sub-array
     * @returns {Object} Merged and sorted object
     */
    Merge(left, right) {
        result := {}
        leftIndex := rightIndex := 1

        while (leftIndex <= left.Length && rightIndex <= right.Length) {
            if (left[leftIndex] <= right[rightIndex]) {
                result.Push(left[leftIndex])
                leftIndex++
            } else {
                result.Push(right[rightIndex])
                rightIndex++
            }
        }

        while (leftIndex <= left.Length) {
            result.Push(left[leftIndex])
            leftIndex++
        }

        while (rightIndex <= right.Length) {
            result.Push(right[rightIndex])
            rightIndex++
        }

        return result
    }

    /**
     * @param {Integer} threadDelay Delay between elements (default: 30)
     * @returns {Object} Sorted object using Sleep Sort algorithm (not practical, for demonstration only)
     */
    SleepSort(threadDelay := 30) {
        sortedObject := {}
        
        SetIndex(value, index) {
            SetTimer(() => sortedObject[index] := value, -value * threadDelay)
        }

        for index, value in this {
            SetIndex(value, index)
        }

        while (sortedObject.Length < Object2.length) {
            Sleep(10)
        }

        return this := sortedObject
    }

    /**
     * @param {Any} value Value to search for
     * @param {Integer} start Starting index (default: 1)
     * @returns {Integer} Index of the value, or 0 if not found
     */
    IndexOfValue(value, start := 1) {
        if (!IsInteger(start)) {
            throw ValueError('IndexOfValue: start value must be an integer')
        }

        for i, v in this {
            if (i < start) {
                continue
            }
            if (v == value) {
                return i
            }
        }
        return 0
    }

    /**
     * @param {String|Integer} depth Maximum depth to recurse (default: 'all')
     * @param {String} indentLevel Current indentation level (default: '')
     * @returns {String} String representation of the object
     */
    _ObjectToString(depth := 'all', indentLevel := '') {
        list := ''
        obj := this.OwnProps()
        for k, v in obj {
            list .= (indentLevel = '' ? '' : indentLevel . '[' . k . ']')
            if (IsObject(v) && (depth = 'all' || depth > 1)) {
                list .= '`n' . this._ObjectToString((depth = 'all' ? 'all' : depth - 1), indentLevel . '    ')
            } else {
                list .= v
            }
            list .= '`n'
        }
        return Trim(list)
    }

    /**
     * @returns {String} String representation of the object
     */
    ToString() => this._ObjectToString()

    /**
     * @param {Any} valueToFind Value to search for
     * @returns {Any|False} Found value or False if not found
     */
    _ObjectHasPropertyValue(valueToFind) {
        for _, propertyValue in this {
            if (propertyValue = valueToFind) {
                return propertyValue
            }
        }
        return false
    }

    /**
     * @param {Any} valueToFind Value to search for
     * @returns {Any|False} Found value or False if not found
     */
    HasValue(valueToFind) => this._ObjectHasPropertyValue(valueToFind)

    ; /**
    ;  * @param {Any} v Value to set
    ;  */
    ; Set(v := unset) {
    ;     if (!IsSet(v)) {
    ;         v := this
    ;     }
    ;     this.DefineProp('value', {Value: v})
    ; }

    ; /**
    ;  * @param {Any} v Value to set safely
    ;  */
    ; SafeSet(v) {
    ;     if (!this.HasOwnProp(v)) {
    ;         this.Set(v)
    ;     }
    ; }

    ; /**
    ;  * @param {Object} obj Object containing values to set
    ;  */
    ; SafeSetObj(obj) {
    ;     for _, value in obj {
    ;         this.SafeSet(value)
    ;     }
    ; }

    /**
     * @returns {Object} Reversed object
     */
    ObjReverse() {
        reversedObject := {}
        for each, value in this {
            reversedObject.Set(value, each)
        }
        return reversedObject
    }

    /**
     * @param {Any*} options Options to choose from
     * @returns {Any} Chosen option
     */
    static Choose(options*) {
        if (options.Length = 1) {
            return options[1]
        }

        infoObjs := [Infos('')]
        for index, option in options {
            if (infoObjs.Length >= Infos.maximumInfos) {
                break
            }
            infoObjs.Push(Infos(option))
        }
        
        loop {
            for _, infoObj in infoObjs {
                if (!WinExist(infoObj.hwnd)) {
                    text := infoObj.text
                    break 2
                }
            }
        }
        
        for _, infoObj in infoObjs {
            infoObj.Destroy()
        }
        return text
    }

    ; /**
    ;  * @param {String} valueName Name of the value to choose
    ;  * @returns {Any} Chosen value
    ;  */
    ; _ChooseObject(valueName) {
    ;     if (this.Prototype.Base.Has(valueName)) {
    ;         return this[valueName]
    ;     }
    ;     options := []
    ;     for _, value in this {
    ;         if (InStr(value, valueName)) {
    ;             options.Push(value)
    ;         }
    ;     }
    ;     chosen := this.Choose(options*)
    ;     return chosen ? this[chosen] : 0
    ; }
}
