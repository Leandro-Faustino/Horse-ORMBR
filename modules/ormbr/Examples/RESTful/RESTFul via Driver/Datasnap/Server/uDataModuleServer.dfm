object DataModuleServer: TDataModuleServer
  OldCreateOrder = False
  Height = 214
  Width = 341
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=..\..\..\Data\Database\database.db3'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 94
    Top = 48
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 148
    Top = 126
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 208
    Top = 50
  end
end
