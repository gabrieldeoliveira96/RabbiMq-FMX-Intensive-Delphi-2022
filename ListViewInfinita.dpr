program ListViewInfinita;
uses
  System.StartUpCopy,
  FMX.Forms,
  view.principal in 'src\view\view.principal.pas' {Form1},
  StompClient in 'src\features\StompClient.pas',
  frame.contato in 'src\frame\frame.contato.pas' {frameContato: TFrame};

{$R *.res}
begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
