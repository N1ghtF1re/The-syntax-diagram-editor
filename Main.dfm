object EditorForm: TEditorForm
  Left = 0
  Top = 0
  Caption = 'EditorForm'
  ClientHeight = 424
  ClientWidth = 737
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object canv: TImage
    Left = 0
    Top = 41
    Width = 737
    Height = 383
    Align = alClient
    OnMouseDown = canvMouseDown
    OnMouseMove = canvMouseMove
    OnMouseUp = canvMouseUp
    ExplicitTop = 8
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object Label1: TLabel
    Left = 504
    Top = 24
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 504
    Top = 56
    Width = 31
    Height = 13
    Caption = 'Label2'
  end
  object pnlOptions: TPanel
    Left = 0
    Top = 0
    Width = 737
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 432
    ExplicitTop = 152
    ExplicitWidth = 185
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
      Left = 280
      Top = 8
      Width = 209
      Height = 21
      AutoSelect = False
      TabOrder = 4
      Text = 'Kek'
    end
    object btnNone: TButton
      Left = 214
      Top = 0
      Width = 43
      Height = 41
      Caption = 'N'
      TabOrder = 5
      OnClick = btnNoneClick
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 136
    Top = 216
  end
end