unit uTeste;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uToastVCL,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.Buttons;

type
  Tfrmteste = class(TForm)
    pnBase: TPanel;
    Panel1: TPanel;
    BtnSuccess: TButton;
    BtnError: TButton;
    BtnInfo: TButton;
    ImageCancelada: TImage;
    ImagePendente: TImage;
    ImageEnviadas: TImage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnSuccessClick(Sender: TObject);
    procedure BtnInfoClick(Sender: TObject);
    procedure BtnErrorClick(Sender: TObject);
  private
    { Private declarations }
    var
      ToastMessage : TToastMessage;
  public
    { Public declarations }
    procedure MsgToast(sTexto, sTitulo : string; sTipo: string = 'S,I,E'; ParentBase : TWinControl = nil);
  end;

var
  frmteste: Tfrmteste;

implementation

{$R *.dfm}


procedure Tfrmteste.MsgToast(sTexto, sTitulo, sTipo: string; ParentBase : TWinControl);
var
  ToastMessage : TToastMessage;
  tpToast : tpMode;
  MinhaImg : TPicture;
begin
  if ParentBase = nil then
  ParentBase := Self;


  ToastMessage := TToastMessage.Create(ParentBase);
  try


    MinhaImg    := ImageEnviadas.Picture;

    case UpperCase(sTipo)[1] of
      'S': begin
             tpToast  := tpSuccess;
             MinhaImg := ImageEnviadas.Picture;
            end;
      'I': begin
             tpToast  := tpInfo;
             MinhaImg := ImagePendente.Picture;
           end;
      'E': begin
             tpToast  := tpError;
             MinhaImg := ImageCancelada.Picture;
            end;
    end;

    ToastMessage.Toast(tpToast, sTitulo, sTexto, MinhaImg);

  finally

  end;
end;

procedure Tfrmteste.BtnErrorClick(Sender: TObject);
begin

  MsgToast('Ocorreu um erro na operação', 'Erro', 'E',  TabSheet2);
end;

procedure Tfrmteste.BtnInfoClick(Sender: TObject);
begin

  MsgToast('Existe uma nova mensagem', 'Atenção', 'I', TabSheet1);
end;

procedure Tfrmteste.BtnSuccessClick(Sender: TObject);
begin

  MsgToast('Processo Finalizado....', 'Sucesso', 'S', pnBase);
end;

procedure Tfrmteste.FormCreate(Sender: TObject);
begin
  ToastMessage := TToastMessage.Create(Panel1);
end;

procedure Tfrmteste.FormDestroy(Sender: TObject);
begin
  if Assigned(ToastMessage) then
    FreeAndNil(ToastMessage);
end;

end.
