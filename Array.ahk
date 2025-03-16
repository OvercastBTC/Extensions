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
#Requires AutoHotkey v2.0+
#SingleInstance Force
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
; Array.Prototype.Base := JS_Array

; ---------------------------------------------------------------------------

Class Array2 {

	static __New() {
		; Add all Array2 methods to Array prototype
		for methodName in this.OwnProps() {
			if methodName != "__New" && HasMethod(this, methodName) {
				; Check if method already exists
				if Array.Prototype.HasOwnProp(methodName) {
					; Skip if method exists to avoid overwriting
					continue
				}
				; Add the method to Array.Prototype
				Array.Prototype.DefineProp(methodName, {
					Call: this.%methodName%
				})
			}
		}

		; Add all JS_Array methods to Array prototype
		for methodName in JS_Array.OwnProps() {
			if methodName != "__New" && HasMethod(JS_Array, methodName) {
				; Check if method already exists
				if Array.Prototype.HasOwnProp(methodName) {
					; Skip if method exists to avoid overwriting
					continue
				}
				; Add the method to Array.Prototype
				Array.Prototype.DefineProp(methodName, {
					Call: JS_Array.%methodName%
				})
			}
		}
		this.DefineProp('from', {call:__arr_from})
		this.DefineProp('of', {call:__arr_of})
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
	 * @name Unshift
	 * @description Enhanced unshift method that intelligently selects the most efficient implementation
	 * @param {Any} elements* - Elements to add to the beginning of the array
	 * @param {Object} options - Optional settings to control behavior:
	 *                         - method: "auto", "nonMutating", "jsStyle", or "optimized" 
	 *                         - preserveOriginal: When true, always uses nonMutating approach
	 * @returns {Integer} - The new length of the array
	 * @example
	 * arr := [1,2,3]
	 * arr.Unshift(0) ; adds 0 to beginning using best method 
	 * arr.Unshift(4, 5, {method: "jsStyle"}) ; forces JavaScript-style method
	 */
	static Unshift(params*) {
		
		; Extract elements and options
		elements := []
		methodSpecified := false

		; Is array empty?
		if (this.Length = 0 || params.length = 0){
			return this.Length
		}

		; Initialize default settings
		options := {
			method: "auto", 			; auto, WithPrepended, nonMutating, jsStyle, or optimized
			smallArrayThreshold: 10, 	; arrays smaller than this use non-mutating
			elementsThreshold: 3, 		; adding fewer elements than this uses JS style
			preserveOriginal: false 	; when true, always uses nonMutating
		}

		for param in params {
			if IsObject(param) && !param.HasProp("Length") {
				; This appears to be an options object
				for key, value in param.OwnProps() {
					if options.HasProp(key) {
						options.%key% := value
						if (key = "method")
							methodSpecified := true
					}
				}
			} else {
				; This is an element to unshift
				elements.Push(param)
			}
		}
		

		; Handle static call pattern
		if (elements.Length > 0 && Type(this) = "Class" && IsObject(elements[1]) && elements[1].HasProp("Length")) {
			arr := elements[1]
			elements.RemoveAt(1)
			; return this.Unshift(elements*)
			return this.Unshift(elements)
		}

		
		; Determine best method if auto
		if (!methodSpecified && options.method = "auto") {
			if (options.preserveOriginal) {
				options.method := "nonMutating"
			}
			else if (this.Length < options.smallArrayThreshold) {
				options.method := "nonMutating" ; Non-mutating is fastest for small arrays
			}
			else if (elements.Length < options.smallArrayThreshold) {
				options.method := "WithPrepended" ; Mutating version is typically second fastest for small arrays
			}
			else if (elements.Length <= options.elementsThreshold) {
				options.method := "jsStyle"     ; JS-style is good for few elements
			}
			else {
				options.method := "optimized"   ; Optimized for larger operations
			}
		}
		
		; Execute the selected method
		switch options.method {
			case "nonMutating":
				return this.nonMutatingUnshift(elements*)
			case "WithPrepended":
				return this.WithPrepended(elements*)
			case "jsStyle":
				return this.jsUnshift(elements*)
			case "optimized":
				return this.OptimizedUnshift(elements*)
			default: ; Fallback to optimized if invalid method
			return this.OptimizedUnshift(elements*)
				; return this.nonMutatingUnshift(elements*)
		}
	}

	/**
	 * @name nonMutatingUnshift
	 * @description Non-mutating implementation for unshift
	 * @param {Any} params* - Elements to add to the beginning of the array
	 * @returns {Integer} - The new length of the array 
	 */
	static nonMutatingUnshift(params*) {
		
		elements := []
		
		if Type(this) = 'Array' {
			params := elements
			return this.Unshift(elements*)
		}
		; Handle static call pattern
		if (elements.Length > 0 && Type(this) = "Class" && IsObject(elements[1]) && elements[1].HasProp("Length")) {
			arr := elements[1]
			elements.RemoveAt(1)
			return this.nonMutatingUnshift(arr, elements*)
		}

		result := []
		
		; Add new elements
		for element in elements {
			result.Push(element)
		}
		
		; Add original array elements
		for item in this {
			result.Push(item)
		}
		
		; Clear and repopulate the original array
		this.Length := 0
		for item in result {
			this.Push(item)
		}
		
		return this.Length
	}

	/**
	 * @name WithPrepended
	 * @description Non-mutating function that returns a new array with elements prepended
	 * @param {Array} params* - Elements to prepend to the array
	 * @returns {Array} - A new array with the elements prepended
	 * @example
	 * newArr := [1,2,3].WithPrepended(0) ; returns [0,1,2,3], original unchanged
	 */
	static withPrepended(params*) {

		elements := []
		
		; if Type(this) = 'Array' {
		; 	params := elements
		; 	return this.Unshift(elements*)
		; }

		; Handle static call pattern
		if (elements.Length > 0 && Type(this) = "Class" && IsObject(elements[1]) && elements[1].HasProp("Length")) {
			arr := elements[1]
			elements.RemoveAt(1)
			
			; Add new elements
			result := []
			for element in elements {
				result.Push(element)
			}
			
			; Add original array elements
			for item in arr {
				result.Push(item)
			}
			
			return result
		}
		
		; Create a new array for the result
		result := []
		
		; Add new elements
		for element in elements {
			result.Push(element)
		}
		
		; Add original array elements
		for item in this {
			result.Push(item)
		}
		
		; Return the new array
		return result
	}

	/**
	 * @name jsUnshift
	 * @description JavaScript-style implementation for unshift
	 * @param {Any} params* - Elements to add to the beginning of the array
	 * @returns {Integer} - The new length of the array
	 */
	static jsUnshift(params*) {

		elements := []
		
		; if Type(this) = 'Array' {
		; 	params := elements
		; 	return this.Unshift(elements*)
		; }
		
		; Handle empty case for performance
		if (elements.Length == 0) {
			return this.Length
		}
		
		; Handle static call pattern
		if (elements.Length > 0 && Type(this) = "Class" && IsObject(elements[1]) && elements[1].HasProp("Length")) {
			arr := elements[1]
			elements.RemoveAt(1)
			return this.jsUnshift(arr, elements*)
		}

		; Track original length
		originalLength := this.Length
		
		; Pre-allocate space to avoid index errors
		Loop elements.Length {
			this.Push("")  ; Add placeholder items at the end
		}
		
		; Loop from the end to avoid overwriting
		i := originalLength
		while (i > 0) {
			this[i + elements.Length] := this[i]
			i--
		}
		
		; Insert new elements
		for i, element in elements {
			this[i] := element
		}
		
		; Return the new length
		return this.Length
	}

	/**
	 * @name OptimizedUnshift
	 * @description Optimized implementation that uses different strategies based on input size
	 * @param {Any} params* - Elements to add to the beginning of the array
	 * @returns {Integer} - The new length of the array
	 */
	static OptimizedUnshift(params*) {
		
		elements := []
		
		; if Type(this) = 'Array' {
		; 	params := elements
		; 	return this.Unshift(elements*)
		; }
		
		; Early return if no elements
		if (elements.Length == 0){
			return this.Length
		}

		; Handle static call pattern
		if (elements.Length > 0 && Type(this) = "Class" && IsObject(elements[1]) && elements[1].HasProp("Length")) {
			arr := elements[1]
			elements.RemoveAt(1)
			return this.OptimizedUnshift(arr, elements*)
		}

		; For small amounts of elements, use optimized in-place approach
		if (elements.Length <= 3) {
			; Save original length
			originalLength := this.Length
			
			; Pre-allocate space to avoid index errors
			Loop elements.Length {
				this.Push("") ; Add placeholders
			}
			
			; Move elements from end to beginning
			i := originalLength
			while (i > 0) {
				this[i + elements.Length] := this[i]
				i--
			}
			
			; Add new elements at the beginning
			for i, element in elements {
				this[i] := element
			}
		} else {
			; For larger element sets, use safer non-mutating approach
			result := []
			
			; Add new elements first
			for element in elements {
				result.Push(element)
			}
			
			; Add original elements
			for item in this {
				result.Push(item)
			}
			
			; Clear and repopulate
			this.Length := 0
			for item in result {
				this.Push(item)
			}
		}
		
		; Return new length
		return this.Length
	}

	/**
	 * @name Array_Unshift
	 * @description Static function version for working with arbitrary arrays
	 * @param {Array} arr - The array to modify
	 * @param {Any} elements* - Elements to add to the beginning
	 * @param {Object} options - Optional settings (same as Unshift method)
	 * @returns {Integer} - The new length of the array
	 */
	static Array_Unshift(arr, params*) {
		if (!IsObject(arr) || !arr.HasProp("Length")) {
			throw ValueError("Array_Unshift: First argument must be an array", -1)
		}
		
		return arr.Unshift(params*)
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
		if !HasMethod(func) {
			throw ValueError("Reduce: func must be a function", -1)
		}
		len := this.Length + 1
		if len = 1 {
			return initialValue ?? ""
		}
		if IsSet(initialValue) {
			out := initialValue, i := 0
		}
		else {
			out := this[1], i := 1
		}
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
			if !HasMethod(enum, "__Enum") {
				throw ValueError("Extend: arr must be an iterable")
			}
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
		for v in this {
			unique[v] := 1
		}
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

	/**
	 * @name Sort
	 * @description Sorts an array with support for custom comparison functions
	 * @param {Function|String} optionsOrCallback - Optional callback function or sorting options
	 * @param {String} key - Optional key for sorting object arrays
	 * @returns {Array} - The sorted array
	 * @example arr.Sort("N")  ; Sort numerically
	 * @example arr.Sort((a, b) => a.value - b.value)  ; Custom sort using callback
	 */
	static Sort(optionsOrCallback := "N", key?) {
		if !this.Length   ; Handle empty array case
			return this

		; If using a custom comparison function
		if HasMethod(optionsOrCallback) {
			; Fix: Ensure key is properly passed, even if undefined
			return this._CustomSort(optionsOrCallback, IsSet(key) ? key : unset)
		}

		; For standard sorting options
		if InStr(optionsOrCallback, "N") {
			return this._NumericSort(IsSet(key) ? key : unset)
		}
		else if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn") {
			return this._CaseSensitiveSort(IsSet(key) ? key : unset)
		}
		else if RegExMatch(optionsOrCallback, "i)C0|COff") {
			return this._CaseInsensitiveSort(IsSet(key) ? key : unset)
		}
		else if InStr(optionsOrCallback, "Random") {
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

	/**
	 * @name _CustomSort
	 * @description Internal method to sort with a custom comparison function
	 * @param {Function} compareFunc - The comparison function
	 * @param {String} key - Optional key for sorting object arrays
	 * @returns {Array} - The sorted array
	 * @private
	 */
	static _CustomSort(compareFunc, key?) {
		; Implementation of custom sort using bubble sort
		n := this.Length
		for i in Range(n - 1) {
			for j in Range(n - i - 1) {
				; Fix: Properly handle the key parameter when it's set or not
				if IsSet(key) {
					val1 := this[j + 1][key]
					val2 := this[j + 2][key]
				} else {
					val1 := this[j + 1]
					val2 := this[j + 2]
				}
				
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

	/**
	 * @name _NumericSort
	 * @description Internal method to sort numerically
	 * @param {String} key - Optional key for sorting object arrays
	 * @returns {Array} - The sorted array
	 * @private
	 */
	static _NumericSort(key?) {
		; Implement numeric sort
		return this._CustomSort((a, b) => (a > b) - (a < b), IsSet(key) ? key : unset)
	}

	/**
	 * @name _CaseSensitiveSort
	 * @description Internal method to sort with case sensitivity
	 * @param {String} key - Optional key for sorting object arrays
	 * @returns {Array} - The sorted array
	 * @private
	 */
	static _CaseInsensitiveSort(key?) {
		; Implement case-insensitive sort
		return this._CustomSort((a, b) => StrCompare(String(a), String(b), true), IsSet(key) ? key : unset)
	}

	/**
	 * @name _CaseSensitiveSort
	 * @description Internal method to sort with case sensitivity
	 * @param {String} key - Optional key for sorting object arrays
	 * @returns {Array} - The sorted array
	 * @private
	 */
	static _CaseSensitiveSort(key?) {
		; Implement case-sensitive sort
		return this._CustomSort((a, b) => StrCompare(String(a), String(b)), IsSet(key) ? key : unset)
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

/************************************************************************
 * @description JavaScript array methods for AHK
 * @file Array.ahk
 * @author Laser Made
 * @date 3/11/2025
 * @version 1.2
 ***********************************************************************/

;JS_Array.Prototype.base := Array2
; Array.Prototype.base := JS_Array
Array.DefineProp('from', {call:__arr_from})
Array.DefineProp('of', {call:__arr_of})

class JS_Array {
	; static __New() {
	;     __ObjDefineProp := Object.Prototype.DefineProp
	;     /*__ObjDefineProp(Array.Prototype, "from", {get:(args*)=> JS_Array.from(args*)})*/
	; }
	static __New() {
		; Add all Array2 methods to Array prototype
		for methodName in this.OwnProps() {
			if methodName != "__New" && HasMethod(this, methodName) {
				; Check if method already exists
				if Array.Prototype.HasOwnProp(methodName) {
					; Skip if method exists to avoid overwriting
					continue
				}
				; Add the method to Array.Prototype
				Array.Prototype.DefineProp(methodName, {
					Call: this.%methodName%
				})
			}
		}
	}
	;static length => this.length

	/*Static Methods*/

	/**
	 * Is it possible to implement Async functions (like this) in AHK?
	 */
	static fromAsync() => this._unimplemented()

	;@returns {Boolean}
	static isArray() => (this is Array)

	/*Instance Methods*/
	/**
	 * @param index - The index of the element to retrieve (can be negative to start from the end of the array)
	 * {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/at|MDN - at()}
	 */
	static at(index) => this[index < 0 ? index + this.length : index] 

	;static push(items*) => this.push(items*)

	/**
	 * @param values - The items to add to the end of the array
	 * @returns {Array} a shallow copy of the existing array on which it is called plus any included parameters as new values
	 * {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/concat|MDN - concat()}
	 */
	static concat(arr*) {
		return this.push(arr*)
	}

	/**
	 * @param target Zero-based index at which to copy the sequence to, converted to an integer. This corresponds to where the element at start will be copied to, and all elements between start and end are copied to succeeding indices.
	 * @param start Zero-based index at which to start copying elements from, converted to an integer.
	 * @param {Any} end Zero-based index at which to end copying elements from, converted to an integer. copyWithin() copies up to but not including end.
	 * @returns {Array} this - The modified array.
	 * {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/copyWithin|MDN - copyWithin()}
	 */
	static copyWithin(target, start, end := this.length) {
		result := this
		copyValue := this[Number(target)]
		for index, value in this {
			if index >= Number(start) && index <= end {
				result[index] := copyValue
			}
		}
		this := result
		return this
	}
	/**
	 * @description functionally similar but not exactly the same as Array.entries() in JavaScript due to the lack of an iterator object in AHK
	 * @returns {Array} Containing an array of key-value pairs for each index in the original array
	 * {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/entries|MDN - entries()}
	 */
	static entries() {
		result := []
		for index, value in this {
			result.push([index, value])
		}
		return result
	}
	/**
	 * @description instances tests whether all elements in the array pass the test implemented by the provided function. It returns a Boolean value.
	 * @param callbackFn A function to execute for each element in the array. It should return a truthy value to indicate the element passes the test, and a falsy value otherwise
	 * @returns {Boolean} true if every element satisfies the condition, else false
	 */
	static every(callbackFn) {
		if (!HasMethod(callbackFn))
			throw ValueError("Every: func must be a function", -1)
		for value in this {
			if !callbackFn(value)
				return false
		}
		return true
	}
	/**
	 * @param insert Value to fill the array with. Note all elements in the array will be this exact value
	 * @param {Integer} start [optional] One-based index at which to start filling
	 * @param {Any} end One-based index at which to end filling, converted to an integer. fill() fills up to but not including end
	 * @returns {Array} The modified array, filled with the value of the parameter insert
	 */
	static fill(insert, start := 1, end := this.length) {
		for index, value in this {
			if index >= start && index < end {
				this[index] := insert
			}
		}
		return this
	}

	/**
	 * @description  instances creates a shallow copy of a portion of a given array, filtered down to just the elements from the given array that pass the test implemented by the provided function.
	 * @param function A function to execute for each element in the array. It should return a truthy value to keep the element in the resulting array, and a falsy value otherwise.
	 * @returns {Array} 
	 */
	static filter(function) {
		result := []
		for index, value in this {
			try {
				if function(value, index) {
					result.push(value)
				}
			} catch {
				if function(value) {
					result.push(value)
				}
			}
		}
		return result    
	}

	/**
	 * @param function A conditional function or expression.
	 * @param start Optional: the index to start the search from. Default is 1.
	 * @returns the first element in the provided array that satisfies the provided conditional function.
	 * If no values satisfy the testing function, 0 is returned.
	 * @example
	 * [1,2,3,4].Find(item => (Mod(item, 3) == 0)) ; returns 3
	 */
	static find(function, start := 1) {
		for index, value in this {
			if index >= start && function(value) {
				return value
			}
		}
		return 0
	}
	/**
	 * @param function A conditional function or expression.
	 * @returns the index of the first element in an array that satisfies the provided conditional function.
	 * If no elements satisfy the testing function, 0 is returned.
	 */
	static findIndex(function) {
		for index, value in this {
			if function(value) {
				return index
			}
		}
		return 0
	}

	/**
	 * @param function A conditional function or expression.
	 * @returns the last element in the provided array that satisfies the provided conditional function, 
	 * If no values satisfy the testing function, 0 is returned.
	 * @example
	 * [1,2,3,4].Find(item => (Mod(item, 3) == 0)) ; returns 3
	 */
	static findLast(function) {
		index := 0
		while (index > 0) {
			value := this[index]
			if function(value) {
				return value
			}
			index--            
		}
		return 0
/*         found := ''
		for index, value in this {
			if function(value) {
				found := value
			}
		}
		return found == '' ? 0 : found */
	}
	
	/**
	 * @description iterates the array in reverse order and returns the index of the first element that satisfies the provided testing function. If no elements satisfy the testing function, 0 is returned.
	 * @param function A function to execute for each element in the array. It should return a truthy value to indicate a matching element has been found, and a falsy value otherwise. The function is called with the following arguments:
	 * @example
	 * [1,3,2,3].findLastIndex(item => (Mod(item, 3) == 0)) ; returns 4
	 */
	static findLastIndex(function) {
		index := this.length
		while (index > 0) {
			if function(this[index]) {
				return index
			}
			index--
		}
		return 0
	}

	/**
	 * @description creates a new array with all sub-array elements concatenated into it recursively up to the specified depth.
	 * @param {Integer} depth The depth level specifying how deep a nested array structure should be flattened. Defaults to 1.
	 * @returns {Array} A new array with the sub-array elements concatenated into it.
	 */
	static flat(depth := 1) {
		result := []
		depth--
		for index, value in this {
			(value is Array) ? result.push(value*) : result.push(value)
		}
		return depth == 0 ? result : result.flat(depth) 
	}

	;same as calling this.map(callbackFn).flat()
	static flatMap(function) => this.map(function).flat()

	/**
	 * Applies a function to each element in the array.
	 * @param function The callback function with arguments:
	 * Callback(value)
	 * OR
	 * Callback(index, value)
	 * @returns {Array} this
	 */
	static forEach(function) {
		if !HasMethod(func)
			throw ValueError("forEach: parameter must be a function", -1)
		for index, value in this
			function(value, index?)
		return this 
	}

	/**
	 * @param function A conditional function or expression.
	 * @param start Optional: the index to start the search from. Default is 1.
	 * @returns the first element in the provided array that satisfies the provided conditional function.
	 * If no values satisfy the testing function, 0 is returned.
	 * @example
	 * [1,2,3,4].includes(item => (Mod(item, 3) == 0)) ; returns true
	 */
	static includes(search, start := 1) {
		for index, value in this {
			if index >= start && value == search {
				return true
			}
		}
		return false
	}

	/**
	 * @author Descolada
	 * Finds a value in the array and returns its index.
	 * @param value The value to search for.
	 * @param start Optional: the index to start the search from. Default is 1.
	 */
	indexOf(value, start:=1) {
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
	 * @description creates and returns a new string by concatenating all of the elements in this array, separated by commas or a specified separator string. If the array has only one item, then that item will be returned without using the separator.
	 * @param delimiter A string to separate each pair of adjacent elements of the array. If omitted, the array elements are separated with a comma (",").
	 * @returns {String} concatenated string of all values in the array, each separated by `delimeter`
	 */
	static JS_Join(delimiter := ',') {
		str := ''
		for index, value in this {
			str := str . value . (index = this.length ? '' : delimiter)
		}
		return str
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
	 * 
	 * @returns {Array} returns a new array ~iterator object~ that contains the keys for each index in the array.
	 */
	static keys() {
		result := []
		for index, value in this
			result.push(index)
		return result
	}

	/**
	 * @param searchElement Element to locate in the array.
	 * @param {Integer[optional]} fromIndex One-based index at which to start searching backwards, converted to an integer.
	 * @returns instances returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at fromIndex.
	 */
	static lastIndexOf(searchElement, fromIndex := this.length) {
		while (fromIndex > 0) {
			if this[fromIndex] = searchElement {
				return fromIndex
			}
			fromIndex--
		}
		return 0
	}

	/**
	 * @author Descolada
	 * @description Applies a function to each element in the array (mutates the array).
	 * @param func The mapping function that accepts one argument.
	 * @param arrays Additional arrays to be accepted in the mapping function
	 * @returns {Array} A new array with each element being the result of the callback function.
	 */
	static map(func, arrays*) {
		if !HasMethod(func)
			throw ValueError("Map: func must be a function", -1)
		for i, v in this {
			boundfunc := func.Bind(v?)
			for _, vv in arrays
				boundfunc := boundfunc.Bind(vv.Has(i) ? vv[i] : unset)
			try boundfunc := boundfunc()
			this[i] := boundfunc
		}
		return this
	}

	/**
	 * @author Descolada
	 * Applies a function cumulatively to all the values in the array, with an optional initial value.
	 * @param func The function that accepts two arguments and returns one value
	 * @param initialValue Optional: the starting value. If omitted, the first value in the array is used.
	 * @returns {func return type}
	 * @example
	 * [1,2,3,4,5].Reduce((a,b) => (a+b)) ; returns 15 (the sum of all the numbers)
	 */
	static reduce(func, initialValue?) {
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

	static reduceRight(function, initialValue?) => this.reverse().reduce(function, initialValue?)
	
	/**
	 * @author Descolada
	 * Reverses the array.
	 * @example
	 * [1,2,3].Reverse() ; returns [3,2,1]
	 */
	static reverse() {
		len := this.Length + 1, max := (len // 2), i := 0
		while ++i <= max
			this.swap(i, len - i)
		return this
	}

	/**
	 * @description Shifts all values to the left by 1 and decrements the length by 1, resulting in the first element being removed. This method mutates the original array. If the length property is 0, undefined is returned.
	 * @returns {Array} 
	 */
	static shift() {
		newArray := []
		for index, value in this {
			if index = 1
				continue
			newArray.push(value)
		}
		this := newArray
		return newArray
	}

	/**
	 * @author Descolada
	 * @returns a section of the array from 'start' to 'end', optionally skipping elements with 'step'.
	 * @description Modifies the original array.
	 * @param start Optional: index to start from. Default is 1.
	 * @param end Optional: index to end at. Can be negative. Default is 0 (includes the last element).
	 * @param step Optional: an integer specifying the incrementation. Default is 1.
	 * @returns {Array}
	 */
	static slice(start:=1, end:=0, step:=1) {
		len := this.length, i := start < 1 ? len + start : start, j := Min(end < 1 ? len + end : end, len), r := [], reverse := False
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

	static some(function) {
		for value in this {
			if function(value)
				return true
		}
		return false
	}

	/**
	 * @author Descolada
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
	static sort(optionsOrCallback:="N", key?) {
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
			this.reverse()
		if InStr(optionsOrCallback, "U")
			this := Unique(this)
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
		Unique(arr) {
			u := Map()
			for v in this
				u[v] := 1
			return [u*]
		}
	}

	/**
	 * @description changes the contents of an array by removing or replacing existing elements and/or adding new elements in place.
	 * @param start One-based index at which to start changing the array, converted to an integer.
	 * @param deleteCount An integer indicating the number of elements in the array to remove from `start`
	 * @param items The elements to add to the array, beginning from start
	 * @returns {Array} An array containing the deleted elements (or an empty array)
	 */
	static splice(start, deleteCount := this.length - start, items*) {
		start := Number(start)
		if -this.length <= start && start < 1
			start += this.length
		else if start < -this.length
			start := 1
		removed := this.remove(start, deleteCount)
		for i,v in items {
			this.InsertAt(start + i - 1, v)
		}       
		return removed
	}

	static toReversed() {
		result := this
		max := ((result.length + 1) // 2)
		index := 0
		while ++index <= max
			result.swap(index, result.Length + 1 - index)
		return result
	}

	static toSorted(options?, key?) {
		result := this
		return result.sort(options?, key?)

	}

	static toSpliced(start, deleteCount := this.length - start, items*) {
		result := this

		if -result.length <= start && start < 1
			start += result.length
		else if start < -result.length
			start := 1
		result.RemoveAt(start, deleteCount)
		for i,v in items {
			result.InsertAt(start + i - 1, v)
		}       
		return result
	}

	; static toString() => this.join()
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

	static unshift(elements*) {
		
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



		/* result := []
		itemArr := Array(items*)
		other := Array(this*)
		result.push(itemArr*)
		result.push(other*)
		MsgBox('result:' result.join())
		this := result
		MsgBox('this:' this.join())
		return this.length */

/*         result := []
		for item in items {
			result.push(item)
		}
		for thing in this {
			result.push(thing)
		}
		MsgBox('this(1): ' this.join())
		this := result
		MsgBox('this(2): ' this.join())
		return result */
		;return this.length


/*         result := [items*]
		result.push(this*)
		this := result
		return this */

	static values() {
		result := []
		for v in this
			result.push(v)
		return result
	}

	static with(index, value) {
		if index >= this.length or index < (this.length * -1)
			throw IndexError('Index out of range')
		result := this
		result[index] := value
		return result
	}

	/*Non JavaScript Methods*/
	/**
	 * @description removes `count` items from an array starting from `start`
	 * @param {Integer} start One-based index to start removing items from the array
	 * @param {Integer} count An integer indicating the number of elements in the array to remove.
	 * @returns {Number | Array} returns the item removed (1) or an array of length equal to `count` containing the items removed
	 */
	static remove(start := 1, count := 1) {
		removed := []
		for i,v in this {
			if i >= start && count > 0 {
				removed.push(this.RemoveAt(start))
				count--
			}
		}
		return removed.length = 1 ? removed[1] : removed
	}

	/**
	 * @author Descolada
	 * Swaps elements at indexes a and b
	 * @param a First elements index to swap
	 * @param b Second elements index to swap
	 * @returns {Array}
	 */
	static swap(a, b) {
		temp := this[b]
		this[b] := this[a]
		this[a] := temp
		return this
	}

	/**
	 * @author Descolada
	 * Counts the number of occurrences of a value
	 * @param value The value to count. Can also be a function.
	 */
	static count(value) {
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

	static _unimplemented() {
		MsgBox('This functionality is not yet implemented.')
	}
}

__arr_of(this, args*) => [args*]

/**
 * @author GroggyOtter
 * @date 3/5/2025
 * @param {Object} this - Standard self-refrence from call descriptor
 * @param {Object} iterable - An iterable object.  
 *        Something that has an __Enum() method
 *        Or an object set up to act as an enumerator
 * @param {Func} [update_fn] - Function to update values each iteration.  
 *        The returned value is what is stored in the array.  
 *        Callback requires 2 parameters:  
 * 
 * * `Value` : The value of the current element.  
 * * `Index` : The current index of the element being processed.  
 * * `obj`   : Optional. If callback has a 3rd parameter, a reference  
 *   to the iterable object is included.
 * 
 *       ; update_fn callback format
 *       updater(value, index [, obj]) {
 *           ; Code here
 *           return 'some value'
 *       }
 * @example
 * arr := [1,2,3,4,5]
 * newArr := Array.from(arr, (value, index) => value * 2)
 * Peep(newArr) => [2,4,6,8,10]
 */
__arr_from(this, iterable, update_fn:=0) {
	local arr := []
		, max_params := 0
		, include_iterable := 0

	if (update_fn is Func) {                                                                        ; Verify function
		max_params := update_fn.MaxParams                                                           ; Check max params
		if (max_params < 2)                                                                         ; Error detection
			throw Error(1, A_ThisFunc, 'Parameters: ' max_params)
	}
	if (max_params > 2)                                                                             ; If at least 3 params
		include_iterable := 1                                                                       ;   Include object

	switch {                                                                                        ; Check iterable type
		case (iterable is String):                                                                  ;   Case: string (array of characters)
			loop parse iterable                                                                     ;     Parse through string
				arr.Push(process(A_LoopField, A_Index))                                             ;       Process and add item to array

		case (iterable.HasProp('__Enum') || iterable is Enumerator):                                ;   Case: Enumerable or an enumerator
			for index, value in iterable                                                            ;     For-loop through item
				;value := value ?? '<UNSET>'
				arr.Push(process(value?, index?))                                                   ;       Process and add item to array


		case iterable.HasProp('Length'):                                                            ;   Case: is object with length property
			subarr := []
			try loop iterable.Length                                                                ;     Try Iterate through it using the length
				value := iterable.%A_Index%
				,subarr.Push(process(value?, A_Index?))                                             ;       Process and add items to subarray
			Catch {                                                                                 ;     Catch try error
				subarr := []                                                                        ;       Reset subarr
				if iterable.HasMethod('OwnProps')                                                   ;       If OwnProps() Exists
					for key, value in iterable.OwnProps()                                           ;         Loop through the items
						subarr.Push(process(value?, key?))                                          ;           Add to subarray
				else err(2, A_ThisFunc, 'Type: ' Type(iterable))
			}
			if subarr.Length                                                                        ;     If any items added to subarray
				arr.Push(subarr*)                                                                   ;       Spread to the main array
		default: err(2, A_ThisFunc, 'Type: ' Type(iterable))                                        ;   Error if anything else
	}
	return arr

	err(msg_num, fn, extra?) {
		switch msg_num {
			case 1: msg := 'Invalid callback. The update_fn() function must accept at least 2 params.'
			case 2: msg := 'Iterable is not enumerable.'
				. '`nExpected: String, .__Enum() method, Enumerator, '
				. '.Length property, or OwnProps() method'
		}
		throw Error(msg, fn, extra ?? unset)
	}

	process(v?, i?) {                                                                               ; Processes each iteration's values
		if update_fn                                                                                ; if update func was provided
			if include_iterable                                                                     ;   if at least 3 params
				v := update_fn(v, i, iterable)                                                      ;     run updater w/ iterable and return
			else v := update_fn(v, i)                                                               ;   else run updater w/o iterable and return
		return v ?? '<UNSET>'                                                                       ; else return original value
	}
}


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

/**
 * @name UnshiftBenchmark
 * @description Perform performance comparison of different unshift implementations
 * @author OvercastBTC
 * @date 2025.03.15
 * @version 1.0.5
 */

class UnshiftBenchmark {
	/**
	 * @description Run benchmarks on different unshift implementations
	 * @param {Integer} iterations Number of benchmark iterations
	 * @param {Integer} arraySize Size of test array
	 * @param {Integer} elementsToAdd Number of elements to add in each unshift
	 * @returns {Object} Benchmark results
	 */
	static Run(iterations := 1000, arraySize := 100, elementsToAdd := 3) {
		results := Map()
		elements := template := []
		trayNotify(Type(this) ' ' A_ThisFunc, 'Benchmark started.')

		; Setup test array template
		Loop arraySize {
			template.Push(A_Index)
		}

		; Setup elements to add
		Loop elementsToAdd {
			elements.Push("new" A_Index)
		}

		; Benchmark current implementation
		results['Current Implementation'] := {
			time: 0,
			method: 'Current Implementation'
		}
		startTime := A_TickCount
		Loop iterations {
			arr := template.Clone()
			arr.Unshift(elements*)
		}
		results['Current Implementation'].time := A_TickCount - startTime

		; Benchmark JavaScript-style implementation
		results['JavaScript-Style'] := {
			time: 0,
			method: 'JavaScript-Style'
		}
		startTime := A_TickCount
		Loop iterations {
			arr := template.Clone()
			this.jsUnshift(arr, elements*)
		}
		results["JavaScript-Style"].time := A_TickCount - startTime

		; Benchmark WithPrepended implementation
		results['WithPrepended'] := {
			time: 0,
			method: 'WithPrepended'
		}
		startTime := A_TickCount
		Loop iterations {
			arr := template.Clone()
			arr := this.WithPrepended(arr, elements*)
		}
		results['WithPrepended'].time := A_TickCount - startTime

		; Benchmark non-mutating implementation
		results['Non-Mutating'] := {
			time: 0,
			method: 'Non-Mutating'
		}
		startTime := A_TickCount
		Loop iterations {
			arr := template.Clone()
			arr := this.nonMutatingUnshift(arr, elements*)
		}
		results['Non-Mutating'].time := A_TickCount - startTime

		; Benchmark optimized implementation
		results['Optimized'] := {
			time: 0,
			method: 'Optimized'
		}
		startTime := A_TickCount
		Loop iterations {
			arr := template.Clone()
			this.optimizedUnshift(arr, elements*)
		}
		results['Optimized'].time := A_TickCount - startTime

		; Format and display results
		output := "Unshift Performance Benchmark`n"
		output .= "===========================`n"
		output .= Format("Test Configuration: {} iterations, array size {}, adding {} elements`n`n",
						iterations, arraySize, elementsToAdd)

		; Find the fastest method for highlighting
		fastest := ""
		fastestTime := 999999
		for method, result in results {
			if (result.time < fastestTime) {
				fastestTime := result.time
				fastest := method
			}
		}

		; Display results ordered by performance
		sortedResults := []
		for method, result in results {
			sortedResults.Push(result)
		}

		; Sort array by time (fastest first)
		sortedResults.Sort((a, b) => a.time - b.time)

		; Output formatted results
		for i, result in sortedResults {
			highlight := result.method == fastest ? " ← FASTEST" : ""
			output .= Format("{}: {}ms{}`n", result.method, result.time, highlight)
		}

		; Display and return results
		MsgBox(output)
		return results
	}
	
	/**
	 * @description JavaScript-style unshift implementation for benchmark (FIXED)
	 * @param {Array} arr Array to modify
	 * @param {Array} elements* Elements to add
	 * @returns {Integer} New array length
	 */
	static jsUnshift(arr, elements*) {
		; arr := Array()
		arr.jsUnshift(arr, elements*)
	}
	
	/**
	 * @description Mutating unshift implementation
	 * @param {Array} arr Original array
	 * @param {Array} elements* Elements to prepend
	 * @returns {Array} New array with elements prepended
	 */    
	static WithPrepended(arr, elements*) {
		; arr := Array()
		arr.WithPrepended(arr, elements*)
	}
	
	/**
	 * @description Non-mutating unshift implementation
	 * @param {Array} arr Original array
	 * @param {Array} elements* Elements to prepend
	 * @returns {Array} New array with elements prepended
	 */    
	static nonMutatingUnshift(arr, elements*) => arr.nonMutatingUnshift(arr, elements*)
	; static nonMutatingUnshift(arr, elements*) {
	; 	; arr := Array()
	; 	arr.nonMutatingUnshift(arr, elements*)
	; }

	/**
	 * @description Optimized unshift implementation (FIXED)
	 * @param {Array} arr Array to modify
	 * @param {Array} elements* Elements to add
	 * @returns {Integer} New array length
	 */
	static optimizedUnshift(arr, elements*) {
		arr := Array()
		Array2.optimizedUnshift(arr, elements*)
	}
}

:X?*C1:p.test::UnshiftBenchmark.Run(1000, 1000, 5000)
; :X?*C1:p.test::{
	; ; Test the implementation
	; months := ["April", "May", "June", "July"]
	; months.unshift("Jan", "Feb", "Mar")

	; mon_tostring := months.ToString()
	; mon_join := months.Join()
	; mon .= 'months_tostring:`n' mon_tostring
	; mon .= '`n'
	; mon .= 'months_join:`n' mon_join
	; x := months.Length

	; infos(
	; 	'[months]`n'
	; 	mon
	; 	'`n'
	; 	'# of months: ' x)
	; Run the benchmark with default settings
	; UnshiftBenchmark.Run()

	; For more detailed comparison with larger arrays
; 	UnshiftBenchmark.Run(1000, 1000, 5000)
; }
