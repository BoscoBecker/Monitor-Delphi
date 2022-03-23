unit SynMiniMap;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Math, ExtCtrls, SynEdit, SynEditHighlighter, SynHighlighterDWS,
  SynEditCodeFolding, Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.StdCtrls,
  FireDAC.Stan.Def, FireDAC.VCLUI.Wait, FireDAC.Phys.IBWrapper,
  FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.IBBase, FireDAC.Phys.FB,
  FireDAC.Moni.Base, FireDAC.Moni.FlatFile, Vcl.Dialogs,
  FireDAC.Moni.RemoteClient, Vcl.AppEvnts, Vcl.CheckLst, Vcl.Menus,
  FireDAC.UI.Intf, FireDAC.Comp.UI,FireDAC.Phys.Intf, Clipbrd, Vcl.ToolWin, System.ImageList,
  Vcl.ImgList, SynEditRegexSearch, SynEditMiscClasses, SynEditSearch, SynEditTypes,
  dlgSearchText,dlgReplaceText,dlgConfirmReplace, Classe.badge.positioned;

type
  TFormSynEditMinimap = class(TForm)
    Splitter: TSplitter;
    SynDWSSyn: TSynDWSSyn;
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    SynEdit: TSynEdit;
    SynEditMiniMap: TSynEdit;
    Trace: TFDMoniFlatFileClientLink;
    update: TTimer;
    remote: TFDMoniRemoteClientLink;
    StatusBar: TStatusBar;
    Panel2: TPanel;
    SynEditDetails: TSynEdit;
    Image1: TImage;
    MainMenu1: TMainMenu;
    Salvar1: TMenuItem;
    Sobre1: TMenuItem;
    Ativar1: TMenuItem;
    Ativar: TMenuItem;
    Desativar: TMenuItem;
    GroupBox1: TGroupBox;
    ADGUIxWaitCursor: TFDGUIxWaitCursor;
    lblDBMS: TLabel;
    BadgePositioneted1: TBadgePositioneted;
    Label1: TLabel;
    popOpcoes: TPopupMenu;
    CopiarparareadeTransfernca1: TMenuItem;
    ObterSQL1: TMenuItem;
    SynEditSearch: TSynEditSearch;
    SynEditRegexSearch: TSynEditRegexSearch;
    ImageListMain: TImageList;
    pnlOpcoes: TPanel;
    ToolBarMain: TToolBar;
    ToolButtonSearch: TToolButton;
    ToolButtonSearchNext: TToolButton;
    ToolButtonSeparator1: TToolButton;
    ToolButtonSearchPrev: TToolButton;
    ToolButtonSeparator2: TToolButton;
    ToolButtonSearchReplace: TToolButton;
    CheckBox1: TCheckBox;
    procedure FormResize(Sender: TObject);
    procedure SynEditStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure SynEditMiniMapSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure SynEditMiniMapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SynEditMiniMapEnter(Sender: TObject);
    procedure updateTimer(Sender: TObject);
    procedure SynEditClick(Sender: TObject);
    procedure AtivarClick(Sender: TObject);
    procedure DesativarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ObterSQL1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ToolButtonSearchClick(Sender: TObject);
    procedure ToolButtonSearchPrevClick(Sender: TObject);
    procedure ToolButtonSearchNextClick(Sender: TObject);
    procedure ToolButtonSearchReplaceClick(Sender: TObject);
    procedure CopiarparareadeTransfernca1Click(Sender: TObject);

    private const
      PATH_FILE_LOG_MONITOR = 'C:\MonitorFiredac\log.txt';

    private
      path: String;
      size, sizeOld: integer;
      FSearchFromCaret: Boolean;
      procedure InitPathLog;
      procedure ShowSearchReplaceDialog(AReplace: boolean);
      procedure DoSearchReplaceText(AReplace: boolean; ABackwards: boolean);
      Function GetSQLQuery: String;
  end;

var
  FormSynEditMinimap: TFormSynEditMinimap;

implementation

{$R *.dfm}

var
  gbSearchBackwards: Boolean;
  gbSearchCaseSensitive: Boolean;
  gbSearchFromCaret: Boolean;
  gbSearchSelectionOnly: Boolean;
  gbSearchTextAtCaret: Boolean;
  gbSearchWholeWords: Boolean;
  gbSearchRegex: Boolean;
  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;

resourcestring
  STextNotFound = 'Text not found';

procedure TFormSynEditMinimap.FormCreate(Sender: TObject);
begin
  SynEditMiniMap.DoubleBuffered := True;
  SynEdit.DoubleBuffered := True;
  SynEditMiniMap.SetLinesPointer(SynEdit);
  size:= 0;
  InitPathLog;

  /// Boostrap Delphi
  BadgePositioneted1.notifications.Caption:= '0';
  BadgePositioneted1.MakeRounded(BadgePositioneted1);
  BadgePositioneted1.MakeRounded(BadgePositioneted1.shape);
  BadgePositioneted1.MakeRounded(BadgePositioneted1.notifications);
