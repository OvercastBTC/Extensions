#Requires AutoHotkey v2.0+
#Include <Includes\ObjectTypeExtensions>



; Modify Object prototype
Object.Prototype.DefineProp("ToString", {Call: (this) => Object2.ToString(this)})
Object.Prototype.DefineProp("Has", {Call: (this, key) => this.HasOwnProp(key)})
Object.Prototype.DefineProp("Get", {Call: (this, key, default := "") => this.Has(key) ? this.%key% : default})
Object.Prototype.DefineProp("ToArray", {Call: (this) => Object2.ToArray(this)})
Object.Prototype.DefineProp("ToMap", {Call: (this) => Object2.ToMap(this)})

class Object2 extends Object {

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
; class Object2 {
    
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
		Print(this)
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

; /*
; 	Name: Array.ahk
; 	Version 0.4 (05.09.23)
; 	Created: 27.08.22
; 	Author: Descolada

; 	Description:
; 	A compilation of useful array methods.

;     Array.Slice(start:=1, end:=0, step:=1)  => Returns a section of the array from 'start' to 'end', 
;         optionally skipping elements with 'step'.
;     Array.Swap(a, b)                        => Swaps elements at indexes a and b.
;     Array.Map(func, arrays*)                => Applies a function to each element in the array.
;     Array.ForEach(func)                     => Calls a function for each element in the array.
;     Array.Filter(func)                      => Keeps only values that satisfy the provided function
;     Array.Reduce(func, initialValue?)       => Applies a function cumulatively to all the values in 
;         the array, with an optional initial value.
;     Array.IndexOf(value, start:=1)          => Finds a value in the array and returns its index.
;     Array.Find(func, &match?, start:=1)     => Finds a value satisfying the provided function and returns the index.
;         match will be set to the found value. 
;     Array.Reverse()                         => Reverses the array.
;     Array.Count(value)                      => Counts the number of occurrences of a value.
;     Array.Sort(OptionsOrCallback?, Key?)    => Sorts an array, optionally by object values.
;     Array.Shuffle()                         => Randomizes the array.
;     Array.Join(delim:=",")                  => Joins all the elements to a string using the provided delimiter.
;     Array.ToString(delim:='`n')             => Same intent as Array.Join() : By Axlefublr
;     Array.Flat()                            => Turns a nested array into a one-level array.
;     Array.Extend(enums*)                    => Adds the values of other arrays or enumerables to the end of this one.
; */

; ;! Copied from Array2
; #Include <Extensions\Gui>
; ; Object.Prototype.base := Object2

; class Object2 extends Object {
; 	static Length() => ObjOwnPropCount(this)
;     /**
;      * Returns a section of the array from 'start' to 'end', optionally skipping elements with 'step'.
;      * Modifies the original array.
;      * @param start Optional: index to start from. Default is 1.
;      * @param end Optional: index to end at. Can be negative. Default is 0 (includes the last element).
;      * @param step Optional: an integer specifying the incrementation. Default is 1.
;      * @returns {Array}
;      */
;     static Slice(start:=1, end:=0, step:=1) {
;         len := Object2.length, i := start < 1 ? len + start : start, j := Min(end < 1 ? len + end : end, len), r := [], reverse := False
;         if len = 0
;             return []
;         if i < 1
;             i := 1
;         if step = 0
;             Throw Error("Slice: step cannot be 0",-1)
;         else if step < 0 {
;             while i >= j {
;                 r.Set(this[i])
;                 i += step
;             }
;         } else {
;             while i <= j {
;                 r.Set(this[i])
;                 i += step
;             }
;         }
;         return this := r
;     }
;     /**
;      * Swaps elements at indexes a and b
;      * @param a First elements index to swap
;      * @param b Second elements index to swap
;      * @returns {Array}
;      */
;     static Swap(a, b) {
;         temp := this[b]
;         this[b] := this[a]
;         this[a] := temp
;         return this
;     }
;     /**
;      * Applies a function to each element in the array (mutates the array).
;      * @param func The mapping function that accepts one argument.
;      * @param Objects Additional Objects to be accepted in the mapping function
;      * @returns {Array}
;      */
;     static Map(func, Objects*) {
;         if !HasMethod(func)
;             throw ValueError("Map: func must be a function", -1)
;         for i, v in this {
;             bf := func.Bind(v?)
;             for _, vv in Objects
;                 bf := bf.Bind(vv.Has(i) ? vv[i] : unset)
;             try bf := bf()
;             this[i] := bf
;         }
;         return this
;     }
;     /**
;      * Applies a function to each element in the array.
;      * @param func The callback function with arguments Callback(value[, index, array]).
;      * @returns {Array}
;      */
;     static ForEach(func) {
;         if !HasMethod(func)
;             throw ValueError("ForEach: func must be a function", -1)
;         for i, v in this
;             func(v, i, this)
;         return this
;     }
;     /**
;      * Keeps only values that satisfy the provided function
;      * @param func The filter function that accepts one argument.
;      * @returns {Array}
;      */
;     static Filter(func) {
;         if !HasMethod(func)
;             throw ValueError("Filter: func must be a function", -1)
;         r := []
;         for v in this
;             if func(v)
;                 r.Set(v)
;         return this := r
;     }
;     /**
;      * Applies a function cumulatively to all the values in the array, with an optional initial value.
;      * @param func The function that accepts two arguments and returns one value
;      * @param initialValue Optional: the starting value. If omitted, the first value in the array is used.
;      * @returns {func return type}
;      * @example
;      * [1,2,3,4,5].Reduce((a,b) => (a+b)) ; returns 15 (the sum of all the numbers)
;      */
;     static Reduce(func, initialValue?) {
;         if !HasMethod(func)
;             throw ValueError("Reduce: func must be a function", -1)
;         len := Object2.length + 1
;         if len = 1
;             return initialValue ?? ""
;         if IsSet(initialValue)
;             out := initialValue, i := 0
;         else
;             out := this[1], i := 1
;         while ++i < len {
;             out := func(out, this[i])
;         }
;         return out
;     }
;     /**
;      * Finds a value in the array and returns its index.
;      * @param value The value to search for.
;      * @param start Optional: the index to start the search from. Default is 1.
;      */
;     static IndexOf(value, start:=1) {
;         if !IsInteger(start)
;             throw ValueError("IndexOf: start value must be an integer")
;         for i, v in this {
;             if i < start
;                 continue
;             if v == value
;                 return i
;         }
;         return 0
;     }
;     /**
;      * Finds a value satisfying the provided function and returns its index.
;      * @param func The condition function that accepts one argument.
;      * @param match Optional: is set to the found value
;      * @param start Optional: the index to start the search from. Default is 1.
;      * @example
;      * [1,2,3,4,5].Find((v) => (Mod(v,2) == 0)) ; returns 2
;      */
;     static Find(func, &match?, start:=1) {
;         if !HasMethod(func)
;             throw ValueError("Find: func must be a function", -1)
;         for i, v in this {
;             if i < start
;                 continue
;             if func(v) {
;                 match := v
;                 return i
;             }
;         }
;         return 0
;     }
;     /**
;      * Reverses the array.
;      * @example
;      * [1,2,3].Reverse() ; returns [3,2,1]
;      */
;     static Reverse() {
;         len := Object2.length + 1, max := (len // 2), i := 0
;         while ++i <= max
;             this.Swap(i, len - i)
;         return this
;     }
;     /**
;      * Counts the number of occurrences of a value
;      * @param value The value to count. Can also be a function.
;      */
;     static Count(value) {
;         count := 0
;         if HasMethod(value) {
;             for _, v in this
;                 if value(v?)
;                     count++
;         } else
;             for _, v in this
;                 if v == value
;                     count++
;         return count
;     }
;     /**
;      * Sorts an array, optionally by object keys
;      * @param OptionsOrCallback Optional: either a callback function, or one of the following:
;      * 
;      *     N => array is considered to consist of only numeric values. This is the default option.
;      *     C, C1 or COn => case-sensitive sort of strings
;      *     C0 or COff => case-insensitive sort of strings
;      * 
;      *     The callback function should accept two parameters elem1 and elem2 and return an integer:
;      *     Return integer < 0 if elem1 less than elem2
;      *     Return 0 is elem1 is equal to elem2
;      *     Return > 0 if elem1 greater than elem2
;      * @param Key Optional: Omit it if you want to sort a array of primitive values (strings, numbers etc).
;      *     If you have an array of objects, specify here the key by which contents the object will be sorted.
;      * @returns {Array}
;      */
;     static Sort(optionsOrCallback:="N", key?) {
;         static sizeofFieldType := 16 ; Same on both 32-bit and 64-bit
;         if HasMethod(optionsOrCallback)
;             pCallback := CallbackCreate(CustomCompare.Bind(optionsOrCallback), "F Cdecl", 2), optionsOrCallback := ""
;         else {
;             if InStr(optionsOrCallback, "N")
;                 pCallback := CallbackCreate(IsSet(key) ? NumericCompareKey.Bind(key) : NumericCompare, "F CDecl", 2)
;             if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn")
;                 pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key,,True) : StringCompare.Bind(,,True), "F CDecl", 2)
;             if RegExMatch(optionsOrCallback, "i)C0|COff")
;                 pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key) : StringCompare, "F CDecl", 2)
;             if InStr(optionsOrCallback, "Random")
;                 pCallback := CallbackCreate(RandomCompare, "F CDecl", 2)
;             if !IsSet(pCallback)
;                 throw ValueError("No valid options provided!", -1)
;         }
;         mFields := NumGet(ObjPtr(this) + (8 + (VerCompare(A_AhkVersion, "<2.1-") > 0 ? 3 : 5)*A_PtrSize), "Ptr") ; in v2.0: 0 is VTable. 2 is mBase, 3 is mFields, 4 is FlatVector, 5 is mLength and 6 is mCapacity
;         DllCall("msvcrt.dll\qsort", "Ptr", mFields, "UInt", Object2.length, "UInt", sizeofFieldType, "Ptr", pCallback, "Cdecl")
;         CallbackFree(pCallback)
;         if RegExMatch(optionsOrCallback, "i)R(?!a)")
;             this.Reverse()
;         if InStr(optionsOrCallback, "U")
;             this := this.Unique()
;         return this

;         CustomCompare(compareFunc, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), compareFunc(fieldValue1, fieldValue2))
;         NumericCompare(pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (fieldValue1 > fieldValue2) - (fieldValue1 < fieldValue2))
;         NumericCompareKey(key, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (f1 := fieldValue1.HasProp("__Item") ? fieldValue1[key] : fieldValue1.%key%), (f2 := fieldValue2.HasProp("__Item") ? fieldValue2[key] : fieldValue2.%key%), (f1 > f2) - (f1 < f2))
;         StringCompare(pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1 "", fieldValue2 "", casesense))
;         StringCompareKey(key, pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1.%key% "", fieldValue2.%key% "", casesense))
;         RandomCompare(pFieldType1, pFieldType2) => (Random(0, 1) ? 1 : -1)

