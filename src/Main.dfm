object EditorForm: TEditorForm
  Left = 0
  Top = 0
  Caption = #1053#1086#1074#1099#1081' '#1092#1072#1081#1083' - Syntax Diagrams'
  ClientHeight = 387
  ClientWidth = 766
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlOptions: TPanel
    Left = 0
    Top = 0
    Width = 766
    Height = 41
    Align = alTop
    Color = clMenu
    ParentBackground = False
    TabOrder = 0
    object btnMV: TButton
      Left = 71
      Top = 0
      Width = 42
      Height = 37
      Caption = '<>'
      TabOrder = 0
      OnClick = btnMVClick
    end
    object btnDef: TButton
      Left = 24
      Top = 0
      Width = 41
      Height = 37
      Caption = '::='
      TabOrder = 1
      OnClick = btnDefClick
    end
    object btnLine: TButton
      Left = 167
      Top = -2
      Width = 41
      Height = 41
      Caption = '---'
      TabOrder = 2
      OnClick = btnLineClick
    end
    object btnMC: TButton
      Left = 119
      Top = 0
      Width = 42
      Height = 37
      Caption = 'C'
      TabOrder = 3
      OnClick = btnMCClick
    end
    object edtRectText: TEdit
      Left = 376
      Top = 8
      Width = 209
      Height = 21
      AutoSelect = False
      TabOrder = 4
      Text = 'Example'
    end
    object btnNone: TButton
      Left = 214
      Top = -2
      Width = 43
      Height = 41
      Caption = 'N'
      TabOrder = 5
      OnClick = btnNoneClick
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 41
    Width = 766
    Height = 346
    Align = alClient
    BorderStyle = bsNone
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 1
    OnMouseWheelDown = ScrollBox1MouseWheelDown
    OnMouseWheelUp = ScrollBox1MouseWheelUp
    object pbMain: TPaintBox
      Left = 0
      Top = 0
      Width = 766
      Height = 346
      Color = clWhite
      ParentColor = False
      OnMouseDown = pbMainMouseDown
      OnMouseMove = pbMainMouseMove
      OnMouseUp = pbMainMouseUp
      OnPaint = pbMainPaint
    end
  end
  object MainMenu: TMainMenu
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    Left = 56
    Top = 120
    object mnFile: TMenuItem
      Caption = #1060#1072#1081#1083
      OnDrawItem = mnFileDrawItem
      object mniNew: TMenuItem
        Action = actNew
        OnDrawItem = mniNewDrawItem
      end
      object mniOpen: TMenuItem
        Action = actOpen
        OnDrawItem = mniNewDrawItem
      end
      object mniSave: TMenuItem
        Action = actSave
        OnDrawItem = mniNewDrawItem
      end
      object mniSaveAs: TMenuItem
        Action = actSaveAs
        OnDrawItem = mniNewDrawItem
      end
      object mniExport: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090
        ImageIndex = 4
        OnDrawItem = mniNewDrawItem
        object mniExportToBMP: TMenuItem
          Action = actExportBMP
          OnDrawItem = mniNewDrawItem
        end
        object mniToSVG: TMenuItem
          Action = actExportSVG
          OnDrawItem = mniNewDrawItem
        end
      end
    end
    object mniEdit: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      object mniCopy: TMenuItem
        Action = actCopy
      end
      object mniPast: TMenuItem
        Action = actPast
      end
    end
    object mnSettings: TMenuItem
      Tag = 1
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      OnDrawItem = mnFileDrawItem
      object mniHolstSize: TMenuItem
        Caption = #1056#1072#1079#1084#1077#1088' '#1093#1086#1083#1089#1090#1072
        OnClick = mniHolstSizeClick
        OnDrawItem = mniNewDrawItem
      end
    end
    object mniHtml: TMenuItem
      Tag = 3
      Caption = #1055#1086#1084#1086#1097#1100
      OnDrawItem = mnFileDrawItem
      object mniWhatIsSD: TMenuItem
        Caption = #1063#1090#1086' '#1090#1072#1082#1086#1077' '#1089#1080#1085#1090#1072#1082#1089#1080#1095#1077#1089#1082#1080#1077' '#1076#1080#1072#1075#1088#1072#1084#1084#1099'?'
        OnClick = mniWhatIsSDClick
        OnDrawItem = mniNewDrawItem
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 56
    Top = 72
  end
  object SaveDialog1: TSaveDialog
    Left = 56
    Top = 168
  end
  object alMain: TActionList
    Left = 56
    Top = 216
    object actNew: TAction
      Category = 'ctgFile'
      Caption = #1053#1086#1074#1099#1081
      ImageIndex = 0
      ShortCut = 16462
      OnExecute = actNewExecute
    end
    object actOpen: TAction
      Category = 'ctgFile'
      Caption = #1054#1090#1082#1088#1099#1090#1100
      ImageIndex = 1
      ShortCut = 16463
      OnExecute = actOpenExecute
    end
    object actSave: TAction
      Category = 'ctgFile'
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      ImageIndex = 2
      ShortCut = 16467
      OnExecute = actSaveExecute
    end
    object actSaveAs: TAction
      Category = 'ctgFile'
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082
      ImageIndex = 3
      ShortCut = 49235
      OnExecute = actSaveAsExecute
    end
    object actExportBMP: TAction
      Category = 'ctgExport'
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' BMP'
      OnExecute = actExportBMPExecute
    end
    object actExportSVG: TAction
      Category = 'ctgExport'
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' SVG'
      OnExecute = actExportSVGExecute
    end
    object actCopy: TAction
      Category = 'Edit'
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      ShortCut = 16451
      OnExecute = actCopyExecute
    end
    object actPast: TAction
      Category = 'Edit'
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      ShortCut = 16470
      OnExecute = actPastExecute
    end
  end
end
