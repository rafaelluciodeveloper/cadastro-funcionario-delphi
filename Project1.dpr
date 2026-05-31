program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {FrmRelatorio},
  Unit3 in 'Unit3.pas' {FrmAssinarXML};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFrmRelatorio, FrmRelatorio);
  Application.CreateForm(TFrmAssinarXML, FrmAssinarXML);
  Application.Run;
end.