;         ValueFromFieldType(pFieldType, &fieldValue?) {
;             static SYM_STRING := 0, PURE_INTEGER := 1, PURE_FLOAT := 2, SYM_MISSING := 3, SYM_OBJECT := 5
;             switch SymbolType := NumGet(pFieldType + 8, "Int") {
;                 case PURE_INTEGER: fieldValue := NumGet(pFieldType, "Int64") 
;                 case PURE_FLOAT: fieldValue := NumGet(pFieldType, "Double") 
;                 case SYM_STRING: fieldValue := StrGet(NumGet(pFieldType, "Ptr")+2*A_PtrSize)
;                 case SYM_OBJECT: fieldValue := ObjFromPtrAddRef(NumGet(pFieldType, "Ptr")) 
;                 case SYM_MISSING: return		
;             }
;         }
;     }
;     /**
;      * Randomizes the array. Slightly faster than Array.Sort(,"Random N")
;      * @returns {Array}
;      */
;     static Shuffle() {
;         len := Object2.length
;         Loop len-1
;             this.Swap(A_index, Random(A_index, len))
;         return this
;     }
;     /**
;      * 
;      */
;     static Unique() {
;         unique := Map()
;         for v in this
;             unique[v] := 1
;         return [unique*]
;     }
;     /**
;      * Joins all the elements to a string using the provided delimiter.
;      * @param delim Optional: the delimiter to use. Default is comma.
;      * @returns {String}
;      */
; 	; static Join(delim:=",") {
; 	static Join(delim:="`n") { ;? OvercastBTC: changed default to `n
; 		result := ""
; 		for v in this
; 			result .= v delim
; 		return (len := StrLen(delim)) ? SubStr(result, 1, -len) : result
; 	}
;     /**
;      * Turns a nested array into a one-level array
;      * @returns {Array}
;      * @example
;      * [1,[2,[3]]].Flat() ; returns [1,2,3]
;      */
;     static Flat() {
;         r := []
;         for v in this {
;             if Type(v) = "Object"
;                 r.Extend(v.Flat())
;             else
;                 r.Set(v)
;         }
;         return this := r
;     }
;     /**
;      * Adds the contents of another array to the end of this one.
;      * @param enums The Objects or other enumerables that are used to extend this one.
;      * @returns {Array}
;      */
;     static Extend(enums*) {
;         for enum in enums {
;             if !Object.DefineProp(enum, "__Enum")
;                 throw ValueError("Extend: Obj must be an iterable")
;             for _, v in enum
;                 v := this
;         }
;         return this
;     }
; ; }
; ; ---------------------------------------------------------------------------
; ;! Original end of Descolada's Array
; ; ---------------------------------------------------------------------------
; ;! Below is Axlefublr's Array additions, that were converted to a class
; ;! Special thanks to Laser_Made for the assistance
; ; ---------------------------------------------------------------------------

; 	/**
; 	 * @example Convert an object to a string representation
; 	 * @param {Object} Obj The object to convert
; 	 * @param {Integer|String} Depth The maximum depth to recurse. Use 'all' for unlimited depth (default: 'all')
; 	 * @param {String} IndentLevel The current indentation level (default: '')
; 	 * @returns {String}
; 	 */
; 	static _ObjToString(Obj := unset, Depth := 'all', IndentLevel := '') {
; 		if (!IsSet(Obj)) {
; 			Obj := this
; 		}
; 		list := ''
; 		if (Type(Obj) = 'Object') {
; 			Obj := Obj.OwnProps()
; 		}
; 		for k, v in Obj {
; 			IndentLevel = '' ? list .= '' : list .= IndentLevel '[' k ']'
; 			if (IsObject(v) && (Depth = 'all' || Depth > 1)) {
; 				list .= '`n' this._ObjToString(v, (Depth = 'all' ? 'all' : Depth - 1), IndentLevel . '    ')
; 			} else {
; 				list .= v
; 			}
; 			list .= '`n'
; 		}
; 		return Trim(list)
; 	}

