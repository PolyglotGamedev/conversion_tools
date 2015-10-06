Procedure.i SaveFormattedXml (xmlId, xmlFile$, flags=0, indentStep=3)
  Protected *buffer, encoding, size, ofn, Lpos, Rpos, indent=0
  Protected xml$, prevLeft$, prevRight$, txt$, curTag$
  
  ; Initialize
  If IsXML(xmlId) = 0
    ProcedureReturn 0                                                 ; error
  EndIf
  
  encoding = GetXMLEncoding(xmlId)
  size = ExportXMLSize(xmlId)
  *buffer = AllocateMemory(size)
  If *buffer = 0
    ProcedureReturn 0                                                 ; error
  EndIf
  
  If ExportXML(xmlId, *buffer, size) = 0
    FreeMemory(*buffer)
    ProcedureReturn 0                                                 ; error
  EndIf
  
  xml$ = PeekS(*buffer, -1, encoding)
  FreeMemory(*buffer)
  
  ofn = CreateFile(#PB_Any, xmlFile$)
  If ofn = 0
    ProcedureReturn 0                                                 ; error
  EndIf
  
  If flags & #PB_XML_StringFormat
    WriteStringFormat(ofn, encoding)
  EndIf
  
  ; Get and write XML declaration
  Lpos = FindString(xml$, "<", 1)
  Rpos = FindString(xml$, ">", Lpos) + 1
  curTag$ = Mid(xml$, Lpos, Rpos-Lpos)
  WriteString(ofn, curTag$, encoding)
  
  ; Get and write the other elements
  Lpos = FindString(xml$, "<", Rpos)
  While Lpos
    prevLeft$  = Left(curTag$, 2)
    prevRight$ = Right(curTag$, 2)
    
    txt$ = Mid(xml$, Rpos, Lpos-Rpos)
    
    If Mid(xml$, Lpos, 9) = "<![CDATA["
      Rpos = FindString(xml$, "]]>", Lpos) + 3
    Else
      Rpos = FindString(xml$, ">", Lpos) + 1
    EndIf
    curTag$ = Mid(xml$, Lpos, Rpos-Lpos)
    
    If FindString("</<!<?", prevLeft$, 1) = 0 And prevRight$ <> "/>"
      If Left(curTag$, 2) = "</"                                     ; <tag>text</tag>
        WriteString(ofn, txt$ + curTag$, encoding)
      Else                                                           ; <tag1><tag2>
        indent + indentStep
        WriteString(ofn, #LF$ + Space(indent) + curTag$, encoding)
      EndIf
    Else
      If Left(curTag$, 2) = "</"                                     ; </tag2>text</tag1>
        If Len(txt$)
          WriteString(ofn, #LF$ + Space(indent) + txt$, encoding)
        EndIf
        indent - indentStep
      EndIf
      WriteString(ofn, #LF$ + Space(indent) + curTag$, encoding)
    EndIf
    
    Lpos = FindString(xml$, "<", Rpos)
  Wend
  
  CloseFile(ofn)
  ProcedureReturn 1                                                    ; success
EndProcedure
; IDE Options = PureBasic 5.24 LTS (Windows - x64)
; CursorPosition = 42
; Folding = -
; EnableUnicode
; EnableXP