end;

procedure TFormSynEditMinimap.AtivarClick(Sender: TObject);
begin
  update.Enabled:= True;
  Ativar.Enabled:= False;
  Desativar.Enabled:= True;
  StatusBar.Panels[0].Text:='Monitor Ativado';
end;

procedure TFormSynEditMinimap.FormResize(Sender: TObject);
begin
  SynEditStatusChange(Self, []);
end;

function TFormSynEditMinimap.GetSQLQuery: String;
begin
//  var strSQL, strText: String;
//  strText:= SynEditDetails.Text;
//
//  if pos(strText,'Command') > 0 then
//    delete(strText,1,Pos('Command', strText)-1)
//  else
//  if pos(strText,'CMD') > 0 then
//    delete(strText,1,Pos('CMD', strText)-1);
//
//  StrSQL :=copy(strText,Pos('Command', strText)+9);
//
//  StrSQL:= StringReplace(StrSQL,'nprepare [Command="','',[rfReplaceAll]);
//  StrSQL:= StringReplace(StrSQL,'[Command="','',[rfReplaceAll]);
//  StrSQL:= copy(StrSQL,1,length(StrSQL)-2);
//  result := StrSQL;
end;

procedure TFormSynEditMinimap.InitPathLog;
begin
  if not FileExists(PATH_FILE_LOG_MONITOR) then
    ForceDirectories('C:\MonitorFiredac\')
end;

procedure TFormSynEditMinimap.ObterSQL1Click(Sender: TObject);
begin
  Clipboard.AsText:= GetSQLQuery;
end;

procedure TFormSynEditMinimap.CheckBox1Click(Sender: TObject);
begin
  pnlOpcoes.Visible:= (CheckBox1.Checked)
end;

procedure TFormSynEditMinimap.CopiarparareadeTransfernca1Click(Sender: TObject);
begin
  Clipboard.AsText:=  SynEditDetails.Text;
end;

procedure TFormSynEditMinimap.DesativarClick(Sender: TObject);
begin
  update.Enabled:= False;
  Ativar.Enabled:= True;
  Desativar.Enabled:= False;
  StatusBar.Panels[0].Text:='Monitor Não Ativado';
end;

procedure TFormSynEditMinimap.DoSearchReplaceText(AReplace,
  ABackwards: boolean);
var
  Options: TSynSearchOptions;
begin
  Statusbar.SimpleText := '';
  if AReplace then
    Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else
    Options := [];
  if ABackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if not FSearchFromCaret then
    Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then
    Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);
  if gbSearchRegex then
    SynEdit.SearchEngine := SynEditRegexSearch
  else
    SynEdit.SearchEngine := SynEditSearch;
  if SynEdit.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    Statusbar.SimpleText := STextNotFound;
    if ssoBackwards in Options then
      SynEdit.BlockEnd := SynEdit.BlockBegin
    else
      SynEdit.BlockBegin := SynEdit.BlockEnd;
    SynEdit.CaretXY := SynEdit.BlockBegin;
  end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

procedure TFormSynEditMinimap.ShowSearchReplaceDialog(AReplace: boolean);
var
  dlg: TTextSearchDialog;
begin
  Statusbar.SimpleText := '';
  if AReplace then
    dlg := TTextReplaceDialog.Create(Self)
  else
    dlg := TTextSearchDialog.Create(Self);
  with dlg do try
    // assign search options
    SearchBackwards := gbSearchBackwards;
    SearchCaseSensitive := gbSearchCaseSensitive;
    SearchFromCursor := gbSearchFromCaret;
    SearchInSelectionOnly := gbSearchSelectionOnly;
    // start with last search text
    SearchText := gsSearchText;
    if gbSearchTextAtCaret then begin
      // if something is selected search for that text
      if SynEdit.SelAvail and (SynEdit.BlockBegin.Line = SynEdit.BlockEnd.Line)
      then
        SearchText := SynEdit.SelText
      else
        SearchText := SynEdit.GetWordAtRowCol(SynEdit.CaretXY);
    end;
    SearchTextHistory := gsSearchTextHistory;
    if AReplace then with dlg as TTextReplaceDialog do begin
      ReplaceText := gsReplaceText;
      ReplaceTextHistory := gsReplaceTextHistory;
    end;
    SearchWholeWords := gbSearchWholeWords;
    if ShowModal = mrOK then begin
      gbSearchBackwards := SearchBackwards;
      gbSearchCaseSensitive := SearchCaseSensitive;
      gbSearchFromCaret := SearchFromCursor;
      gbSearchSelectionOnly := SearchInSelectionOnly;
      gbSearchWholeWords := SearchWholeWords;
      gbSearchRegex := SearchRegularExpression;
      gsSearchText := SearchText;
      gsSearchTextHistory := SearchTextHistory;
      if AReplace then with dlg as TTextReplaceDialog do begin
        gsReplaceText := ReplaceText;
        gsReplaceTextHistory := ReplaceTextHistory;
      end;
      FSearchFromCaret := gbSearchFromCaret;
      if gsSearchText <> '' then begin
        DoSearchReplaceText(AReplace, gbSearchBackwards);
        FSearchFromCaret := TRUE;
      end;
    end;
  finally
    dlg.Free;
  end;

