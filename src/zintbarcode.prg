******************************************************
*
*	ZintBarcode
*
*	A VFP connector to the Zint Barcode Library
*
*	Check documentation for usage and terms
*
*

#DEFINE	SAFETHIS		ASSERT !USED("This") AND TYPE("This") == "O"
#DEFINE	ZBVFPSIG		"~zbvfp_"

* install the classes
SET PROCEDURE TO (SYS(16)) ADDITIVE

* and the dependencies (Zint and Vfp2C32 libraries)
SET PATH TO (ADDBS(JUSTPATH(SYS(16))) + "external") ADDITIVE

* instantiate the library and we're ready to go
CREATEOBJECT("ZintLibrary")

*
* ZintBarcode
* a class to produce barcodes images
*
DEFINE CLASS ZintBarcode AS Custom

	* manage storage
	ADD OBJECT PROTECTED ImageFiles AS Collection

	PROTECTED Symbol, TempFolder, OwnFolder, SingleFile

	* the address of the Zint symbol structure
	Symbol = 0
	* location of temporary images (used to set the ControlSource of controls in forms and reports)
	TempFolder = ""
	OwnFolder = .F.
	SingleFile = .F.

	_MemberData = '<VFPData>' + ;
						'<memberdata name="encodesave" type="method" display="EncodeSave" />' + ;
						'<memberdata name="encode" type="method" display="Encode" />' + ;
						'<memberdata name="save" type="method" display="Save" />' + ;
						'<memberdata name="imagefile" type="method" display="ImageFile" />' + ;
						'<memberdata name="dynamicsettings" type="method" display="DynamicSettings" />' + ;
						'<memberdata name="reset" type="method" display="Reset" />' + ;
						'<memberdata name="issupported" type="method" display="IsSupported" />' + ;
						'<memberdata name="getsinglefile" type="method" display="GetSingleFile" />' + ;
						'<memberdata name="setsinglefile" type="method" display="SetSingleFile" />' + ;
						'<memberdata name="getsymbology" type="method" display="GetSymbology" />' + ;
						'<memberdata name="setsymbology" type="method" display="SetSymbology" />' + ;
						'<memberdata name="getheight" type="method" display="GetHeight" />' + ;
						'<memberdata name="setheight" type="method" display="SetHeight" />' + ;
						'<memberdata name="getwhitespacewidth" type="method" display="GetWhitespaceWidth" />' + ;
						'<memberdata name="setwhitespacewidth" type="method" display="SetWhitespaceWidth" />' + ;
						'<memberdata name="getborderwidth" type="method" display="GetBorderWidth" />' + ;
						'<memberdata name="setborderwidth" type="method" display="SetBorderWidth" />' + ;
						'<memberdata name="getoutputoptions" type="method" display="GetOutputOptions" />' + ;
						'<memberdata name="setoutputoptions" type="method" display="SetOutputOptions" />' + ;
						'<memberdata name="getfgcolour" type="method" display="GetFGColour" />' + ;
						'<memberdata name="setfgcolour" type="method" display="SetFGColour" />' + ;
						'<memberdata name="getbgcolour" type="method" display="GetBGColour" />' + ;
						'<memberdata name="setbgcolour" type="method" display="SetBGColour" />' + ;
						'<memberdata name="getoutfile" type="method" display="GetOutfile" />' + ;
						'<memberdata name="setoutfile" type="method" display="SetOutfile" />' + ;
						'<memberdata name="getscale" type="method" display="GetScale" />' + ;
						'<memberdata name="setscale" type="method" display="SetScale" />' + ;
						'<memberdata name="getoption" type="method" display="GetOption" />' + ;
						'<memberdata name="setoption" type="method" display="SetOption" />' + ;
						'<memberdata name="getshowhumanreadabletext" type="method" display="GetShowHumanReadableText" />' + ;
						'<memberdata name="setshowhumanreadabletext" type="method" display="SetShowHumanReadableText" />' + ;
						'<memberdata name="getfontsize" type="method" display="GetFontSize" />' + ;
						'<memberdata name="setfontsize" type="method" display="SetFontSize" />' + ;
						'<memberdata name="getinputmode" type="method" display="GetInputMode" />' + ;
						'<memberdata name="setinputmode" type="method" display="SetInputMode" />' + ;
						'<memberdata name="geteci" type="method" display="GetECI" />' + ;
						'<memberdata name="seteci" type="method" display="SetECI" />' + ;
						'<memberdata name="gettext" type="method" display="GetText" />' + ;
						'<memberdata name="settext" type="method" display="SetText" />' + ;
						'<memberdata name="getrows" type="method" display="GetRows" />' + ;
						'<memberdata name="getwidth" type="method" display="GetWidth" />' + ;
						'<memberdata name="getprimary" type="method" display="GetPrimary" />' + ;
						'<memberdata name="getencodeddata" type="method" display="GetEncodedData" />' + ;
						'<memberdata name="getrowheight" type="method" display="GetRowHeight" />' + ;
						'<memberdata name="geterrortext" type="method" display="GetErrorText" />' + ;
						'<memberdata name="getbitmappointer" type="method" display="GetBitmapPointer" />' + ;
						'<memberdata name="getbitmapwidth" type="method" display="GetBitmapWidth" />' + ;
						'<memberdata name="getbitmapheight" type="method" display="GetBitmapHeight" />' + ;
						'<memberdata name="getalphamappointer" type="method" display="GetAlphamapPointer" />' + ;
						'<memberdata name="getbitmapbytelength" type="method" display="GetBitmapByteLength" />' + ;
						'<memberdata name="getdotsize" type="method" display="GetDotSize" />' + ;
						'<memberdata name="getvectorpointer" type="method" display="GetVectorPointer" />' + ;
						'<memberdata name="getdebug" type="method" display="GetDebug" />' + ;
						'<memberdata name="setdebug" type="method" display="SetDebug" />' + ;
						'<memberdata name="getwarnlevel" type="method" display="GetWarnLevel" />' + ;
						'<memberdata name="setwarnlevel" type="method" display="SetWarnLevel" />' + ;
						'</VFPData>'

	PROCEDURE Init

		* get a Zint symbol structure from the Zint library
		This.Symbol = ZBarcode_Create()

		* create a folder for temporary images, or use the general temporary folder if that is not possible
		LOCAL Retries AS Integer

		m.Retries = 100
		DO WHILE m.Retries > 0 AND !This.OwnFolder
			TRY
				This.TempFolder = ADDBS(SYS(2023)) + SYS(3)
				MKDIR (This.TempFolder)
				This.OwnFolder = .T.
			CATCH
				m.Retries = m.Retries - 1
			ENDTRY
		ENDDO

		IF !This.OwnFolder
			This.TempFolder = SYS(2023)
		ENDIF

	ENDPROC

	PROCEDURE Destroy

		SAFETHIS

		* on exit, free the Zint symbol structure
		ZBarcode_Delete(This.Symbol)

		* and try to delete all temporary files and temporary folder, if we created one
		IF This.OwnFolder

			TRY
				ERASE (ADDBS(This.TempFolder) + "*.*")
				RMDIR (This.TempFolder)
			CATCH
			ENDTRY

		ELSE

			LOCAL Filename AS String
			FOR EACH m.Filename IN This.ImageFiles
				TRY
					ERASE (m.Filename)
				CATCH
				ENDTRY
			ENDFOR

		ENDIF

	ENDPROC

	* prepare and save a barcode to a file, at a given angle (0-90-180-270)
	PROCEDURE EncodeSave (InputData AS String, Filename AS String, Angle AS Integer) AS Integer

		SAFETHIS

		ZBarcode_Clear(This.Symbol)

		IF PCOUNT() > 1
			This.SetOutfile(m.Filename)
		ENDIF
		RETURN ZBarcode_Encode_And_Print(This.Symbol, m.InputData, LEN(m.InputData), EVL(m.Angle, 0))

	ENDPROC

	* prepare and render a barcode
	PROCEDURE Encode (InputData AS String, Filename AS String) AS Integer

		SAFETHIS

		IF PCOUNT() > 1 AND !EMPTY(m.Filename)
			This.SetOutfile(m.Filename)
		ENDIF
		RETURN ZBarcode_Encode(This.Symbol, m.InputData, LEN(m.InputData))

	ENDPROC

	* save a prepared barcode to a file at a given angle (0-90-180-270)
	PROCEDURE Save (Angle AS Integer) AS Integer

		SAFETHIS

		RETURN ZBarcode_Print(This.Symbol, EVL(m.Angle, 0))

	ENDPROC

	* render a barcode and save it to a temporary file, and return its filename
	* image file format is set as an extension
	PROCEDURE ImageFile (InputData AS String, ImageFormat AS String, Angle AS Integer) AS String

		SAFETHIS

		LOCAL Filename AS String
		LOCAL Extension AS String
		LOCAL ARRAY CheckFile(1)

		m.Extension = EVL(m.ImageFormat, "gif")

		IF This.SingleFile AND This.ImageFiles.Count > 0
			m.Filename = This.ImageFiles(1)
		ELSE
			m.Filename = ADDBS(This.TempFolder) + FORCEEXT(ZBVFPSIG + SYS(3), m.Extension)
			DO WHILE ADIR(m.CheckFile, m.Filename) > 0
				m.Filename = ADDBS(This.TempFolder) + FORCEEXT(ZBVFPSIG + SYS(3), m.Extension)
			ENDDO
			This.ImageFiles.Add(m.Filename)
		ENDIF

		* have other settings dynamically prepared
		This.DynamicSettings(m.InputData)

		IF This.EncodeSave(m.InputData, m.Filename, m.Angle) = 0
			RETURN m.Filename
			* the filename can be used as a ControlSource or Picture in controls
		ELSE
			RETURN ""
			* error should be checked by .GetErrorText()
		ENDIF

	ENDPROC

	* a placeholder for dynamic settings (subclass ZintBarcode to use this feature)
	PROCEDURE DynamicSettings (InputData AS String)
	ENDPROC

	* reset the Symbol structure to its defaults
	PROCEDURE Reset ()

		SAFETHIS

		ZBarcode_Clear(This.Symbol)

		LOCAL ZB AS ZintBarcode

		m.ZB = CREATEOBJECT("ZintBarCode")

		This.SetSymbology(m.ZB.GetSymbology())
		This.SetHeight(m.ZB.GetHeight())
		This.SetWhitespaceWidth(m.ZB.GetWhitespaceWidth())
		This.SetBorderWidth(m.ZB.GetBorderWidth())
		This.SetOutputOptions(m.ZB.GetOutputOptions())
		This.SetFGColour(m.ZB.GetFGColour())
		This.SetBGColour(m.ZB.GetBGColour())
		This.SetOutfile(m.ZB.GetOutfile())
		This.SetScale(m.ZB.GetScale())
		This.SetOption(1, m.ZB.GetOption(1))
		This.SetOption(2, m.ZB.GetOption(2))
		This.SetOption(3, m.ZB.GetOption(3))
		This.SetShowHumanReadableText(m.ZB.GetShowHumanReadableText())
		This.SetInputMode(m.ZB.GetInputMode())
		This.SetECI(m.ZB.GetECI())
		This.SetText(m.ZB.GetText())

	ENDPROC			

	* check if a barcode symbology, or a feature of a barcode symbology, is supported by the library
