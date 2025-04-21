#Requires AutoHotkey v2.0+
#Include <Includes\Extensions>

/*
	Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Get.ahk
	Author: Nich-Cebolla
	Version: 1.0.0
	License: MIT
*/

/**
 * @class
 * @description - A namespace for functions that retrieve values from objects, arrays, or other data
 * structures.
 */
class Get {

	/**
	 * @class
	 * @description - A namespace for functions that retrieve values from object properties.
	 */
	class Prop {

		/**
		 * @descrition - Gets a property's value if it exists, else returns an empty string.
		 * @param {Object} Obj - The object from which to get the value.
		 * @param {String} Prop - The name of the property to access.
		 * @returns {*} - The value of the property if it exists, else an empty string.
		 */
		static Call(Obj, Prop) => HasProp(Obj, Prop) ? Obj.%Prop% : ''

		/**
		 * @descrition - If the property exists, the value is assigned to the `OutValue` parameter
		 * and the function returns 1. Else, the function returns an empty string.
		 * @param {Object} Obj - The object from which to get the value.
		 * @param {String} Prop - The name of the property to access.
		 * @param {VarRef} [OutValue] - A variable that will receive the value of the property if it
		 * exists.
		 * @returns {Boolean} - If the property exists, the function returns 1. Else, an empty string.
		 */
		static If(Obj, Prop, &OutValue?) => HasProp(Obj, Prop) ? (OutValue := Obj.%Prop% || 1) : ''

		/**
		 * @description - If the property exists, returns the value. Else, returns the default value.
		 * @param {Object} Obj - The object from which to get the value.
		 * @param {String} Prop - The name of the property to access.
		 * @param {*} Default - The default value to return if the property does not exist.
		 * @returns {*} - The value of the property if it exists, else the default value.
		 */
		static Or(Obj, Prop, Default) => HasProp(Obj, Prop) ? Obj.%Prop% : Default

		/**
		 * @description - Iterates a list of property names until a property exists on the input
		 * object, then returns that value. If none of the properties exist, and the `Default` parameter
		 * is set, this returns the `Default` value. Else, throws an error.
		 * @param {Object} Obj - The object from which to get the value.
		 * @param {String[]} Props - A list of property names to check for on the input object.
		 * @param {*} [Default] - The default value to return if none of the properties exist.
		 * @param {VarRef} [OutProp] - A variable that will receive the name of the property that was
		 * found on the object.
		 */
		static First(Obj, Props, Default?, &OutProp?) {
			for Prop in Props {
				if HasProp(Obj, Prop) {
					OutProp := Prop
					return Obj.%Prop%
				}
			}
			if IsSet(Default)
				return Default
			throw UnsetItemError('The object does not have a property from the list.', -1)
		}
	}

	/**
	 * @class
	 * @description - A namespace for functions that retrieve values from array objects.
	 */
	class Index {

		/**
		 * @description - Gets an index's value if it exists, else returns an empty string.
		 * @param {Array} Arr - The array from which to get the value.
		 * @param {Integer} Index - The index to access.
		 * @returns {*} - The value of the index if it exists, else an empty string.
		 */
		static Call(Arr, Index) => Arr.Has(Index) ? Arr[Index] : ''

		/**
		 * @description - If the index exists, the value is assigned to the `OutValue` parameter
		 * and the function returns 1. Else, the function returns an empty string.
		 * @param {Array} Arr - The array from which to get the value.
		 * @param {Integer} Index - The index to access.
		 * @param {VarRef} [OutValue] - A variable that will receive the value of the index if it
		 * exists.
		 * @returns {Boolean} - If the index exists, the function returns 1. Else, an empty string.
		 */
		static If(Arr, Index, &OutValue?) => Arr.Has(Index) ? (OutValue := Arr[Index] || 1) : ''

		/**
		 * @description - If the index exists, returns the value. Else, returns the default value.
		 * @param {Array} Arr - The array from which to get the value.
		 * @param {Integer} Index - The index to access.
		 * @param {*} Default - The default value to return if the index does not exist.
		 * @returns {*} - The value of the index if it exists, else the default value.
		 */
		static Or(Arr, Index, Default) => Arr.Has(Index) ? Arr[Index] : Default

		/**
		 * @description - Iterates a list of index values until the function accesses an index that
		 * contains a value, then returns that value. If none of the indices have a value, and the
		 * `Default` parameter is set, the function returns the `Default` value. Else, throws an error.
		 * @param {Array} Arr - The array from which to get the value.
		 * @param {Integer[]} Indices - A list of index values to check for in the input array.
		 * @param {*} [Default] - The default value to return if none of the indices have a value.
		 * @param {VarRef} [OutIndex] - A variable that will receive the index that was found in the
		 * array.
		 */
		static First(Arr, Indices, Default?, &OutIndex?) {
			for Index in Indices {
				if Arr.Has(Index) {
					OutIndex := Index
					return Arr[Index]
				}
			}
			if IsSet(Default)
				return Default
			throw UnsetItemError('The array does not have an item at any index from the list.', -1)
		}

