/************************************************************************
 * @description Initialize a Class Property
 * @author OvercastBTC
 * @author Orignal by Axlefublr
 * @date 2024/09/11
 * @version 1.0.0
 * @class Initializable
 ***********************************************************************/

#Requires AutoHotkey v2.0+
#Include <Includes\Basic>

class Initializable {
	Initialize(argObj) {
		for property, value in argObj.OwnProps() {
			if this.HasProp(property) {
				this.%property% := value
				continue
			}
			throw PropertyError("Class doesn't define this property / field", -2, property)
		}
	}
}

class TestSuite {
    static results := Map()
    
    static RunAll() {
        this.results.Clear()
        for testName in this.List() {
            try {
                if this.%testName%() {
                    this.results[testName] := "✓ Pass"
                } else {
                    this.results[testName] := "✗ Fail"
                }
            } catch as err {
                this.results[testName] := Format("✗ Error: {}", err.Message)
            }
        }
        return this.results
    }
    
    static List() {
        tests := []
        for prop in this.OwnProps() {
            if InStr(prop, "Test") = 1 && HasMethod(this.%prop%) {
                tests.Push(prop)
            }
        }
        return tests
    }

    static AssertEqual(expected, actual, message := "") {
        if (expected = actual)
            return true
        throw Error(Format("Expected '{}' but got '{}'. {}", expected, actual, message))
    }

    static AssertTrue(condition, message := "") {
        if (condition)
            return true
        throw Error(Format("Expected true condition. {}", message))
    }

    static AssertFalse(condition, message := "") {
        if (!condition)
            return true
        throw Error(Format("Expected false condition. {}", message))
    }

    static AssertNotEmpty(value, message := "") {
        if (value && value.Length > 0)
            return true
        throw Error(Format("Expected non-empty value. {}", message))
    }
}

; Updated Map Tests
class MapTests extends TestSuite {
    static TestCreate() {
        testMap := Map("key1", "value1", "key2", "value2")
        this.AssertEqual(2, testMap.Count)
        this.AssertEqual("value1", testMap["key1"])
        return true
    }

    static TestSafeSet() {
        testMap := Map()
        testMap.SafeSet("key1", "value1")
        this.AssertEqual("value1", testMap["key1"])
        
        ; Test duplicate key - should throw error
        try {
            testMap.SafeSet("key1", "value2")
            return false
        } catch {
            return true
        }
    }

    static TestToString() {
        testMap := Map("key1", "value1", "key2", "value2")
        result := testMap.ToString()
        this.AssertTrue(InStr(result, "key1") && InStr(result, "value1"))
        return true
    }

    static TestHasKey() {
        testMap := Map("key1", "value1")
        this.AssertTrue(testMap.Has("key1"))
        this.AssertFalse(testMap.Has("nonexistent"))
        return true
    }

    static TestHasValue() {
        testMap := Map("key1", "value1")
        this.AssertTrue(testMap.HasValue("value1"))
        this.AssertFalse(testMap.HasValue("nonexistent"))
        return true
    }
}

class ArrayTests extends TestSuite {
    static TestCreate() {
        testArray := ["item1", "item2"]
        this.AssertEqual(2, testArray.Length)
        this.AssertEqual("item1", testArray[1])
        return true
    }

    static TestSafePush() {
        testArray := []
        testArray.SafePush("value1")
        this.AssertEqual(1, testArray.Length)
        this.AssertEqual("value1", testArray[1])
        
        ; Test duplicate value
        testArray.SafePush("value2")
        this.AssertEqual(2, testArray.Length)
        return true
    }

    static TestToString() {
        testArray := ["item1", "item2"]
        result := testArray._ArrayToString()  ; Using internal method name
        this.AssertTrue(InStr(result, "item1") && InStr(result, "item2"))
        return true
    }

    static TestHasValue() {
        testArray := ["item1", "item2"]
        this.AssertTrue(testArray._ArrayHasValue("item1"))  ; Using internal method name
        this.AssertTrue(!testArray._ArrayHasValue("nonexistent"))
        return true
    }
}

; Updated String Tests - using String2 methods
class StringTests extends TestSuite {
    static TestCreate() {
        testStr := "Test string"
        this.AssertNotEmpty(testStr)
        return true
    }

    static TestToMap() {
        testStr := "key1=value1`nkey2=value2"
        result := String2.ToMap(testStr)
        this.AssertEqual("value1", result["key1"])
        this.AssertEqual("value2", result["key2"])
        return true
    }

    static TestToArray() {
        testStr := "line1`nline2`nline3"
        result := String2.ToArray(testStr)
        this.AssertEqual(3, result.Length)
        this.AssertEqual("line2", result[2])
        return true
    }