#IF .F.		&& Capability interrogation not available in distributed DLL
	PROCEDURE IsSupported (Symbology AS Integer, Feature AS Integer) AS Logical
#ELSE
	PROCEDURE IsSupported (Symbology AS Integer) AS Logical
#ENDIF
		SAFETHIS

		IF PCOUNT() > 1
			RETURN ZBarcode_Cap(m.Symbology, m.Feature) == m.Feature
		ELSE
			RETURN ZBarcode_ValidID(m.Symbology) != 0
		ENDIF

	ENDPROC

	* the SingleFile property determines if the ControlSource requires a single file (for instance, in a form)
	* or different files (for several barcodes in a page report)
	PROCEDURE GetSingleFile () AS Logical
		SAFETHIS

		RETURN This.SingleFile
	ENDPROC

	PROCEDURE SetSingleFile (SingleFile AS Logical)
		This.SingleFile = m.SingleFile
	ENDPROC

	* getters and setters of the Zint properties
	* check Zint documentation, mainly at http://www.zint.org.uk/Manual.aspx?type=p&page=5 (in particular 5.5)
	* and http://www.zint.org.uk/Manual.aspx?type=p&page=6

	PROCEDURE GetSymbology () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol)
	ENDPROC

	PROCEDURE SetSymbology (Symbology AS Integer)
		SAFETHIS

		WriteInt(This.Symbol, m.Symbology)
	ENDPROC

	PROCEDURE GetHeight () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 4)
	ENDPROC

	PROCEDURE SetHeight (Height AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 4, m.Height)
	ENDPROC

	PROCEDURE GetWhitespaceWidth () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 8)
	ENDPROC

	PROCEDURE SetWhitespaceWidth (WhitespaceWidth AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 8, m.WhitespaceWidth)
	ENDPROC

	PROCEDURE GetBorderWidth () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 12)
	ENDPROC

	PROCEDURE SetBorderWidth (BorderWidth AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 12, m.BorderWidth)
	ENDPROC

	PROCEDURE GetOutputOptions () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 16)
	ENDPROC

	PROCEDURE SetOutputOptions (OutputOptions AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 16, m.OutputOptions)
	ENDPROC

	* colors are translated back and forth to VFP's RGB() colors
	PROCEDURE GetFGColour () AS Integer
		SAFETHIS

		LOCAL HexString AS String

		m.HexString = PADR(ReadCString(This.Symbol + 20), 6, "0")
		RETURN EVALUATE("0x" + RIGHT(m.HexString, 2) + SUBSTR(m.HexString, 3, 2) + LEFT(m.HexString, 2))
	ENDPROC

	PROCEDURE SetFGColour (FGColour AS Integer)
		SAFETHIS

		WriteCharArray(This.Symbol + 20, SUBSTR(TRANSFORM(CTOBIN(BINTOC(m.FGColour, "S"), "4RS"), "@0"), 3, 6) + CHR(0))
	ENDPROC

	PROCEDURE GetBGColour () AS Integer
		SAFETHIS

		LOCAL HexString AS String

		m.HexString = PADR(ReadCString(This.Symbol + 36), 6, "0")
		RETURN EVALUATE("0x" + RIGHT(m.HexString, 2) + SUBSTR(m.HexString, 3, 2) + LEFT(m.HexString, 2))
	ENDPROC

	PROCEDURE SetBGColour (BGColour AS Integer)
		SAFETHIS

		WriteCharArray(This.Symbol + 36, SUBSTR(TRANSFORM(CTOBIN(BINTOC(m.BGColour, "S"), "4RS"), "@0"), 3, 6) + CHR(0))
	ENDPROC

	PROCEDURE GetOutfile () AS String
		SAFETHIS

		RETURN ReadCString(This.Symbol + 52)
	ENDPROC

	PROCEDURE SetOutfile (Outfile AS String)
		SAFETHIS

		WriteCharArray(This.Symbol + 52, PADR(m.Outfile, 255, CHR(0)) + CHR(0))
	ENDPROC

	PROCEDURE GetScale () AS Float
		SAFETHIS

		RETURN ReadFloat(This.Symbol + 308)
	ENDPROC

	PROCEDURE SetScale (Scale AS Float)
		SAFETHIS

		RETURN WriteFloat(This.Symbol + 308, m.Scale)
	ENDPROC

	* options are indexed 1..3
	PROCEDURE GetOption (Option AS Integer) AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 308 + MIN((MAX(INT(m.Option), 1)), 3) * 4)
	ENDPROC

	PROCEDURE SetOption (Option AS Integer, OptionValue AS Integer) AS Integer
		SAFETHIS

		RETURN WriteInt(This.Symbol + 308 + MIN((MAX(INT(m.Option), 1)), 3) * 4, m.OptionValue)
	ENDPROC

	PROCEDURE GetShowHumanReadableText () AS Logical
		SAFETHIS

		RETURN ReadInt(This.Symbol + 324) = 1
	ENDPROC

	PROCEDURE SetShowHumanReadableText (ShowHumanReadableText AS Logical)
		SAFETHIS

		RETURN WriteInt(This.Symbol + 324, IIF(m.ShowHumanReadableText, 1, 0))
	ENDPROC

	PROCEDURE GetFontSize () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 328)
	ENDPROC

	PROCEDURE SetFontSize (FontSize AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 328, m.FontSize)
	ENDPROC

	PROCEDURE GetInputMode () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 332)
	ENDPROC

	PROCEDURE SetInputMode (InputMode AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 332, m.InputMode)
	ENDPROC

	PROCEDURE GetECI () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 336)
	ENDPROC

	PROCEDURE SetECI (ECI AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 336, m.ECI)
	ENDPROC

	PROCEDURE GetText () AS String
		SAFETHIS

		RETURN STRCONV(ReadCharArray(This.Symbol + 340, 128), 11)
	ENDPROC

	PROCEDURE SetText (Text AS String)
		SAFETHIS

		WriteCharArray(This.Symbol + 340, PADR(STRCONV(m.Text, 9), 128, CHR(0)))
	ENDPROC

	PROCEDURE GetRows () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 468)
	ENDPROC

	PROCEDURE GetWidth () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 472)
	ENDPROC

	PROCEDURE GetPrimary () AS String
		SAFETHIS

		RETURN ReadCharArray(This.Symbol + 476, 128)
	ENDPROC

	PROCEDURE GetEncodedData () AS String
		SAFETHIS

		RETURN ReadBytes(This.Symbol + 604, 28600)	&& 200 * 143
	ENDPROC

	PROCEDURE GetRowHeight () AS String
		SAFETHIS

		RETURN ReadBytes(This.Symbol + 29204, 800)	&& 200 * sizeof(int)
	ENDPROC

	PROCEDURE GetErrorText () AS String
		SAFETHIS

		RETURN ReadCString(This.Symbol + 30004)
	ENDPROC

	PROCEDURE GetBitmapPointer () AS Long
		SAFETHIS

		RETURN ReadInt(This.Symbol + 30104)
	ENDPROC

	PROCEDURE GetBitmapWidth () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 30108)
	ENDPROC

	PROCEDURE GetBitmapHeight () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 30112)
	ENDPROC

	PROCEDURE GetAlphamapPointer () AS Long
		SAFETHIS

		RETURN ReadInt(This.Symbol + 30116)
	ENDPROC

	PROCEDURE GetBitmapByteLength () AS Integer
		SAFETHIS

		RETURN ReadUInt(This.Symbol + 30120)
	ENDPROC

	PROCEDURE GetDotSize () AS Float
		SAFETHIS

		RETURN ReadFloat(This.Symbol + 30124)
	ENDPROC

	PROCEDURE GetVectorPointer () AS Long
		SAFETHIS

		RETURN ReadInt(This.Symbol + 30128)
	ENDPROC

	PROCEDURE GetDebug () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 30132)
	ENDPROC

	PROCEDURE SetDebug (Debug AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 30132, m.Debug)
	ENDPROC

	PROCEDURE GetWarnLevel () AS Integer
		SAFETHIS

		RETURN ReadInt(This.Symbol + 30136)
	ENDPROC
        
	PROCEDURE SetWarnLevel (WarnLevel AS Integer)
		SAFETHIS

		WriteInt(This.Symbol + 30136, m.WarnLevel)
	ENDPROC

