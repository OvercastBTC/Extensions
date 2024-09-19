/*
	Name: Array.ahk
	Version 0.4 (05.09.23)
	Created: 27.08.22
	Author: Descolada

	Description:
	A compilation of useful array methods.

    Array.Slice(start:=1, end:=0, step:=1)  => Returns a section of the array from 'start' to 'end', 
        optionally skipping elements with 'step'.
    Array.Swap(a, b)                        => Swaps elements at indexes a and b.
    Array.Map(func, arrays*)                => Applies a function to each element in the array.
    Array.ForEach(func)                     => Calls a function for each element in the array.
    Array.Filter(func)                      => Keeps only values that satisfy the provided function
    Array.Reduce(func, initialValue?)       => Applies a function cumulatively to all the values in 
        the array, with an optional initial value.
    Array.IndexOf(value, start:=1)          => Finds a value in the array and returns its index.
    Array.Find(func, &match?, start:=1)     => Finds a value satisfying the provided function and returns the index.
        match will be set to the found value. 
    Array.Reverse()                         => Reverses the array.
    Array.Count(value)                      => Counts the number of occurrences of a value.
    Array.Sort(OptionsOrCallback?, Key?)    => Sorts an array, optionally by object values.
    Array.Shuffle()                         => Randomizes the array.
    Array.Join(delim:=",")                  => Joins all the elements to a string using the provided delimiter.
    Array.ToString(delim:='`n')             => Same intent as Array.Join() : By Axlefublr
    Array.Flat()                            => Turns a nested array into a one-level array.
    Array.Extend(enums*)                    => Adds the values of other arrays or enumerables to the end of this one.
*/

Array.Prototype.base := Array2

