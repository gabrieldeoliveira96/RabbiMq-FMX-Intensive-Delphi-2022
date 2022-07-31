unit frame.contato;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Effects,
  FMX.Filter.Effects;

type
  TframeContato = class(TFrame)
    Circle1: TCircle;
    Layout1: TLayout;
    Label1: TLabel;
    Line1: TLine;
    Image1: TImage;
    FillRGBEffect1: TFillRGBEffect;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
