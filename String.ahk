/*
Name: String.ahk
Version 0.13 (15.10.22)
Github link: https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/String.ahk
Created: 27.08.22
Author: Descolada
Credit:
tidbit		--- Author of "String Things - Common String & Array Functions", from which
				I copied/based a lot of methods
Contributors to "String Things": AfterLemon, Bon, Lexikos, MasterFocus, Rseding91, Verdlin

Description:
A compilation of useful string methods. Also lets strings be treated as objects.

These methods cannot be used as stand-alone. To do that, you must add another argument
'string' to the function and replace all occurrences of 'this' with 'string'.
.-==========================================================================-.
| Methods                                                                    |
|============================================================================|
| Native functions as methods:                                               |
| String.ToUpper()                                                           |
|       .ToLower()                                                           |
|       .ToTitle()                                                           |
|       .Split([Delimiters, OmitChars, MaxParts])                            |
|       .Replace(Needle [, ReplaceText, CaseSense, &OutputVarCount, Limit])  |
|       .Trim([OmitChars])                                                   |
|       .LTrim([OmitChars])                                                  |
|       .RTrim([OmitChars])                                                  |
|       .Compare(comparison [, CaseSense])                                   |
|       .Sort([, Options, Function])                                         |
|       .Find(Needle [, CaseSense, StartingPos, Occurrence])                 |
|       .SplitPath() => returns object {FileName, Dir, Ext, NameNoExt, Drive}|
|		.RegExMatch(needleRegex, &match?, startingPos?)                      |
|		.RegExReplace(needle, replacement?, &count?, limit?, startingPos?)   |
|                                                                            |
| String[n] => gets nth character                                            |
| String[i,j] => substring from i to j                                       |
| String.Length                                                              |
| String.Count(searchFor)                                                    |
| String.Insert(insert, into [, pos])                                        |
| String.Delete(string [, start, length])                                    |
| String.Overwrite(overwrite, into [, pos])                                  |
| String.Repeat(count)                                                       |
| Delimeter.Concat(words*)                                                   |
|                                                                            |
| String.LineWrap([column:=56, indentChar:=""])                              |
| String.WordWrap([column:=56, indentChar:=""])                              |
| String.ReadLine(line [, delim:="`n", exclude:="`r"])                       |
| String.DeleteLine(line [, delim:="`n", exclude:="`r"])                     |
| String.InsertLine(insert, into, line [, delim:="`n", exclude:="`r"])       |
|                                                                            |
| String.Reverse()                                                           |
| String.Contains(needle1 [, needle2, needle3...])                           |
| String.RemoveDuplicates([delim:="`n"])                                     |
| String.LPad(count)                                                         |
| String.RPad(count)                                                         |
|                                                                            |
| String.Center([fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width])  |
| String.Right([fill:=" ", delim:="`n", exclude:="`r"])                      |
'-==========================================================================-'
*/

String.Prototype := String2

class String2 {

	static ToMap(strObj?) {
        return this._StringToMap(IsSet(strObj) ? strObj : this)
    }

    static _StringToMap(str) {
        StrMap := Map()
        for line in StrSplit(str, "`n", "`r") {
            if (line := Trim(line)) {
                parts := StrSplit(line, "=", " `t", 2)
                if (parts.Length = 2)
                    StrMap[parts[1]] := parts[2]
            }
        }
        return StrMap
    }

    static ToArray(strObj?) {
        return this._StringToArray(IsSet(strObj) ? strObj : this)
    }

    static _StringToArray(str) {
        return StrSplit(str, "`n", "`r")
    }

    static ToObject(strObj?) {
        return this._StringToObject(IsSet(strObj) ? strObj : this)
    }

    static _StringToObject(str) {
        StrObj := {}
        for line in StrSplit(str, "`n", "`r") {
            if (line := Trim(line)) {
                parts := StrSplit(line, "=", " `t", 2)
                if (parts.Length = 2)
                    StrObj.%parts[1]% := parts[2]
            }
        }
        return StrObj
    }

	static __New() {
		; Add String2 methods and properties into String object
		__ObjDefineProp := Object.Prototype.DefineProp
		for __String2_Prop in String2.OwnProps() {
			if !(__String2_Prop ~= "__Init|__Item|Prototype|Length") {
				if HasMethod(String2, __String2_Prop)
					__ObjDefineProp(String.Prototype, __String2_Prop, {call:String2.%__String2_Prop%})
			}
		}
		__ObjDefineProp(String.Prototype, "__Item", {get:(args*)=>String2.__Item[args*]})
		__ObjDefineProp(String.Prototype, "Length", {get:(arg)=>String2.Length(arg)})
		__ObjDefineProp(String.Prototype, "WLength", {get:(arg)=>String2.WLength(arg)})
	}

	; static __Item[args*] {
	; 	get {
	; 		if args.length = 2
	; 			return SubStr(args[1], args[2], 1)
	; 		else {
	; 			len := StrLen(args[1])
	; 			if args[2] < 0
	; 				args[2] := len+args[2]+1
	; 			if args[3] < 0
	; 				args[3] := len+args[3]+1
	; 			if args[3] >= args[2]
	; 				return SubStr(args[1], args[2], args[3]-args[2]+1)
	; 			else
	; 				return SubStr(args[1], args[3], args[2]-args[3]+1).Reverse()
	; 		}
	; 	}
	; }