		/**
		 * @description - Iterates a range of indices until the function accesses an index that
		 * contains a value, then returns that value. If no index in the range has a value, and the
		 * `Default` parameter is set, this returns the `Default` value. Else, throws an error.
		 * @param {Array} Arr - The array from which to get the value.
		 * @param {Integer} [Start=1] - The index to begin searching from.
		 * @param {Integer} [End] - The index to stop the search at. If unset, the search continues
		 * until reaching the beginning or end of the array.
		 * @param {Integer} [Step=1] - The amount to increment the index by after each iteration.
		 * @param {*} [Default] - The default value to return if none of the indices have a value.
		 * @param {VarRef} [OutIndex] - A variable that will receive the index that was found in the
		 * array.
		 */
		static Range(Arr, Start := 1, Length?, Step := 1, Default?, &OutIndex?) {
			if Step > 0 {
				if !IsSet(End)
					End := Arr.Length
				Condition := () => i >= End
			} else if Step < 0 {
				if !IsSet(End)
					End := 1
				Condition := () => i <= End
			} else {
				throw ValueError('``Step`` cannot be 0.', -1)
			}
			i := Start += Step * -1
			while !Condition() {
				i += Step
				if Arr.Has(i) {
					OutIndex := i
					return Arr[i]
				}
			}
			if IsSet(Default)
				return Default
			throw UnsetItemError('The array does not have an item at any index from the list.', -1)
		}
	}

	/**
	 * @class
	 * @description - A namespace for functions that retrieve values from map objects.
	 */
	class Key {

		/**
		 * @description - Gets a key's value if it exists, else returns an empty string.
		 * @param {Map} Obj - The map from which to get the value.
		 * @param {String} Key - The key to access.
		 * @returns {*} - The value of the key if it exists, else an empty string.
		 */
		static Call(Obj, Key) => Obj.Has(Key) ? Obj.Get(Key) : ''

		/**
		 * @description - If the key exists, the value is assigned to the `OutValue` parameter
		 * and the function returns 1. Else, the function returns an empty string.
		 * @param {Map} Obj - The map from which to get the value.
		 * @param {String} Key - The key to access.
		 * @param {VarRef} [OutValue] - A variable that will receive the value of the key if it
		 * exists.
		 * @returns {Boolean} - If the key exists, the function returns 1. Else, an empty string.
		 */
		static If(Obj, Key, &OutValue?) => Obj.Has(Key) ? (OutValue := Obj.Get(Key) || 1) : ''

		/**
		 * @description - If the key exists, returns the value. Else, returns the default value.
		 * @param {Map} Obj - The map from which to get the value.
		 * @param {String} Key - The key to access.
		 * @param {*} Default - The default value to return if the key does not exist.
		 * @returns {*} - The value of the key if it exists, else the default value.
		 */
		static Or(Obj, Key, Default) => Obj.Has(Key) ? Obj.Get(Key) : Default

		/**
		 * @description - Iterates a list of key names until a key exists on the input map, then
		 * returns that value. If none of the keys exist, and the `Default` parameter is set, this
		 * returns the `Default` value. Else, throws an error.
		 * @param {Map} Obj - The map from which to get the value.
		 * @param {String[]} Keys - A list of key names to check for on the input map.
		 * @param {*} [Default] - The default value to return if none of the keys exist.
		 * @param {VarRef} [OutKey] - A variable that will receive the name of the key that was found
		 * on the map.
		 */
		static First(Obj, Keys, Default?, &OutKey?) {
			for Key in Keys {
				if Obj.Has(Key) {
					OutKey := Key
					return Obj.Get(Key)
				}
			}
			if IsSet(Default)
				return Default
			throw UnsetItemError('The object does not have a key from the list.', -1)
		}
	}
}

; Modify Object prototype
; Object.Prototype.DefineProp("ToString", {Call: (this) => Object2.ToString(this)})
; Object.Prototype.DefineProp("Has", 		{Call: (this, key) => this.HasOwnProp(key)})
; Object.Prototype.DefineProp("Get", 		{Call: (this, key, default := "") => this.Has(key) ? this.%key% : default})
; Object.Prototype.DefineProp("ToArray", 	{Call: (this) => Object2.ToArray(this)})
; Object.Prototype.DefineProp("ToMap", 	{Call: (this) => Object2.ToMap(this)})

class Object2 extends Object {

	static __New() {

		; Add all Object2 methods to Object prototype
		for methodName in Object2.OwnProps() {
			if methodName != "__New" && HasMethod(Object2, methodName) {
				; Check if method already exists
				if Object.Prototype.HasOwnProp(methodName) {
					; Skip if method exists
					continue  
					; Or override:
					; Object.Prototype.DeleteProp(methodName)
				}
				Object.Prototype.DefineProp(methodName, {
					Call: Object2.%methodName%
				})
			}
		}
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
; class Object2 {
	
	/**
	 * @returns {Integer} The number of own properties in the object
	 */

	static Length => ObjOwnPropCount(this)

	/**
	 * @param {Integer} start Index to start from (default: 1)
	 * @param {Integer} end Index to end at (default: 0, meaning last element)
	 * @param {Integer} step Increment value (default: 1)
	 * @returns {Object} Modified object
	 */
	Slice(start := 1, end := 0, step := 1) {
		len := Object2.Length, i := (start < 1) ? len + start : start
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
	 * @description static version of Count
	 * @param {Any} value Value to count (can be a function)
	 * @returns {Integer} Number of occurrences
	 */
	static Count(value) {
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
}
