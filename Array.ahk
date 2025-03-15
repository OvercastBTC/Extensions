/************************************************************************
 * @name Array.ahk
 * @description A compilation of useful array methods.
 * @author Descolada
 * @version 0.4 (05.09.23)
 * @created 08.27.22
 * @author OvercastBTC
 * @date 2024/12/05
 * @version 12.05.24
 ***********************************************************************/

/**
 * @example
    Array.Slice(start:=1, end:=0, step:=1)  => Returns a section of the array from 'start' to 'end', 
        optionally skipping elements with 'step'.
    Array.Swap(a, b)                        => Swaps elements at indexes a and b.
    Array.Map(func, arrays*)                => Applies a function to each element in the array.
    Array.ForEach(func)                     => Calls a function for each element in the array.
    Array.Filter(func)                      => Keeps only values that satisfy the provided function
    Array.Reduce(func, initialValue?)       => Applies a function cumulatively to all the values in the array, with an optional initial value.
    Array.IndexOf(value, start:=1)          => Finds a value in the array and returns its index.
    Array.Find(func, &match?, start:=1)     => Finds a value satisfying the provided function and returns the index. Match will be set to the found value. 
    Array.Reverse()                         => Reverses the array.
    Array.Count(value)                      => Counts the number of occurrences of a value.
    Array.Sort(OptionsOrCallback?, Key?)    => Sorts an array, optionally by object values.
    Array.Shuffle()                         => Randomizes the array.
    Array.Join(delim:=",")                  => Joins all the elements to a string using the provided delimiter.
    Array.ToString(delim:='`n')             => Same intent as Array.Join() : By Axlefublr
    Array.Flat()                            => Turns a nested array into a one-level array.
    Array.Extend(enums*)                    => Adds the values of other arrays or enumerables to the end of this one.
*/

; ---------------------------------------------------------------------------

/**
 * @description Sets the Prototype.Base for Array to be built by Array2 and its properties, then add all the properties in Array
 */
Array.Prototype.Base := Array2

; ---------------------------------------------------------------------------

