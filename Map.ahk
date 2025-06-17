/*
	Name: Map.ahk
	Version 0.1 (05.09.23)
	Created: 05.09.23
	Author: Descolada

	Description:
	A compilation of useful Map methods.

    Map.Keys                              	=> All keys of the map in an array
    Map.Values                            	=> All values of the map in an array
    Map.Map(func, enums*)                 	=> Applies a function to each element in the map.
    Map.ForEach(func)                     	=> Calls a function for each element in the map.
    Map.Filter(func)                      	=> Keeps only key-value pairs that satisfy the provided function
    Map.Reduce(func, initialValue?)       	=> Applies a function cumulatively to all the values in 
        the array, with an optional initial value.
    Map.Find(func, &match?, start:=1)     	=> Finds a value satisfying the provided function and returns the index.
        match will be set to the found value. 
    Map.Count(value)                      	=> Counts the number of occurrences of a value.
    Map.Merge(enums*)                     	=> Adds the contents of other maps/enumerables to this map
*/
/**
	Version 0.1 (2024.07.08)
	Created 2024.07.08
	Authors: OvercastBTC, Laser_Made => converted to class => original functions from Axlefublr

	Map.SafeSet(key, value)					=> Sets a key-value pair ONLY if it doesn't already exist
	Map.SafeSetMap(mapObj)					=> Same as Map.SafeSet() but for a whole Map
	Map.Reverse()							=> reverse to value-key pair
	Map.Choose()							=> Chooses a key-value pair, and uses the class Infos to display, maybe other too
	Map._ChooseMap()						=> Chooses a Map from a Array of Maps, and then uses/calls Map.Choose()
	Map.ToString(delim := ',')				=> Converts a Map to a string
	Map._MapHasValue(valueToFind)			=> finds if a value is in a map => Same intent as Map.Find() above
	Map._MapHaskey(keyToFind)				=> finds if a key is in a map
 */


Map.Prototype.base := Map2

class Map2 {

	/**
     * @description Get a property value using dot notation
     * @param {String} key The property name
     * @returns {Any} The corresponding value or empty string if not found
     */
	__Get(key) {
		if this.HasKey(key)
			return this[key]
		return ""
	}

	/**
     * @description Set a property value using dot notation
     * @param {String} key The property name
     * @param {Any} value The value to set
     * @returns {Any} The set value
     */
	__Set(key, value) {
		return this[key] := value
	}

	Has(keyvalue) {
		If this.HasKey(keyvalue) {
			return true
		}
		else if this.HasValue(keyvalue) {
			return true
		}
		else if this.HasOwnProp(keyvalue) {
			return true
		}
		else {
			return false
		}
	}

	static Has(keyvalue) {
		If this.HasKey(keyvalue) {
			return true
		}
		else if this.HasValue(keyvalue) {
			return true
		}
		else if this.HasOwnProp(keyvalue) {
			return true
		}
		else {
			return false
		}
	}

	/**
	 * @description Get the length of the map
	 * @returns {Number} The number of key-value pairs in the map
	 */
	static Length() {
		return this.Count()  ; Assuming Count method is implemented
	}

	/**
	 * @description Get the keys of the map as an array
	 * @returns {Array} An array of keys in the map
	 */
	static Keys() {
		keys := []
		for k, _ in this {
			keys.Push(k)
		}
		return keys
	}
	/**
	 * @description Get the values of the map as an array
	 * @returns {Array} An array of values in the map
	 */
	static Values() {
		values := []
		for _, v in this {
			values.Push(v)
		}
		return values
	}
	static __New() {
		; Add all Map2 methods to Array prototype
		for methodName in this.OwnProps() {
			if methodName != "__New" && HasMethod(this, methodName) {
				; Check if method already exists
				if Map.Prototype.HasOwnProp(methodName) {
					; Either skip, warn, or override based on your needs
					continue  ; Skip if method exists
					; Or override:
					; Map.Prototype.DeleteProp(methodName)
				}
				Map.Prototype.DefineProp(methodName, {
					Call: this.%methodName%
				})
			}
		}
	}

