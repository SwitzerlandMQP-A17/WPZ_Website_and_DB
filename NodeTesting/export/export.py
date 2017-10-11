#!C:\Python34\python.exe

"""
Primary executing logic of WPZ test result data export from MySQL database to Microsoft Excel
Requires a system argument for connecting to the database
May be given two optional argument for custom paths of logos and Excel file creation. 
The folder specified for Excel file creation does not have to previously exist.

Python 3.4 should be installed for SQLAlchemy and python connector
pandas, sqlalchemy, pymysql, xlsxwriter installed through pip
"""
import sys, os
import pandas
from sqlalchemy import create_engine
from heatPump import * 

LOGO_ROW_HEIGHT = 65 # Excel row height requirement of logos (65 = ~100 pixels)
HEADER_ROW = 0
ROWS_PER_PUMP = 3
DATABASE_AUTH = sys.argv[1] # driver://username:password@host:port/database
IMG_FOLDER = sys.argv[2] if len(sys.argv) > 2 else "export\\" # location of logos
DOWNLOAD_FOLDER = sys.argv[3] if len(sys.argv) > 3 else "export\\" # desired location of excel file creation
NTB_LOGO_PATH = IMG_FOLDER+"logoNTB.png" # assumed to be shorter in width than the first column
WPZ_LOGO_PATH = IMG_FOLDER+"logoWPZ.png"
        
def exportAirWaterFile():
    """ Exports data on air/water heat pumps to Excel """
    # describes the values used to differentiate rows between the different sheets. Structure defined in mergeWhereFields()    
    sheetDifferentiators = {
        "Floor": {"Kategorie": ["LW"], "Heizungstyp": ["Low"]},
        "Radiator": {"Kategorie": ["LW"], "Heizungstyp": ["Medium"]},
        "Mixed": {"Kategorie": ["LW"], "Heizungstyp": ["Low & Medium"]}
    }    
    orderedSheetNames = ["Floor", "Radiator", "Mixed"]
    
    bauartListing = extractBauartListing()
    normListing = extractNormListing()    
    legend = readLegendFromDB()
    legend.extend([("", ""), # spacing
        ("Abkürzungen / Abbreviations", ""), 
        ("A", "Lufttemperatur / Air temperature"),
        ("W", "Wassertemperatur / Water temperature"),
        ("r. H.", "relative Luftfeuchtigkeit / relative humidity"),
        ("Vx", "Durchflussrate / Volume flow rate at x °C")]
    )    
        
    try:
        writer = pandas.ExcelWriter(DOWNLOAD_FOLDER+'NTB_WPZ_LW_Pruef-Resultate-Temp.xlsx', engine='xlsxwriter')
        workbook = writer.book
        for sheetName in orderedSheetNames:
            # load and initialize heat pumps from SQL
            rawDataFrame = readPumpsFromDB(sheetDifferentiators[sheetName])    
            pumps = HeatPump.loadFromDataFrame(rawDataFrame, bauartListing, normListing)           
            filterAndProcessPumps(workbook, sheetName, sheetDifferentiators[sheetName], pumps, legend)
        writer.save()
        os.replace(DOWNLOAD_FOLDER+'NTB_WPZ_LW_Pruef-Resultate-Temp.xlsx', DOWNLOAD_FOLDER+'NTB_WPZ_LW_Pruef-Resultate.xlsx')
    except Exception:
        pass
    
    
