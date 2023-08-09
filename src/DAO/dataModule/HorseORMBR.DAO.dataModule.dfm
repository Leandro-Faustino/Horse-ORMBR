object DMConection: TDMConection
  OldCreateOrder = False
  Height = 236
  Width = 360
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Program Files (x86)\Firebird\Firebird_2_5\cliente.fd' +
        'b'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 128
    Top = 88
  end
end