	static __Item[args*] {
		get {
			if (args.Length = 2) {
				index := IsInteger(args[2]) ? args[2] : 1
				return SubStr(args[1], index, 1)
			} else {
				len := StrLen(args[1])
				start := IsInteger(args[2]) ? args[2] : 1
				end := IsInteger(args[3]) ? args[3] : len
				
				if (start < 0)
					start := len + start + 1
				if (end < 0)
					end := len + end + 1
				
				if (end >= start)
					return SubStr(args[1], start, end - start + 1)
				else
					return SubStr(args[1], end, start - end + 1).Reverse()
			}
		}
	}

	; Native functions implemented as methods for the String object
	static Length(str)    => StrLen(str)
	static WLength(str)   => (RegExReplace(str, "s).", "", &i), i)
	static ToUpper()      => StrUpper(this)
	static ToLower()      => StrLower(this)
	static ToTitle()      => StrTitle(this)
	static Split(args*)   => StrSplit(this, args*)
	static Replace(args*) => StrReplace(this, args*)
	static Trim(args*)    => Trim(this, args*)
	static LTrim(args*)   => LTrim(this, args*)
	static RTrim(args*)   => RTrim(this, args*)
	static Compare(args*) => StrCompare(this, args*)
	static Sort(args*)    => Sort(this, args*)
	static Find(args*)    => InStr(this, args*)
	static SplitPath()    => (SplitPath(this, &a1, &a2, &a3, &a4, &a5), {FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5})
	/**
	 * Returns the match object
	 * @param needleRegex *String* What pattern to match
	 * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	 * @returns {Object}
	 */
	static RegExMatch(needleRegex, &match?, startingPos?) => (RegExMatch(this, needleRegex, &match, startingPos?), match)
	/**
	 * Uses regex to perform a replacement, returns the changed string
	 * @param needleRegex *String* What pattern to match
	 * @param replacement *String* What to replace that match into
	 * @param outputVarCount *Varref* Specify a variable with a `&` before it to assign it to the amount of replacements that have occured
	 * @param limit *Integer* The maximum amount of replacements that can happen. Unlimited by default
	 * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	 * @returns {String} The changed string
	 */
	static RegExReplace(needleRegex, replacement?, &outputVarCount?, limit?, startingPos?) => RegExReplace(this, needleRegex, replacement?, &outputVarCount?, limit?, startingPos?)

	/**
	 * Add character(s) to left side of the input string.
	 * example: "aaa".LPad("+", 5)
	 * output: +++++aaa
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static LPad(padding, count:=1) {
		str := this
		if (count>0) {
			Loop count
				str := padding str
		}
		return str
	}

	/**
	 * Add character(s) to right side of the input string.
	 * example: "aaa".RPad("+", 5)
	 * output: aaa+++++
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static RPad(padding, count:=1) {
		str := this
		if (count>0) {
			Loop count
				str := str padding
		}
		return str
	}

	/**
	 * Count the number of occurrences of needle in the string
	 * input: "12234".Count("2")
	 * output: 2
	 * @param needle Text to search for
	 * @param caseSensitive
	 * @returns {Integer}
	 */
	static Count(needle, caseSensitive:=False) {
		StrReplace(this, needle,, caseSensitive, &count)
		return count
	}

	/**
	 * Duplicate the string 'count' times.
	 * input: "abc".Repeat(3)
	 * output: "abcabcabc"
	 * @param count *Integer*
	 * @returns {String}
	 */
	static Repeat(count) => StrReplace(Format("{:" count "}",""), " ", this)

	/**
	 * Reverse the string.
	 * @returns {String}
	 */
	static Reverse() {
		DllCall("msvcrt\_wcsrev", "str", str := this, "CDecl str")
		return str
	}
	static WReverse() {
		str := this, out := "", m := ""
		While str && (m := Chr(Ord(str))) && (out := m . out)
			str := SubStr(str,StrLen(m)+1)
		return out
	}

	/**
	 * Insert the string inside 'insert' into position 'pos'
	 * input: "abc".Insert("d", 2)
	 * output: "adbc"
	 * @param insert The text to insert
	 * @param pos *Integer*
	 * @returns {String}
	 */
	static Insert(insert, pos:=1) {
		Length := StrLen(this)
		((pos > 0)
			? pos2 := pos - 1
			: (pos = 0
				? (pos2 := StrLen(this), Length := 0)
				: pos2 := pos
				)
		)
		output := SubStr(this, 1, pos2) . insert . SubStr(this, pos, Length)
		if (StrLen(output) > StrLen(this) + StrLen(insert))
			((Abs(pos) <= StrLen(this)/2)
				? (output := SubStr(output, 1, pos2 - 1)
					. SubStr(output, pos + 1, StrLen(this))
				)
				: (output := SubStr(output, 1, pos2 - StrLen(insert) - 2)
					. SubStr(output, pos - StrLen(insert), StrLen(this))
				)
			)
		return output
	}

