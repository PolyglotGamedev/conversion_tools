;
; ------------------------------------------------------------
;
;   PureBasic - polyglot tool
;
;    (c) 2015 - trisymphony.com
;
; ------------------------------------------------------------

version.s = "0.4"

UsePNGImageDecoder()


; -- helpers

Procedure.s unescapeCSVquotes(QUOTE.s)
  num = CountString(QUOTE, #DOUBLEQUOTE$)
  If num > 2 ; some escaped quotes detected
    ; TODO
    ; pos1 = FindString(QUOTE, #DOUBLEQUOTE$)
    ; ReplaceString(QUOTE, #DOUBLEQUOTE$, "", #PB_String_CaseSensitive, pos1, 1)
    ProcedureReturn QUOTE
  ElseIf num = 2 ; just marks the data
    ProcedureReturn ReplaceString(QUOTE, #DOUBLEQUOTE$, "")
  Else ; no double quotes
    ProcedureReturn QUOTE
  EndIf
EndProcedure


; -- program

XIncludeFile "polyglotTool.pbf"
IncludeFile "formatxml.pb"

; open window
OpenwinMain()
; run basic init setup
IncludeFile "init.pb"
SetWindowTitle(winMain, GetWindowTitle(winMain) + " v" + version)

Structure lang
  init.i
  List langcode.s()
  List langname.s()
  List langdir.s()
EndStructure

NewMap LangRegister.lang()


Procedure convertCSV()
  ; IN from UI
  ip.s = GetGadgetText(sCSVpath)
  op.s = GetGadgetText(sOutputPath)
  vs.s = GetGadgetText(sVersion)
  
  ; version correction
  If vs = ""
    vs = "100"
  EndIf
  
  
  NewList CSV.s()
  LANGCODES.lang\init = 1 ; initialize langua code struct
  
  ; check output dir
  If FileSize(op) <> -2
    MessageRequester("Error", "Output path does not exist!")
    ProcedureReturn 0
  EndIf
  
  ; check CSV and read
  If ReadFile(0, ip)
    While Eof(0) = 0
      curline.s = Trim(ReadString(0))
      If curline <> ""
        AddElement(CSV())
        CSV() = curline
      EndIf
    Wend
    CloseFile(0)
  Else
    MessageRequester("Error", "Could not open CSV input file!")
    ProcedureReturn 0
  EndIf
  
  ; rewind CSV()
  FirstElement(CSV()) ; ignore first line content, but use it to count 
  nColumns = CountString(CSV(), ",") + 1
  DeleteElement(CSV(), 1) ; DEL 1
  ; lang codes
  For k=3 To nColumns
    AddElement(LANGCODES\langcode())
    LANGCODES\langcode() = ReplaceString(StringField(CSV(), k, ","), " ", "_", #PB_String_InPlace) ; replace spaces between multiple codes with underscores
  Next
  DeleteElement(CSV(), 1) ; DEL 2
  ; lang names
  For k=3 To nColumns
    AddElement(LANGCODES\langname())
    LANGCODES\langname() = StringField(CSV(), k, ",")
  Next
  ResetList(LANGCODES\langname())
  DeleteElement(CSV(), 1) ; DEL 3
  ; lang directions
  For k=3 To nColumns
    AddElement(LANGCODES\langdir())
    LANGCODES\langdir() = StringField(CSV(), k, ",")
  Next
  ResetList(LANGCODES\langdir())
  DeleteElement(CSV(), 1) ; DEL 4
  
  DeleteElement(CSV(), 1) ; DEL 5
  DeleteElement(CSV(), 1) ; DEL 6
  
  
  ; translated strings start at line 7
  ForEach LANGCODES\langcode()
    index = ListIndex(LANGCODES\langcode())
    NextElement(LANGCODES\langname())
    NextElement(LANGCODES\langdir())
    
    
    ; -- XML generator
    If GetGadgetState(cXML) = #PB_Checkbox_Checked
      
      ; Create xml head
      xml = CreateXML(#PB_Any)
      mainNode = CreateXMLNode(RootXMLNode(xml)) 
      SetXMLNodeName(mainNode, "resources") 
      item = CreateXMLNode(mainNode)
      SetXMLNodeName(item, "polyglot") 
      SetXMLAttribute(item, "LANG", LANGCODES\langname())
      SetXMLAttribute(item, "DIRECTION", LANGCODES\langdir())
      SetXMLAttribute(item, "VERSION", vs)
      SetXMLAttribute(item, "DATE", FormatDate("%yyyy-%mm-%dd", Date()))
      
      ; loop through each line of translated strings
      ForEach CSV()
        ; get first for STRING_CODE
        first.s = StringField(CSV(), 1, ",")
        ; get at current LANGCODES index for properly translated string
        trans.s = StringField(CSV(), index+3, ",")
        ; Create xml node
        item = CreateXMLNode(mainNode)
        SetXMLNodeName(item, "s") 
        SetXMLAttribute(item, "n", first) 
        SetXMLNodeText(item, trans) 
      Next
      
      ; compose file name
      FILENAME.s = "Polyglot-" + vs + "_" + LANGCODES\langcode() + ".xml"
      ; write file
      FormatXML(xml, #PB_XML_CutNewline)
      If Not SaveFormattedXML(xml, op + FILENAME)
        MessageRequester("Error", "XML files could not be saved. Please try another path.")
        ProcedureReturn 0
      EndIf
      
      FreeXML(xml)
    EndIf
  
    
    ; -- JSON generator
    If GetGadgetState(cJSON) = #PB_Checkbox_Checked
      
      ; header
      json.s = "{" + #LF$
      json + "    " + #DOUBLEQUOTE$ + "resources" + #DOUBLEQUOTE$ + ": {" + #LF$
      json + "        " + #DOUBLEQUOTE$ + "polyglot" + #DOUBLEQUOTE$ + ": {" + #LF$
      json + "            " + #DOUBLEQUOTE$ + "LANG" + #DOUBLEQUOTE$ + ": " + #DOUBLEQUOTE$ + LANGCODES\langname() + #DOUBLEQUOTE$ + "," + #LF$
      json + "            " + #DOUBLEQUOTE$ + "DIRECTION" + #DOUBLEQUOTE$ + ": " + #DOUBLEQUOTE$ + LANGCODES\langdir() + #DOUBLEQUOTE$ + "," + #LF$
      json + "            " + #DOUBLEQUOTE$ + "VERSION" + #DOUBLEQUOTE$ + ": " + #DOUBLEQUOTE$ + vs + #DOUBLEQUOTE$ + "," + #LF$
      json + "            " + #DOUBLEQUOTE$ + "DATE" + #DOUBLEQUOTE$ + ": " + #DOUBLEQUOTE$ + FormatDate("%yyyy-%mm-%dd", Date()) + #DOUBLEQUOTE$ + #LF$
      json + "        }," + #LF$
      json + "        " + #DOUBLEQUOTE$ + "data" + #DOUBLEQUOTE$ + ": [" + #LF$
      
      ; loop through each line of translated strings
      ForEach CSV()
        ; get first for STRING_CODE
        first.s = StringField(CSV(), 1, ",")
        ; get at current LANGCODES index for properly translated string
        trans.s = StringField(CSV(), index+3, ",")
        ; Create node
        json + "            {" + #LF$
        json + "                " + #DOUBLEQUOTE$ + "n" + #DOUBLEQUOTE$ + ": " + #DOUBLEQUOTE$ + first + #DOUBLEQUOTE$ + "," + #LF$
        json + "                " + #DOUBLEQUOTE$ + "s" + #DOUBLEQUOTE$ + ": " + #DOUBLEQUOTE$ + trans + #DOUBLEQUOTE$ + #LF$
        json + "            }," + #LF$
      Next
      
      json = Mid(json, 1, Len(json)-2)
      json + #LF$ + "        ]" + #LF$
      json + "    }" + #LF$
      json + "}"
     
      ; compose file name
      FILENAME.s = "Polyglot-" + vs + "_" + LANGCODES\langcode() + ".json"
      ; write file
      If OpenFile(0, op + FILENAME, #PB_UTF8)
        WriteStringN(0, json)
        CloseFile(0)
      Else
        MessageRequester("Error", "JSON files could not be saved. Please try another path.")
        ProcedureReturn 0
      EndIf
      
    EndIf
    
    
    
    
    
    
  Next
  
  MessageRequester("Success", "Language files have been written to " + op + ".")
  
  ProcedureReturn 0
EndProcedure



;main loop da whoop

Repeat
  Event = WaitWindowEvent()
  
  Select Event
      
      
    Case #PB_Event_Gadget
      Select EventGadget()
          
        Case bOutput
          Path$ = PathRequester("Please choose your Output path...", GetHomeDirectory())
          If Path$
            SetGadgetText(sOutputPath, Path$)
          EndIf
          
        Case bInput
          Path$ = OpenFileRequester("Please choose your CSV input file...", GetHomeDirectory(), "CSV file (*.csv)|*.csv", 0)
          If Path$
            SetGadgetText(sCSVpath, Path$)
          EndIf
          
        Case bCSVconvert
          DisableGadget(bCSVconvert, 1)
          SetGadgetText(bCSVconvert, "Working...")
          Delay(100)
          convertCSV()
          DisableGadget(bCSVconvert, 0)
          SetGadgetText(bCSVconvert, "Generate language files")
          
      EndSelect
      
  EndSelect
Until Event = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 9
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; Executable = build\PolyglotToolv02.exe