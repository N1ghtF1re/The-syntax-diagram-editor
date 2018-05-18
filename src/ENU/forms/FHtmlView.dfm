object FHtml: TFHtml
  Left = 0
  Top = 0
  Caption = 'FHtml'
  ClientHeight = 505
  ClientWidth = 562
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 562
    Height = 505
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 16
    ExplicitTop = 16
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C000000163A0000313400000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126209000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object pmHtmlMenu: TPopupMenu
    Left = 328
    Top = 72
    object pmiClose: TMenuItem
      Caption = 'Close'
      OnClick = pmiCloseClick
    end
  end
end
