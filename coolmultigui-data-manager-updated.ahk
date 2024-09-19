#Requires AutoHotkey v2.0

class DataManager {
    static dataFile := "CoolMultiGUIData.json"

    SaveData(data) {
        try {
            jsonString := jsongo.Stringify(data, 4)
            FileDelete(this.dataFile)
            FileAppend(jsonString, this.dataFile, "UTF-8")
        } catch as err {
            ErrorLogger.Log("Error saving data: " . err.Message)
        }
    }

    LoadData() {
        try {
            if FileExist(this.dataFile) {
                fileContent := FileRead(this.dataFile, "UTF-8")
                return jsongo.Parse(fileContent)
            }
        } catch as err {
            ErrorLogger.Log("Error loading data: " . err.Message)
        }
        return {instances: []}
    }

    StoreRevision(instanceName, revisionData) {
        data := this.LoadData()
        if !data.HasOwnProp("revisions")
            data.revisions := Map()
        
        if !data.revisions.Has(instanceName)
            data.revisions[instanceName] := []
        
        data.revisions[instanceName].Push({
            timestamp: A_Now,
            data: revisionData
        })
        
        this.SaveData(data)
    }

    GetRevisions(instanceName) {
        data := this.LoadData()
        if data.HasOwnProp("revisions") && data.revisions.Has(instanceName)
            return data.revisions[instanceName]
        return []
    }

    DeleteInstance(instanceName) {
        data := this.LoadData()
        for index, instance in data.instances {
            if instance.name == instanceName {
                data.instances.RemoveAt(index)
                break
            }
        }
        this.SaveData(data)
    }
}
