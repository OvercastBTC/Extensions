/**
 * @file Any.ahk
 * @class Any2
 * @abstract Provides comprehensive type checking and type inspection utilities
 * @version 1.0.0
 * @author OvercastBTC (Adam Bacon)
 * @license MIT
 * @date 2025-04-28
 * @description This class provides a set of static methods for type checking and type inspection in AutoHotkey.
 */

Any.Prototype := Any2
; class Any2 extends Any {
class Any2 {

	/**
	 * @description Static constructor that adds all Any2 methods to Any.Prototype
	 * Allows using Any methods directly on variables through prototype inheritance
	 */
	static __New() {
		Object2
		; ; Add HasOwnProp method (safe wrapper)
		; if !HasProp(Any.Prototype, "HasOwnProp") {
		; 	; Use direct built-in function to avoid recursion
		; 	Any.Prototype.HasOwnProp := HasOwnPropFunc
		; }
		
		; ; Add DefineProp method (safe wrapper)
		; if !HasProp(Any.Prototype, "DefineProp") {
		; 	; Use direct built-in function to avoid reference error
		; 	Any.Prototype.DefineProp := DefinePropFunc
		; }

		; ; Helper functions defined as standard functions to maintain compatibility
		; HasOwnPropFunc(obj, propName) {
		; 	return IsObject(obj) && ObjHasOwnProp(obj, propName)
		; }

		; DefinePropFunc(obj, propName, descriptor) {
		; 	obj := []
		; 	if IsObject(obj)
		; 		return obj := obj.DefineProp(propName, descriptor)
		; 	return false
		; }

		; ; Add all methods to prototype
		; for methodName in this.OwnProps() {
		; 	if (methodName != "__New") {
		; 		try {
		; 			; Skip if method already exists to prevent conflicts
		; 			if ObjHasOwnProp(Any.Prototype, methodName){
		; 				continue
		; 			}
		; 			; Define the method on Any.Prototype
		; 			Any.Prototype.%methodName% := this.%methodName%.Bind(this)
		; 		} catch as err {
		; 			OutputDebug "Failed to add method " methodName " to Any.Prototype: " err.Message
		; 		}
		; 	}
		; }
	}

	/**
	 * @property {Map} _typeCache
	 * @description Cache for type checking results
	 * @private
	 */
	static _typeCache := Map()
	
	/**
	 * @description Get the type of a value
	 * @param {Any} value The value to check
	 * @returns {String} The type name
	 */
	static GetType(value) => Type(value)
	
	; ====== POSITIVE TYPE CHECKS ======
	
	/**
	 * @description Checks if the value is an Array
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is an Array
	 */
	static IsArray(value) => Type(value) = "Array"
	
	/**
	 * @description Checks if the value is a Map
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Map
	 */
	static IsMap(value) => Type(value) = "Map"
	
	/**
	 * @description Checks if the value is a Class
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Class
	 */
	static IsClass(value) => Type(value) = "Class"
	
	/**
	 * @description Checks if the value is a String
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a String
	 */
	static IsString(value) => Type(value) = "String"
	
	/**
	 * @description Checks if the value is a Number
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Number
	 */
	static IsNumber(value) => Type(value) = "Integer" || Type(value) = "Float"
	
	/**
	 * @description Checks if the value is an Integer
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is an Integer
	 */
	static IsInteger(value) => Type(value) = "Integer"
	
	/**
	 * @description Checks if the value is a Float
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Float
	 */
	static IsFloat(value) => Type(value) = "Float"
	
	/**
	 * @description Checks if the value is a Boolean
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Boolean
	 */
	static IsBoolean(value) => Type(value) = "Integer" && (value = 0 || value = 1)
	
	/**
	 * @description Checks if the value is a Function
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Function
	 */
	static IsFunction(value) => Type(value) = "Func" || Type(value) = "BoundFunc" || Type(value) = "Closure"
	
	/**
	 * @description Checks if the value is an Object
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is an Object
	 */
	; static IsObject(value) => IsObject(value)
	
	/**
	 * @description Checks if the value is a Gui
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Gui
	 */
	static IsGui(value) => IsObject(value) && HasMethod(value, "Show") && HasMethod(value, "Hide") && HasMethod(value, "Add")
	
	/**
	 * @description Checks if the value is a Gui Control
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Gui Control
	 */
	static IsGuiControl(value) => IsObject(value) && HasProp(value, "Gui") && HasProp(value, "Type")
	
	/**
	 * @description Checks if the value is a Nested Array (array containing arrays)
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is a Nested Array
	 */
	static IsNestedArray(value) {
		if !this.IsArray(value){
			return false
		}
		for item in value {
			if this.IsArray(item){
				return true
			}
		}
		return false
	}
	
	/**
	 * @description Checks if the value is of a specific type
	 * @param {Any} value The value to check
	 * @param {String} type The type to check against
	 * @returns {Boolean} True if the value matches the type
	 */
	static IsType(value, type) => Type(value) = type
	
	; ====== NEGATIVE TYPE CHECKS ======
	
	/**
	 * @description Checks if the value is NOT an Array
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is NOT an Array
	 */
	static IsNotArray(value) => Type(value) != "Array"
	
	/**
	 * @description Checks if the value is NOT a Map
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is NOT a Map
	 */
	static IsNotMap(value) => Type(value) != "Map"
	
	/**
	 * @description Checks if the value is NOT a Class
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is NOT a Class
	 */
	static IsNotClass(value) => Type(value) != "Class"
	
	/**
	 * @description Checks if the value is NOT a String
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is NOT a String
	 */
	static IsNotString(value) => Type(value) != "String"
	
	/**
	 * @description Checks if the value is NOT a Number
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is NOT a Number
	 */
	static IsNotNumber(value) => Type(value) != "Integer" && Type(value) != "Float"
	
	/**
	 * @description Checks if the value is NOT a Function
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is NOT a Function
	 */
	static IsNotFunction(value) => Type(value) != "Func" && Type(value) != "BoundFunc" && Type(value) != "Closure"
	
	/**
	 * @description Checks if the value is NOT an Object
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is NOT an Object
	 */
	static IsNotObject(value) => !IsObject(value)
	
	/**
	 * @description Checks if the value is NOT of a specific type
	 * @param {Any} value The value to check
	 * @param {String} type The type to check against
	 * @returns {Boolean} True if the value does NOT match the type
	 */
	static IsNotType(value, type) => Type(value) != type
	
	; ====== TYPE INSPECTION ======
	
	; @region GetProperties
	/**
	 * @description Gets all properties of an object
	 * @param {Object} obj The object to inspect
	 * @returns {Array} Array of property names
	 */
	static GetProperties(obj) {
		if !IsObject(obj)
			return []
		
		result := []
		for prop in obj.OwnProps()
			result.Push(prop)
		return result
	}
	; @endregion GetProperties
	; ---------------------------------------------------------------------------
	; @region GetMethods
	/**
	 * @description Gets all methods of an object
	 * @param {Object} obj The object to inspect
	 * @returns {Array} Array of method names
	 */
	static GetMethods(obj) {
		if !IsObject(obj)
			return []
		
		result := []
		for method in obj.OwnMethods(){
			result.Push(method)
		}
		return result
	}
	; @endregion GetMethods
	; ---------------------------------------------------------------------------
	; @region HasMethod
	/**
	 * @description Checks if a class has a specific method
	 * @param {Object} obj The object to check
	 * @param {String} methodName The method name to check for
	 * @returns {Boolean} True if the object has the method
	 */
	static HasMethod(obj, methodName) {
		return IsObject(obj) && HasMethod(obj, methodName)
	}
	; @endregion HasMethod
	; ---------------------------------------------------------------------------
	; @region HasProperty
	/**
	 * @description Checks if a class has a specific property
	 * @param {Object} obj The object to check
	 * @param {String} propName The property name to check for
	 * @returns {Boolean} True if the object has the property
	 */
	static HasProperty(obj, propName) {
		return IsObject(obj) && HasProp(obj, propName)
	}
	; @endregion HasProperty
	; ---------------------------------------------------------------------------
	; @region IsEmpty
	/**
	 * @description Checks if a value is empty (empty string, array, map or object)
	 * @param {Any} value The value to check
	 * @returns {Boolean} True if the value is empty
	 */
	static IsEmpty(value) {
		if !IsSet(value){
			return true
		}
		if this.IsString(value){
			return value = ""
		}
		if this.IsArray(value){
			return value.Length = 0
		}
		if this.IsMap(value){
			return value.Count = 0
		}
		if IsObject(value) {
			for _ in value.OwnProps(){
				return false
			}
			return true
		}
		
		return false
	}
	; @endregion IsEmpty
	; ---------------------------------------------------------------------------
	; @region IsValidGuiSetting
	/**
	 * @description Checks if a GUI setting string is valid (e.g., "s10", "bold")
	 * @param {String} setting The setting string to check
	 * @returns {Boolean} True if the setting is valid
	 */
	static IsValidGuiSetting(setting) {
		if !this.IsString(setting)
			return false
			
		; Font size
		if setting ~= "^s\d+$" {
			return true
		}
		; Font styles
		if setting ~= "i)^(bold|italic|underline|strike)$" {
			return true
		}
		; Common GUI options
		if setting ~= "i)^(center|right|readonly|disabled|checked|hidden)$" {
			return true
		}
		; Position options
		if setting ~= "^[xy][+-]?\d+$" {
			return true
		}
		; Size options
		if setting ~= "^[wh]\d+$" {
			return true
		}
		return false
	}
	; @region IsValidFont
	/**
	 * @description Checks if a string is a valid font name
	 * @param {String} fontName The font name to check
	 * @returns {Boolean} True if the font exists in the system
	 */
	static IsValidFont(fontName) {
		static fontCache := Map()
		
		if !this.IsString(fontName){
			return false
		}
		; Check cache first
		if fontCache.Has(fontName){
			return fontCache[fontName]
		}
		; Create a temporary GUI to test the font
		testGui := Gui("-DPIScale -Caption +AlwaysOnTop")
		try {
			testGui.SetFont("s10", fontName)
			fontCache[fontName] := true
			testGui.Destroy()
			return true
		} catch {
			fontCache[fontName] := false
			testGui.Destroy()
			return false
		}
	}

}

; ====== Dot Notation Support for Type Checking ======
; @region class IsType
/**
 * @class IsType
 * @description Allows dot notation for type checking
 */
class IsType {
	static Array(value) 		=> Any2.IsArray(value)
	static Map(value) 			=> Any2.IsMap(value)
	static Class(value) 		=> Any2.IsClass(value)
	static String(value) 		=> Any2.IsString(value)
	static Number(value) 		=> Any2.IsNumber(value)
	static Integer(value) 		=> Any2.IsInteger(value)
	static Float(value) 		=> Any2.IsFloat(value)
	static Boolean(value) 		=> Any2.IsBoolean(value)
	static Function(value) 		=> Any2.IsFunction(value)
	static Object(value) 		=> IsObjectEx(value)
	static Gui(value) 			=> Any2.IsGui(value)
	static GuiControl(value) 	=> Any2.IsGuiControl(value)
	static NestedArray(value) 	=> Any2.IsNestedArray(value)
	static Empty(value) 		=> Any2.IsEmpty(value)
}
; @endregion class IsType
; ---------------------------------------------------------------------------
; @region class HasProp
/**
 * @class HasProp
 * @description Check if an object has a property using dot notation
 */
; class HasProp {
; 	static Call(obj, propName) => Any2.HasProperty(obj, propName)
; 	static Gui(obj) => Any2.IsGui(obj)
; }

; @endregion class HasProp
; ---------------------------------------------------------------------------
; @region class HasMethod
/**
 * @class HasMethod
 * @description Check if an object has a method using dot notation
 */
; class HasMethod {
; 	static Call(obj, methodName) => Any2.HasMethod(obj, methodName)
; }
; ---------------------------------------------------------------------------
; @endregion class HasMethod
; ---------------------------------------------------------------------------
; ====== Global Helper Functions ======
; @region Is/IsNot Functions
/**
 * @description Checks if the value is an Array
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is an Array
 */
IsArray(value) => Any2.IsArray(value)

/**
 * @description Checks if the value is a Map
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a Map
 */
IsMap(value) => Any2.IsMap(value)

/**
 * @description Checks if the value is a Class
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a Class
 */
IsClass(value) => Any2.IsClass(value)

/**
 * @description Checks if the value is a String
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a String
 */
IsString(value) => Any2.IsString(value)

/**
 * @description Checks if the value is a Number (Integer or Float)
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a Number
 */
IsNumber(value) => Any2.IsNumber(value)

/**
 * @description Checks if the value is an Integer
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is an Integer
 */
IsInteger(value) => Any2.IsInteger(value)

/**
 * @description Checks if the value is a Float
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a Float
 */
IsFloat(value) => Any2.IsFloat(value)

/**
 * @description Checks if the value is a Boolean
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a Boolean
 */
IsBoolean(value) => Any2.IsBoolean(value)

/**
 * @description Checks if the value is a Function
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a Function
 */
IsFunction(value) => Any2.IsFunction(value)
/**
 * @description Checks if the value is an Object (does not shadow built-in IsObject)
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is an Object
 */
IsObjectEx(value) => IsObject(value)
/**
 * @description Checks if the value is an Object (does not shadow built-in IsObject)
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is an Object
 */
; IsObject(value) => IsObject(value) 

/**
 * @description Checks if the value is a Gui
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a Gui
 */
IsGui(value) => Any2.IsGui(value)

/**
 * @description Checks if the value is a GUI control
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a GUI control
 */
IsGuiControl(value) => Any2.IsGuiControl(value)

/**
 * @description Checks if the value is a nested array
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is a nested array
 */
IsNestedArray(value) => Any2.IsNestedArray(value)

/**
 * @description Checks if the value is of a specific type
 * @param {Any} value The value to check
 * @param {String} type The type to check against
 * @returns {Boolean} True if the value matches the type
 */
TypeIs(value, type) => Any2.IsType(value, type)

/**
 * @description Checks if the value is NOT an Array
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is NOT an Array
 */
IsNotArray(value) => Any2.IsNotArray(value)

/**
 * @description Checks if the value is NOT a Map
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is NOT a Map
 */
IsNotMap(value) => Any2.IsNotMap(value)

/**
 * @description Checks if the value is NOT a Class
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is NOT a Class
 */
IsNotClass(value) => Any2.IsNotClass(value)

/**
 * @description Checks if the value is NOT a String
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is NOT a String
 */
IsNotString(value) => Any2.IsNotString(value)

/**
 * @description Checks if the value is NOT a Number
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is NOT a Number
 */
IsNotNumber(value) => Any2.IsNotNumber(value)

/**
 * @description Checks if the value is NOT a Function
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is NOT a Function
 */
IsNotFunction(value) => Any2.IsNotFunction(value)

/**
 * @description Checks if the value is NOT an Object
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is NOT an Object
 */
IsNotObject(value) => Any2.IsNotObject(value)

/**
 * @description Checks if the value is empty
 * @param {Any} value The value to check
 * @returns {Boolean} True if the value is empty
 */
IsEmpty(value) => Any2.IsEmpty(value)
