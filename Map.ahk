
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
; #Include <Tools\Info> ;? Added for the Choose()

Map.Prototype.base := Map2

class Map2 {
    /**
     * Returns all the keys of the Map in an array
     * @returns {Array}
     */
    ; static Keys {
    ;     get => [this*]
    ; }
    /**
     * Returns all the values of the Map in an array
     * @returns {Array}
     */
    ; static Values {
    ;     get => [this.__Enum(2).Bind(&_)*]
    ; }

    /**
     * Applies a function to each element in the map (mutates the map).
     * @param func The mapping function that accepts at least key and value (key, value1, [value2, ...]).
     * @param enums Additional enumerables to be accepted in the mapping function
     * @returns {Map}
     */
    static Map(func, enums*) {
        if !HasMethod(func)
            throw ValueError("Map: func must be a function", -1)
        for k, v in this {
            bf := func.Bind(k,v)
            for _, vv in enums
                bf := bf.Bind(vv.Has(k) ? vv[k] : unset)
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
        if !HasMethod(func)
            throw ValueError("ForEach: func must be a function", -1)
        for i, v in this
            func(v, i, this)
        return this
    }
    /**
     * Keeps only values that satisfy the provided function
     * @param func The filter function that accepts key and value.
     * @returns {Map}
     */
    static Filter(func) {
        if !HasMethod(func)
            throw ValueError("Filter: func must be a function", -1)
        r := Map()
        for k, v in this
            if func(k, v)
                r[k] := v
        return this := r
    }
    /**
     * Finds a value satisfying the provided function and returns its key.
     * @param func The condition function that accepts one argument (value).
     * @param match Optional: is set to the found value
     * @example
     * Map("a", 1, "b", 2, "c", 3).Find((v) => (Mod(v,2) == 0)) ; returns "b"
     */
    static Find(func, &match?) {
        if !HasMethod(func)
            throw ValueError("Find: func must be a function", -1)
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
     * Adds the contents of other enumerables to this one.
     * @param enums The enumerables that are used to extend this one.
     * @returns {Array}
     */
    static Extend(enums*) {
        for i, enum in enums {
            if !HasMethod(enum, "__Enum")
                throw ValueError("Extend: argument " i " is not an iterable")
            for k, v in enum
                this[k] := v
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
	 * @param mapObj ***Map*** to set the key-value pair into
	 * @param key ***String***
	 * @param value ***Any***
	 */
	static SafeSet(key, value) {
		if !this.Prototype.Base.Has(key) {
			this.Prototype.Base.Set(key, value)
			; return ;? disabled => dunno why a return is necessary
		}
		; throw IndexError("Map already has key", -1, key) ;? disabled => causes thread to stop
	}

	/**
	 * A version of SafeSet that you can just pass another map object into to set everything in it.
	 * Will still throw an error for every key that already exists in the map.
	 * @param mapObj ***Map*** the initial map
	 * @param mapToSet ***Map*** the map to set into the initial map
	 */
	static SafeSetMap(mapToSet) {
		for key, value in mapToSet {
			this.SafeSet(key, value)
		}
		return mapToSet
	}
	

	static Reverse() {
		reversedMap := Map()
		for key, value in this {
			reversedMap.Set(value, key)
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
		for key, _ in this {
			if InStr(key, keyName){
				options.Push(key)
			}
		}
		chosen := this.Choose(options*)
		if chosen{
			return this[chosen]
		}
		return ""
	}
	; static Choose(keyName) => this._ChooseMap(keyName)
	; ---------------------------------------------------------------------------
	static _MapToString(delim := ", ") {
		value := key := str := ''
		for key, value in this {
			; if key = mapObj.Length {
			; 	str .= value
			; 	break
			; }
			str .= key ' : ' value delim
		}
		return str
	}
	static ToString(delim?) => this._MapToString(delim?)
	; ---------------------------------------------------------------------------

	static _MapHasValue(valueToFind) {
		for key, value in this {
			if (value = valueToFind){
				return true
			}
		}
		return false
	}
	static HasValue(valueToFind) => this._MapHasValue(valueToFind)

	static _MapHaskey(keyToFind) {
		for key, value in this {
			if (key = keyToFind){
				return true
			}
		}
		return false
	}
	static HasKey(keyToFind) => this._MapHaskey(keyToFind)
	; ---------------------------------------------------------------------------
}
; ---------------------------------------------------------------------------
