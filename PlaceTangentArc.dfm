object PlaceConnectingArcForm: TPlaceConnectingArcForm
  Left = 200
  Top = 292
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  Caption = 'Place Connecting Tangent Arc'
  ClientHeight = 120
  ClientWidth = 314
  Color = clWhite
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = PlaceConnectingArcFormOnShow
  FormKind = fkModal
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 16
    Top = 24
    Width = 52
    Height = 13
    Caption = 'Arc Radius'
  end
  object UnitsLabel: TLabel
    Left = 215
    Top = 20
    Width = 16
    Height = 13
    Caption = 'mm'
  end
  object Label1: TLabel
    Left = 86
    Top = 47
    Width = 36
    Height = 13
    Caption = 'Metric'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object XPBitBtn1: TXPBitBtn
    Left = 113
    Top = 75
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = XPBitBtn1Click
    Default = True
    ModalResult = 1
  end
  object XPBitBtn2: TXPBitBtn
    Left = 217
    Top = 75
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = XPBitBtn2Click
    Cancel = True
  end
  object ArcRadius: TEdit
    Left = 80
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'ArcRadius'
  end
  object Metric: TXPCheckBox
    Left = 135
    Top = 45
    Width = 15
    Height = 17
    Caption = 'Metric'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = MetricClick
    Alignment = taLeftJustify
  end
end
