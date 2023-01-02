import SwiftUI
import Charts
import PlaygroundSupport


// Chart View dimensions
let chartMaxWidth: CGFloat = 860.0
// Extra Offset
let chartOffset:CGFloat = 40.0
let chartMaxHeight:CGFloat = 260.0

// DataElement class which defines the Consumer Price Index Data
struct DataElement: Identifiable {
    // Unique id
    var id = UUID()
    // Consumer Price Index value
    let cpiValue: Double
    // Sector like Rural, Urban
    let sector: String
    // effective year
    let year: Int
    // Month
    let month: String
    // In this example filtering "Andhra Pradesh"
    let state: String
}


/*---------------------------------------------------------------------------------
                        LOADING THE JSON FROM RESOURCES
---------------------------------------------------------------------------------*/
let dataPath = Bundle.main.path(forResource: "sample_cpi_data", ofType: "json")!
let jsonData = try String(contentsOfFile: dataPath).data(using: .utf8)!

// Storing the key values based on Index
var fieldList: [String] = [String]()
// Chart dataList array
var dataList: [DataElement] = [DataElement]()

if let json = try? JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as? NSDictionary
{
    let fields = json.object(forKey: "fields") as! NSArray
    
    for field in fields {
        let fieldDict = field as! NSDictionary
        let labelValue = fieldDict.object(forKey: "label") as! String
        fieldList.append(labelValue)
    }
    
    let dataArray = json.object(forKey: "data") as! NSArray
    
    for item in dataArray {
        let itemDict = item as! NSArray
        let sector = itemDict[0] as! String
        let year = itemDict[1] as! Int
        let month = itemDict[2] as! String
        // Taking only first state from the JSON "Andhra Pradesh"
        if let value = itemDict[3] as? Double {
            let dataItem = DataElement(cpiValue: value,
                                       sector: sector,
                                       year: year,
                                       month: month,
                                       state: fieldList[3])
            //print(dataItem)
            dataList.append(dataItem)
        }
    }
}

/*---------------------------------------------------------------------------------
            FILTERING THE DATA AGAIN BASED ON YEAR 2011 & SECTOR AS RURAL
---------------------------------------------------------------------------------*/
let filteredList = dataList.filter { element in
    return element.year == 2011 && element.sector == "Rural"
}


/*---------------------------------------------------------------------------------
                    THE MASTERVIEW WHERE THE CHARTS ARE ADDED
---------------------------------------------------------------------------------*/
struct ContentView: View {
    var body: some View {
        VStack {
            BarChart()
            CustomBarChart()
            LineChart()
            AreaChart()
            RuleChart()
        }
        .frame(width: (chartMaxWidth + chartOffset),
               height:(chartMaxHeight*6),
               alignment: .center
        )
        .padding()
    }
}

/*---------------------------------------------------------------------------------
                                SAMPLE BAR CHART
---------------------------------------------------------------------------------*/
struct BarChart: View {
    var body: some View {
        Chart(filteredList, id: \.month) {
            BarMark(
                x: .value("Months", $0.month),
                y: .value("CPI", $0.cpiValue),
                width: 2,
                height: 150
            )
        }
        .frame(width: chartMaxWidth, height: chartMaxHeight, alignment: .center)
        .foregroundStyle(.red)
    }
    
}

/*---------------------------------------------------------------------------------
                    SAMPLE CUSTOM BAR CHART BY INVERTING X, Y
---------------------------------------------------------------------------------*/
struct CustomBarChart: View {
    var body: some View {
        Chart(filteredList, id: \.month) {
            BarMark(
                x: .value("CPI", $0.cpiValue),
                y: .value("Months", $0.month),
                width: 20
            )
        }
        .frame(width: chartMaxWidth, height: chartMaxHeight*2, alignment: .center)
        .foregroundStyle(.purple)
    }
    
}

/*---------------------------------------------------------------------------------
                                SAMPLE LINE CHART
---------------------------------------------------------------------------------*/
struct LineChart: View {
    var body: some View {
        Chart(filteredList, id: \.month) {
            LineMark(
                x: .value("Months", $0.month),
                y: .value("CPI", $0.cpiValue)
            )
        }
        .frame(width: chartMaxWidth, height: chartMaxHeight, alignment: .center)
        .foregroundStyle(.blue)
    }
    
}

/*---------------------------------------------------------------------------------
                                SAMPLE AREA CHART
---------------------------------------------------------------------------------*/
struct AreaChart: View {
    var body: some View {
        Chart(filteredList, id: \.month) {
            AreaMark(
                x: .value("Months", $0.month),
                y: .value("CPI", $0.cpiValue)
            )
        }
        .frame(width: chartMaxWidth, height: chartMaxHeight, alignment: .center)
        .foregroundStyle(.green)
    }
}

/*---------------------------------------------------------------------------------
                    ADDING A RULE LINE/THRESHOLD LINE TO BAR CHART
---------------------------------------------------------------------------------*/
struct RuleChart: View {
    var body: some View {
        Chart {
            ForEach(filteredList) { item in
                BarMark(
                    x: .value("Shape Type", item.month),
                    y: .value("Total Count", item.cpiValue)
                )
            }
            RuleMark(y: .value("Break Even Threshold", 100))
                .foregroundStyle(.red)
        }
        .frame(width: chartMaxWidth, height: chartMaxHeight, alignment: .center)
        .foregroundStyle(.green)
    }
}

/*---------------------------------------------------------------------------------
                            PLAYGROUND SETUP FOR VIEW
---------------------------------------------------------------------------------*/
PlaygroundPage.current.setLiveView(ContentView())