; 	/**
; 	 * @example Convert the object to a string
; 	 * @param {Object} Obj The object to convert (optional)
; 	 * @returns {String}
; 	 */
; 	static ToString(Obj?) => this._ObjToString(Obj?)

; 	; ---------------------------------------------------------------------------

; 	/**
; 	 * @example Check if the object has a property with a specific value
; 	 * @param {Any} valueToFind The value to search for
; 	 * @returns {Any|False} The found value or False if not found
; 	 */
; 	static _ObjectHasPropertyValue(valueToFind := unset) {
; 		if (!IsSet(valueToFind)) {
; 			valueToFind := this
; 		}
; 		for Name, propertyValue in this {
; 			if (propertyValue = valueToFind) {
; 				return propertyValue
; 			}
; 		}
; 		return false
; 	}

; 	/**
; 	 * @example Check if the object has a specific value
; 	 * @param {Any} valueToFind The value to search for
; 	 * @returns {Any|False} The found value or False if not found
; 	 */
; 	static HasValue(valueToFind) => this._ObjectHasPropertyValue(valueToFind)

; 	; ---------------------------------------------------------------------------

; 	/**
; 	 * @example Set a property value in the object
; 	 * @param {Any} v The value to set
; 	 */
; 	static Set(v := unset) {
; 		if (!IsSet(v)) {
; 			v := this
; 		}
; 		descriptor := {Value: v}
; 		this.DefineProp('value', descriptor)
; 	}

