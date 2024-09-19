/************************************************************************
 * @description Initialize a Class Property
 * @author OvercastBTC
 * @author Orignal by Axlefublr
 * @date 2024/09/11
 * @version 1.0.0
 * @class Initializable
 ***********************************************************************/

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
