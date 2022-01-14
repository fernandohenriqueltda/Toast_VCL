program ToastVCL;

uses
  Vcl.Forms,
  uTeste in 'uTeste.pas' {frmteste},
  uToastVCL in 'uToastVCL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfrmteste, frmteste);
  Application.Run;
end.