; 	/**
; 	 * @example Safely set a property value in the object
; 	 * @param {Any} v The value to set
; 	 */
; 	static SafeSet(v) {
; 		if (!this.HasOwnProp(v)) {
; 			this.Set(v)
; 		}
; 		; Commented out to prevent script from stopping on duplicate keys
; 		; throw IndexError('Object already has key', -1, v)
; 	}

; 	/**
; 	 * @example Safely set multiple values from another object
; 	 * @param {Object} Object The object containing values to set
; 	 */
; 	static SafeSetObj(Object) {
; 		for each, value in Object {
; 			this.SafeSet(value)
; 		}
; 	}
        
;     static aReverse() {
;         reversedArray := Object()
;         for each, value in this {
;             reversedArray.Set(value, each)
;         }
;         return reversedArray
;     }

;     Choose(options*){
; 		if options.length == 1 {
; 			return options[1]
; 		}
		
; 		else {
; 			infoObjs := [Infos("")]
; 			for index, option in options {
; 				if infoObjs.Length >= Infos.maximumInfos
; 					break
; 				infoObjs.Set(Infos(option))
; 			}
; 			loop {
; 				for index, infoObj in infoObjs {
; 					if WinExist(infoObj.hwnd)
; 						continue
; 					text := infoObj.text
; 					break 2
; 				}
; 			}
; 			for index, infoObj in infoObjs {
; 				infoObj.Destroy()
; 			}
; 			return text
; 		}
; 	} 
;     static Choose(options*){
; 		if options.length == 1 {
; 			return options[1]
; 		}
		
; 		else {
; 			infoObjs := [Infos("")]
; 			for index, option in options {
; 				if infoObjs.Length >= Infos.maximumInfos
; 					break
; 				infoObjs.Set(Infos(option))
; 			}
; 			loop {
; 				for index, infoObj in infoObjs {
; 					if WinExist(infoObj.hwnd)
; 						continue
; 					text := infoObj.text
; 					break 2
; 				}
; 			}
; 			for index, infoObj in infoObjs {
; 				infoObj.Destroy()
; 			}
; 			return text
; 		}
; 	} 

