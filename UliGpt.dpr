program UliGpt;

uses
  System.StartUpCopy,
  FMX.Forms,
  umain in 'umain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