end;

procedure TFormSynEditMinimap.SynEditClick(Sender: TObject);
begin
  var Linha:= SynEdit.CaretY;
  var Coluna := SynEdit.CaretX;

  StatusBar.Panels[3].Text:=
    'Linha: '+ IntToStr(Linha) +
      ' Coluna : ' + IntToStr(Coluna);

  SynEditDetails.Lines.Clear;
  SynEditDetails.Lines.Add(SynEdit.Lines[SynEdit.CaretY - 1]);
end;

procedure TFormSynEditMinimap.SynEditMiniMapEnter(Sender: TObject);
begin
  SynEdit.SetFocus;
end;

procedure TFormSynEditMinimap.SynEditMiniMapMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Coord: TDisplayCoord;
begin
  Coord := SynEditMiniMap.PixelsToNearestRowColumn(X, Y);
  SynEdit.CaretXY := SynEdit.DisplayToBufferPos(Coord);
  SynEdit.Invalidate;
  SynEdit.TopLine := Max(1, Coord.Row - (SynEdit.LinesInWindow div 2));
end;

procedure TFormSynEditMinimap.SynEditMiniMapSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
begin
  Special := (Cardinal(Line - SynEdit.TopLine) <= Cardinal(SynEdit.LinesInWindow));
  BG := clBtnFace;
end;

procedure TFormSynEditMinimap.SynEditStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if SynEditMiniMap.Tag = SynEdit.TopLine then
    Exit;
  SynEditMiniMap.Tag := SynEdit.TopLine;
  SynEditMiniMap.TopLine :=
    Max(1, SynEdit.TopLine - (SynEditMiniMap.LinesInWindow -
    SynEdit.LinesInWindow) div 2);
  SynEditMiniMap.Invalidate;
end;

procedure TFormSynEditMinimap.ToolButtonSearchClick(Sender: TObject);
begin
  ShowSearchReplaceDialog(False);
end;

procedure TFormSynEditMinimap.ToolButtonSearchNextClick(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, TRUE);
end;

procedure TFormSynEditMinimap.ToolButtonSearchPrevClick(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, FALSE);
end;

procedure TFormSynEditMinimap.ToolButtonSearchReplaceClick(Sender: TObject);
begin
  ShowSearchReplaceDialog(TRUE);
end;

procedure TFormSynEditMinimap.updateTimer(Sender: TObject);
var
  updateCount: integer;
  FileStream:TFileStream;
  FileList: TStringList;
begin
  var primeiroacess:= False;
  Try
    if FileExists(PATH_FILE_LOG_MONITOR) then
    begin
      FileStream := TFileStream.Create(PATH_FILE_LOG_MONITOR,fmOpenRead or fmShareDenyNone);
      FileList:= TStringList.Create;
      FileList.LoadFromStream(FileStream);
      Try
        if (size = 0)then
        begin
          SynEdit.Clear;
          sizeOld:= Length(FileList.Text);
          primeiroacess:= True;
        end;

        size:= Length(FileList.Text);
        if (size <> sizeOld) or (primeiroacess)then
        Begin
          updateCount:= updateCount + 1;
          StatusBar.Panels[2].Text:= 'Recebendo dados...';
          BadgePositioneted1.notifications.Caption:= IntToStr(updateCount);
          for var i := 1 to FileList.Count - 1 do
          begin
            SynEdit.Lines.Add(FileList.Strings[i]);
            StatusBar.Panels[1].Text:= FormatDateTime('dd/mm/yyyy hh:mm:ss',now);
            StatusBar.Panels[2].Text:= 'Aguardando leitura...';
          end;

          SendMessage(SynEdit.Handle, WM_VSCROLL, SB_BOTTOM, 0);
        End;
        sizeOld:= size;
      Except
        update.Enabled:= False;
      End;
    end;
  Finally
    FileList.Free;
    FileStream.Destroy;
  End;
end;

end.





