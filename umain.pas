unit umain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  OpenAIClient,
  OpenAIDtos, FMX.Layouts, FMX.ListBox, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Ani, FMX.Edit,
    IdURI, FMX.Memo.Types,
{$IFDEF MSWINDOWS}
 Winapi.ShellAPI, Winapi.Windows;
{$ELSE}
{$IFDEF ANDROID}
  Androidapi.Helpers,
  FMX.Helpers.Android, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Net, Androidapi.JNI.JavaTypes;
{$ELSE}
{$IFDEF IOS}
  Macapi.Helpers, iOSapi.Foundation, FMX.Helpers.iOS;
{$ENDIF IOS}
{$ENDIF ANDROID}
{$ENDIF MSWINDOWS}
type
  TForm1 = class(TForm)
    ScaledLayout1: TScaledLayout;
    Layout2: TLayout;
    Layout1: TLayout;
    Image1: TImage;
    StyleBook1: TStyleBook;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Layout6: TLayout;
    edquestion: TMemo;
    bQuest: TButton;
    lbAnswer: TListBox;
    Layout7: TLayout;
    Layout8: TLayout;
    Image2: TImage;
    fpemby: TFloatAnimation;
    Label1: TLabel;
    edApikey: TEdit;
    Memo1: TMemo;
    lWrite: TLabel;
    lresponse: TLabel;
    btLink: TButton;
    Layout9: TLayout;
    Label4: TLabel;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    procedure bQuestClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edquestionEnter(Sender: TObject);
    procedure btLinkClick(Sender: TObject);
    procedure edApikeyClick(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
  private
    procedure setleng(lenguage:integer);
    { Private declarations }
  public
  item:integer;
    function AskQuestion(const Question: string): string;{ Public declarations }
    function OpenURL(const URL: string; const DisplayError: Boolean = False): Boolean;

  end;

const
  CApiKeyVar = 'OPENAI_API_KEY';

var
  Client: IOpenAIClient;
  Form1: TForm1;

implementation

{$R *.fmx}
 procedure TForm1.setleng(lenguage:integer);
 begin
 case lenguage of
  1:begin
    lresponse.text := 'Odpowiedzi:';
    lwrite.text := 'Pytanie:';
    bquest.text := 'Zapytać';
   end;
    2:begin
    lwrite.text := 'Escribe tu pregunta :';
    lresponse.text := 'Respuestas';
    bquest.text := 'Preguntar';
     end;
     3:begin
    lresponse.text := 'REsponses:';
    lwrite.text := 'Write your Question:';
    bquest.text := 'Ask Question';
     end;

  end
end;

function TForm1.AskQuestion(const Question: string): string;
var
  Request: TCreateCompletionRequest;
  Response: TCreateCompletionResponse;
begin
  Response := nil;
  Request := TCreateCompletionRequest.Create;
  try
    Request.Prompt := Question;
    Request.Model := 'text-davinci-003';
    Request.MaxTokens := 2048; // Be careful as this can quickly consume your API quota.
    Response := Client.OpenAI.CreateCompletion(Request);
    if Assigned(Response.Choices) and (Response.Choices.Count > 0) then
      Result := Response.Choices[0].Text
    else
      Result := '';
  finally
    Request.Free;
    Response.Free;
  end;

end;

procedure TForm1.btLinkClick(Sender: TObject);
begin
 openurl( 'https://beta.openai.com/account/api-keys');
end;

procedure TForm1.bQuestClick(Sender: TObject);
var
  Question: string;
  Answer: string;
  aItem: TListBoxItem;
begin
      Client.Config.AccessToken := edApikey.Text;
      fpemby.Enabled:=true;
      Question:=edQuestion.Text;
      Answer := AskQuestion(Question);

     // aItem := TListBoxItem.Create(Self);
    //  aItem.Tag := item+1;

       if Answer <> '' then
           memo1.lines.add(Answer)
     else
         MEMO1.Text := 'Could not retrieve an answer.';

    //  aItem.Parent := MEMO1;

   fpemby.Enabled:=false;
end;

procedure TForm1.edApikeyClick(Sender: TObject);
begin
  edapikey.Password:=not edapikey.Password;
end;

procedure TForm1.edquestionEnter(Sender: TObject);
begin

   fpemby.Enabled:=true;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Client := TOpenAIClient.Create;
item:=1;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
 setLeng(1);

end;

procedure TForm1.Image4Click(Sender: TObject);
begin
 setLeng(2);
end;

procedure TForm1.Image5Click(Sender: TObject);
begin
setLeng(3);
end;

function TForm1.OpenURL(const URL: string;
  const DisplayError: Boolean): Boolean;
 {$IFDEF MSWINDOWS}
  begin
  ShellExecute(0, 'OPEN', PChar(URL), '', '', SW_SHOWNORMAL);
  end;



{$ELSE}


{$IFDEF ANDROID}
      var
        Intent: JIntent;
      begin
      // There may be an issue with the geo: prefix and URLEncode.
      // will need to research
        Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW,
          TJnet_Uri.JavaClass.parse(StringToJString(TIdURI.URLEncode(URL))));
        try
          SharedActivity.startActivity(Intent);
          exit(true);
        except
          on e: Exception do
          begin
            if DisplayError then ShowMessage('Error: ' + e.Message);
            exit(false);
          end;
        end;
      end;



{$ELSE}
 {$IFDEF IOS}
      var
        NSU: NSUrl;
      begin
        // iOS doesn't like spaces, so URL encode is important.
        NSU := StrToNSUrl(TIdURI.URLEncode(URL));
        if SharedApplication.canOpenURL(NSU) then
          exit(SharedApplication.openUrl(NSU))
        else
        begin
          if DisplayError then
            ShowMessage('Error: Opening "' + URL + '" not supported.');
          exit(false);
        end;
      end;

{$ELSE}
      begin
        raise Exception.Create('Not supported!');
      end;

 {$ENDIF IOS}
{$ENDIF ANDROID}
{$ENDIF MSWINDOWS}





end.
