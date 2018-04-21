object EditorForm: TEditorForm
  Left = 0
  Top = 0
  Caption = #1053#1086#1074#1099#1081' '#1092#1072#1081#1083' - Syntax Diagrams'
  ClientHeight = 403
  ClientWidth = 737
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
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlOptions: TPanel
    Left = 0
    Top = 0
    Width = 737
    Height = 41
    Align = alTop
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
      Top = 14
      Width = 209
      Height = 21
      AutoSelect = False
      TabOrder = 4
      Text = 'Kek'
    end
    object btnNone: TButton
      Left = 270
      Top = -2
      Width = 43
      Height = 41
      Caption = 'N'
      TabOrder = 5
      OnClick = btnNoneClick
    end
    object btnALine: TButton
      Left = 215
      Top = -2
      Width = 49
      Height = 41
      Caption = '\----/'
      TabOrder = 6
      OnClick = btnALineClick
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 41
    Width = 737
    Height = 362
    Align = alClient
    BorderStyle = bsNone
    TabOrder = 1
    OnMouseWheelDown = ScrollBox1MouseWheelDown
    OnMouseWheelUp = ScrollBox1MouseWheelUp
    object canv: TPaintBox
      Left = 0
      Top = -2
      Width = 733
      Height = 360
      Color = clWhite
      ParentColor = False
      OnMouseDown = canvMouseDown
      OnMouseMove = canvMouseMove
      OnMouseUp = canvMouseUp
      OnPaint = canvPaint
    end
  end
  object MainMenu: TMainMenu
    Left = 424
    Top = 200
    object mnFile: TMenuItem
      Caption = #1060#1072#1081#1083
      object mniNew: TMenuItem
        Caption = #1053#1086#1074#1099#1081
        OnClick = mniNewClick
      end
      object mniOpen: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        OnClick = mniOpenClick
      end
      object mniSave: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        OnClick = mniSaveClick
      end
      object mniSaveAs: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082
        OnClick = mniSaveAsClick
      end
      object mniExport: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090
        object mniExportToBMP: TMenuItem
          Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' BMP'
          OnClick = mniExportToBMPClick
        end
        object mniToSVG: TMenuItem
          Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' SVG'
          OnClick = mniToSVGClick
        end
      end
    end
    object mnSettings: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      object mniHolstSize: TMenuItem
        Caption = #1056#1072#1079#1084#1077#1088' '#1093#1086#1083#1089#1090#1072
        OnClick = mniHolstSizeClick
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 640
    Top = 160
  end
  object SaveDialog1: TSaveDialog
    Left = 56
    Top = 168
  end
end