ENDDEFINE

*
* ZintEnumerations
* the enumerations used in ZintSymbol settings
*
* for instance
* m.ZS.SetSymbology(m.ZE.BARCODE_PDF417)
*
DEFINE CLASS ZintEnumerations AS Custom

	* imported from zint.h

	BARCODE_CODE11 = 1
	BARCODE_C25STANDARD = 2
	BARCODE_C25MATRIX = 2 && Legacy
	BARCODE_C25INTER = 3
	BARCODE_C25IATA = 4
	BARCODE_C25LOGIC = 6
	BARCODE_C25IND = 7
	BARCODE_CODE39 = 8
	BARCODE_EXCODE39 = 9
	BARCODE_EANX = 13
	BARCODE_EANX_CHK = 14
	BARCODE_GS1_128 = 16
	BARCODE_EAN128 = 16 && Legacy
	BARCODE_CODABAR = 18
	BARCODE_CODE128 = 20
	BARCODE_DPLEIT = 21
	BARCODE_DPIDENT = 22
	BARCODE_CODE16K = 23
	BARCODE_CODE49 = 24
	BARCODE_CODE93 = 25
	BARCODE_FLAT = 28
	BARCODE_DBAR_OMN = 29
	BARCODE_RSS14 = 29 && Legacy
	BARCODE_DBAR_LTD = 30
	BARCODE_RSS_LTD = 30 && Legacy
	BARCODE_DBAR_EXP = 31
	BARCODE_RSS_EXP = 31 && Legacy
	BARCODE_TELEPEN = 32
	BARCODE_UPCA = 34
	BARCODE_UPCA_CHK = 35
	BARCODE_UPCE = 37
	BARCODE_UPCE_CHK = 38
	BARCODE_POSTNET = 40
	BARCODE_MSI_PLESSEY = 47
	BARCODE_FIM = 49
	BARCODE_LOGMARS = 50
	BARCODE_PHARMA = 51
	BARCODE_PZN = 52
	BARCODE_PHARMA_TWO = 53
	BARCODE_PDF417 = 55
	BARCODE_PDF417COMP = 56
	BARCODE_PDF417TRUNC = 56 && Legacy
	BARCODE_MAXICODE = 57
	BARCODE_QRCODE = 58
	BARCODE_CODE128B = 60
	BARCODE_AUSPOST = 63
	BARCODE_AUSREPLY = 66
	BARCODE_AUSROUTE = 67
	BARCODE_AUSREDIRECT = 68
	BARCODE_ISBNX = 69
	BARCODE_RM4SCC = 70
	BARCODE_DATAMATRIX = 71
	BARCODE_EAN14 = 72
	BARCODE_VIN = 73
	BARCODE_CODABLOCKF = 74
	BARCODE_NVE18 = 75
	BARCODE_JAPANPOST = 76
	BARCODE_KOREAPOST = 77
	BARCODE_DBAR_STK = 79
	BARCODE_RSS14STACK = 79 && Legacy
	BARCODE_DBAR_OMNSTK = 80
	BARCODE_RSS14STACK_OMNI = 80 && Legacy
	BARCODE_DBAR_EXPSTK = 81
	BARCODE_RSS_EXPSTACK = 81 && Legacy
	BARCODE_PLANET = 82
	BARCODE_MICROPDF417 = 84
	BARCODE_USPS_IMAIL = 85
	BARCODE_ONECODE = 85 && Legacy
	BARCODE_PLESSEY = 86

    && Tbarcode 8 codes 
	BARCODE_TELEPEN_NUM = 87
	BARCODE_ITF14 = 89
	BARCODE_KIX = 90
	BARCODE_AZTEC = 92
	BARCODE_DAFT = 93
	BARCODE_DPD = 96
	BARCODE_MICROQR = 97

    && Tbarcode 9 codes 
	BARCODE_HIBC_128 = 98
	BARCODE_HIBC_39 = 99
	BARCODE_HIBC_DM = 102
	BARCODE_HIBC_QR = 104
	BARCODE_HIBC_PDF = 106
	BARCODE_HIBC_MICPDF = 108
	BARCODE_HIBC_BLOCKF = 110
	BARCODE_HIBC_AZTEC = 112

    && Tbarcode 10 codes 
	BARCODE_DOTCODE = 115
	BARCODE_HANXIN = 116

    &&Tbarcode 11 codes
	BARCODE_MAILMARK = 121

    && Zint specific 
	BARCODE_AZRUNE = 128
	BARCODE_CODE32 = 129
	BARCODE_EANX_CC = 130
	BARCODE_GS1_128_CC = 131
	BARCODE_EAN128_CC = 131 && Legacy
	BARCODE_DBAR_OMN_CC = 132
	BARCODE_RSS14_CC = 132 && Legacy
	BARCODE_DBAR_LTD_CC = 133
	BARCODE_RSS_LTD_CC = 133 && Legacy
	BARCODE_DBAR_EXP_CC = 134
	BARCODE_RSS_EXP_CC = 134 && Legacy
	BARCODE_UPCA_CC = 135
	BARCODE_UPCE_CC = 136
	BARCODE_DBAR_STK_CC = 137
	BARCODE_RSS14STACK_CC = 137 && Legacy
	BARCODE_DBAR_OMNSTK_CC = 138
	BARCODE_RSS14_OMNI_CC = 138 && Legacy
	BARCODE_DBAR_EXPSTK_CC = 139
	BARCODE_RSS_EXPSTACK_CC = 139 && Legacy
	BARCODE_CHANNEL = 140
	BARCODE_CODEONE = 141
	BARCODE_GRIDMATRIX = 142
	BARCODE_UPNQR = 143
	BARCODE_ULTRA = 144
	BARCODE_RMQR = 145

