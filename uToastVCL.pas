unit uToastVCL;

interface

uses System.NetEncoding,
     Vcl.Graphics,
     Vcl.Controls,
     Vcl.Extctrls,
     Vcl.StdCtrls,
     Vcl.Imaging.pngimage,
     System.Classes,
     System.SysUtils,
     Forms,
     System.Threading,
     TypInfo,
     Vcl.ComCtrls,
     Vcl.Buttons;

type tpMode = (tpSuccess, tpInfo, tpError);

type
  TToastMessage = class
    private
      {Timer}
      procedure PanelBoxPosition (Sender: TObject);
      procedure TerminateToastTThread(Sender: TObject);
      procedure ClickClose(Sender: TObject);
      procedure CreatePanelBox   (const Parent : TWinControl);
      procedure PanelBoxMouseEnter(Sender: TObject);
      procedure PanelBoxMouseLeave(Sender: TObject);
      procedure RegisterColors;
      procedure AcaoToast;

      var
        ToastTThread : TThread;
        PanelBox     : TPanel;
        PanelLine    : TPanel;
        Image        : TImage;
        Title        : TLabel;
        Text         : TLabel;
        MaxTop       : Integer;
        MinTop       : Integer;
        btnClose      : TSpeedButton;
        pPositionTop : Integer;
        StopThread : Boolean;
    public
      PanelBoxColor : TColor;
      TitleColor    : TColor;
      TextColor     : TColor;
      SuccessColor  : TColor;
      InfoColor     : TColor;
      ErrorColor    : TColor;

      procedure   Toast(const MessageType : tpMode; pTitle, pText : string ; ImgAnimate : TPicture = nil);
      constructor Create(const Parent : TWinControl); overload;
      destructor  Destroy; override;
  end;

implementation

{ ToastMessage }

procedure TToastMessage.ClickClose(Sender: TObject);
begin
   StopThread := True;

end;

constructor TToastMessage.Create(const Parent : TWinControl);
begin
  pPositionTop := 0;
  MaxTop := Parent.Height;
  MinTop := - Parent.Height;
  StopThread := False;
  CreatePanelBox(Parent);

end;

procedure TToastMessage.AcaoToast;
begin
    ToastTThread := TThread.CreateAnonymousThread(
    procedure
    begin
       if StopThread then
       exit;

       if PanelBox.Tag = 0 then
       begin
          while (MaxTop > pPositionTop) and (not StopThread)  do
          begin
             TThread.Sleep(50);
             Inc(pPositionTop);

            TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
               PanelBox.Top := PanelBox.Top + 1;
            end);
             
          end;

          PanelBox.Tag := 1;
       end;

       if StopThread then
       exit;

       TThread.Sleep(1000);
       
       if PanelBox.Tag = 1 then
       begin
          while  (pPositionTop > MinTop) and (not StopThread) do
          begin
             ToastTThread.Sleep(50);
             Dec(pPositionTop);

            TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
              PanelBox.Top := PanelBox.Top - 1;
            end);
          end;

          PanelBox.Tag := 0;
       end;   

    end);
    ToastTThread.FreeOnTerminate := True;
    ToastTThread.OnTerminate := TerminateToastTThread;
    ToastTThread.Start;
end;

procedure TToastMessage.CreatePanelBox(const Parent : TWinControl);
var
  PanelImage   : TPanel;
  PanelMessage : TPanel;
  PanelClose   : TPanel;