def exportBrineWaterFile():
    """ Exports data on brine-water and water-water heat pumps to Excel """    
    # describes the values used to differentiate rows between the different sheets. Structure defined in mergeWhereFields()    
    sheetDifferentiators = {
        "SW Floor": {"Kategorie": ["SW", "SW-WW"], "Heizungstyp": ["Low"]},
        "SW Radiator": {"Kategorie": ["SW", "SW-WW"], "Heizungstyp": ["Medium"]},
        "SW Mixed": {"Kategorie": ["SW", "SW-WW"], "Heizungstyp": ["Low & Medium"]},
        "WW Floor": {"Kategorie": ["WW", "SW-WW"], "Heizungstyp": ["Low"]},
        "WW Radiator": {"Kategorie": ["WW", "SW-WW"], "Heizungstyp": ["Medium"]},
        "WW Mixed": {"Kategorie": ["WW", "SW-WW"], "Heizungstyp": ["Low & Medium"]}
    }    
    orderedSheetNames = ["SW Floor", "SW Radiator", "SW Mixed", "WW Floor", "WW Radiator", "WW Mixed"]
    
    bauartListing = extractBauartListing()
    normListing = extractNormListing()    
    legend = readLegendFromDB()
    legend.extend([("", ""), # spacing
        ("Abkürzungen / Abbreviations", ""), 
        ("B", "Soletemperatur / Brine temperature"),
        ("W", "Wassertemperatur / Water temperature"),
        ("Vx", "Durchflussrate / Volume flow rate at x °C")] 
    ) 

    try:
        writer = pandas.ExcelWriter(DOWNLOAD_FOLDER+'NTB_WPZ_SW&WW-WP_Pruef-Resultate-Temp.xlsx', engine='xlsxwriter')
        workbook = writer.book
        for sheetName in orderedSheetNames:
            # load and initialize heat pumps from SQL
            rawDataFrame = readPumpsFromDB(sheetDifferentiators[sheetName])    
            pumps = HeatPump.loadFromDataFrame(rawDataFrame, bauartListing, normListing) 
            filterAndProcessPumps(workbook, sheetName, sheetDifferentiators[sheetName], pumps, legend)                 
        writer.save()   
        os.replace(DOWNLOAD_FOLDER+'NTB_WPZ_SW&WW-WP_Pruef-Resultate-Temp.xlsx', DOWNLOAD_FOLDER+'NTB_WPZ_SW&WW-WP_Pruef-Resultate.xlsx')
    except Exception:
        pass
    
def filterAndProcessPumps(workbook, sheetName, filterAttributes, pumps, legend):
    """ Writes a desired subset of pumps to a single Excel sheet 
    
    Structure of the filterAttributes field given by HeatPump.filterSortPumpCollection
    Beyond just the normal capabilities of filtering from a SQL query capabilities, this
    filtering can separate data from SW-WW pumps into their individual sheets because they're 
    tested during initialization for being a dataset of one type or the other
    """    
    matchingPumps = HeatPump.filterSortPumpCollection(filterAttributes, pumps)
    if not len(matchingPumps): # skips sheets with no data
        return

    # export heat pump to data frame
    sheetDataFrame = pandas.DataFrame()        
    formatDict = matchingPumps[0].getHeaderFormatting()                
    for pump in matchingPumps:
        sheetDataFrame = sheetDataFrame.append(pump.exportToDataFrame())
                    
    sheetDataFrame = insertHeaders(sheetDataFrame, matchingPumps[0].ColumnHeaders)
    # style data frame                      
    writeExcelSheet(workbook, sheetName, sheetDataFrame, formatDict, legend)     
        
"""
SQL Data Gathering Functions
"""             

def readPumpsFromDB(differentiators={}):
    """ Reads and returns all relevant heat pump data from database
    
    Takes in specifiers which narrow down the rows from a query which would otherwise read all 
    data points in the database
    """        
    superJoin = "Verbindung JOIN Resultat ON Verbindung.ResultatID = Resultat.ResultatID"
    necessaryTables = [superJoin, "Bedingung", "Info", "Heizungstyp", "Kategorie", "Auftraggeber"]    
    query = mergeQueryStrings("*", necessaryTables, whereFields=differentiators)    
    return querySQL(query)   

def extractNormListing():
    """ Returns a dictionary with a list of norm types for each infoID 
    
    normListing return value format is defined by the parameter in HeatPump.loadFromDataFrame()
    """       
    query = "SELECT * FROM NormInfo NATURAL JOIN Norm"
    rawDataFrame = querySQL(query)   
    norms = sorted(list(set([string.split(":")[0] for string in list(rawDataFrame.Norm.unique())])))
    normListing = {"Standards": norms}
    
    for rowIdx, row in rawDataFrame.iterrows():         
        standard = row.Norm.split(":")[0]             
        if row.InfoID in normListing: # heat pump exists            
            isNewStandard = standard not in normListing[row.InfoID]
            # relies on short circuiting to not error
            if isNewStandard or normListing[row.InfoID][standard] < row.Norm_Year:
                normListing[row.InfoID][standard] = row.Norm_Year             
        else:
            normListing[row.InfoID] = {standard: row.Norm_Year}       
    return normListing