&& Output options
	BARCODE_NO_ASCII = 1
	BARCODE_BIND = 2
	BARCODE_BOX = 4
	BARCODE_STDOUT = 8
	READER_INIT = 16
	SMALL_TEXT = 32
	BOLD_TEXT = 64
	CMYK_COLOUR = 128
	BARCODE_DOTTY_MODE = 256
	GS1_GS_SEPARATOR = 512
	OUT_BUFFER_INTERMEDIATE = 1024

&& Input data types
	DATA_MODE = 0
	UNICODE_MODE = 1
	GS1_MODE = 2
	ESCAPE_MODE = 8

&& Data Matrix specific options (option_3)
	DM_SQUARE = 100
	DM_DMRE = 101

&& QR, Han Xin, Grid Matrix specific options (option_3)
	ZINT_FULL_MULTIBYTE = 200

&& Ultracode specific option (option_3)
	ULTRA_COMPRESSION = 128

&& Warning and error conditions
	ZINT_WARN_INVALID_OPTION = 2
	ZINT_WARN_USES_ECI = 3
	ZINT_WARN_NONCOMPLIANT = 4
	ZINT_ERROR = 5 && Warn/error marker, not returned 
	ZINT_ERROR_TOO_LONG = 5
	ZINT_ERROR_INVALID_DATA = 6
	ZINT_ERROR_INVALID_CHECK = 7
	ZINT_ERROR_INVALID_OPTION = 8
	ZINT_ERROR_ENCODING_PROBLEM = 9
	ZINT_ERROR_FILE_ACCESS = 10
	ZINT_ERROR_MEMORY = 11