    /**
     * Applies a function to each element in the map (mutates the map).
     * @param func The mapping function that accepts at least key and value (key, value1, [value2, ...]).
     * @param enums Additional enumerables to be accepted in the mapping function
     * @returns {Map}
     */
    static Map(func, enums*) {
        if !HasMethod(func) {
            throw ValueError("Map: func must be a function", -1)
		}
        for k, v in this {
            bf := func.Bind(k,v)
            for _, vv in enums {
                bf := bf.Bind(vv.Has(k) ? vv[k] : unset)
			}
            try bf := bf()
            this[k] := bf
        }
        return this
    }
    /**
     * Applies a function to each key/value pair in the map.
     * @param func The callback function with arguments Callback(value[, key, map]).
     * @returns {Map}
     */
    static ForEach(func) {
        if !HasMethod(func) {
            throw ValueError("ForEach: func must be a function", -1)
		}
        for i, v in this {
            func(v, i, this)
        }
        return this
    }
    /**
     * Keeps only values that satisfy the provided function
     * @param func The filter function that accepts key and value.
     * @returns {Map}
     */
    static Filter(func) {
        if !HasMethod(func) {
            throw ValueError("Filter: func must be a function", -1)
		}
        r := Map()
        for k, v in this {
            if func(k, v) {
                r[k] := v
            }
        }
		this := r
		; return r
        return this
    }
    /**
     * Finds a value satisfying the provided function and returns its key.
     * @param func The condition function that accepts one argument (value).
     * @param match Optional: is set to the found value
     * @example
     * Map("a", 1, "b", 2, "c", 3).Find((v) => (Mod(v,2) == 0)) ; returns "b"
     */
    static Find(func, &match?) {
        if !HasMethod(func) {
            throw ValueError("Find: func must be a function", -1)
		}
        for k, v in this {
            if func(v) {
                match := v
                return k
            }
        }
        return 0
    }
    /**
     * Counts the number of occurrences of a value
     * @param value The value to count. Can also be a function that accepts a value and evaluates to true/false.
     * @returns {Number} The number of occurrences of the value in the map.
     */
	static Count(value?) {
		count := 0
		if !IsSet(value) {
			value := this
		}
		if HasMethod(value) {
			for _, v in this {
				if value(v?) {
					count++
				}
			}
		}
		else {
			for _, v in this {
				if v == value {
					count++
				}
			}
		}
		return count
	}

	/**
	 * 
	 * @param value The value to count. Can also be a function that accepts a value and evaluates to true/false.
	 * @returns {Number} The number of occurrences of the value in the map.
	 */
	Count(value?) {
		count := 0
		if !IsSet(value) {
			value := this
		}
		if HasMethod(value) {
			for _, v in this {
				if value(v?) {
					count++
				}
			}
		}
		else {
			for _, v in this {
				if v == value {
					count++
				}
			}
		}
		return count
	}