def extractBauartListing():
    """ Returns a dictionary with a list of bauart types for each infoID 
    
    bauartListing return value format is defined by the parameter in HeatPump.loadFromDataFrame()
    """       
    query = "SELECT Bauart, InfoID FROM BauartInfo NATURAL JOIN Bauart"
    rawDataFrame = querySQL(query) 
    bauartListing = {}
    for rowIdx, row in rawDataFrame.iterrows():  
        if row.InfoID in bauartListing:
            bauartListing[row.InfoID].append(row.Bauart)
        else:
            bauartListing[row.InfoID] = [row.Bauart]    
    return bauartListing
    
def readLegendFromDB():
    """ Reads and returns legend data from database """      
    query = "SELECT Bauart, Bauart_Bezeichnung_DE, Bauart_Bezeichnung_EN FROM Bauart ORDER BY Bauart"
    data = querySQL(query)
    legend = [("Bauart / Type of construction", "")] # 2nd "" forces first element to stay in first column of Excel
    for rowIdx, row in data.iterrows():
        legend.append((row.Bauart, row.Bauart_Bezeichnung_DE + " / " + row.Bauart_Bezeichnung_EN))
        
    legend.extend([("", ""), # spacing
        ("Produktart / Product typ", ""),
        ("S", "Serienprodukt / Standard product"),
        ("P", "Prototyp / Prototype"),
        ("E", "Einzelanfertigung / Single-unit production")]
    )       
    return legend
    
"""
SQL Query Tools
"""                 

def querySQL(query):
    """ Returns result of query from database """    
    engine = create_engine(DATABASE_AUTH)    
    with engine.connect() as conn, conn.begin():                                   
        data = pandas.read_sql_query(query, conn)            
        return data    
    
def mergeQueryStrings(selectFields, fromFields, whereFields={}, orderFields=[]):
    """ Brings together attributes and tables into well formatted query. """
    if len(fromFields) < 1 or len(selectFields) < 1:
        raise Exception("Building query failed. Lacks necessary fields")
        
    query = "SELECT " + ", ".join(selectFields) 
    query += " FROM " + " NATURAL JOIN ".join(fromFields) 
    if len(whereFields): # optional parameter
        query += mergeWhereFields(whereFields)
    if len(orderFields): # optional parameter
        query += " ORDER BY " + ", ".join(orderFields)    
    return query
    
def mergeWhereFields(whereFields):
    """ Merges logic from dictionary of specifiers to narrow down SQL query results 
    
    whereFields dictionary structure: {columnHeader1: [value1, value2, ...], columnHeader2: [value1, value2, ...], ... }
    The dictionary must have at least one column header and at least one possible value per header
    returned clause format: "WHERE (columnHeader1=value1 OR columnHeader1=value2 ... ) AND (columnHeader2=value1 OR columnHeader2=value2 ... ) ... "    
    """        
    andClauses = []
    for column in whereFields.keys():        
        orClauses = []
        for possibleValue in whereFields[column]:            
            orClauses.append(column + "='" + possibleValue + "'")
        andClauses.append("("+" OR ".join(orClauses)+")")
    whereClause = " WHERE " + " AND ".join(andClauses)    
    return whereClause
    
"""
Excel Formatting Functions
"""

def insertHeaders(sheetDataFrame, headers):
    """ styles data frame with necessary test result headers """           
    sheetDataFrame.reset_index(drop=True, inplace=True)    
    sheetDataFrame.loc[-1] = headers 
    sheetDataFrame.sort_index(inplace=True)
    sheetDataFrame.reset_index(drop=True, inplace=True)
    return sheetDataFrame 