&& File types
	OUT_BUFFER = 0
	OUT_SVG_FILE = 10
	OUT_EPS_FILE = 20
	OUT_EMF_FILE = 30
	OUT_PNG_FILE = 100
	OUT_BMP_FILE = 120
	OUT_GIF_FILE = 140
	OUT_PCX_FILE = 160
	OUT_JPG_FILE = 180
	OUT_TIF_FILE = 200

&& Warning warn
	WARN_DEFAULT = 0
	WARN_ZPL_COMPAT = 1
	WARN_FAIL_ALL = 2

&& Capability flags
	ZINT_CAP_HRT = 0x0001
	ZINT_CAP_STACKABLE = 0x0002
	ZINT_CAP_EXTENDABLE = 0x0004
	ZINT_CAP_COMPOSITE = 0x0008
	ZINT_CAP_ECI = 0x0010
	ZINT_CAP_GS1 = 0x0020
	ZINT_CAP_DOTTY = 0x0040
	ZINT_CAP_FIXED_RATIO = 0x0100 && Aspect ratio 
	ZINT_CAP_READER_INIT = 0x0200
	ZINT_CAP_FULL_MULTIBYTE = 0x0400

&& Debug flags
	ZINT_DEBUG_PRINT = 1
	ZINT_DEBUG_TEST = 2

