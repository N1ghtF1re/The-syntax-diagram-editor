object CanvasSettingsForm: TCanvasSettingsForm
  Left = 0
  Top = 0
  Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1088#1072#1079#1084#1077#1088' '#1093#1086#1083#1089#1090#1072
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
      Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1086#1074#1099#1077' '#1088#1072#1079#1084#1077#1088#1099' '#1093#1086#1083#1089#1090#1072': '
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
      Caption = #1064#1080#1088#1080#1085#1072':'
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
      Caption = #1042#1099#1089#1086#1090#1072':'
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
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Default = True
      ModalResult = 1
      TabOrder = 2
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 320
      Top = 208
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 3
      OnClick = btnCancelClick
    end
  end
end