def writeExcelSheet(workbook, sheetName, sheetDF, formatDict, legend):
    """ writes data frame to Excel with proper styling """  
    worksheet = workbook.add_worksheet(sheetName)       
    prevAddress = ["", "", ""]
    maxColIdx = 0    
    for rowIdx, row in sheetDF.iterrows():
        for colIdx, val in row.iteritems():
            maxColIdx = colIdx if colIdx > maxColIdx else maxColIdx
            pastHeader = rowIdx > HEADER_ROW            
            perPumpRowIdx = (rowIdx-HEADER_ROW-1) % ROWS_PER_PUMP
            val = None if pandas.isnull(val) else val
            
            # delete duplicate customer entries
            duplicateCustomerCell = False
            if colIdx == 0 and pastHeader:                
                if val not in prevAddress:
                    if perPumpRowIdx == 0: # always show address if company changes
                        prevAddress = ["" for _ in prevAddress]
                    prevAddress[perPumpRowIdx] = val
                else:
                    duplicateCustomerCell = True
                    val = ""

            formatAttributes = {'text_wrap': True, 'font_size': 8} # interprets newlines for all cells            
            # bordering            
            if pastHeader and not duplicateCustomerCell and perPumpRowIdx == 0:
                formatAttributes["top"] = 1
            if rowIdx >= HEADER_ROW:
                formatAttributes["right"] = 1 
                formatAttributes["left"] = 1 # only needed if printing the sheets
            
            # column formatting 
            for columnSpecs in formatDict["Column Formatting"]: 
                if colIdx in range(columnSpecs[0], columnSpecs[1]+1):
                    formatAttributes.update(columnSpecs[3])
            
            # cell-specific formatting
            for coord in formatDict["Cell Formatting"]:
                if pastHeader and perPumpRowIdx == coord[0] and colIdx == coord[1]:
                    formatAttributes.update(formatDict["Cell Formatting"][coord])                    
            
            # header formatting
            if rowIdx == HEADER_ROW:
                if val in formatDict["Bold Headers"]:
                    formatAttributes['bold'] = True               
                if val not in formatDict["Horizontal Headers"]:
                    formatAttributes.update({'rotation': 90, 'align': 'center'})
                elif val in formatDict["Horizontal Headers"]:
                    formatAttributes.update({'font_size': 10, 'valign': 'top'})                       
            
            # write data to file
            format = workbook.add_format(formatAttributes)
            worksheet.write(rowIdx, colIdx, val, format)
        
    formatColumns(sheetDF, worksheet, formatDict)            
    # create bottom border    
    worksheet.write_row(rowIdx+1, 0, ["" for _ in range(maxColIdx+1)], workbook.add_format({"top":1}))           
    # insert logos and legend after table    
    insertFooter(worksheet, rowIdx+1, legend)    
    
def formatColumns(sheetDF, worksheet, formatDict):
    """ hides columns with no data and formats visible columns """
    emptyColumns = []
    obscureNullValues = ["", "-", "N/A"]
    for colIdx, column in sheetDF.iteritems():
        columnIsEmpty = True
        for cell in column[HEADER_ROW+1:]:        
            if not pandas.isnull(cell) and cell not in obscureNullValues:
                columnIsEmpty = False
                break
        if columnIsEmpty:
            worksheet.set_column(colIdx, colIdx, None, None, {'hidden': 1})
            emptyColumns.append(colIdx)
    
    for columnSpecs in formatDict["Column Formatting"]:
        for colIdx in range(columnSpecs[0], columnSpecs[1]+1): # inclusive range
            if colIdx not in emptyColumns:
                worksheet.set_column(colIdx, colIdx, columnSpecs[2])  

def insertFooter(worksheet, row, legend):
    """ adds logos and legend to the bottom of the Excel sheet 
    
    legend is a list of string pairs in tuples sorted by the letter key. 
    Tuple format: (key, description)
    """
    ntbLogoColumn = 0
    wpzLogoColumn = 1
    worksheet.set_row(row, LOGO_ROW_HEIGHT) # set row height to accomodate logos      
    # offsets allows borders to be visible
    worksheet.insert_image(row, ntbLogoColumn, NTB_LOGO_PATH, {'x_offset': 1, 'y_offset': 2}) 
    worksheet.insert_image(row, wpzLogoColumn, WPZ_LOGO_PATH, {'x_offset': 1, 'y_offset': 2})
    
    
    # insert legend
    baseColumn = 0
    row += 1 # move past the logos
    for entryIdx in range(len(legend)):
        worksheet.write_row(row+entryIdx, baseColumn, legend[entryIdx])  