ENDDEFINE

*
* ZintLibrary
* a loader of dependencies
* - zint.dll - barcode generator
* - vfp2c32.fll - VFP to C structures connector
*
DEFINE CLASS ZintLibrary AS Custom

	PROCEDURE Init

		SET LIBRARY TO (LOCFILE("vfp2c32.fll")) ADDITIVE

		LOCAL ZintDLL AS String

		m.ZintDLL = LOCFILE("zint.dll")

		DECLARE LONG ZBarcode_Create IN (m.ZintDLL)
		DECLARE ZBarcode_Clear IN (m.ZintDLL) ;
			LONG zint_symbol
		DECLARE ZBarcode_Delete IN (m.ZintDLL) ;
			LONG zint_symbol
		DECLARE INTEGER ZBarcode_Encode_and_Print IN (m.ZintDLL) ;
			LONG zint_symbol, STRING input_data, INTEGER length, INTEGER rotate_angle
		DECLARE INTEGER ZBarcode_Encode IN (m.ZintDLL) ;
			LONG zint_symbol, STRING input_data, INTEGER length
		DECLARE INTEGER ZBarcode_Print IN (m.ZintDLL) ;
			LONG zint_symbol, INTEGER rotate_angle
		DECLARE INTEGER ZBarcode_ValidID IN (M.ZintDLL) ;
			LONG symbol_id
#IF	.F.		&& Capability interrogation not available in distributed DLL
		DECLARE INTEGER ZBarcode_Cap IN (m.ZintDLL) ;
			LONG symbol_id, LONG cap_flag
#ENDIF

	ENDPROC

ENDDEFINE
