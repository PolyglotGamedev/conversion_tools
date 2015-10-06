; fill labels
SetGadgetText(tCSVexplanation, "Welcome to the CSV converter. Please set the path to your Polyglot-CSV file below and press 'Generate language files' to generate all language files in the correct format.")
SetGadgetText(tVersion, "Force version")
SetGadgetText(sVersion, "")
SetGadgetText(bOutput, "Browse folder")
SetGadgetText(bInput, "Browse CSV file")
SetGadgetText(tOutput, "Output folder")
SetGadgetText(tInput, "Input CSV")
SetGadgetText(sOutputPath, GetHomeDirectory())
SetGadgetText(bCSVconvert, "Generate language files")
SetGadgetText(sCSVpath, GetHomeDirectory() + "Polyglot.csv")

; set logo image
If LoadImage(0, GetCurrentDirectory() + "res/polyglot.png")
  SetGadgetState(iLogo, ImageID(0))
EndIf

; set attributes
SetGadgetAttribute(sVersion, #PB_String_MaximumLength, 3)

; fill editors
credstr.s = ""
If ReadFile(0, GetCurrentDirectory() + "res/CREDITS.txt")
  While Eof(0) = 0
    credstr = credstr + ReadString(0) + #LF$
  Wend
Else
  credstr = "COULD NOT LOAD RES/CREDITS.TXT"
EndIf
SetGadgetText(CreditsEditor, credstr)

licstr.s = ""
If ReadFile(0, GetCurrentDirectory() + "res/LICENSE.txt")
  While Eof(0) = 0
    licstr = licstr + ReadString(0) + #LF$
  Wend
Else
  credstr = "COULD NOT LOAD RES/LICENSE.TXT"
EndIf
SetGadgetText(LicenseEditor, licstr)
; IDE Options = PureBasic 5.24 LTS (Windows - x64)
; CursorPosition = 1
; EnableUnicode
; EnableXP