class Array2 {
; class Array2 extends Array{
    /**
     * Returns a section of the array from 'start' to 'end', optionally skipping elements with 'step'.
     * Modifies the original array.
     * @param start Optional: index to start from. Default is 1.
     * @param end Optional: index to end at. Can be negative. Default is 0 (includes the last element).
     * @param step Optional: an integer specifying the incrementation. Default is 1.
     * @returns {Array}
     */
    static Slice(start:=1, end:=0, step:=1) {
        len := this.Length, i := start < 1 ? len + start : start, j := Min(end < 1 ? len + end : end, len), r := [], reverse := False
        if len = 0
            return []
        if i < 1
            i := 1
        if step = 0
            Throw Error("Slice: step cannot be 0",-1)
        else if step < 0 {
            while i >= j {
                r.Push(this[i])
                i += step
            }
        } else {
            while i <= j {
                r.Push(this[i])
                i += step
            }
        }
        return this := r
    }
    /**
     * Swaps elements at indexes a and b
     * @param a First elements index to swap
     * @param b Second elements index to swap
     * @returns {Array}
     */
    static Swap(a, b) {
        temp := this[b]
        this[b] := this[a]
        this[a] := temp
        return this
    }
    /**
     * Applies a function to each element in the array (mutates the array).
     * @param func The mapping function that accepts one argument.
     * @param arrays Additional arrays to be accepted in the mapping function
     * @returns {Array}
     */
    static Map(func, arrays*) {
        if !HasMethod(func)
            throw ValueError("Map: func must be a function", -1)
        for i, v in this {
            bf := func.Bind(v?)
            for _, vv in arrays
                bf := bf.Bind(vv.Has(i) ? vv[i] : unset)
            try bf := bf()
            this[i] := bf
        }
        return this
    }
    /**
     * Applies a function to each element in the array.
     * @param func The callback function with arguments Callback(value[, index, array]).
     * @returns {Array}
     */
    static ForEach(func) {
        if !HasMethod(func)
            throw ValueError("ForEach: func must be a function", -1)
        for i, v in this
            func(v, i, this)
        return this
    }
    /**
     * Keeps only values that satisfy the provided function
     * @param func The filter function that accepts one argument.
     * @returns {Array}
     */
    static Filter(func) {
        if !HasMethod(func)
            throw ValueError("Filter: func must be a function", -1)
        r := []
        for v in this
            if func(v)
                r.Push(v)
        return this := r
    }
    /**
     * Applies a function cumulatively to all the values in the array, with an optional initial value.
     * @param func The function that accepts two arguments and returns one value
     * @param initialValue Optional: the starting value. If omitted, the first value in the array is used.
     * @returns {func return type}
     * @example
     * [1,2,3,4,5].Reduce((a,b) => (a+b)) ; returns 15 (the sum of all the numbers)
     */
    static Reduce(func, initialValue?) {
        if !HasMethod(func)
            throw ValueError("Reduce: func must be a function", -1)
        len := this.Length + 1
        if len = 1
            return initialValue ?? ""
        if IsSet(initialValue)
            out := initialValue, i := 0
        else
            out := this[1], i := 1
        while ++i < len {
            out := func(out, this[i])
        }
        return out
    }
    /**
     * Finds a value in the array and returns its index.
     * @param value The value to search for.
     * @param start Optional: the index to start the search from. Default is 1.
     */
    static IndexOf(value, start:=1) {
        if !IsInteger(start)
            throw ValueError("IndexOf: start value must be an integer")
        for i, v in this {
            if i < start
                continue
            if v == value
                return i
        }
        return 0
    }
    /**
     * Finds a value satisfying the provided function and returns its index.
     * @param func The condition function that accepts one argument.
     * @param match Optional: is set to the found value
     * @param start Optional: the index to start the search from. Default is 1.
     * @example
     * [1,2,3,4,5].Find((v) => (Mod(v,2) == 0)) ; returns 2
     */
    static Find(func, &match?, start:=1) {
        if !HasMethod(func)
            throw ValueError("Find: func must be a function", -1)
        for i, v in this {
            if i < start
                continue
            if func(v) {
                match := v
                return i
            }
        }
        return 0
    }
    /**
     * Reverses the array.
     * @example
     * [1,2,3].Reverse() ; returns [3,2,1]
     */
    static Reverse() {
        len := this.Length + 1, max := (len // 2), i := 0
        while ++i <= max
            this.Swap(i, len - i)
        return this
    }
    /**
     * Counts the number of occurrences of a value
     * @param value The value to count. Can also be a function.
     */
    static Count(value) {
        count := 0
        if HasMethod(value) {
            for _, v in this
                if value(v?)
                    count++
        } else
            for _, v in this
                if v == value
                    count++
        return count
    }
    /**
     * Sorts an array, optionally by object keys
     * @param OptionsOrCallback Optional: either a callback function, or one of the following:
     * 
     *     N => array is considered to consist of only numeric values. This is the default option.
     *     C, C1 or COn => case-sensitive sort of strings
     *     C0 or COff => case-insensitive sort of strings
     * 
     *     The callback function should accept two parameters elem1 and elem2 and return an integer:
     *     Return integer < 0 if elem1 less than elem2
     *     Return 0 is elem1 is equal to elem2
     *     Return > 0 if elem1 greater than elem2
     * @param Key Optional: Omit it if you want to sort a array of primitive values (strings, numbers etc).
     *     If you have an array of objects, specify here the key by which contents the object will be sorted.
     * @returns {Array}
     */
    static Sort(optionsOrCallback:="N", key?) {
        static sizeofFieldType := 16 ; Same on both 32-bit and 64-bit
        if HasMethod(optionsOrCallback)
            pCallback := CallbackCreate(CustomCompare.Bind(optionsOrCallback), "F Cdecl", 2), optionsOrCallback := ""
        else {
            if InStr(optionsOrCallback, "N")
                pCallback := CallbackCreate(IsSet(key) ? NumericCompareKey.Bind(key) : NumericCompare, "F CDecl", 2)
            if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn")
                pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key,,True) : StringCompare.Bind(,,True), "F CDecl", 2)
            if RegExMatch(optionsOrCallback, "i)C0|COff")
                pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key) : StringCompare, "F CDecl", 2)
            if InStr(optionsOrCallback, "Random")
                pCallback := CallbackCreate(RandomCompare, "F CDecl", 2)
            if !IsSet(pCallback)
                throw ValueError("No valid options provided!", -1)
        }
        mFields := NumGet(ObjPtr(this) + (8 + (VerCompare(A_AhkVersion, "<2.1-") > 0 ? 3 : 5)*A_PtrSize), "Ptr") ; in v2.0: 0 is VTable. 2 is mBase, 3 is mFields, 4 is FlatVector, 5 is mLength and 6 is mCapacity
        DllCall("msvcrt.dll\qsort", "Ptr", mFields, "UInt", this.Length, "UInt", sizeofFieldType, "Ptr", pCallback, "Cdecl")
        CallbackFree(pCallback)
        if RegExMatch(optionsOrCallback, "i)R(?!a)")
            this.Reverse()
        if InStr(optionsOrCallback, "U")
            this := this.Unique()
        return this

        CustomCompare(compareFunc, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), compareFunc(fieldValue1, fieldValue2))
        NumericCompare(pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (fieldValue1 > fieldValue2) - (fieldValue1 < fieldValue2))
        NumericCompareKey(key, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (f1 := fieldValue1.HasProp("__Item") ? fieldValue1[key] : fieldValue1.%key%), (f2 := fieldValue2.HasProp("__Item") ? fieldValue2[key] : fieldValue2.%key%), (f1 > f2) - (f1 < f2))
        StringCompare(pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1 "", fieldValue2 "", casesense))
        StringCompareKey(key, pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1.%key% "", fieldValue2.%key% "", casesense))
        RandomCompare(pFieldType1, pFieldType2) => (Random(0, 1) ? 1 : -1)

        ValueFromFieldType(pFieldType, &fieldValue?) {
            static SYM_STRING := 0, PURE_INTEGER := 1, PURE_FLOAT := 2, SYM_MISSING := 3, SYM_OBJECT := 5
            switch SymbolType := NumGet(pFieldType + 8, "Int") {
                case PURE_INTEGER: fieldValue := NumGet(pFieldType, "Int64") 
                case PURE_FLOAT: fieldValue := NumGet(pFieldType, "Double") 
                case SYM_STRING: fieldValue := StrGet(NumGet(pFieldType, "Ptr")+2*A_PtrSize)
                case SYM_OBJECT: fieldValue := ObjFromPtrAddRef(NumGet(pFieldType, "Ptr")) 
                case SYM_MISSING: return		
            }
        }
    }
    /**
     * Randomizes the array. Slightly faster than Array.Sort(,"Random N")
     * @returns {Array}
     */
    static Shuffle() {
        len := this.Length
        Loop len-1
            this.Swap(A_index, Random(A_index, len))
        return this
    }
    /**
     * 
     */
    static Unique() {
        unique := Map()
        for v in this
            unique[v] := 1
        return [unique*]
    }
    /**
     * Joins all the elements to a string using the provided delimiter.
     * @param delim Optional: the delimiter to use. Default is comma.
     * @returns {String}
     */
	; static Join(delim:=",") {
	static Join(delim:="`n") { ;? OvercastBTC: changed default to `n
		result := ""
		for v in this
			result .= v delim
		return (len := StrLen(delim)) ? SubStr(result, 1, -len) : result
	}
    /**
     * Turns a nested array into a one-level array
     * @returns {Array}
     * @example
     * [1,[2,[3]]].Flat() ; returns [1,2,3]
     */
    static Flat() {
        r := []
        for v in this {
            if Type(v) = "Array"
                r.Extend(v.Flat())
            else
                r.Push(v)
        }
        return this := r
    }
    /**
     * Adds the contents of another array to the end of this one.
     * @param enums The arrays or other enumerables that are used to extend this one.
     * @returns {Array}
     */
    static Extend(enums*) {
        for enum in enums {
            if !HasMethod(enum, "__Enum")
                throw ValueError("Extend: arr must be an iterable")
            for _, v in enum
                this.Push(v)
        }
        return this
    }
; }
; ---------------------------------------------------------------------------
;! Original end of Descolada's Array
; ---------------------------------------------------------------------------
;! Below is Axlefublr's Array additions, that were converted to a class
;! Special thanks to Laser_Made for the assistance
; ---------------------------------------------------------------------------

; Class Array2 extends Array {
; Class Array2 {
    static _ArrayToString(char := '`n') {
        str := ''
        for index, value in this {
            if index = this.Length {
                str .= value
                break
            }
            str .= value char
        }
        return str
    }
    static ToString(char?) => this._ArrayToString(char?)
    ; ---------------------------------------------------------------------------
    static _ArrayHasValue(valueToFind) {
        for index, value in this {
            if (value = valueToFind){
                return value
            }
        }
        return false
    }
    static HasValue(valueToFind) => this._ArrayHasValue(valueToFind)
    ; ---------------------------------------------------------------------------
    /**
     * By default, you can set the same value to an array multiple times.
     * Naturally, you'll be able to reference only one of them, which is likely not the behavior you want.
     * This function will throw an error if you try to set a value that already exists in the array.
     * @param arrayObj ***Array*** to set the index-value pair into
     * @param each ***index*** (or A_Index)
     * @param value ***Any***
     */
    static SafePush(value) {
        if !this.HasValue(value) {
            this.Push(value)
            ; return
        }
        ; throw IndexError("Array already has key", -1, key)
    }

    /**
     * A version of SafePush that you can just pass another array object into to set everything in it.
     * Will still throw an error for every key that already exists in the array.
     * @param arrayObj ***Array*** the initial array
     * @param arrayToPush ***Array*** the array to set into the initial array
     */
    static SafePushArray(ArrayObj) {
        for each, value in this {
            this.SafePush(value)
        }
    }
        
    static aReverse() {
        reversedArray := Array()
        for each, value in this {
            reversedArray.Push(value, each)
        }
        return reversedArray
    }

    Choose(options*){
		if options.length == 1 {
			return options[1]
		}
		
		else {
			infoObjs := [Infos("")]
			for index, option in options {
				if infoObjs.Length >= Infos.maximumInfos
					break
				infoObjs.Push(Infos(option))
			}
			loop {
				for index, infoObj in infoObjs {
					if WinExist(infoObj.hwnd)
						continue
					text := infoObj.text
					break 2
				}
			}
			for index, infoObj in infoObjs {
				infoObj.Destroy()
			}
			return text
		}
	} 
    static Choose(options*){
		if options.length == 1 {
			return options[1]
		}
		
		else {
			infoObjs := [Infos("")]
			for index, option in options {
				if infoObjs.Length >= Infos.maximumInfos
					break
				infoObjs.Push(Infos(option))
			}
			loop {
				for index, infoObj in infoObjs {
					if WinExist(infoObj.hwnd)
						continue
					text := infoObj.text
					break 2
				}
			}
			for index, infoObj in infoObjs {
				infoObj.Destroy()
			}
			return text
		}
	} 

    static _ChooseArray(valueName) {
        if this.Prototype.Base.Has(valueName){
            return this[valueName]
        }
        options := []
        for each, value in this {
            if InStr(value, valueName){
                options.Push(value)
            }
        }
        chosen := this.Choose(options*)
        if chosen{
            return this[chosen]
        }
        return ""
    }
    ; ---------------------------------------------------------------------------
    /*
        This library contains multiple sorting algorithms and array-related functions to test them out
        You'll see the Big O notation for every sorting algorithm: worst, average and best case
        What each of those means in the context of the sorting algorithm will likely not be explicitly explained

        Some sorting algorithms will have been tested in terms of real time taken to sort 100000 indexes
        Take the time coming from the tests with a huge rock of salt, it's there simply to have a rough comparison between sorting algorithms

        Terms:
        Rising array   -- every index matches its value
        Shuffled array -- a shuffled rising array (Fisher-Yates shuffle)
        Random array   -- array filled with random numbers. the range of each number starts at 1 and ends at the length of the array multiplied by 7 (check the preset parameter of variation in GenerateRandomArray())

        The time it takes to sort 100k indexes is measured by sorting *shuffled* arrays
    */

    static ArrToStr(delimiter := "") {
        str := ""
        for key, value in this {
            if key = this.Prototype.Base.Length {
                str .= value
                break
            }
            str .= value delimiter
        }
        return str
    }
    

    static GenerateRandomArray(indexes, variation := 7) {
        arrayObj := []
        Loop indexes {
            arrayObj.Push(Random(1, indexes * variation))
        }
        return arrayObj
    }

    static GenerateRisingArray(indexes) {
        arrayObj := []
        i := 1
        Loop indexes {
            arrayObj.Push(i)
            i++
        }
        return arrayObj
    }

    static GenerateShuffledArray(indexes) {
        risingArray := this.GenerateRisingArray(indexes)
        shuffledArray := this.FisherYatesShuffle()
        return shuffledArray
    }

    static FisherYatesShuffle() {
        shufflerIndex := 0
        while --shufflerIndex > -this.Prototype.Base.Length {
            randomIndex := Random(-this.Prototype.Base.Length, shufflerIndex)
            if this[randomIndex] = this[shufflerIndex]
                continue
            temp := this[shufflerIndex]
            this[shufflerIndex] := this[randomIndex]
            this[randomIndex] := temp
        }
        return this
    }
    

    /*
        O(n^2) -- worst case
        O(n^2) -- average case
        O(n)   -- best case
        Sorts 100k indexes in: 1 hour 40 minutes
    */
    static BubbleSort() {
        finishedIndex := -1
        Loop this.Prototype.Base.Length - 1 {
            swaps := 0
            for key, value in this {
                if value = this[finishedIndex]
                    break
                if value <= this[key + 1]
                    continue

                firstComp := this[key]
                secondComp := this[key + 1]
                this[key] := secondComp
                this[key + 1] := firstComp
                swaps++
            }
            if !swaps
                break
            finishedIndex--
        }
        return this
    }
    

    /*
        O(n^2) -- all cases
        Sorts 100k indexes in: 1 hour 3 minutes
    */
    static SelectionSort() {
        sortedIndex := 0
        Loop this.Prototype.Base.Length - 1 {
            sortedIndex++
            NewMinInts := 0

            for key, value in this {
                if key < sortedIndex
                    continue
                if key = sortedIndex
                    min := {key:key, value:value}
                else if min.value > value {
                    min := {key:key, value:value}
                    NewMinInts++
                }
            }

            if !NewMinInts
                continue

            temp := this[sortedIndex]
            this[sortedIndex] := min.value
            this[min.key] := temp
        }
        return this
    }
    

    /*
        O(n^2) -- worst case
        O(n^2) -- average case
        O(n)   -- best case
        Sorts 100k indexes in: 40 minutes
    */
    static InsertionSort() {
        for key, value in this {
            if key = 1
                continue
            temp := value
            prevIndex := 0
            While key + prevIndex - 1 >= 1 && temp < this[key + prevIndex - 1] {
                this[key + prevIndex] := this[key + prevIndex - 1]
                prevIndex--
            }
            this[key + prevIndex] := temp
        }
        return this
    }
    

    /*
        O(n logn) -- all cases
        Sorts 100k indexes in: 4 seconds
    */
    static MergeSort() {
        Merge(leftArray, rightArray, fullArrayLength) {
            leftArraySize := fullArrayLength // 2
            rightArraySize := fullArrayLength - leftArraySize
            fullArray := []
            l := 1, r := 1

            While l <= leftArraySize && r <= rightArraySize {
                if leftArray[l] < rightArray[r] {
                    fullArray.Push(leftArray[l])
                    l++
                }
                else if leftArray[l] >= rightArray[r] {
                    fullArray.Push(rightArray[r])
                    r++
                }
            }
            While l <= leftArraySize {
                fullArray.Push(leftArray[l])
                l++
            }
            While r <= rightArraySize {
                fullArray.Push(rightArray[r])
                r++
            }
            return fullArray
        }

        arrayLength := this.Prototype.Base.Length

        if arrayLength <= 1
            return this

        middle := arrayLength // 2
        leftArray := []
        rightArray := []

        i := 1
        While i <= arrayLength {
            if i <= middle
                leftArray.Push(this[i])
            else if i > middle
                rightArray.Push(this[i])
            i++
        }

        leftArray := this.MergeSort()
        rightArray := this.MergeSort()
        ; return Merge(leftArray, rightArray, arrayLength)
        return this
    }
    

    /*
        O(n + k) -- all cases
        Where "k" is the highest integer in the array
        The more indexes you want to sort, the bigger "thread delay" will have to be
        This sorting algorithm is *not* practical, use it exclusively for fun!
    */
    static SleepSort(threadDelay := 30) {
        sortedArrayObj := []

        _PushIndex(passedValue) {
            Settimer(() => sortedArrayObj.Push(passedValue), -passedValue * threadDelay)
        }

        for key, value in this {
            _PushIndex(value)
        }

        While sortedArrayObj.Length != this.Prototype.Base.Length {
            ;We're waiting for the sorted array to be filled since otherwise we immidiately return an empty array (settimers don't take up the thread while waiting, unlike sleep)
        }
        return sortedArrayObj
    }
    /**
     * IndexOfValue
     * Original from Descolada
     */
    /**
     * Finds a value in the array and returns its index.
     * @param value The value to search for.
     * @param start Optional: the index to start the search from. Default is 1.
     */
        static IndexOfValue(value, start:=1) {
            if !IsInteger(start)
                throw ValueError("IndexOf: start value must be an integer")
            for i, v in this {
                if i < start
                    continue
                if v == value
                    return i
            }
            return 0
        }
}