	/**
	 * Replace part of the string with the string in 'overwrite' starting from position 'pos'
	 * input: "aaabbbccc".Overwrite("zzz", 4)
	 * output: "aaazzzccc"
	 * @param overwrite Text to insert.
	 * @param pos The position where to begin overwriting. 0 may be used to overwrite at the very end, -1 will offset 1 from the end, and so on.
	 * @returns {String}
	 */
	static Overwrite(overwrite, pos:=1) {
		if (Abs(pos) > StrLen(this))
			return ""
		else if (pos>0)
			return SubStr(this, 1, pos-1) . overwrite . SubStr(this, pos+StrLen(overwrite))
		else if (pos<0)
			return SubStr(this, 1, pos) . overwrite . SubStr(this " ",(Abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0), Abs(pos+StrLen(overwrite)))
		else if (pos=0)
			return this . overwrite
	}

	/**
	 * Delete a range of characters from the specified string.
	 * input: "aaabbbccc".Delete(4, 3)
	 * output: "aaaccc"
	 * @param start The position where to start deleting.
	 * @param length How many characters to delete.
	 * @returns {String}
	 */
	static Delete(start:=1, length:=1) {
		if (Abs(start) > StrLen(this))
			return ""
		if (start>0)
			return SubStr(this, 1, start-1) . SubStr(this, start + length)
		else if (start<=0)
			return SubStr(this " ", 1, start-1) SubStr(this " ", ((start<0) ? start-1+length : 0), -1)
	}

	/**
	 * Wrap the string so each line is never more than a specified length.
	 * input: "Apples are a round fruit, usually red".LineWrap(20, "---")
	 * output: "Apples are a round f
	 *          ---ruit, usually red"
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static LineWrap(column:=56, indentChar:="") {
		CharLength := StrLen(indentChar)
		, columnSpan := column - CharLength
		, Ptr := A_PtrSize ? "Ptr" : "UInt"
		, UnicodeModifier := 2
		, VarSetStrCapacity(&out, (finalLength := (StrLen(this) + (Ceil(StrLen(this) / columnSpan) * (column + CharLength + 1))))*2)
		, A := StrPtr(out)

		Loop parse, this, "`n", "`r" {
			if ((FieldLength := StrLen(ALoopField := A_LoopField)) > column) {
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", column * UnicodeModifier)
				, A += column * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
				, Pos := column

				While (Pos < FieldLength) {
					if CharLength
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(indentChar), "UInt", CharLength * UnicodeModifier)
						, A += CharLength * UnicodeModifier

					if (Pos + columnSpan > FieldLength)
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", (FieldLength - Pos) * UnicodeModifier)
						, A += (FieldLength - Pos) * UnicodeModifier
						, Pos += FieldLength - Pos
					else
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", columnSpan * UnicodeModifier)
						, A += columnSpan * UnicodeModifier
						, Pos += columnSpan

					NumPut("UShort", 10, A)
					, A += UnicodeModifier
				}
			} else
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", FieldLength * UnicodeModifier)
				, A += FieldLength * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
		}
		NumPut("UShort", 0, A)
		VarSetStrCapacity(&out, -1)
		return SubStr(out,1, -1)
	}

	/**
	 * Wrap the string so each line is never more than a specified length.
	 * Unlike LineWrap(), this method takes into account words separated by a space.
	 * input: "Apples are a round fruit, usually red.".WordWrap(20, "---")
	 * output: "Apples are a round
	 *          ---fruit, usually
	 *          ---red."
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static WordWrap(column:=56, indentChar:="") {
		if !IsInteger(column)
			throw TypeError("WordWrap: argument 'column' must be an integer", -1)
		out := ""
		indentLength := StrLen(indentChar)

		Loop parse, this, "`n", "`r" {
			if (StrLen(A_LoopField) > column) {
				pos := 1
				Loop parse, A_LoopField, " "
					if (pos + (LoopLength := StrLen(A_LoopField)) <= column)
						out .= (A_Index = 1 ? "" : " ") A_LoopField
						, pos += LoopLength + 1
					else
						pos := LoopLength + 1 + indentLength
						, out .= "`n" indentChar A_LoopField

				out .= "`n"
			} else
				out .= A_LoopField "`n"
		}
		return SubStr(out, 1, -1)
	}

	/**
	* Insert a line of text at the specified line number.
	* The line you specify is pushed down 1 and your text is inserted at its
	* position. A "line" can be determined by the delimiter parameter. Not
	* necessarily just a `r or `n. But perhaps you want a | as your "line".
	* input: "aaa|ccc|ddd".InsertLine("bbb", 2, "|")
	* output: "aaa|bbb|ccc|ddd"
	* @param insert Text you want to insert.
	* @param line What line number to insert at. Use a 0 or negative to start inserting from the end.
	* @param delim The string which defines a "line".
	* @param exclude The text you want to ignore when defining a line.
	* @returns {String}
	*/
	static InsertLine(insert, line, delim:="`n", exclude:="`r") {
		into := this, new := ""
		count := into.Count(delim)+1

		; Create any lines that don't exist yet, if the Line is less than the total line count.
		if (line<0 && Abs(line)>count) {
			Loop Abs(line)-count
				into := delim into
			line:=1
		}
		if (line == 0)
			line:=Count+1
		if (line<0)
			line:=count+line+1
		; Create any lines that don't exist yet. Otherwise the Insert doesn't work.
		if (count<line)
			Loop line-count
				into.=delim

		Loop parse, into, delim, exclude
			new.=((a_index==line) ? insert . delim . A_LoopField . delim : A_LoopField . delim)

		return RTrim(new, delim)
	}

