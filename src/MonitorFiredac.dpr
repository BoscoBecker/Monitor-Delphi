program MonitorFiredac;

{$SetPEFlags $0001}
{$WEAKLINKRTTI ON}

uses
  Forms,
  SynMiniMap in 'SynMiniMap.pas' {FormSynEditMinimap},
  dlgSearchText in 'dlgSearchText.pas' {TextSearchDialog},
  dlgReplaceText in 'dlgReplaceText.pas' {TextReplaceDialog},
  dlgConfirmReplace in 'dlgConfirmReplace.pas' {ConfirmReplaceDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormSynEditMinimap, FormSynEditMinimap);
  Application.Run;
end.