Class Array2 {

	static __New() {
		; Add all Array2 methods to Array prototype
		for methodName in Array2.OwnProps() {
			if methodName != "__New" && HasMethod(Array2, methodName) {
				; Check if method already exists
				if Array.Prototype.HasOwnProp(methodName) {
					; Skip if method exists to avoid overwriting
					continue
				}
				; Add the method to Array.Prototype
				Array.Prototype.DefineProp(methodName, {
					Call: Array2.%methodName%
				})
			}
		}
	}

	static Length() {
		arrObj := Array()
		arrObj.Length()
	}

	static Push(v) {
		arrObj := Array()
		arrObj.Push(v)
	}

	/**
	 * @description Adds one or more elements to the beginning of an array and returns the new length
	 * @param elements* Elements to add to the beginning of the array
	 * @returns {Integer} The new length of the array
	 * @example
	 * [1,2,3].Unshift(0) ; returns 4, array becomes [0,1,2,3]
	 * [3,4,5].Unshift(1,2) ; returns 5, array becomes [1,2,3,4,5]
	 */
	static Unshift(elements*) {
		
		aNew := []

		if (elements.Length == 0){
			return this.Length
		}

		; Handle case where this method is called statically with an array as first parameter
		if (elements.Length > 0 && Type(this) == "Class" && IsObject(elements[1]) && elements[1].HasProp("Length")) {
			arr := elements[1]
			elements.RemoveAt(1)
			return this.Unshift(arr, elements*)
		}
		
		for element in elements{
			aNew.Push(element)
		}

		for item in this {
			aNew.Push(item)
		}

		; Clear the original array
		this.Length := 0
		
		for item in aNew {
			this.Push(item)
		}

		; Return the new length
		return this.length
	}

	/**
	 * @description Alias for Unshift that can be used statically
	 * @param arr The array to modify
	 * @param elements* Elements to add to the beginning of the array 
	 * @returns {Integer} The new length of the array
	 * @example
	 * Array2.Array_Unshift([1,2,3], 0) ; returns 4, array becomes [0,1,2,3]
	 */
	static Array_Unshift(arr, elements*) {
		if (!IsObject(arr) || !arr.HasProp("Length"))
			throw ValueError("Array_Unshift: First argument must be an array", -1)
		
		return arr.Unshift(elements*)
	}

	/**
     * Returns a section of the array from 'start' to 'end', optionally skipping elements with 'step'.
     * @param start Optional: index to start from. Default is 1.
     * @param end Optional: index to end at. Can be negative. Default is 0 (includes the last element).
     * @param step Optional: an integer specifying the incrementation. Default is 1.
     * @returns {Array}
     */
    static Slice(start:=1, end:=0, step:=1) {
        len := this.Length, i := start < 1 ? len + start : start, j := Min(end < 1 ? len + end : end, len)
        r := []
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
     * Applies a function cumulatively to all the values in the array.
     * @param func The function that accepts two arguments and returns one value
     * @param initialValue Optional: the starting value. If omitted, first array value is used.
     * @returns {func return type}
     * @example
     * [1,2,3,4,5].Reduce((a,b) => (a+b)) ; returns 15 (sum of all numbers)
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
     * @returns {Integer} Index of found value or 0 if not found
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
     * Joins all the elements to a string using the provided delimiter.
     * @param delim Optional: the delimiter to use. Default is newline.
     * @returns {String}
     */
    static Join(delim:="`n") {
        result := ''
        for v in this {
            result .= v delim
		}
        return (len := StrLen(delim)) ? SubStr(result, 1, -len) : result
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
     * @returns {Array}
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
     * @returns {Integer}
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
            for _, v in enum {
                this.Push(v)
            }
        }
        return this
    }

    /**
     * Converts array to string with custom delimiter
     * @param char Optional: delimiter character. Default is newline.
     * @returns {String}
     */
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

    /**
     * Alias for _ArrayToString
     */
    static ToString(char?) => this._ArrayToString(char?)

    /**
     * Checks if array contains a value
     * @param valueToFind The value to search for
     * @returns {Any|False} The found value or False if not found
     */
    static _ArrayHasValue(valueToFind) {
        for index, value in this {
            if (value = valueToFind) {
                return value
            }
        }
        return false
    }

    /**
     * Alias for _ArrayHasValue
     */
    static HasValue(valueToFind) => this._ArrayHasValue(valueToFind)

    /**
     * Safely push a value to array only if it doesn't exist
     * @param value The value to push
     * @throws {IndexError} If value already exists
     */
    static SafePush(value) {
        if !this.HasValue(value) {
            this.Push(value)
        }
    }

	/**
     * Generates an array of random numbers
     * @param indexes Number of elements to generate
     * @param variation Multiplier for maximum random value
     * @returns {Array}
     */
    static GenerateRandomArray(indexes, variation := 7) {
        arrayObj := []
        Loop indexes {
            arrayObj.Push(Random(1, indexes * variation))
        }
        return arrayObj
    }

    /**
     * Generates a sequential array from 1 to indexes
     * @param indexes The length of the array to generate
     * @returns {Array}
     */
    static GenerateRisingArray(indexes) {
        arrayObj := []
        i := 1
        Loop indexes {
            arrayObj.Push(i)
            i++
        }
        return arrayObj
    }

    /**
     * Generates a shuffled array of sequential numbers
     * @param indexes The length of the array to generate
     * @returns {Array}
     */
    static GenerateShuffledArray(indexes) {
        risingArray := this.GenerateRisingArray(indexes)
        shuffledArray := this.FisherYatesShuffle()
        return shuffledArray
    }

    /**
     * Implements Fisher-Yates shuffle algorithm
     * @returns {Array}
     */
    static FisherYatesShuffle() {
        shufflerIndex := 0
        while --shufflerIndex > -this.Length {
            randomIndex := Random(-this.Length, shufflerIndex)
            if this[randomIndex] = this[shufflerIndex]
                continue
            temp := this[shufflerIndex]
            this[shufflerIndex] := this[randomIndex]
            this[randomIndex] := temp
        }
        return this
    }

    /**
     * Removes duplicate values from array
     * @returns {Array}
     */
    static Unique() {
        unique := Map()
        for v in this
            unique[v] := 1
        return [unique*]
    }

	/**
     * Implementation of Bubble Sort
     * O(n^2) -- worst and average case
     * O(n)   -- best case
     * @returns {Array}
     */
    static BubbleSort() {
        finishedIndex := -1
        Loop this.Length - 1 {
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

    /**
     * Implementation of Selection Sort
     * O(n^2) -- all cases
     * @returns {Array}
     */
    static SelectionSort() {
        sortedIndex := 0
        Loop this.Length - 1 {
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

    /**
     * Implementation of Insertion Sort
     * O(n^2) -- worst and average case
     * O(n)   -- best case
     * @returns {Array}
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

	/**
     * Implementation of Merge Sort
     * O(n logn) -- all cases
     * @returns {Array}
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

        arrayLength := this.Length

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

        leftArray := leftArray.MergeSort()
        rightArray := rightArray.MergeSort()
        return Merge(leftArray, rightArray, arrayLength)
    }

    /**
     * Implementation of Sleep Sort (for fun!)
     * O(n + k) -- all cases
     * Where "k" is the highest integer in the array
     * @param threadDelay Optional: delay multiplier for sorting. Default is 30.
     * @returns {Array}
     * @warning This sorting algorithm is not practical, use only for demonstration!
     */
    static SleepSort(threadDelay := 30) {
        sortedArrayObj := []

        _PushIndex(passedValue) {
            SetTimer(() => sortedArrayObj.Push(passedValue), -passedValue * threadDelay)
        }

        for key, value in this {
            _PushIndex(value)
        }

        While sortedArrayObj.Length != this.Length {
            ; Wait for the sorted array to be filled
        }
        return sortedArrayObj
    }

    ; /**
    ;  * Main Sort method with various options
    ;  * @param optionsOrCallback Optional: callback function or sorting options
    ;  * @param key Optional: key to sort by for object arrays
    ;  * @returns {Array}
    ;  */
    ; static Sort(optionsOrCallback := "N", key?) {
    ;     static sizeofFieldType := 16  ; Same on both 32-bit and 64-bit
        
    ;     if HasMethod(optionsOrCallback)
    ;         pCallback := CallbackCreate(this.CustomCompare.Bind(optionsOrCallback), "F Cdecl", 2)
    ;     else if InStr(optionsOrCallback, "N")
    ;         pCallback := CallbackCreate(IsSet(key) ? this.NumericCompareKey.Bind(key) : this.NumericCompare, "F CDecl", 2)
    ;     else if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn")
    ;         pCallback := CallbackCreate(IsSet(key) ? this.StringCompareKey.Bind(key,,True) : this.StringCompare.Bind(,,True), "F CDecl", 2)
    ;     else if RegExMatch(optionsOrCallback, "i)C0|COff")
    ;         pCallback := CallbackCreate(IsSet(key) ? this.StringCompareKey.Bind(key) : this.StringCompare, "F CDecl", 2)
    ;     else if InStr(optionsOrCallback, "Random")
    ;         pCallback := CallbackCreate(this.RandomCompare, "F CDecl", 2)
    ;     else
    ;         throw ValueError("No valid options provided!", -1)
        
    ;     ; Sort using qsort from msvcrt.dll
    ;     mFields := NumGet(ObjPtr(this) + (8 + (VerCompare(A_AhkVersion, "<2.1-") > 0 ? 3 : 5)*A_PtrSize), "Ptr")
    ;     DllCall("msvcrt.dll\qsort", "Ptr", mFields, "UInt", this.Length, "UInt", sizeofFieldType, "Ptr", pCallback, "Cdecl")
    ;     CallbackFree(pCallback)

    ;     ; Handle additional options
    ;     if RegExMatch(optionsOrCallback, "i)R(?!a)")
    ;         this.Reverse()
    ;     if InStr(optionsOrCallback, "U")
    ;         this := this.Unique()
        
    ;     return this
    ; }

	/**
	 * Sort method with support for custom comparison functions
	 * @param {Function|String} optionsOrCallback Optional callback function or sorting options
	 * @param {String} key Optional key for sorting object arrays
	 * @returns {Array} The sorted array
	 */
		static Sort(optionsOrCallback := "N", key?) {
			if !this.Length   ; Handle empty array case
				return this

			; If using a custom comparison function
			if HasMethod(optionsOrCallback) {
				return this._CustomSort(optionsOrCallback, key)
			}

			; For standard sorting options
			if InStr(optionsOrCallback, "N") {
				return this._NumericSort(key)
			} else if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn") {
				return this._CaseSensitiveSort(key)
			} else if RegExMatch(optionsOrCallback, "i)C0|COff") {
				return this._CaseInsensitiveSort(key)
			} else if InStr(optionsOrCallback, "Random") {
				return this._RandomSort()
			}

			; Handle reverse option
			if RegExMatch(optionsOrCallback, "i)R(?!a)") {
				this.Reverse()
			}

			; Handle unique option
			if InStr(optionsOrCallback, "U") {
				this := this.Unique()
			}

			return this
		}

	static _CustomSort(compareFunc, key?) {
		; Implementation of custom sort using bubble sort
		n := this.Length
		for i in Range(n - 1) {
			for j in Range(n - i - 1) {
				val1 := key ? this[j + 1][key] : this[j + 1]
				val2 := key ? this[j + 2][key] : this[j + 2]
				if (compareFunc(val1, val2) > 0) {
					; Swap elements
					temp := this[j + 1]
					this[j + 1] := this[j + 2]
					this[j + 2] := temp
				}
			}
		}
		return this
	}

	static _NumericSort(key?) {
		; Implement numeric sort
		return this._CustomSort((a, b) => (a > b) - (a < b), key)
	}

	static _CaseSensitiveSort(key?) {
		; Implement case-sensitive sort
		return this._CustomSort((a, b) => StrCompare(String(a), String(b)), key)
	}

	static _CaseInsensitiveSort(key?) {
		; Implement case-insensitive sort
		return this._CustomSort((a, b) => StrCompare(String(a), String(b), true), key)
	}

	static _RandomSort() {
		; Fisher-Yates shuffle
		n := this.Length
		while (n > 1) {
			k := Random(1, n)
			n--
			temp := this[n + 1]
			this[n + 1] := this[k]
			this[k] := temp
		}
		return this
	}

	; Helper functions for Sort method
    static CustomCompare(compareFunc, pFieldType1, pFieldType2) {
        this.ValueFromFieldType(pFieldType1, &fieldValue1)
        this.ValueFromFieldType(pFieldType2, &fieldValue2)
        return compareFunc(fieldValue1, fieldValue2)
    }

    static NumericCompare(pFieldType1, pFieldType2) {
        this.ValueFromFieldType(pFieldType1, &fieldValue1)
        this.ValueFromFieldType(pFieldType2, &fieldValue2)
        return (fieldValue1 > fieldValue2) - (fieldValue1 < fieldValue2)
    }

    static NumericCompareKey(key, pFieldType1, pFieldType2) {
        this.ValueFromFieldType(pFieldType1, &fieldValue1)
        this.ValueFromFieldType(pFieldType2, &fieldValue2)
        f1 := fieldValue1.HasProp("__Item") ? fieldValue1[key] : fieldValue1.%key%
        f2 := fieldValue2.HasProp("__Item") ? fieldValue2[key] : fieldValue2.%key%
        return (f1 > f2) - (f1 < f2)
    }

    static StringCompare(pFieldType1, pFieldType2, caseSense := False) {
        this.ValueFromFieldType(pFieldType1, &fieldValue1)
        this.ValueFromFieldType(pFieldType2, &fieldValue2)
        return StrCompare(fieldValue1 "", fieldValue2 "", caseSense)
    }

    static StringCompareKey(key, pFieldType1, pFieldType2, caseSense := False) {
        this.ValueFromFieldType(pFieldType1, &fieldValue1)
        this.ValueFromFieldType(pFieldType2, &fieldValue2)
        return StrCompare(fieldValue1.%key% "", fieldValue2.%key% "", caseSense)
    }

    static RandomCompare(pFieldType1, pFieldType2) {
        return Random(0, 1) ? 1 : -1
    }

    static ValueFromFieldType(pFieldType, &fieldValue?) {
        static SYM_STRING := 0, PURE_INTEGER := 1, PURE_FLOAT := 2
        static SYM_MISSING := 3, SYM_OBJECT := 5

        switch SymbolType := NumGet(pFieldType + 8, "Int") {
            case PURE_INTEGER:
                fieldValue := NumGet(pFieldType, "Int64")
            case PURE_FLOAT:
                fieldValue := NumGet(pFieldType, "Double")
            case SYM_STRING:
                fieldValue := StrGet(NumGet(pFieldType, "Ptr") + 2*A_PtrSize)
            case SYM_OBJECT:
                fieldValue := ObjFromPtrAddRef(NumGet(pFieldType, "Ptr"))
            case SYM_MISSING:
                return
        }
    }
}

#Requires AutoHotkey v2.0
#SingleInstance Force

class SymbolicLinkHandler {
    static Create(destinationPath, sourcePath, isDir := false) {
        ; Ensure paths are absolute and clean
        sourcePath := this.GetFullPath(sourcePath)
        destinationPath := this.GetFullPath(destinationPath)
        
        ; Check if destination directory exists
        destDir := RegExReplace(destinationPath, "\\[^\\]+$")
        if !DirExist(destDir) {
            try DirCreate(destDir)
            catch as e {
                return { success: false, error: "Cannot create destination directory: " e.Message }
            }
        }

        ; Check for and remove existing link/file
        if FileExist(destinationPath) {
            try {
                attributes := FileGetAttrib(destinationPath)
                if InStr(attributes, "L")  ; It's a symbolic link
                    RunWait('cmd.exe /c rmdir "' destinationPath '"',, "Hide")
                else
                    FileDelete(destinationPath)
            }
            catch as e {
                return { success: false, error: "Cannot remove existing file: " e.Message }
            }
        }

        ; Attempt to create symbolic link
        try {
            if this.HasAdminRights() {
                ; Direct method if we have admin rights
                result := DllCall("Kernel32.dll\CreateSymbolicLinkW", 
                    "Str", destinationPath, 
                    "Str", sourcePath, 
                    "UInt", isDir ? 1 : 0)
                if (result)
                    return { success: true }
            } else {
                ; Fallback to elevated CMD if we don't have admin rights
                command := 'cmd.exe /c mklink ' (isDir ? '/D ' : '') 
                    . '"' destinationPath '" "'
                    . sourcePath '"'
                RunWait(command,, "Hide")
                if FileExist(destinationPath)
                    return { success: true }
            }
        }
        catch as e {
            return { success: false, error: "Failed to create symbolic link: " e.Message }
        }

        return { success: false, error: "Unknown error creating symbolic link" }
    }

    static Remove(linkPath) {
        if !FileExist(linkPath)
            return { success: true }  ; Already gone

        try {
            attributes := FileGetAttrib(linkPath)
            if InStr(attributes, "L") {  ; It's a symbolic link
                RunWait('cmd.exe /c rmdir "' linkPath '"',, "Hide")
            } else {
                FileDelete(linkPath)
            }
            return { success: true }
        }
        catch as e {
            return { success: false, error: "Failed to remove link: " e.Message }
        }
    }

    static GetFullPath(path) {
        ; Convert relative path to absolute
        if (SubStr(path, 1, 1) = ".")
            path := A_WorkingDir "\" path
        return RegExReplace(path, "\\+", "\")  ; Clean up multiple backslashes
    }

    static HasAdminRights() {
        try {
            return DllCall("shell32\IsUserAnAdmin")
        }
        catch {
            return false
        }
    }

    static IsSymlink(path) {
        if !FileExist(path)
            return false
        try {
            attributes := FileGetAttrib(path)
            return InStr(attributes, "L")
        }
        catch {
            return false
        }
    }
}
