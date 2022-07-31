unit view.principal;
interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation,
  FMX.Layouts, FMX.Ani, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  System.Json, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.DBScope, FMX.TabControl,
  frame.contato, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, StompClient, FMX.Edit;

type
  TTipo = (Enviada, Recebida);
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Rectangle1: TRectangle;
    Circle1: TCircle;
    SpeedButton1: TSpeedButton;
    Label1: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    VertScrollBox1: TVertScrollBox;
    TabControl1: TTabControl;
    tabContato: TTabItem;
    tabMensagem: TTabItem;
    mmoRecebido: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    mmoEnviada: TMemo;
    Timer1: TTimer;
    edtMinhaFila: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    edtFilaClient: TEdit;
    Rectangle2: TRectangle;
    VertScrollBox2: TVertScrollBox;
    Rectangle3: TRectangle;
    Layout1: TLayout;
    edtMensagemEnviada: TEdit;
    Circle2: TCircle;
    SpeedButton4: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
     const TEMPO_LEITURA = 900;
    procedure AddMensagem(Amensagem: String; ATipo: TTipo);
    procedure VerificaMensagens;
     var
     FClient: IStompClient;
     FStompFrame: IStompFrame;
     FStompClient: IStompClient;
     LStop: boolean;
    procedure AbrirChat(Sender: TObject);
    procedure BeforeSendFrame(AFrame: IStompFrame);
  public
    { Public declarations }
    procedure CarregaTela;
  end;
var
  Form1: TForm1;

implementation

{$R *.fmx}

{ TForm1 }

procedure TForm1.CarregaTela;
var
 LFrame:Tframecontato;
begin

  for var i := 0 to 0 do
  begin
    LFrame:= Tframecontato.Create(self);
    LFrame.Name:= 'frame'+i.ToString;
    //LFrame.TagString:= '/queue/11321';
    LFrame.OnClick:= AbrirChat;

    VertScrollBox1.AddObject(LFrame);

  end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LStop:= true;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TabControl1.TabPosition:= TTabPosition.None;
  TabControl1.ActiveTab:= tabContato;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  LStop:= true;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  CarregaTela;
end;

procedure TForm1.VerificaMensagens;
begin

  TThread.CreateAnonymousThread(
  procedure
    var
      lMessage: string;
  begin
    while True do
    begin
      if LStop then
        break;
      try

        if FClient.Receive(FStompFrame, TEMPO_LEITURA-10) then
        begin
          TThread.Synchronize(nil,
          procedure
          begin
            lMessage := FStompFrame.GetBody;
            mmoRecebido.Lines.Add('Recebendo mensagem...');
            mmoRecebido.Lines.Add(lMessage);

            AddMensagem(lMessage,TTipo.Recebida);

            mmoRecebido.Lines.Add('Informando o broker que a mensagem ' +
              FStompFrame.MessageID + ' foi processada');
            FClient.Ack(FStompFrame.MessageID);

          end);
        end;

      finally
        sleep(TEMPO_LEITURA);
      end;
    end;
  end).Start;
end;

procedure TForm1.AbrirChat(Sender:TObject);
begin
  TabControl1.ActiveTab:= tabMensagem;

  FClient := StompUtils.StompClient;

  try
    FClient.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Cannot connect to Apollo server. Run the server and restart the application');
    end;
  end;
  FClient.SetOnBeforeSendFrame(BeforeSendFrame);
  FStompFrame := StompUtils.NewFrame();

  FClient := StompUtils.StompClient.SetHeartBeat(1000, 1000)
    .SetAcceptVersion(TStompAcceptProtocol.Ver_1_1).Connect;


  mmoRecebido.Lines.Add('Inscrevendo na fila ' + edtMinhaFila.Text);
  FClient.Subscribe(edtMinhaFila.Text, TAckMode.amClient
    // ,StompUtils.Headers
    // .Add('auto-delete', 'true')
    );

  VerificaMensagens;

  try
    try
      FStompClient := StompUtils.StompClient;
      FStompClient.SetOnBeforeSendFrame(BeforeSendFrame);
    except
      on e: Exception do
        mmoEnviada.Lines.Add('Erro ao Conectar: ' + e.Message);
    end;
  finally
    mmoEnviada.Lines.Add('Conectou');
  end;


end;

procedure TForm1.BeforeSendFrame(AFrame: IStompFrame);
begin
  mmoRecebido.Lines.Add(StringReplace(AFrame.Output, #10, sLineBreak,
    [rfReplaceAll]));

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  FStompClient.Connect;
  try
    try

      FStompClient.Send(edtFilaClient.Text , edtMensagemEnviada.Text);
      AddMensagem(edtMensagemEnviada.Text,TTipo.Enviada);

    except
      on e: Exception do
      begin
        mmoRecebido.Lines.Add('ERROR: ' + e.Message);
      end;
    end;
  finally
    FStompClient.Disconnect;
    edtMensagemEnviada.Text:= EmptyStr;
  end;

end;

procedure TForm1.AddMensagem(Amensagem:String; ATipo: TTipo);
var
 LBallon:TCalloutRectangle;
 LMsg:TLabel;
begin

  LBallon:= TCalloutRectangle.Create(self);
  LMsg:= TLabel.Create(self);

  case ATipo of
    Enviada:
    begin
      LBallon.CalloutPosition:= TCalloutPosition.Right;
      LMsg.Margins.Left:= 4;
      LMsg.Margins.Right:= 16;
      LBallon.Margins.Right:= 4;
      LBallon.Margins.Left:= 16;

      LBallon.Fill.Color:= $FF358100;
    end;
    Recebida:
    begin
      LBallon.CalloutPosition:= TCalloutPosition.Left;
      LMsg.Margins.Left:= 16;
      LMsg.Margins.Right:= 4;

      LBallon.Margins.Left:= 16;
      LBallon.Margins.Right:= 4;

      LBallon.Fill.Color:= $FFB1B1B1;

    end;
  end;

  LMsg.Text:= Amensagem;

  LMsg.Align:= TAlignLayout.Client;

  LMsg.Margins.Bottom:= 4;
  LMsg.Margins.Top:= 4;

  LBallon.AddObject(LMsg);
  LBallon.Align:= TAlignLayout.Top;
  LBallon.XRadius:= 10;
  LBallon.YRadius:= 10;

  LBallon.Margins.Top:= 16;
  LBallon.Margins.Left:= 16;

  VertScrollBox2.AddObject(LBallon);


end;

end.