""" 
SINGLE PUMP EXPORT 
"""

def exportSortableFile():
    """ Collects and exports data on all pumps in single easily sorted rows to Excel
    
    Assumes at least one heat pump is stored in the database. No legend is exported
    """        
    bauartListing = extractBauartListing()
    normListing = extractNormListing() 
    
    try:    
        writer = pandas.ExcelWriter(DOWNLOAD_FOLDER+'NTB_WPZ_Alle_Pruefresultate-Temp.xlsx', engine='xlsxwriter')
        workbook = writer.book
        
        # load and initialize heat pumps from SQL
        rawDataFrame = readPumpsFromDB()    
        pumps = HeatPump.loadFromDataFrame(rawDataFrame, bauartListing, normListing) 
        writePumpsAsSingleRows(workbook, pumps)                 
        writer.save()
        os.replace(DOWNLOAD_FOLDER+'NTB_WPZ_Alle_Pruefresultate-Temp.xlsx', DOWNLOAD_FOLDER+'NTB_WPZ_Alle_Pruefresultate.xlsx')
    except Exception:
        pass
    

def writePumpsAsSingleRows(workbook, pumps):
    """ Writes pumps to Excel sheet in single-row format """
    pumps.sort(key=singleRowPumpSortCriteria)    
    # export heat pump to data frame
    sheetDataFrame = pandas.DataFrame()        
    formatDict = pumps[0].getSingleRowHeaderFormatting()                
    for pump in pumps:
        sheetDataFrame = sheetDataFrame.append(pump.exportAsSingleRow())
                    
    sheetDataFrame = insertHeaders(sheetDataFrame, pumps[0].SingleRowHeaders)
    # style data frame                      
    writeSingleExcelSheet(workbook, sheetDataFrame, formatDict)   

def singleRowPumpSortCriteria(pump):
    """ Returns attributes with which to sort a list of heat pumps """
    sortingKey = [pump.Kategorie, pump.Heizungstyp]
    sortingKey.extend([pump.Norms[standard] for standard in pump.Standards if standard in pump.Norms])    
    return sortingKey
    
def writeSingleExcelSheet(workbook, sheetDF, formatDict):
    """ writes data frame to Excel with proper styling """  
    worksheet = workbook.add_worksheet("Alle Waermepumpen")           
    maxColIdx = 0    
    for rowIdx, row in sheetDF.iterrows():
        for colIdx, val in row.iteritems():
            maxColIdx = colIdx if colIdx > maxColIdx else maxColIdx            
            val = None if pandas.isnull(val) else val                       

            formatAttributes = {'text_wrap': True, 'font_size': 8} # interprets newlines for all cells            
            # bordering            
            if rowIdx > HEADER_ROW :
                formatAttributes["top"] = 1
            if rowIdx >= HEADER_ROW:
                formatAttributes["right"] = 1 
                formatAttributes["left"] = 1 # only needed if printing the sheets
            
            # column formatting 
            for columnSpecs in formatDict["Column Formatting"]: 
                if colIdx in range(columnSpecs[0], columnSpecs[1]+1):
                    formatAttributes.update(columnSpecs[3])                  
            
            # header formatting
            if rowIdx == HEADER_ROW:
                if val in formatDict["Bold Headers"]:
                    formatAttributes['bold'] = True               
                if val not in formatDict["Horizontal Headers"]:
                    formatAttributes.update({'rotation': 90, 'align': 'center'})
                elif val in formatDict["Horizontal Headers"]:
                    formatAttributes.update({'font_size': 10, 'valign': 'top'})                       
            
            # write data to file
            format = workbook.add_format(formatAttributes)
            worksheet.write(rowIdx, colIdx, val, format)
        
    formatColumns(sheetDF, worksheet, formatDict)            
    # create bottom border    
    worksheet.write_row(rowIdx+1, 0, ["" for _ in range(maxColIdx+1)], workbook.add_format({"top":1})) 
    
if __name__ == "__main__":
    if not os.path.exists(DOWNLOAD_FOLDER):
        os.makedirs(DOWNLOAD_FOLDER)
    exportAirWaterFile()     
    exportBrineWaterFile()
    exportSortableFile()