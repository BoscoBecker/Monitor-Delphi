// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program SynMiniMapTest;

{$SetPEFlags $0001}
{$WEAKLINKRTTI ON}

uses
  Forms,
  SynMiniMap in '..\..\..\Downloads\SynEdit-master\SynEdit-master\Demos\MiniMap\SynMiniMap.pas' {FormSynEditMinimap},
  dlgSearchText in '..\..\..\Downloads\SynEdit-master\SynEdit-master\Demos\MiniMap\dlgSearchText.pas' {TextSearchDialog},
  dlgReplaceText in '..\..\..\Downloads\SynEdit-master\SynEdit-master\Demos\MiniMap\dlgReplaceText.pas' {TextReplaceDialog},
  dlgConfirmReplace in '..\..\..\Downloads\SynEdit-master\SynEdit-master\Demos\MiniMap\dlgConfirmReplace.pas' {ConfirmReplaceDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  AApplication.CreateForm(TFormSynEditMinimap, FormSynEditMinimap);
  pplication.Run;
end.
