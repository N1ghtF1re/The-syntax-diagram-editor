object FCanvasSettings: TFCanvasSettings
  Left = 0
  Top = 0
  Caption = 'Change canvas size'
  ClientHeight = 246
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 418
    Height = 246
    Align = alClient
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 16
      Width = 190
      Height = 20
      Caption = 'Enter new sizes'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
    end
    object lblWidth: TLabel
      Left = 24
      Top = 64
      Width = 50
      Height = 16
      Caption = 'Width:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object lblHeight: TLabel
      Left = 24
      Top = 125
      Width = 48
      Height = 16
      Caption = 'Height:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object lbl1px: TLabel
      Left = 175
      Top = 88
      Width = 12
      Height = 14
      Caption = 'px'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 175
      Top = 148
      Width = 12
      Height = 14
      Caption = 'px'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object edtWidth: TEdit
      Left = 24
      Top = 85
      Width = 145
      Height = 22
      NumbersOnly = True
      TabOrder = 0
      Text = 'edtWidth'
    end
    object edtHeight: TEdit
      Left = 24
      Top = 144
      Width = 145
      Height = 22
      NumbersOnly = True
      TabOrder = 1
      Text = 'edtHeight'
    end
    object btnOk: TButton
      Left = 224
      Top = 208
      Width = 75
      Height = 25
      Caption = 'Accept'
      Default = True
      ModalResult = 1
      TabOrder = 2
    end
    object btnCancel: TButton
      Left = 320
      Top = 208
      Width = 75
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
  end
end