	/**
	 * Delete a line of text at the specified line number.
	 * The line you specify is deleted and all lines below it are shifted up.
	 * A "line" can be determined by the delimiter parameter. Not necessarily
	 * just a `r or `n. But perhaps you want a | as your "line".
	 * input: "aaa|bbb|777|ccc".DeleteLine(3, "|")
	 * output: "aaa|bbb|ccc"
	 * @param string Text you want to delete the line from.
	 * @param line What line to delete. You may use -1 for the last line and a negative an offset from the last. -2 would be the second to the last.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static DeleteLine(line, delim:="`n", exclude:="`r") {
		new := ""
		; checks to see if we are trying to delete a non-existing line.
		count:=this.Count(delim)+1
		if (abs(line)>Count)
			throw ValueError("DeleteLine: the line number cannot be greater than the number of lines", -1)
		if (line<0)
			line:=count+line+1
		else if (line=0)
			throw ValueError("DeleteLine: line number cannot be 0", -1)

		Loop parse, this, delim, exclude {
			if (a_index==line) {
				Continue
			} else
				(new .= A_LoopField . delim)
		}

		return SubStr(new,1,-StrLen(delim))
	}

	/**
	 * Read the content of the specified line in a string. A "line" can be
	 * determined by the delimiter parameter. Not necessarily just a `r or `n.
	 * But perhaps you want a | as your "line".
	 * input: "aaa|bbb|ccc|ddd|eee|fff".ReadLine(4, "|")
	 * output: "ddd"
	 * @param line What line to read*. "L" = The last line. "R" = A random line. Otherwise specify a number to get that line. You may specify a negative number to get the line starting from the end. -1 is the same as "L", the last. -2 would be the second to the last, and so on.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static ReadLine(line, delim:="`n", exclude:="`r") {
		out := "", count:=this.Count(delim)+1

		if (line="R")
			line := Random(1, count)
		else if (line="L")
			line := count
		else if abs(line)>Count
			throw ValueError("ReadLine: the line number cannot be greater than the number of lines", -1)
		else if (line<0)
			line:=count+line+1
		else if (line=0)
			throw ValueError("ReadLine: line number cannot be 0", -1)

		Loop parse, this, delim, exclude {
			if A_Index = line
				return A_LoopField
		}
		throw Error("ReadLine: something went wrong, the line was not found", -1)
	}


	/**
	 * Replace all consecutive occurrences of 'delim' with only one occurrence.
	 * input: "aaa|bbb|||ccc||ddd".RemoveDuplicates("|")
	 * output: "aaa|bbb|ccc|ddd"
	 * @param delim *String*
	 */
	static RemoveDuplicates(delim:="`n") => RegExReplace(this, "(\Q" delim "\E)+", "$1")


	/**
	 * Checks whether the string contains any of the needles provided.
	 * input: "aaa|bbb|ccc|ddd".Contains("eee", "aaa")
	 * output: 1 (although the string doesn't contain "eee", it DOES contain "aaa")
	 * @param needles
	 * @returns {Boolean}
	 */
	static Contains(needles*) {
		for needle in needles
			if InStr(this, needle)
				return 1
		return 0
	}