    static TestToString() {
        testStr := "Test string"
        this.AssertEqual(testStr, testStr)
        return true
    }
}

TestRunner() {
    results := "Test Results:`n`n"
    
    ; Run Map tests
    results .= "Map Tests:`n"
    for test, result in MapTests.RunAll() {
        results .= Format("{}: {}`n", test, result)
    }
    
    ; Run Array tests
    results .= "`nArray Tests:`n"
    for test, result in ArrayTests.RunAll() {
        results .= Format("{}: {}`n", test, result)
    }
    
    ; Run String tests
    results .= "`nString Tests:`n"
    for test, result in StringTests.RunAll() {
        results .= Format("{}: {}`n", test, result)
    }
    ; Usage:
	results .= MapInfo.ShowExtendedMethods()
	results .= MapInfo.TestMethodAccessibility()
    Infos(results)

	Clip.Send(results)
}

class MapInfo extends TestSuite {
    /**
     * Lists and displays all extended methods available on Map
     * @returns {String} Formatted list of methods and their descriptions
     */
    static ShowExtendedMethods() {
        info := "Extended Map Methods:`n`n"

        ; Get all methods from Map2
        methods := this.GetMethodInfo(Map2)
        
        ; Format and display the information
        for name, desc in methods {
            info .= Format("Method: {}`n", name)
            if desc.HasOwnProp("description")
                info .= Format("Description: {}`n", desc.description)
            if desc.HasOwnProp("params")
                info .= Format("Parameters: {}`n", desc.params.Join(", "))
            if desc.HasOwnProp("returns")
                info .= Format("Returns: {}`n", desc.returns)
            if desc.HasOwnProp("example")
                info .= Format("Example:`n{}`n", desc.example)
            info .= "`n"
        }

        ; Display the information
        Infos(info)
        return info
    }

    /**
     * Gets documentation information for all methods in a class
     * @param {Class} class The class to examine
     * @returns {Map} Method information
     */
    static GetMethodInfo(class) {
        methods := Map()

        methods["SafeSet"] := {
            description: "Safely sets a key-value pair, only if the key doesn't already exist",
            params: ["key", "value"],
            returns: "Map (for chaining)",
            example: "
            (
            myMap := Map()
            myMap.SafeSet(`"key1`", `"value1`")
            try {
                myMap.SafeSet(`"key1`", `"value2`")  ; Throws error
            }
            )"
        }

        methods["SafeSetMap"] := {
            description: "Safely sets multiple key-value pairs from another map",
            params: ["mapToSet"],
            returns: "Map (for chaining)",
            example: "
            (
            targetMap := Map()
            sourceMap := Map(`"key1`", `"value1`", `"key2`", `"value2`")
            targetMap.SafeSetMap(sourceMap)
            )"
        }

        methods["HasValue"] := {
            description: "Checks if a value exists in the map",
            params: ["valueToFind"],
            returns: "Boolean",
            example: "
            (
            myMap := Map(`"key1`", `"value1`")
            if myMap.HasValue(`"value1`")
                MsgBox(`"Found!`")
            )"
        }

        methods["ToString"] := {
            description: "Converts the map to a string representation",
            params: ["delimiter (optional, default = ', ')"],
            returns: "String",
            example: "
            (
            myMap := Map(`"key1`", `"value1`", `"key2`", `"value2`")
            MsgBox(myMap.ToString())  ; Outputs: key1 : value1, key2 : value2
            )"
        }

        return methods
    }

    /**
     * Tests accessibility of all extended methods
     * @returns {String} Test results
     */
    static TestMethodAccessibility() {
        testMap := Map()
        results := "Method Accessibility Test Results:`n`n"

        ; Test SafeSet
        try {
            testMap.SafeSet("test", "value")
            results .= "SafeSet: ✓ Accessible`n"
        } catch as err {
            results .= Format("SafeSet: ✗ Not accessible - {}`n", err.Message)
        }

        ; Test SafeSetMap
        try {
            testMap.SafeSetMap(Map())
            results .= "SafeSetMap: ✓ Accessible`n"
        } catch as err {
            results .= Format("SafeSetMap: ✗ Not accessible - {}`n", err.Message)
        }

        ; Test HasValue
        try {
            testMap.HasValue("test")
            results .= "HasValue: ✓ Accessible`n"
        } catch as err {
            results .= Format("HasValue: ✗ Not accessible - {}`n", err.Message)
        }

        ; Test ToString
        try {
            testMap.ToString()
            results .= "ToString: ✓ Accessible`n"
        } catch as err {
            results .= Format("ToString: ✗ Not accessible - {}`n", err.Message)
        }

        Infos(results)
        return results
    }
}

; Run the tests
; TestRunner()