;     static _ChooseArray(valueName) {
;         if this.Prototype.Base.Has(valueName){
;             return this[valueName]
;         }
;         options := []
;         for each, value in this {
;             if InStr(value, valueName){
;                 options.Set(value)
;             }
;         }
;         chosen := this.Choose(options*)
;         if chosen{
;             return this[chosen]
;         }
;         return 0
;     }
;     ; ---------------------------------------------------------------------------
;     /*
;         This library contains multiple sorting algorithms and array-related functions to test them out
;         You'll see the Big O notation for every sorting algorithm: worst, average and best case
;         What each of those means in the context of the sorting algorithm will likely not be explicitly explained

;         Some sorting algorithms will have been tested in terms of real time taken to sort 100000 indexes
;         Take the time coming from the tests with a huge rock of salt, it's there simply to have a rough comparison between sorting algorithms

;         Terms:
;         Rising array   -- every index matches its value
;         Shuffled array -- a shuffled rising array (Fisher-Yates shuffle)
;         Random array   -- array filled with random numbers. the range of each number starts at 1 and ends at the length of the array multiplied by 7 (check the preset parameter of variation in GenerateRandomArray())

;         The time it takes to sort 100k indexes is measured by sorting *shuffled* Objects
;     */

;     static ArrToStr(delimiter := "") {
;         str := ""
;         for key, value in this {
;             if key = this.Prototype.Base.Length {
;                 str .= value
;                 break
;             }
;             str .= value delimiter
;         }
;         return str
;     }
    

;     static GenerateRandomObject(indexes, variation := 7) {
;         ; Object := {}
;         Loop indexes {
;             this.Set(Random(1, indexes * variation))
;         }
;         return this
;     }

; 	static GenerateRisingObject(indexes) {

; 		i := 1
; 		Loop indexes {
; 			this.Set(i)
; 			i++
; 		}
; 		return this
; 	}

;     static GenerateShuffledObject(indexes) {
;         risingObject := this.GenerateRisingObject(indexes)
;         shuffledObject := this.FisherYatesShuffle()
;         return shuffledObject
;     }

;     static FisherYatesShuffle() {
;         shufflerIndex := 0
;         while --shufflerIndex > -this.Prototype.Base.Length {
;             randomIndex := Random(-this.Prototype.Base.Length, shufflerIndex)
;             if this[randomIndex] = this[shufflerIndex]
;                 continue
;             temp := this[shufflerIndex]
;             this[shufflerIndex] := this[randomIndex]
;             this[randomIndex] := temp
;         }
;         return this
;     }
    

;     /*
;         O(n^2) -- worst case
;         O(n^2) -- average case
;         O(n)   -- best case
;         Sorts 100k indexes in: 1 hour 40 minutes
;     */
;     static BubbleSort() {
;         finishedIndex := -1
;         Loop this.Prototype.Base.Length - 1 {
;             swaps := 0
;             for key, value in this {
;                 if value = this[finishedIndex]
;                     break
;                 if value <= this[key + 1]
;                     continue

;                 firstComp := this[key]
;                 secondComp := this[key + 1]
;                 this[key] := secondComp
;                 this[key + 1] := firstComp
;                 swaps++
;             }
;             if !swaps
;                 break
;             finishedIndex--
;         }
;         return this
;     }
    

