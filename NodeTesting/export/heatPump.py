#!C:\Python34\python.exe

"""
Storage class to encapsulate all characteristics and test result data of a heat pump
"""

import pandas
import re # required for extracting number from bedingung

BIV_DATA_PT = "Abiv / W__"

class HeatPump():       
    def __init__(self, classAttributes, allDataPointHeaders):  
        """ 
        All attributes in this class are fully capitalized while methods are 
        camelCased, which breaks some style rules, but it also simplifies 
        handling the data and adds consistency with SQL.
        """
        # Auto-loads all simple attributes directly from the database
        for attr in classAttributes.keys(): 
            setattr(self, attr, classAttributes[attr])                                             
        self.generateColumnHeaders(allDataPointHeaders)
        self.narrowKategorie()

    def generateColumnHeaders(self, allDataPointHeaders):
        """ generates column headers from TestResultsDict """        
        self.ColumnHeaders = ["Auftraggeber\nCustomer", "Gerät\nMachine", "Prüfnummer\nTest number", "Bauart\nType of Construction", 
            "Produktart\nProduct Type", "Kältemittel\nRefrigerant", "Kältemittelmenge [kg]\nRefrigerant Capacity", "Prüfbedingungen\nTest Conditions"
        ]
        self.SingleRowHeaders = ["Kategorie\nCategory", "Heizungstyp\nHeating Type"]
        self.SingleRowHeaders.extend(self.Standards)
        self.SingleRowHeaders.extend(["Auftraggeber\nCustomer", "Adresse erster Teil\nAddress Part 1", 
            "Adresse zweiter Teil\nAddress Part 2", "Gerät erster Teil\nModel Name Part 1", "Gerät zweiter Teil\nModel Name Part 2", "Bemerkung\nComments", 
            "Prüfnummer\nTest number", "Bauart\nType of Construction", "Produktart\nProduct Type", "Kältemittel 1\nRefrigerant 1", 
            "Kältemittelmenge 1 [kg]\nRefrigerant 1 Capacity", "Kältemittel 2\nRefrigerant 2", "Kältemittelmenge 2 [kg]\nRefrigerant 2 Capacity"
        ])          
        
        headersGenResults = ["Bivalenzpunkt\nBivalent Point", "Volumenstrom [m3/h]\nVolume Flow", "SCOP", 
            "Schallleistungspegel aussen [dB(A)]\nOutdoor Sound Power Level", "Schallleistungspegel innen [dB(A)]\n Indoor Sound Power Level"
        ]
        headersGenSingleRowResults = ["Bivalenzpunkt\nBivalent Point", "Normal Volumenstrom [m3/h]\nStandard Volume Flow", "35C Volumenstrom [m3/h]\nVolume Flow at 35C",
            "45C Volumenstrom [m3/h]\nVolume Flow at 45C", "55C Volumenstrom [m3/h]\nVolume Flow at 55C", "SCOP", 
            "Schallleistungspegel aussen [dB(A)]\nOutdoor Sound Power Level", "Schallbedingung aussen\nOutdoor Sound Test Point", 
            "Schallleistungspegel innen [dB(A)]\n Indoor Sound Power Level", "Schallbedingung innen\nIndoor Sound Test Point"
        ]
        
        # sort data point titles by type, ambient temperature and then source temperature with the bivalent point always last
        self.AllDataPointKeys = sorted(allDataPointHeaders, 
            key=lambda x: (x[0], int(re.findall('\-?\d+', x)[0]) if re.findall('\-?\d+', x) else float("-inf"), x),
            reverse=True
        )
        
        # create headers, adding a newline in before the humidity if it's displayed    
        self.DataPointHeaders = [] # header titles written to Excel          
        for key in self.AllDataPointKeys:                        
            self.DataPointHeaders.append(key.replace(" (", "\n("))
            self.SingleRowHeaders.append("Heizleistung [kW] "+key)
            self.SingleRowHeaders.append("El. Leistung [kW] "+key)
            self.SingleRowHeaders.append("COP "+key)
                
        self.ColumnHeaders.extend(self.DataPointHeaders)
        self.ColumnHeaders.extend(headersGenResults)   
        self.SingleRowHeaders.extend(headersGenSingleRowResults)   
        self.ColumnHeaders.extend(self.Standards)         
        
    def narrowKategorie(self):
        """ Attempts to narrow down the Kategorie attribute to either WW or SW if it's both """        
        if self.Kategorie == "SW-WW":
            flagSW = True
            flagWW = True
            for dataPointName in self.TestResultsDict:
                # Water or Air (biv pt) are possible ambient environments
                flagWW = flagWW and dataPointName[0].capitalize() in ["A", "W"]
                # Brine or Air (biv pt) are possible ambient environments
                flagSW = flagSW and dataPointName[0].capitalize() in ["A", "B"]
            if flagSW and not flagWW:
                self.Kategorie = "SW"
            elif flagWW and not flagSW:
                self.Kategorie = "WW"
    
    def getHeaderFormatting(self):
        """ gives formatting for applicable cell ranges 
        
        Returns dict of the form 
            "Bold Headers": [names...]
            "Horizontal Headers": [names...]
            "Column Formatting": [(colIdxStart, colIdxEnd, colWidth, formatting), ...]
            "Cell Formatting": [(rowIdx, colIdx, formatting), ...] # formatting for each heat pump cell
        """
        boldHeaders = ["Auftraggeber\nCustomer", "Gerät\nMachine", "Prüfbedingungen\nTest Conditions", "SCOP"]
        boldHeaders.extend(self.DataPointHeaders)
        horizHeaders = ["Auftraggeber\nCustomer", "Gerät\nMachine", "Prüfbedingungen\nTest Conditions"]
        # start and end indices are inclusive
        columnFormatting = [         
            (self.ColumnHeaders.index("Auftraggeber\nCustomer"), self.ColumnHeaders.index("Auftraggeber\nCustomer"), 30, {}), 
            (self.ColumnHeaders.index("Gerät\nMachine"), self.ColumnHeaders.index("Gerät\nMachine"), 20, {}),             
            (self.ColumnHeaders.index("Prüfnummer\nTest number"), self.ColumnHeaders.index("Prüfnummer\nTest number"), 6.5, {'align': 'center'}),             
            (self.ColumnHeaders.index("Bauart\nType of Construction"), self.ColumnHeaders.index("Bauart\nType of Construction"), 4.5, {'num_format':'0.0', 'align': 'center'}), 
            (self.ColumnHeaders.index("Produktart\nProduct Type"), self.ColumnHeaders.index("Produktart\nProduct Type"), 3, {'align': 'center'}), 
            (self.ColumnHeaders.index("Kältemittel\nRefrigerant"), self.ColumnHeaders.index("Kältemittel\nRefrigerant"), 4.5, {'num_format':'0.0', 'align': 'center'}), 
            (self.ColumnHeaders.index("Kältemittelmenge [kg]\nRefrigerant Capacity"), self.ColumnHeaders.index("Kältemittelmenge [kg]\nRefrigerant Capacity"), 3, {'num_format':'0.0', 'align': 'center'}), 
            (self.ColumnHeaders.index("Prüfbedingungen\nTest Conditions"), self.ColumnHeaders.index("Prüfbedingungen\nTest Conditions"), 21, {}), 
            (self.ColumnHeaders.index("Prüfbedingungen\nTest Conditions")+1, self.ColumnHeaders.index("Bivalenzpunkt\nBivalent Point")-1, 3, {'num_format':'0.0', 'align': 'right'}),
            (self.ColumnHeaders.index("Bivalenzpunkt\nBivalent Point"), self.ColumnHeaders.index("Bivalenzpunkt\nBivalent Point"), 5, {'align': 'center'}),
            (self.ColumnHeaders.index("Volumenstrom [m3/h]\nVolume Flow"), self.ColumnHeaders.index("Volumenstrom [m3/h]\nVolume Flow"), 7, {'align': 'center'}),
            (self.ColumnHeaders.index("SCOP"), self.ColumnHeaders.index("SCOP"), 3, {'num_format':'0.0', 'align': 'center'}),
            (
                self.ColumnHeaders.index("Schallleistungspegel aussen [dB(A)]\nOutdoor Sound Power Level"), 
                self.ColumnHeaders.index("Schallleistungspegel innen [dB(A)]\n Indoor Sound Power Level"), 
                6, {'num_format':'0.0', 'align': 'center'}
            ),
            (self.ColumnHeaders.index("Schallleistungspegel innen [dB(A)]\n Indoor Sound Power Level")+1, 100, 4, {'align': 'center'})            
        ]
        cellFormatting = {(0,0): {"bold": True}}
        for colIdx in range(self.ColumnHeaders.index("Prüfbedingungen\nTest Conditions")+1, self.ColumnHeaders.index("Bivalenzpunkt\nBivalent Point")):
            cellFormatting[(2,colIdx)] = {"num_format": "0.00"}
        formatDict = {"Bold Headers": boldHeaders, "Horizontal Headers": horizHeaders, "Column Formatting": columnFormatting, "Cell Formatting": cellFormatting}
        return formatDict
    
    def getSingleRowHeaderFormatting(self):
        """ gives headers with corresponding column formatting
        
        Returns dict of the form 
            "Bold Headers": [names...]
            "Horizontal Headers": [names...]
            "Column Formatting": [(colIdxStart, colIdxEnd, colWidth, formatting), ...]            
        """        
        copHeaders = [header for header in self.SingleRowHeaders if "COP" in header] # bold and 0.00 format
        horizHeaders = [
            "Auftraggeber\nCustomer", "Adresse erster Teil\nAddress Part 1", "Adresse zweiter Teil\nAddress Part 2", 
            "Gerät erster Teil\nModel Name Part 1", "Gerät zweiter Teil\nModel Name Part 2", "Bemerkung\nComments"
        ]   
        # start and end indices are inclusive
        columnFormatting = [        
            (self.SingleRowHeaders.index("Kategorie\nCategory"), self.SingleRowHeaders.index("Kategorie\nCategory"), 3, {'align': 'center'}), 
            (self.SingleRowHeaders.index("Heizungstyp\nHeating Type"), self.SingleRowHeaders.index("Heizungstyp\nHeating Type"), 10, {'align': 'center'}), 
            (self.SingleRowHeaders.index("Heizungstyp\nHeating Type")+1, self.SingleRowHeaders.index("Auftraggeber\nCustomer")-1, 4, {'align': 'center'}),            
            (self.SingleRowHeaders.index("Auftraggeber\nCustomer"), self.SingleRowHeaders.index("Auftraggeber\nCustomer"), 35, {}), 
            (self.SingleRowHeaders.index("Adresse erster Teil\nAddress Part 1"), self.SingleRowHeaders.index("Adresse zweiter Teil\nAddress Part 2"), 25, {}), 
            (self.SingleRowHeaders.index("Gerät erster Teil\nModel Name Part 1"), self.SingleRowHeaders.index("Gerät zweiter Teil\nModel Name Part 2"), 20, {}),             
            (self.SingleRowHeaders.index("Bemerkung\nComments"), self.SingleRowHeaders.index("Bemerkung\nComments"), 12, {}),     
            (self.SingleRowHeaders.index("Prüfnummer\nTest number"), self.SingleRowHeaders.index("Prüfnummer\nTest number"), 6.5, {'align': 'center'}),                         
            (self.SingleRowHeaders.index("Bauart\nType of Construction"), self.SingleRowHeaders.index("Bauart\nType of Construction"), 4.5, {'num_format':'0.0', 'align': 'center'}), 
            (self.SingleRowHeaders.index("Produktart\nProduct Type"), self.SingleRowHeaders.index("Produktart\nProduct Type"), 3, {'align': 'center'}), 
            (self.SingleRowHeaders.index("Kältemittel 1\nRefrigerant 1"), self.SingleRowHeaders.index("Kältemittelmenge 2 [kg]\nRefrigerant 2 Capacity"), 4.5, {'num_format':'0.0', 'align': 'center'}),           
            (self.SingleRowHeaders.index("Kältemittelmenge 2 [kg]\nRefrigerant 2 Capacity")+1, self.SingleRowHeaders.index("Bivalenzpunkt\nBivalent Point")-1, 3, {'num_format':'0.0', 'align': 'right'}),
            (self.SingleRowHeaders.index("Bivalenzpunkt\nBivalent Point"), self.SingleRowHeaders.index("Bivalenzpunkt\nBivalent Point"), 5, {'align': 'center'}),
            (self.SingleRowHeaders.index("Normal Volumenstrom [m3/h]\nStandard Volume Flow"), self.SingleRowHeaders.index("55C Volumenstrom [m3/h]\nVolume Flow at 55C"), 3.5, {'num_format':'0.00', 'align': 'center'}),
            (self.SingleRowHeaders.index("SCOP"), self.SingleRowHeaders.index("SCOP"), 3, {'num_format':'0.0', 'align': 'center'}),
            (self.SingleRowHeaders.index("Schallleistungspegel aussen [dB(A)]\nOutdoor Sound Power Level"), self.SingleRowHeaders.index("Schallleistungspegel aussen [dB(A)]\nOutdoor Sound Power Level"), 3, {'num_format':'0.0', 'align': 'center'}),
            (self.SingleRowHeaders.index("Schallbedingung aussen\nOutdoor Sound Test Point"), self.SingleRowHeaders.index("Schallbedingung aussen\nOutdoor Sound Test Point"), 6, {'align': 'center'}),
            (self.SingleRowHeaders.index("Schallleistungspegel innen [dB(A)]\n Indoor Sound Power Level"), self.SingleRowHeaders.index("Schallleistungspegel innen [dB(A)]\n Indoor Sound Power Level"), 3, {'num_format':'0.0', 'align': 'center'}),
            (self.SingleRowHeaders.index("Schallbedingung innen\nIndoor Sound Test Point"), self.SingleRowHeaders.index("Schallbedingung innen\nIndoor Sound Test Point"), 6, {'align': 'center'})            
        ]        
        for header in copHeaders:
            columnFormatting.append((self.SingleRowHeaders.index(header), self.SingleRowHeaders.index(header), 3, {'num_format':'0.00'}))
        formatDict = {"Bold Headers": copHeaders, "Horizontal Headers": horizHeaders, "Column Formatting": columnFormatting}
        return formatDict
        
    def exportToDataFrame(self):
        """ Returns heat pump information in a 3xN Pandas data frame for Excel export """
        
        # all pump specification data preceeding the test results
        specsMatrix = [
            [self.Auftraggeber, self.Bemerkung, None, None, None, None, None],
            [self.Adresse_Part1, self.Geraet_Part1, self.Pruefnummer, self.Bauart, self.Produktart, self.Kaeltemittel_Typ1, self.Kaeltemittelmenge_Typ1],
            [self.Adresse_Part2, self.Geraet_Part2, None, None, None, self.Kaeltemittel_Typ2, self.Kaeltemittelmenge_Typ2]
        ] 
        
        resultsMatrix = [["Heizleistung / Heat. cap. [kW]"], ["El. Leistung / Input Power [kW]"], ["COP"]]        
        # unknown number of data point test results
        for dataPt in self.AllDataPointKeys:
            if dataPt in self.TestResultsDict:
                resultsMatrix[0].append(safeguardToStr(self.TestResultsDict[dataPt]["Heizleistung"], "-"))
                resultsMatrix[1].append(safeguardToStr(self.TestResultsDict[dataPt]["Leistungsaufnahme"], "-"))
                resultsMatrix[2].append(safeguardToStr(self.TestResultsDict[dataPt]["COP"], "-"))
            else:
                resultsMatrix[0].append("-")
                resultsMatrix[1].append("-")
                resultsMatrix[2].append("-")
            
        # convert volume flow text
        if not pandas.isnull(self.Volumenstrom[0]):
            volumeFlow = ["", "Vstd: "+strRound(self.Volumenstrom[0], 2), ""]
        else:            
            volumeFlow = [
                "V35: "+safeguardToStr(strRound(self.Volumenstrom[1], 2), "N/A"), 
                "V45: "+safeguardToStr(strRound(self.Volumenstrom[2], 2), "N/A"), 
                "V55: "+safeguardToStr(strRound(self.Volumenstrom[3], 2), "N/A")
            ]
        # general pump test result data                
        suffixMatrix = [ # Volumenstrom order is defined in self.extractVolumeFlow()
            [None, volumeFlow[0], None, None, None],
            [self.Bivalenzpunkt, volumeFlow[1], self.SCOP, self.Schall_Aussen, self.Schall_Innen],
            [None, volumeFlow[2], None, self.Schall_Aussen_Bedingung, self.Schall_Innen_Bedingung]
        ] 
        

        # matrix of the latest year that a pump has been tested in per standard
        testStandardsMatrix = [ 
            [None for _ in self.Standards],
            [self.Norms[standard] if standard in self.Norms else None for standard in self.Standards],
            [None for _ in self.Standards]
        ]    
        
        # merge previous 3 matrices together
        finalMatrix = []
        for rowIndex in range(len(specsMatrix)):
            row = []            
            row.extend(specsMatrix[rowIndex])
            row.extend(resultsMatrix[rowIndex])
            row.extend(suffixMatrix[rowIndex])
            row.extend(testStandardsMatrix[rowIndex])
            finalMatrix.append(row)        
        return pandas.DataFrame(finalMatrix)   
    
    def exportAsSingleRow(self):
        """ Returns heat pump information in a single row Pandas data frame for Excel export """
        
        # all pump specification data preceeding the test results
        specsColumns = [self.Kategorie, self.Heizungstyp]
        specsColumns.extend([self.Norms[standard] if standard in self.Norms else None for standard in self.Standards])        
        specsColumns.extend([self.Auftraggeber, self.Adresse_Part1, self.Adresse_Part2, self.Geraet_Part1, self.Geraet_Part2, self.Bemerkung, self.Pruefnummer, 
            self.Bauart, self.Produktart, self.Kaeltemittel_Typ1, self.Kaeltemittelmenge_Typ1, self.Kaeltemittel_Typ2, self.Kaeltemittelmenge_Typ2
        ])
        
        resultsColumns = []        
        # unknown number of data point test results
        for dataPt in self.AllDataPointKeys:
            if dataPt in self.TestResultsDict:
                resultsColumns.extend([
                    safeguardToStr(self.TestResultsDict[dataPt]["Heizleistung"], "-"),
                    safeguardToStr(self.TestResultsDict[dataPt]["Leistungsaufnahme"], "-"),
                    safeguardToStr(self.TestResultsDict[dataPt]["COP"], "-"),
                ])
            else:
                resultsColumns.extend(["-", "-", "-"])
            
        # general pump test result data
        suffixColumns = [
            self.Bivalenzpunkt, self.Volumenstrom[0], self.Volumenstrom[1], self.Volumenstrom[2], self.Volumenstrom[3], self.SCOP, self.Schall_Aussen, 
            self.Schall_Aussen_Bedingung, self.Schall_Innen, self.Schall_Innen_Bedingung
        ]          
        
        # merge matrices together
        row = specsColumns
        row.extend(resultsColumns)
        row.extend(suffixColumns)      
        return pandas.DataFrame([row])        
    
    def loadFromDataFrame(dataFrame, bauartListing, normListing):   
        """ Loads collection of air/water heat pumps from Pandas data frame 
        
        bauartListing format: {infoID1: bauartList, infoID2: bauartList, ...}
        example: {1: ["d"], 2:["c","d"], 3:["a","c"], ...}
        
        normListing is a dictionary linking infoID keys to norm standards in the form:
        {Norm_Standard1: Norm_Year, Norm_Standard2: Norm_Year, ...]
        where the norm year is always the latest year in the table for that standard
        It also contains a special key: "Standards" listing out all possible keys to the inner dictionary
        """                
        pumps = []        
        indexedDF = dataFrame.set_index(['InfoID'])
        allDataPointHeaders = HeatPump.extractDataPointHeaders(indexedDF)        
        
        # initialize each unique pump
        for pumpID in indexedDF.index.unique():             
            pumpDF = getRowsOfSinglePump(indexedDF, pumpID)
            classAttributes = HeatPump.readAttributesToDict(pumpID, pumpDF, bauartListing, normListing)             
            pumps.append(HeatPump(classAttributes, allDataPointHeaders))          
        return pumps 
        
    def readAttributesToDict(pumpID, pumpDataFrame, bauartListing, normListing):
        """ Gathers attributes needed for heat pump from Pandas data frame into dictionary """        
        
        simpleSqlValues = ["Sichtbarkeit", "Heizungstyp", "Kategorie", "Auftraggeber", "Adresse_Part1", "Adresse_Part2", "Bemerkung", 
            "Geraet_Part1", "Geraet_Part2", "Pruefnummer", "Produktart", "Kaeltemittel_Typ1", "Kaeltemittelmenge_Typ1", "Kaeltemittel_Typ2",
            "Kaeltemittelmenge_Typ2", "SCOP", "Schall_Aussen", "Schall_Aussen_Bedingung", "Schall_Innen", "Schall_Innen_Bedingung"]            
        # initialize dictionary first with the simplest attributes
        classAttributes = {}
        for attrName in simpleSqlValues:
            classAttributes[attrName] = enforceSingleValAttr(pumpDataFrame, attrName, pumpID)        
            
        # store non-SQL attributes 
        classAttributes["Norms"] = normListing[pumpID]
        classAttributes["Standards"] = normListing["Standards"]
        
        # process complex attributes            
        classAttributes["Bauart"] = ",".join(bauartListing[pumpID]) if pumpID in bauartListing else ""                
        classAttributes["Volumenstrom"] = HeatPump.extractVolumeFlow(pumpDataFrame, pumpID)            
        classAttributes["Bivalenzpunkt"] = HeatPump.extractBivPt(pumpDataFrame, pumpID) 
        classAttributes["TestResultsDict"] = HeatPump.extractTestData(pumpDataFrame)        

        return classAttributes

    def extractDataPointHeaders(indexedDF):
        """ Returns a list of all the test point names contained in a collection of heat pumps """
        allDataPointHeaders = set()        
        for pumpID in indexedDF.index.unique():             
            pumpDF = getRowsOfSinglePump(indexedDF, pumpID)
            allDataPointHeaders.update(HeatPump.extractTestData(pumpDF).keys())
        return list(allDataPointHeaders) 
        
    def extractTestData(pumpDataFrame):   
        """ Reads the test data from Pandas data frame regardless of the number of test points 
        
        Returns dictionary in the form {string:dictionary, ...}
            string: data point name (e.g. "A12 / W24 (89% r. H.)")
            dictionary: {"Heizleistung": double/None, "Leistungsaufnahme": double/None, "COP": double/None}
        """ 
        TestResultsDict = {}
        testAttributes = ["Bedingung", "Heizleistung", "Leistungsaufnahme", "COP"]                       
        miniaturizedDataFrame = pumpDataFrame[testAttributes] # duplicates through Bauart                   
        for index, row in miniaturizedDataFrame.iterrows():
            dataPointHeader = row.Bedingung if "biv" not in row.Bedingung else BIV_DATA_PT    
            TestResultsDict[dataPointHeader] = {
                "Heizleistung": row.Heizleistung, 
                "Leistungsaufnahme": row.Leistungsaufnahme,
                "COP": row.COP
            }        
        return TestResultsDict

    def extractVolumeFlow(pumpDataFrame, pumpID):   
        """ Reads the volume flow single or triplet value from Pandas data frame 
        
        Returns a triplet list of strings where if only a single value exists it is 
        in the middle but otherwise all three elements are used, though some may 
        still be None types. This format is to aid the exportToDataFrame method
        examples: [None, std, None] or [35C, 45C, 55C] 
        """ 
        vsStd = enforceSingleValAttr(pumpDataFrame, "Volumenstrom_Standard", pumpID)
        vs35 = enforceSingleValAttr(pumpDataFrame, "Volumenstrom_V35", pumpID)
        vs45 = enforceSingleValAttr(pumpDataFrame, "Volumenstrom_V45", pumpID)
        vs55 = enforceSingleValAttr(pumpDataFrame, "Volumenstrom_V55", pumpID)  
        if not pandas.isnull(vsStd):
            volumeFlow = [vsStd, None, None, None]
        else:            
            volumeFlow = [None, vs35, vs45, vs55]
        return volumeFlow

    def extractBivPt(pumpDataFrame, pumpID):   
        """ Reads the bivalent point from Pandas data frame """ 
        bivalentPtAir = enforceSingleValAttr(pumpDataFrame, "Bivalenzpunkt_Wert_1", pumpID) 
        bivalentPtWater = enforceSingleValAttr(pumpDataFrame, "Bivalenzpunkt_Wert_2", pumpID)
        if pandas.isnull(bivalentPtAir) or pandas.isnull(bivalentPtWater):
            bivalentPt = None
        else:            
            bivalentPt = str(int(bivalentPtAir)) + " \ " + str(int(bivalentPtWater))
        return bivalentPt              
        
    def filterSortPumpCollection(differentiators, pumps):    
        """ Returns the pumps in alphabetical order containing the required attributes from the differentiators dict
    
        Also hides any invisible pumps.
        differentiators dict structure: {attr1: [value1, value2, ...], attr2: [value1, value2, ...], ... }
        The dictionary must have at least one HeatPump attribute and at least one possible value per attribute
        Equivalent filter logic: "if (attr1=value1 or attr1=value2 ... ) and (attr2=value1 or attr2=value2 ... ) ... "    
        """   
        filteredPumps = []
        for pump in pumps:
            pumpMatches = True
            for attr in differentiators.keys():                 
                pumpMatches = pumpMatches and (getattr(pump, attr) in differentiators[attr])
            if pumpMatches and pump.Sichtbarkeit:
                filteredPumps.append(pump)
        filteredPumps.sort(key=lambda pump: (pump.Auftraggeber, pump.Geraet_Part1, pump.Geraet_Part2))
        return filteredPumps 
        
"""
UTILITY FUNCTIONS
"""

def enforceSingleValAttr(dataFrameRow, attrName, pumpID):
    """ Ensures the given attribute of the heat pump has the same value for all test points """        
    values = dataFrameRow[attrName].unique()
    if len(values) != 1:
        raise Exception("Unexpected number of values for pump attribute: "+attrName+" on pumpID: "+pumpID)
    return values[0]
    
def strRound(value, decimalPlaces):
    """ Ensures the given value exists and is exported with as many decimal places as specified """
    if pandas.isnull(value):
        return ""
    formatString = "{0:."+str(decimalPlaces)+"f}"
    return formatString.format(value)       
    
def safeguardToStr(value, string):
    """ Converts values that could be null values to "N/A" """
    return value if (not pandas.isnull(value) and value != "") else string 

def getRowsOfSinglePump(indexedDF, pumpID):
    """ Extracts the data frame rows correlated to a single heat pump from a collection of results """
    pumpDF = indexedDF.loc[pumpID] # all rows of data for a single heat pump 
    # handle pumps with only a single test point
    if "Series" in str(type(pumpDF)): 
        pumpDF = pandas.DataFrame(pumpDF).transpose()
    return pumpDF