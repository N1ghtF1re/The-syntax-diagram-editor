object EditorForm: TEditorForm
  Left = 0
  Top = 0
  Caption = 'EditorForm'
  ClientHeight = 324
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
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object canv: TPaintBox
    Left = 0
    Top = 41
    Width = 737
    Height = 283
    Align = alClient
    Color = clWhite
    ParentColor = False
    OnMouseDown = canvMouseDown
    OnMouseMove = canvMouseMove
    OnMouseUp = canvMouseUp
    OnPaint = canvPaint
    ExplicitLeft = 408
    ExplicitTop = 136
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
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
  object MainMenu: TMainMenu
    Left = 424
    Top = 200
    object mnFile: TMenuItem
      Caption = #1060#1072#1081#1083
      object mniSave: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        OnClick = mniSaveClick
      end
      object mniOpen: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        OnClick = mniOpenClick
      end
      object mniToSVG: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' SVG'
        OnClick = mniToSVGClick
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