;     /*
;         O(n^2) -- all cases
;         Sorts 100k indexes in: 1 hour 3 minutes
;     */
;     static SelectionSort() {
;         sortedIndex := 0
;         Loop this.Prototype.Base.Length - 1 {
;             sortedIndex++
;             NewMinInts := 0

;             for key, value in this {
;                 if key < sortedIndex
;                     continue
;                 if key = sortedIndex
;                     min := {key:key, value:value}
;                 else if min.value > value {
;                     min := {key:key, value:value}
;                     NewMinInts++
;                 }
;             }

;             if !NewMinInts
;                 continue

;             temp := this[sortedIndex]
;             this[sortedIndex] := min.value
;             this[min.key] := temp
;         }
;         return this
;     }
    

;     /*
;         O(n^2) -- worst case
;         O(n^2) -- average case
;         O(n)   -- best case
;         Sorts 100k indexes in: 40 minutes
;     */
;     static InsertionSort() {
;         for key, value in this {
;             if key = 1
;                 continue
;             temp := value
;             prevIndex := 0
;             While key + prevIndex - 1 >= 1 && temp < this[key + prevIndex - 1] {
;                 this[key + prevIndex] := this[key + prevIndex - 1]
;                 prevIndex--
;             }
;             this[key + prevIndex] := temp
;         }
;         return this
;     }
    

;     /*
;         O(n logn) -- all cases
;         Sorts 100k indexes in: 4 seconds
;     */
;     static MergeSort() {
;         Merge(leftArray, rightArray, fullArrayLength) {
;             leftArraySize := fullArrayLength // 2
;             rightArraySize := fullArrayLength - leftArraySize
;             fullArray := []
;             l := 1, r := 1

;             While l <= leftArraySize && r <= rightArraySize {
;                 if leftArray[l] < rightArray[r] {
;                     fullArray.Set(leftArray[l])
;                     l++
;                 }
;                 else if leftArray[l] >= rightArray[r] {
;                     fullArray.Set(rightArray[r])
;                     r++
;                 }
;             }
;             While l <= leftArraySize {
;                 fullArray.Set(leftArray[l])
;                 l++
;             }
;             While r <= rightArraySize {
;                 fullArray.Set(rightArray[r])
;                 r++
;             }
;             return fullArray
;         }

;         arrayLength := this.Prototype.Base.Length

;         if arrayLength <= 1
;             return this

;         middle := arrayLength // 2
;         leftArray := []
;         rightArray := []

;         i := 1
;         While i <= arrayLength {
;             if i <= middle
;                 leftArray.Set(this[i])
;             else if i > middle
;                 rightArray.Set(this[i])
;             i++
;         }

;         leftArray := this.MergeSort()
;         rightArray := this.MergeSort()
;         ; return Merge(leftArray, rightArray, arrayLength)
;         return this
;     }
    

;     /*
;         O(n + k) -- all cases
;         Where "k" is the highest integer in the array
;         The more indexes you want to sort, the bigger "thread delay" will have to be
;         This sorting algorithm is *not* practical, use it exclusively for fun!
;     */
;     static SleepSort(threadDelay := 30) {
        
;         _SetIndex(passedValue) {
;             Settimer(() => this.Set(passedValue), -passedValue * threadDelay)
;         }

;         for key, value in this {
;             _SetIndex(value)
;         }

;         While Object2.length != this.Prototype.Base.Length {
;             ;We're waiting for the sorted array to be filled since otherwise we immidiately return an empty array (settimers don't take up the thread while waiting, unlike sleep)
;         }
;         return this
;     }
;     /**
;      * IndexOfValue
;      * Original from Descolada
;      */
;     /**
;      * Finds a value in the array and returns its index.
;      * @param value The value to search for.
;      * @param start Optional: the index to start the search from. Default is 1.
;      */
;         static IndexOfValue(value, start:=1) {
;             if !IsInteger(start)
;                 throw ValueError("IndexOf: start value must be an integer")
;             for i, v in this {
;                 if i < start
;                     continue
;                 if v == value
;                     return i
;             }
;             return 0
;         }
; }
