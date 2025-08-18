object PlaceRectangleForm: TPlaceRectangleForm
  Left = 51
  Top = 89
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  Caption = 'Find Runt Object'
  ClientHeight = 114
  ClientWidth = 447
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
  OnShow = FindRuntObjectFormCreate
  FormKind = fkModal
  PixelsPerInch = 96
  TextHeight = 13
  object Label13: TLabel
    Left = 106
    Top = 18
    Width = 64
    Height = 13
    Alignment = taRightJustify
    Caption = 'Min Length'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object UnitsLabel: TLabel
    Left = 263
    Top = 20
    Width = 16
    Height = 13
    Caption = 'mm'
  end
  object XPBitBtn1: TXPBitBtn
    Left = 257
    Top = 75
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = OkButtonClick
    Default = True
    ModalResult = 1
  end
  object XPBitBtn2: TXPBitBtn
    Left = 337
    Top = 75
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = CancelButtonClick
    Cancel = True
  end
  object MinArcLength: TEdit
    Left = 176
    Top = 15
    Width = 80
    Height = 19
    BevelEdges = []
    Color = clWhite
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    Text = '2000'
  end
  object Metric: TCheckBox
    Left = 158
    Top = 50
    Width = 97
    Height = 17
    Caption = 'Metric'
    TabOrder = 3
    OnClick = MetricClick
  end
end