	/**
	 * Centers a block of text to the longest item in the string.
	 * example: "aaa`na`naaaaaaaa".Center()
	 * output: "aaa
	 *           a
	 *       aaaaaaaa"
	 * @param text The text you would like to center.
	 * @param fill A single character to use as the padding to center text.
	 * @param symFill 0: Just fill in the left half. 1: Fill in both sides.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @param width Can be specified to add extra padding to the sides
	 * @returns {String}
	 */
	static Center(fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width?) {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest := StrLen(A_LoopField)
		if IsSet(width)
			longest := Max(longest, width)
		Loop parse this, delim, exclude
		{
			filled:="", len := StrLen(A_LoopField)
			Loop (longest-len)//2
				filled.=fill
			new .= filled A_LoopField ((symFill=1) ? filled (2*StrLen(filled)+len = longest ? "" : fill) : "") "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * Align a block of text to the right side.
	 * input: "aaa`na`naaaaaaaa".Right()
	 * output: "     aaa
	 *                 a
	 *          aaaaaaaa"
	 * @param fill A single character to use as to push the text to the right.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static Right(fill:=" ", delim:="`n", exclude:="`r") {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest:=StrLen(A_LoopField)
		Loop parse, this, delim, exclude {
			filled:=""
			Loop Abs(longest-StrLen(A_LoopField))
				filled.=fill
			new.= filled A_LoopField "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * Join a list of strings together to form a string separated by delimiter this was called with.
	 * input: "|".Concat("111", "222", "333", "abc")
	 * output: "111|222|333|abc"
	 * @param words A list of strings separated by a comma.
	 * @returns {String}
	 */
	static Concat(words*) {
		delim := this, s := ""
		for v in words{
			s .= v . delim
		}
		return SubStr(s,1,-StrLen(this))
	}

	/**
	 * Calculates the Damerau-Levenshtein distance between two strings.
	 * @param s The first string to compare.
	 * @param t The second string to compare.
	 * @returns {Integer} The number of operations required to transform one string into another.
	 */
	static DamerauLevenshteinDistance(s, t) {
		m := StrLen(s)
		n := StrLen(t)
		if (m = 0){
			return n
		}
		if (n = 0){
			return m
		}
		d := Array()
		d.Push([])
		d[1].Push(0)
		Loop m+1
			d[1].Push(A_Index)
		Loop n {
			d.Push([A_Index])
			Loop m+1{
				d[A_Index+1].Push(0)
			}
		}

		ix := 0
		iy := -1
		Loop Parse, s {
			sc := A_LoopField
			i := A_Index
			jx := 0
			jy := -1
			Loop Parse, t {
				j := A_Index
				a := d[ix+1][jx+1] + 1
				b := d[i+1][jx+1] + 1
				c := (A_LoopField != sc) + d[ix+1][jx+1]
				d[i+1][j+1] := Min(a, b, c)

				if (i > 1 and j > 1 and sc = tx and sx = A_LoopField){
					d[i+1][j+1] := Min(d[i+1][j+1], d[iy+1][ix+1] + c)
				}

				jx++
				jy++
				tx := A_LoopField
			}
			ix++
			iy++
			sx := A_LoopField
		}
		return d[m+1][n+1]
	}

	static LevenshteinDistance(s, t) {
		m := StrLen(s)
		n := StrLen(t)
		d := Array()
	
		Loop m+1{
			d.Push([A_Index-1])
		}
		Loop n{
			d[1].Push(A_Index)
		}
	
		Loop m {
			i := A_Index + 1
			Loop n {
				j := A_Index + 1
				cost := (SubStr(s, i-1, 1) != SubStr(t, j-1, 1))
				d[i][j] := Min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost)
			}
		}
		return d[m+1][n+1]
	}

	; Choose(options*){
	; 	if options.length == 1 {
	; 		return options[1]
	; 	}
		
	; 	else {
	; 		infoObjs := [Infos("")]
	; 		for index, option in options {
	; 			if infoObjs.Length >= Infos.maximumInfos
	; 				break
	; 			infoObjs.Push(Infos(option))
	; 		}
	; 		loop {
	; 			for index, infoObj in infoObjs {
	; 				if WinExist(infoObj.hwnd)
	; 					continue
	; 				text := infoObj.text
	; 				break 2
	; 			}
	; 		}
	; 		for index, infoObj in infoObjs {
	; 			infoObj.Destroy()
	; 		}
	; 		return text
	; 	}
	; }

	static LongestCommonSubsequence(s, t) {
		m := StrLen(s)
		n := StrLen(t)
		L := Array()
	
		Loop m+1 {
			L.Push([])
			Loop n+1{
				L[A_Index].Push(0)
			}
		}
	
		Loop m {
			i := A_Index
			Loop n {
				j := A_Index
				if (SubStr(s, i, 1) = SubStr(t, j, 1)){
					L[i+1][j+1] := L[i][j] + 1
				}
				else{
					L[i+1][j+1] := Max(L[i+1][j], L[i][j+1])
				}
			}
		}
	
		return L[m+1][n+1]
	}

	static JaroWinklerDistance(s, t) {
		jaroDist := this.JaroDistance(s, t)
		prefixLength := 0
		Loop 4 {
			if (SubStr(s, A_Index, 1) = SubStr(t, A_Index, 1))
				prefixLength++
			else
				break
		}
		return jaroDist + (prefixLength * 0.1 * (1 - jaroDist))
	}
	
	static JaroDistance(s, t) {
		sLen := StrLen(s)
		tLen := StrLen(t)
		
		if (sLen = 0 and tLen = 0)
			return 1
		
		matchDistance := Floor(Max(sLen, tLen) / 2) - 1
		sMatches := Array(), tMatches := Array()
		matches := 0, transpositions := 0
		
		Loop Parse, s {
			start := Max(1, A_Index - matchDistance)
			end := Min(A_Index + matchDistance, tLen)
			Loop end - start + 1 {
				j := start + A_Index - 1
				if (!tMatches[j] and A_LoopField = SubStr(t, j, 1)) {
					sMatches[A_Index] := true
					tMatches[j] := true
					matches++
					break
				}
			}
		}
		
		if (matches = 0)
			return 0
		
		k := 1
		Loop Parse, s {
			if (sMatches[A_Index]) {
				while (!tMatches[k])
					k++
				if (A_LoopField != SubStr(t, k, 1))
					transpositions++
				k++
			}
		}
		
		return (matches / sLen + matches / tLen + (matches - transpositions / 2) / matches) / 3
	}

	static HammingDistance(s, t) {
		if (StrLen(s) != StrLen(t))
			throw Error("Strings must be of equal length")
		
		distance := 0
		Loop Parse, s
			if (A_LoopField != SubStr(t, A_Index, 1))
				distance++
		return distance
	}

	; Improved FindBestMatch method
    static FindBestMatch(input, possibilities) {
        bestMatch := ""
        highestScore := 0

        for _, possibility in possibilities {
            score := this.CalculateSimilarityScore(input, possibility)
            if (score > highestScore) {
                highestScore := score
                bestMatch := possibility
            }
        }

        return bestMatch
    }

    ; Calculate similarity score between two strings
    static CalculateSimilarityScore(str1, str2) {
        ; Combine multiple similarity metrics for a more robust match
        levenshteinScore := 1 - (this.LevenshteinDistance(str1, str2) / Max(StrLen(str1), StrLen(str2)))
        jaroWinklerScore := this.JaroWinklerSimilarity(str1, str2)
        prefixScore := this.PrefixSimilarity(str1, str2)

        ; Weighted average of scores
        return (levenshteinScore * 0.4) + (jaroWinklerScore * 0.4) + (prefixScore * 0.2)
    }

    ; Jaro-Winkler similarity
    static JaroWinklerSimilarity(s, t) => this.JaroWinklerDistance(s, t)

    ; Prefix similarity
    static PrefixSimilarity(s, t) {
        commonPrefixLength := 0
        minLength := Min(StrLen(s), StrLen(t))

        while (commonPrefixLength < minLength && SubStr(s, commonPrefixLength + 1, 1) == SubStr(t, commonPrefixLength + 1, 1)) {
            commonPrefixLength++
        }

        return commonPrefixLength / Max(StrLen(s), StrLen(t))
    }

}

DamerauLevenshteinDistance(s, t) {
	m := StrLen(s)
	n := StrLen(t)
	if (m = 0)
		return n
	if (n = 0)
		return m

	d := Array()
	d.Push([])
	d[1].Push(0)
	Loop m+1
		d[1].Push(A_Index)
	Loop n
	{
		d.Push([A_Index])
		Loop m+1
			d[A_Index+1].Push(0)
	}

	ix := 0
	iy := -1
	Loop Parse, s
	{
		sc := A_LoopField
		i := A_Index
		jx := 0
		jy := -1
		Loop Parse, t
		{
			j := A_Index
			a := d[ix+1][jx+1] + 1
			b := d[i+1][jx+1] + 1
			c := (A_LoopField != sc) + d[ix+1][jx+1]
			d[i+1][j+1] := Min(a, b, c)

			if (i > 1 and j > 1 and sc = tx and sx = A_LoopField)
				d[i+1][j+1] := Min(d[i+1][j+1], d[iy+1][ix+1] + c)

			jx++
			jy++
			tx := A_LoopField
		}
		ix++
		iy++
		sx := A_LoopField
	}
	return d[m+1][n+1]
}

String2.Prototype.Base := Text2

Class Text2 {
	static CompressSpaces() => RegexReplace(this, " {2,}", " ")

	static WriteFile(whichFile, flags := 'rw', encoding := 'UTF-8-RAW') {
		; fileObj := FileOpen(whichFile, "w", "UTF-8-RAW")
		; fileObj := FileOpen(whichFile, 'rw', 'UTF-8')
		; fileObj := FileOpen(this, 'rw')
		fileObj := FileOpen(whichFile, flags, encoding) || fileObj := FileOpen(this, flags, encoding)
		fileObj.Write(this)
	}

	static AppendFile(whichFile, encoding := 'UTF-8-RAW') => FileAppend(this, whichFile, encoding)

	static ToggleInfo() {
		g_ToggleInfo := Gui("AlwaysOnTop -Caption +ToolWindow").DarkMode().MakeFontNicer()
		g_ToggleInfo.AddText(, this)
		g_ToggleInfo.Show("W225 NA x1595 y640")
		SetTimer(() => g_ToggleInfo.Destroy(), -1000)
		return this
	}

	static FileWrite(content, filePath) {
		FileAppend(content, filePath, "UTF-8")
	}


	/**
	 * 
	 * @param {String} whichFile New file name or path to existing file
	 * @param {String} ext extension of the new file: Default: .txt
	 * @returns {String} newfile returns the new file name and associated extension
	 */
	static WriteTxtToFile(whichFile := A_ScriptDir '\' whichFile, ext := '.txt') {
		if FileExist(whichFile) {
			FileDelete(whichFile)
			this.AppendFile(this)
		}
		else {
			newfile := whichFile ext
			this.AppendFile(newfile)
			return newfile
		}
	}
}


File.Prototype.Base := File2
; File.Prototype.Append := (content) => FileWrite(content, this, "UTF-8")

Class File2 {

	static Run() => Run(this)

	; static ReadFile() => FileRead(this, 'UTF-8')
	static SwitchFiles(path2) {

		file1Read := FileOpen(this, "r", "UTF-8-RAW")
		file1Read.Seek(0, 0)
	
		file2Read := FileOpen(path2, "r", "UTF-8-RAW")
		file2Read.Seek(0, 0)
	
		text1 := file1Read.Read()
		text2 := file2Read.Read()
	
		file1Write := FileOpen(this, "w", "UTF-8-RAW")
	
		file2Write := FileOpen(path2, "w", "UTF-8-RAW")
	
		file1Write.Write(text2)
		file2Write.Write(text1)
	
		file1Read.Close()
		file2Read.Close()
	
		file1Write.Close()
		file2Write.Close()
	}

	/**
	 * @param {String} flags default flags of 'r'
	 * @param {String} encoding default encoding := 'UTF-8-RAW' 
	 * @returns {File} Same as FileOpen() but with default flags, and default encoding
	 */
	static Open() => FileOpen(this, "r", encoding := 'UTF-8-RAW')

		/**
	 * @param {String} flags default flags of 'r a' (read & append if the file doesn't exist)
	 * @param {String} encoding default encoding := 'UTF-8-RAW' 
	 * @returns {File} Same as FileOpen() but with default flags, and default encoding
	 */
	static Open2() => FileOpen(this, "r a", encoding := 'UTF-8-RAW')

	static Read2() => this.FileRead()

	static FileRead(text := '', encoding := 'UTF-8-RAW') {
		; !(file2Read := FileOpen(this, "r", encoding)) ? file2Read := FileOpen(this, "r a", encoding) : file2Read := FileOpen(this, "r", encoding)
		!(file2Read := this.Open()) ? file2Read := this.Open2() : file2Read := this.Open()
		text := file2Read.Read()
		file2Read.Seek(0, 0)
		file2Read.Close()
		return text
	}

	static WriteToFile(text := '', encoding := 'UTF-8-RAW') {

		; if !(fileRead := FileOpen(this, "r", encoding)) {
		; 	fileRead := FileOpen(this, "r a", encoding)
		; }
		; else {
		; 	fileRead := FileOpen(this, "r", encoding)
		; }
		!(file2Read := FileOpen(this, "r", encoding)) ? file2Read := FileOpen(this, "r a", encoding) : file2Read := FileOpen(this, "r", encoding)
		file2Read.Seek(0, 0)
	
		; file2Read := FileOpen(path2, "r", "UTF-8-RAW")
		; file2Read.Seek(0, 0)
	
		text := file2Read.Read()
		; text2 := file2Read.Read()
	
		file2Write := FileOpen(this, "w", encoding)
	
		; file2Write := FileOpen(path2, "w", "UTF-8-RAW")
	
		file2Write.Write(text)
		; file2Write.Write(text1)
	
		; file2Read.Close()
		; file2Read.Close()
	
		file2Write.Close()
		; file2Write.Close()
	}
	; Adding static method to built-in File class
	static Ext(filename){
		SplitPath(filename,, &dir, &ext)
		return ext
	}
}

; Standalone function
FileExt(filename) {
	SplitPath(filename,, &dir, &ext)
	return ext
}

class Unicode {

	static Symbols := Map(

		" ",                        0x0020,
		"zwj",                      0x200D,
		"varsel16",                 0xFE0F,
		"female sign",              0x2640,  ; ♀
		"pleading",                 0x1F97A, ; 🥺
		"yum",                      0x1F60B, ; 😋
		"exploding head",           0x1F92F, ; 🤯
		"smirk cat",                0x1F63C, ; 😼
		"sunglasses",               0x1F60E, ; 😎
		"sob",                      0x1F62D, ; 😭
		"face with monocle",        0x1F9D0, ; 🧐
		"flushed",                  0x1F633, ; 😳
		"face with raised eyebrow", 0x1F928, ; 🤨
		"purple heart",             0x1F49C, ; 💜
		"skull",                    0x1F480, ; 💀
		"rolling eyes",             0x1F644, ; 🙄
		"thinking",                 0x1F914, ; 🤔
		"weary",                    0x1F629, ; 😩
		"woozy",                    0x1F974, ; 🥴
		"finger left",              0x1F448, ; 👈
		"finger right",             0x1F449, ; 👉
		"drooling",                 0x1F924, ; 🤤
		"eggplant",                 0x1F346, ; 🍆
		"smiling imp",              0x1F608, ; 😈
		"fearful",                  0x1F628, ; 😨
		"middle dot",               0x00B7,  ; ·
		"long dash",                0x2014,  ; —
		"sun",                      0x2600,  ; ☀
		"cloud",                    0x2601,  ; ☁
		"nerd",                     0x1F913, ; 🤓
		"handshake",                0x1F91D, ; 🤝
		"shrug",                    0x1F937, ; 🤷
		"clap",                     0x1F44F, ; 👏
		"amogus",                   0x0D9E,  ; ඞ
		"confetti",                 0x1F389, ; 🎉
		"eyes",                     0x1F440, ; 👀
		"sneezing face",            0x1F927, ; 🤧
		"grimacing",                0x1F62C, ; 😬
		"crossed out",              0x1F635, ; 😵
		"dizzy",                    0x1F4AB, ; 💫
		"face with hearts",         0x1F970, ; 🥰
		"innocent",                 0x1F607, ; 😇
		"scarf",                    0x1F9E3, ; 🧣
		"sparkles",                 0x2728,  ; ✨
		"relieved",                 0x1F60C, ; 😌
		"knot",                     0x1FAA2, ;
		"comet",                    0x2604,  ; ☄️varsel16
		"panda",                    0x1F43C, ; 🐼
		"bamboo",                   0x1F38D, ; 🎍
		"muscle",                   0x1F4AA, ; 💪
		"scale",                    0x2696,  ; ⚖varsel16
		"alien",                    0x1F47D, ; 👽
		"badminton",                0x1F3F8, ; 🏸
		"clipboard",                0x1F4CB, ; 📋
		"lobster",                  0x1F99E, ; 🦞
		"rosette",                  0x1F3F5, ; 🏵varsel16
		"gem",                      0x1F48E, ; 💎
		"firecracker",              0x1F9E8, ; 🧨
		"athletic shoe",            0x1F45F, ; 👟
		"fish",                     0x1F41F, ; 🐟
		"satellite",                0x1F6F0, ; 🛰varsel16
		"statue of liberty",        0x1F5FD, ; 🗽
		"tropical fish",            0x1F420, ; 🐠
		"penguin",                  0x1F427, ; 🐧
		"kiwi",                     0x1F95D, ; 🥝
		"archery",                  0x1F3F9, ; 🏹
		"shell",                    0x1F41A, ; 🐚
		"shrimp",                   0x1F990, ; 🦐
		"broom",                    0x1F9F9, ; 🧹
		"ocean",                    0x1F30A, ; 🌊
		"wolf",                     0x1F43A, ; 🐺
		"paperclip",                0x1F4CE, ; 📎
		"nail polish",              0x1F485, ; 💅
		"shell top arc",            0x256D,  ; ╭
		"shell horizontal",         0x2500,  ; ─
		"shell bottom arc",         0x2570,  ; ╰
		"shell middle line",        0x2502,  ; │
		"cat",                      0x1F408, ; 🐈
		"chicken",                  0x1F414, ; 🐔
		"parrot",                   0x1F99C, ; 🦜
		"cricket",                  0x1F997, ; 🦗
		"glowing star",             0x1F31F, ; 🌟
		"ship",                     0x1F6A2, ; 🚢

	)

	/**
	* Sends a unicode character using the Send function by using the character's predefined name
	* @param name *String* The predefined name of the character
	* @param endingChar *String* The string to append to the character. For example, a space or a newline
	*/
	static Send(symbols*) {
		output := ''
		for index, symbol in symbols{
			output .= Chr(this.Symbols[symbol])
		}
		if symbols.Length > 1{
			Clip.Send(output)
		}
		else{
			SendText(output)
		}
	}

	static DynamicSend() {
		output := ''
		if !input := CleanInputBox().WaitForInput(){
			return
		}
		symbols := StrSplit(input, ",")
		for index, symbol in symbols {
			output .= Chr(this.Symbols.Choose(symbol))
		}
		Clip.Send(output)
	}

}
; #Include <Directives\__AE.v2>
; #Requires AutoHotkey v2+
; OnError(LogError)
; i := Integer("cause_error")

; LogError(exception, mode) {
; 	FileAppend("Error on line " exception.Line ": " exception.Message "`n", "errorlog.txt")
; 	return true
; }

; --------------------------------------------------------------------------------
CompressSpaces(text) => RegexReplace(text, " {2,}", " ")


/**
* Syntax sugar. Write text to a file
* @param whichFile *String* The path to the file
* @param text *String* The text to write
*/
WriteFile(whichFile, text := "") {
	; fileObj := FileOpen(whichFile, "w", "UTF-8-RAW")
	; fileObj := FileOpen(whichFile, 'rw', 'UTF-8')
	fileObj := FileOpen(whichFile, 'rw')
	fileObj.Write(text)
}

/**
* Syntax sugar. Append text to a file, or write it if the file
* doesn't exist yet
* @param whichFile *String* The path to the file
* @param text *String* The text to write
*/
AppendFile(whichFile, text) => FileAppend(text, whichFile, "UTF-8-RAW")



/**
* Syntax sugar. Reads a file and returns the text in it
* @param whichFile *String* The path to the file to read
* @returns {String}
*/
; ReadFile(whichFile) => FileRead(whichFile, 'UTF-8-RAW')
ReadFile(whichFile) => FileRead(whichFile, 'UTF-8')

/**
* Switch the contents of two files.
* The contents of file a will now be in file b, and the contents of file b will now be in file a.
* "Why not just use ReadFile and then WriteFile?" — Closing the file objects happens slower than ahk thinks.
* Because of this, there's a chance to have a failed write to one of the files, losing the data you were trying to write to it.
* Meaning, you end up with one file's contents just lost, effectively moving one file onto another.
* And there's no worse thing than code that works only *sometimes*.
* @param path1 ***String***
* @param path2 ***String***
*/
SwitchFiles(path1, path2) {

	file1Read := FileOpen(path1, "r", "UTF-8-RAW")
	file1Read.Seek(0, 0)

	file2Read := FileOpen(path2, "r", "UTF-8-RAW")
	file2Read.Seek(0, 0)

	text1 := file1Read.Read()
	text2 := file2Read.Read()

	file1Write := FileOpen(path1, "w", "UTF-8-RAW")

	file2Write := FileOpen(path2, "w", "UTF-8-RAW")

	file1Write.Write(text2)
	file2Write.Write(text1)

	file1Read.Close()
	file2Read.Close()

	file1Write.Close()
	file2Write.Close()
}