begin
  RegisterColors;

  {Create Principal Panel}
  PanelBox                  := TPanel.Create(Parent);
  PanelBox.Visible          := False;
  PanelBox.Parent           := Parent;
  PanelBox.BorderStyle      := Forms.bsNone;
  PanelBox.Color            := PanelBoxColor;
  PanelBox.Height           := 50;
  PanelBox.Anchors          := [];


  if Parent.Width > 300 then
    PanelBox.Width          := 300
  else 
    PanelBox.Width          := 200;

  if PanelBox.Width > Parent.Width  then
  PanelBox.Width := Parent.Width - 20;
    
  PanelBox.Top              := - PanelBox.Height;
  PanelBox.BevelOuter       := bvNone;
  PanelBox.BevelInner       := bvNone;
  PanelBox.BevelKind        := bkNone;
  PanelImage.BorderStyle    := bsNone;
  PanelBox.ParentBackground := False;
  PanelBox.Ctl3d            := False;
  PanelBox.Tag              := 0;

  {Create Panel Vertical Line}
  PanelLine                  := TPanel.Create(PanelBox);
  PanelLine.Parent           := PanelBox;
  PanelLine.BorderStyle      := Forms.bsNone;
  PanelLine.Align            := alLeft;
  PanelLine.BevelOuter       := bvNone;
  PanelLine.BevelInner       := bvNone;
  PanelLine.BevelKind        := bkNone;
  PanelLine.Width            := 5;
  PanelLine.ParentBackground := False;
  PanelLine.Visible          := True;
  PanelLine.Ctl3d            := False;

  {Create Image}
  PanelImage             := TPanel.Create(PanelBox);
  PanelImage.Parent      := PanelBox;
  PanelImage.Visible     := True;
  PanelImage.Align       := alLeft;
  PanelImage.BevelOuter  := bvNone;
  PanelImage.BevelInner  := bvNone;
  PanelImage.BevelKind   := bkNone;
  PanelImage.BorderStyle := bsNone;
  PanelImage.Color       := PanelBoxColor;
  PanelImage.Height      := 38;
  PanelImage.Left        := 0;
  PanelImage.Width       := 31;

  Image := TImage.Create(PanelImage);

  Image.Align        := AlClient;
  Image.Parent       := PanelImage;
  Image.Visible      := True;
  Image.Center       := True;
  Image.Proportional := True;

  {Create Panel Message}
  PanelMessage             := TPanel.Create(PanelBox);
  PanelMessage.Parent      := PanelBox;
  PanelMessage.Visible     := True;
  PanelMessage.Align       := alClient;
  PanelMessage.BevelOuter  := bvNone;
  PanelMessage.BevelInner  := bvNone;
  PanelMessage.BevelKind   := bkNone;
  PanelMessage.BorderStyle := Forms.bsNone;
  PanelMessage.Color       := PanelBoxColor;


  {Create Title}
  Title := TLabel.Create(PanelMessage);

  Title.Parent      := PanelMessage;
  Title.AutoSize    := True;
  Title.Align       := AlTop;
  Title.Alignment   := taCenter;
  Title.Layout      := tlCenter;
  Title.WordWrap    := True;
  Title.Enabled     := True;
  Title.Font.Color  := TitleColor;
  Title.Font.Name   := 'Segoe UI';
  Title.Font.Size   := 12;
  Title.Transparent := True;
  Title.Font.Style  := [fsBold];
  Title.Top         := 0;


  PanelClose  := TPanel.Create(PanelBox);
  PanelClose.Parent      := PanelBox;
  PanelClose.Visible     := True;
  PanelClose.Align       := alRight;
  PanelClose.BevelOuter  := bvNone;
  PanelClose.BevelInner  := bvNone;
  PanelClose.BevelKind   := bkNone;
  PanelClose.BorderStyle := bsNone;
  PanelClose.Color       := PanelBoxColor;
  PanelClose.Width       := 16;

  btnClose := TSpeedButton.Create(PanelClose);
  btnClose.Align        := alTop;
  btnClose.Parent       := PanelClose;
  btnClose.Visible      := True;
  btnClose.OnClick      := ClickClose;
  btnClose.Caption      := 'X';
  btnClose.Font.Size    := 8;
  btnClose.Font.Style   := [fsBold];
  btnClose.Font.Color   := clSilver;
  btnClose.Flat         := True;
  btnClose.Layout       := TButtonLayout.blGlyphTop;
  btnClose.Height       := 18;


  {Create Text}
  Text := TLabel.Create(PanelMessage);
  Text.Parent       := PanelMessage;
  Text.AutoSize     := True;
  Text.Align        := alClient;
  Text.Alignment    := taCenter;
  Text.Layout       := tlCenter;
  Text.WordWrap     := True;
  Text.Enabled      := True;
  Text.Font.Color   := TextColor;
  Text.Font.Name    := 'Segoe UI';
  Text.Font.Size    := 10;
  Text.Transparent  := True;
  Text.Font.Style   := [fsBold];
  Text.OnMouseEnter     := PanelBoxMouseEnter;
  Text.OnMouseLeave     := PanelBoxMouseLeave;
  PanelBoxPosition(Parent);

  if Parent is TForm then
    (Parent as TForm).OnResize :=  PanelBoxPosition
  else
  if Parent is TPanel then
    (Parent as TPanel).OnResize :=  PanelBoxPosition
  else
  if Parent is TTabSheet then
    (Parent as TTabSheet).OnResize :=  PanelBoxPosition;
end;

destructor TToastMessage.Destroy;
begin
  inherited;

  if Assigned(PanelBox) then
    PanelBox.Destroy;
end;

procedure TToastMessage.PanelBoxMouseEnter(Sender: TObject);
begin
  ToastTThread.Suspended := True;
end;

procedure TToastMessage.PanelBoxMouseLeave(Sender: TObject);
begin
  ToastTThread.Suspended := False;
end;

procedure TToastMessage.PanelBoxPosition(Sender: TObject);
begin
  PanelBox.Left := Trunc((TWinControl(Sender).Width / 2) - (PanelBox.Width / 2));
end;

procedure TToastMessage.RegisterColors;
begin
  PanelBoxColor := clWhite;
  TitleColor    := $003F3F3F;
  TextColor     := $00616161;
  SuccessColor  := $0064D747;
  InfoColor     := $00EA7012;
  ErrorColor    := $003643F4;
end;

procedure TToastMessage.TerminateToastTThread(Sender: TObject);
begin
   Destroy;
end;

procedure TToastMessage.Toast(const MessageType : tpMode; pTitle, pText : string ; ImgAnimate : TPicture = nil);
begin
  Title.Caption    := pTitle;
  Text.Caption     := pText;
  PanelBox.Visible := True;

  if MessageType = tpSuccess then
    begin
      PanelLine.Color := SuccessColor;
      Image.Picture   := ImgAnimate;
    end
  else if MessageType = tpInfo then
    begin
      PanelLine.Color := InfoColor;
      Image.Picture   := ImgAnimate;
    end
  else if MessageType = tpError then
    begin
      PanelLine.Color := ErrorColor;
      Image.Picture   := ImgAnimate;
    end;

    AcaoToast;
end;

end.