    /**
     * Adds the contents of other enumerables to this one.
     * @param enums The enumerables that are used to extend this one.
     * @returns {Array}
     */
    static Extend(enums*) {
        for i, enum in enums {
            if !HasMethod(enum, "__Enum") {
                throw ValueError("Extend: argument " i " is not an iterable")
            }
            for k, v in enum {
                this[k] := v
			}
        }
        return this
    }
; }
; ---------------------------------------------------------------------------
;! Original end of Descolada's Map
; ---------------------------------------------------------------------------
;! Below is Axlefublr's Map additions, that were converted to a class
;! Special thanks to Laser_Made for the assistance
; ---------------------------------------------------------------------------
; Class Map2 {
    /************************************************************************
    * @description Adds a timestamp property to Map2 objects
    * @example
    * myMap := Map("key1", "value1")
    * myMap.SetTimestamp()
    * MsgBox(myMap.GetTimestamp())
    ***********************************************************************/

    static SetTimestamp(value := "") {
        if (value == "")
            this["__timestamp"] := A_TickCount
        else
            this["__timestamp"] := value
        return this
    }

    static GetTimestamp() {
        return this.HasOwnProp("__timestamp") ? this["__timestamp"] : ""
    }

    static Timestamp {
        get => this.GetTimestamp()
        set => this.SetTimestamp(value)
    }
	/**
	 * By default, you can set the same key to a map multiple times.
	 * Naturally, you'll be able to reference only one of them, which is likely not the behavior you want.
	 * This function will throw an error if you try to set a key that already exists in the map.
	 * @description Safely sets a key-value pair, only if the key doesn't already exist
	 * @param mapObj ***Map*** to set the key-value pair into
	 * @param key ***String***
	 * @param value ***Any***
	 */

	static SafeSet(key, value) {
		MapObj := this
        if this.HasKey(key){
            throw IndexError("Map already has key: " key)
		}
        MapObj.Set(key, value)
        return this
    }
	
	/**
	 * A version of SafeSet that you can just pass another map object into to set everything in it.
	 * Will still throw an error for every key that already exists in the map.
	 * @description Safely sets multiple key-value pairs from another map
	 * @param mapObj ***Map*** the initial map
	 * @param mapToSet ***Map*** the map to set into the initial map
	 */
	static SafeSetMap(mapToSet) {
		for k, value in mapToSet {
			this.SafeSet(k, value)
		}
		return mapToSet
	}
	

	static Reverse() {
		reversedMap := Map()
		for k, value in this {
			reversedMap.Set(value, k)
		}
		return reversedMap
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

	static _ChooseMap(keyName) {
		if this.Prototype.Base.Has(keyName){
			return this[keyName]
		}
		options := []
		for k, _ in this {
			if InStr(k, keyName){
				options.Push(k)
			}
		}
		chosen := this.Choose(options*)
		if chosen {
			return this[chosen]
		}
		return ""
	}
	; static Choose(keyName) => this._ChooseMap(keyName)
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region MapToString(delim := "`n")
	/**
	 * @description Converts a Map to string representation with custom delimiter
	 * @param {String} [delim="`n"] Optional delimiter character. Default is newline
	 * @returns {String} String representation of the map
	 * @throws {Error} If conversion fails
	 * @example
	 * myMap := Map("key1", "value1", "key2", "value2")
	 * str := myMap.MapToString()  ; "key1 : value1`nkey2 : value2"
	 * str2 := myMap.MapToString("|")  ; "key1 : value1|key2 : value2"
	 */
	static MapToString(delim := "`n") {
		visitedMaps := 0
		v := k := str := ''
		count := this.Count()
		if (count == 0) {
			return ""
		}
		; Initialize visited maps tracking on first call
		if (visitedMaps == 0) {
			visitedMaps := Map()
		}
		
		; Check for circular references
		visitedMaps[ObjPtr(this)] := true
		
		; When processing nested maps:
		if (IsMap(value) && !visitedMaps.Has(ObjPtr(value))) {
			; Safe to process
		} else if (IsMap(value)) {
			value := "[Circular]"
		}
		; For large maps, pre-allocate capacity
		VarSetStrCapacity(&str, count * 50)  ; Estimate average entry length
		
		; Rest of implementation
		for k, v in this {
			; Use Any2 methods for type checking
			if ((IsObject(k) && IsArray(k)||IsMap(k)||IsClass(k)) && !IsString(k) && !IsNumber(k)) {
				; Try to convert object key to string
				if HasMethod(k, "ToString") {
					k := k.ToString()
				}
			}
			
			if ((IsObject(v) && IsArray(v)||IsMap(v)||IsClass(v)) && !IsString(v) && !IsNumber(v)) {
				; Try to convert object value to string
				if HasMethod(v, "ToString") {
					v := v.ToString()
				}
			}
			
			str .= k ' : ' v delim
		}
	
		str := RTrim(str, delim)
	
		this := str

		; Clear local variables to help GC (optional, not strictly necessary in AHK v2)
		visitedMaps := str := k := v := count := unset

		return this
	}
	; @endregion MapToString(delim := "`n")
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region ToString(delim?)
	/**
	 * @description Primary string conversion method. Wrapper for MapToString
	 * @param {String} [delim="`n"] Optional delimiter character
	 * @returns {String} String representation of the map
	 * @throws {Error} If conversion fails
	 * @example
	 * myMap := Map("key1", "value1", "key2", "value2")
	 * str := myMap.ToString()  ; "key1 : value1`nkey2 : value2"
	 */
	static ToString(delim?) {
		objText := this.MapToString(delim?)
		return objText
	}
	; @endregion ToString(delim?)
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region ToStr(delim?)
	/**
	 * @description Alias for MapToString - shorter name version
	 * @param {String} [delim="`n"] Optional delimiter character
	 * @returns {String} String representation of the map
	 * @example
	 * myMap := Map("key1", "value1", "key2", "value2")
	 * str := myMap.ToStr()  ; "key1 : value1`nkey2 : value2" 
	 */
	static ToStr(delim?){
		objText := this.MapToString(delim?)
		return objText
	}
	; @endregion ToStr(delim?)
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region Stringify(delim?)
	/**
	 * @description Alias for MapToString - matches JavaScript convention
	 * @param {String} [delim="`n"] Optional delimiter character
	 * @returns {String} String representation of the map
	 * @example
	 * myMap := Map("key1", "value1", "key2", "value2")
	 * str := myMap.Stringify()  ; "key1 : value1`nkey2 : value2"
	 */
	static Stringify(delim?){
		objText := this.MapToString(delim?)
		return objText
	}
	; @endregion Stringify(delim?)
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region ToJSON()
	/**
	 * @description Converts map to JSON string representation
	 * @param {Integer} [indent=0] Optional indentation spaces (0 for no formatting)
	 * @returns {String} JSON string representation of the map
	 * @throws {Error} If JSON conversion fails
	 * @example
	 * myMap := Map("key1", "value1", "key2", 42, "key3", true)
	 * json := myMap.ToJSON()  ; '{"key1":"value1","key2":42,"key3":true}'
	 * prettyJson := myMap.ToJSON(2)  ; Formatted with 2-space indentation
	 */
	static ToJSON(indent := 0) {
		jsonObj := {}
		libJSON := 'cJSON'
		
		; Convert Map to standard object for JSON serialization
		for k, v in this {
			; Convert keys to string (JSON keys must be strings)
			keyStr := IsString(k) ? k : String(k)
			
			; Process values
			if (IsObject(v)) {
				if (HasMethod(v, "ToJSON")) {
					; Use object's own ToJSON method if available
					jsonObj.%keyStr% := %libJSON%.Parse(v.ToJSON())
				} 
				else if (IsMap(v)) {
					; Recursively convert nested maps
					nestedObj := {}
					for nk, nv in v {
						nestedObj.%nk% := nv
					}
					jsonObj.%keyStr% := nestedObj
				}
				else if (IsArray(v)) {
					; Arrays can be directly used
					jsonObj.%keyStr% := v
				}
				else {
					; Fall back to string representation for other objects
					try {
						jsonObj.%keyStr% := v.ToString()
					} catch {
						jsonObj.%keyStr% := "[Object]"
					}
				}
			}
			else {
				; Direct assignment for primitive types
				jsonObj.%keyStr% := v
			}
		}
		
		; Use JSON library to stringify with proper formatting
		if (indent > 0) {
			return %libJSON%.Stringify(jsonObj, indent)
		} else {
			return %libJSON%.Stringify(jsonObj)
		}
	}
	; @endregion ToJSON()
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region FromJSON(jsonString)
	/**
	 * @description Creates a map from JSON string
	 * @param {String} jsonString Valid JSON string to parse
	 * @returns {Map} New map populated with data from JSON
	 * @throws {Error} If JSON parsing fails
	 * @example
	 * jsonStr := '{"name":"John","age":30,"active":true}'
	 * myMap := Map2.FromJSON(jsonStr)
	 */
	static FromJSON(jsonString) {
		; Parse JSON string to object
		try {
			obj := JSON.Parse(jsonString)
		} catch Error as e {
			throw ValueError("Invalid JSON format: " e.Message, -1)
		}
		
		; Convert object to Map
		resultMap := Map()
		
		; Process object properties
		for key, value in obj.OwnProps() {
			if IsObject(value) {
				if IsArray(value) {
					; Keep arrays as arrays
					resultMap[key] := value
				} else {
					; Convert nested objects to maps
					nestedMap := Map()
					for nKey, nValue in value.OwnProps() {
						nestedMap[nKey] := nValue
					}
					resultMap[key] := nestedMap
				}
			} else {
				; Direct assignment for primitive values
				resultMap[key] := value
			}
		}
		
		return resultMap
	}
	; @endregion FromJSON(jsonString)
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region MapHasValue(valueToFind)
	/**
	 * @description Checks if the specified value exists in the map.
	 * @param valueToFind The value to search for in the map.
	 * @returns {Boolean} True if the value exists, otherwise false.
	 */
	static MapHasValue(valueToFind) {
        for k, value in this {
            if (value = valueToFind) {
                return value
            }
        }
        return false
	}

	static HasValue(valueToFind) {
		return this.MapHasValue(valueToFind)
	}
	HasValue(valueToFind) {
		return Map2.MapHasValue(valueToFind)
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region HasKey(findKey)
	/**
	 * @type Static
	 * @description Checks if the specified key exists in the map.
	 *
	 * @param findKey The key to search for in the map.
	 * @returns {Boolean} True if the key exists, otherwise false.
	 */
	/**
	 * 
	 */
	static HasKey(findKey) {
		return this._MapHaskey(findKey)
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	/**
	 * @type Non-static
	 * @description Checks if the specified key exists in the map.
	 *
	 * @param findKey The key to search for in the map.
	 * @returns {Boolean} True if the key exists, otherwise false.
	 */
	HasKey(findKey) {
		return Map2._MapHaskey(findKey)
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region _MapHasKey(findKey)
	/**
	 * @type Non-static
	 * @description Checks if the specified key exists in the map.
	 */
	static _MapHaskey(findKey) {
		for k, value in this {
			if (k = findKey){
				return k
			}
		}
		return false
	}
	; @endregion HasKey(findKey)
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region GetKeys()
	static GetKeys() {
		keys := []
		for k, _ in this {
			keys.Push(k)
		}
		return keys
	}
	; @endregion GetKeys()
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region GetValues()
	static GetValues() {
		values := []
		for _, value in this {
			values.Push(value)
		}
		return values
	}
	; @endregion GetValues()
	; ---------------------------------------------------------------------------
	/**
	 * @description Converts a Map to an Array or handles various inputs to produce arrays
	 * @param {...Any} [inputs] Optional inputs to convert (defaults to this instance)
	 * @returns {Array} An array containing the converted elements
	 * @throws {TypeError} If input cannot be processed
	 * @example
	 * ; Basic instance conversion
	 * myMap := Map("a", 1, "b", 2)
	 * arr := myMap.ToArray()  ; Returns ["a", 1, "b", 2]
	 * 
	 * ; Static conversion
	 * arr := Map2.ToArray(myMap)  ; Same result
	 * 
	 * ; Converting multiple objects
	 * arr := Map2.ToArray(myMap, [3, 4], "text")  ; Complex conversion
	 */
	; @region ToArray(obj?)
	static ToArray(obj?) {
		; Call the more comprehensive MapToArray method for consistency
		return this.ToArray(IsSet(obj) ? obj : unset)
	}
	; @endregion ToArray(obj?)
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region MapToArray(inputs*)
	/**
	 * @description Converts a Map to an Array (legacy method)
	 * @param {Map|Object} [obj] Optional map to convert; defaults to this instance
	 * @returns {Array} An array containing alternating keys and values
	 * @throws {TypeError} If input cannot be enumerated
	 */
	static MapToArray(inputs*) {
		; If no inputs, convert this object
		if (inputs.Length == 0) {
			; Default conversion for maps
			arrObj := []
			for k, v in this {
				arrObj.Push(k, v)
			}
			return this := arrObj
		}
		
		result := []
		
		; Process each input
		for input in inputs {
			; Handle different types
			if IsMap(input) {
				; Convert map to alternating key/value elements
				for k, v in input {
					result.Push(k, v)
				}
			} 
			else if IsObject(input) && HasMethod(input, "__Enum") {
				; Handle general enumerable objects
				if HasMethod(input, "ToArray") {
					; Use object's own ToArray method if available
					result.Push(input.ToArray()*)
				} 
				else {
					; Default handling for enumerable objects
					for item in input {
						result.Push(item)
					}
				}
			}
			else if IsArray(input) {
				; Arrays can be directly added
				result.Push(input*)
			}
			else if Type(input) == "String" {
				; Split strings by newlines (default) or specified separator
				strings := StrSplit(input, "`n", "`r")
				result.Push(strings*)
			}
			else {
				; Non-collection values are added directly
				result.Push(input)
			}
		}
		
		return result
	}
	; @endregion MapToArray(inputs*)

	; /**
	;  * Static method to convert the current object into a native Map object.
	;  * Iterates over all key-value pairs in the current object and sets them in a new Map.
	;  * Replaces the current object with the new Map instance.
	;  *
	;  * @returns {Map} The new Map instance containing all key-value pairs from the original object.
	;  */
	; static __Set() {
	; 	objMap := Map()
	; 	for k, v in this {
	; 		objMap.Set(k, v)
	; 	}
	; 	return this := objMap
	; }
	
}

; ====== Map with Dot Notation Support ======

/**
 * @class DotMap
 * @description Extended Map class with dot notation support
 * @extends Map
 */
class DotMap extends Map {
    /**
     * @constructor
     * @param {Object|Array|Map} init Optional initial values
     */
    __New(init?) {
        super.__New()
        
        if IsSet(init) {
            if IsObject(init) {
                for key, value in init.OwnProps() {
                    this[key] := value
				}
            }
			else if IsArray(init) {
                Loop init.Length // 2{
                    this[init[A_Index*2-1]] := init[A_Index*2]
				}
            }
			else if IsMap(init) {
                for key, value in init {
                    this[key] := value
				}
            }
        }
    }
    
    /**
     * @description Get a value using dot notation
     * @param {String} key The key to get
     * @returns {Any} The value
     */
    __Get(key) {
		objMap := Map()
		if this.Has(key) {
			objMap := this[key]
			if IsObject(objMap) {
				return objMap
			} else {
				return objMap
			}
		}
		return false
    }
    
    /**
     * @description Set a value using dot notation
     * @param {String} key The key to set
     * @param {Any} value The value to set
     */
    __Set(key, value) {
		objMap := Map()
		if this.Has(key) {
			objMap := this[key]
			if IsObject(objMap) {
				objMap := objMap.__Set(key, value)
				return objMap
			} else if IsArray(objMap) {
				objMap := objMap.__Set(key, value)
				return objMap
			} else if IsMap(objMap) {
				objMap := objMap.__Set(key, value)
				return objMap
			}
		}
        return objMap.__Set(key, value)
    }
    
    /**
     * @description Convert to a standard object
     * @returns {Object} Object representation
     */
    ToObject() {
        obj := {}
        for key, value in this
            obj.%key% := value
        return obj
    }
    
    /**
     * @description Create from a standard object
     * @param {Object} obj Object to convert
     * @returns {DotMap} New DotMap instance
     */
    static FromObject(obj) {
        return DotMap(obj)
    }
}
