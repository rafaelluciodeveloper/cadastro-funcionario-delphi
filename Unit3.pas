unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Variants;

type
  TFrmAssinarXML = class(TForm)
    PanelTopo: TPanel;
    LblTitulo: TLabel;
    GroupCert: TGroupBox;
    LblCert: TLabel;
    ComboCert: TComboBox;
    BtnRecarregar: TButton;
    GroupArquivo: TGroupBox;
    LblArquivo: TLabel;
    EditArquivo: TEdit;
    BtnProcurar: TButton;
    GroupResultado: TGroupBox;
    MemoLog: TMemo;
    PanelBotoes: TPanel;
    BtnAssinar: TButton;
    BtnFechar: TButton;
    OpenDlg: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure BtnRecarregarClick(Sender: TObject);
    procedure BtnProcurarClick(Sender: TObject);
    procedure BtnAssinarClick(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
  private
    procedure CarregarCertificados;
    procedure Log(const S: string);
  end;

var
  FrmAssinarXML: TFrmAssinarXML;

implementation

uses ComObj;

{$R *.dfm}

const
  CERT_NAME_FRIENDLY_DISPLAY_TYPE = 5;
  CERT_NAME_SIMPLE_DISPLAY_TYPE   = 4;
  CALG_SHA_256                    = $0000800C;
  HP_HASHVAL                      = $0002;
  AT_KEYEXCHANGE                  = 1;
  AT_SIGNATURE                    = 2;
  CRYPT_ACQUIRE_COMPARE_KEY_FLAG  = $00000004;
  CERT_KEY_PROV_INFO_PROP_ID      = 2;
  PROV_RSA_AES                    = 24;
  CRYPT_SILENT                    = $00000040;
  MS_ENH_RSA_AES_PROV_NAME = 'Microsoft Enhanced RSA and AES Cryptographic Provider';

type
  PCryptKeyProvInfo = ^TCryptKeyProvInfo;
  TCryptKeyProvInfo = record
    pwszContainerName: PWideChar;
    pwszProvName: PWideChar;
    dwProvType: DWORD;
    dwFlags: DWORD;
    cProvParam: DWORD;
    rgProvParam: Pointer;
    dwKeySpec: DWORD;
  end;

type
  HCERTSTORE = Pointer;
  HCRYPTPROV = Cardinal;
  HCRYPTHASH = Cardinal;

  PCERT_CONTEXT = ^CERT_CONTEXT;
  CERT_CONTEXT = record
    dwCertEncodingType: DWORD;
    pbCertEncoded: PByte;
    cbCertEncoded: DWORD;
    pCertInfo: Pointer;
    hCertStore: HCERTSTORE;
  end;

function CertOpenSystemStoreA(hProv: Pointer;
  szSubsystemProtocol: PAnsiChar): HCERTSTORE;
  stdcall; external 'Crypt32.dll';

function CertCloseStore(hCertStore: HCERTSTORE; dwFlags: DWORD): BOOL;
  stdcall; external 'Crypt32.dll';

function CertEnumCertificatesInStore(hCertStore: HCERTSTORE;
  pPrevCertContext: PCERT_CONTEXT): PCERT_CONTEXT;
  stdcall; external 'Crypt32.dll';

function CertGetNameStringA(pCertContext: PCERT_CONTEXT; dwType: DWORD;
  dwFlags: DWORD; pvTypePara: Pointer; pszNameString: PAnsiChar;
  cchNameString: DWORD): DWORD;
  stdcall; external 'Crypt32.dll';

function CertFreeCertificateContext(pCertContext: PCERT_CONTEXT): BOOL;
  stdcall; external 'Crypt32.dll';

function CertGetCertificateContextProperty(pCertContext: PCERT_CONTEXT;
  dwPropId: DWORD; pvData: Pointer; var pcbData: DWORD): BOOL;
  stdcall; external 'Crypt32.dll' name 'CertGetCertificateContextProperty';

function CryptAcquireContextW(var phProv: HCRYPTPROV; pszContainer: PWideChar;
  pszProvider: PWideChar; dwProvType: DWORD; dwFlags: DWORD): BOOL;
  stdcall; external 'Advapi32.dll' name 'CryptAcquireContextW';

function CryptAcquireCertificatePrivateKey(pCert: PCERT_CONTEXT; dwFlags: DWORD;
  pvReserved: Pointer; var phCryptProv: HCRYPTPROV; var pdwKeySpec: DWORD;
  var pfCallerFreeProv: BOOL): BOOL;
  stdcall; external 'Crypt32.dll';

function CryptCreateHash(hProv: HCRYPTPROV; Algid: DWORD; hKey: HCRYPTHASH;
  dwFlags: DWORD; var phHash: HCRYPTHASH): BOOL;
  stdcall; external 'Advapi32.dll';

function CryptHashData(hHash: HCRYPTHASH; pbData: PByte; dwDataLen: DWORD;
  dwFlags: DWORD): BOOL;
  stdcall; external 'Advapi32.dll';

function CryptGetHashParam(hHash: HCRYPTHASH; dwParam: DWORD; pbData: PByte;
  var pdwDataLen: DWORD; dwFlags: DWORD): BOOL;
  stdcall; external 'Advapi32.dll';

function CryptSignHashA(hHash: HCRYPTHASH; dwKeySpec: DWORD;
  szDescription: PAnsiChar; dwFlags: DWORD; pbSignature: PByte;
  var pdwSigLen: DWORD): BOOL;
  stdcall; external 'Advapi32.dll' name 'CryptSignHashA';

function CryptDestroyHash(hHash: HCRYPTHASH): BOOL;
  stdcall; external 'Advapi32.dll';

function CryptReleaseContext(hProv: HCRYPTPROV; dwFlags: DWORD): BOOL;
  stdcall; external 'Advapi32.dll';

function Base64Encode(Data: PByte; Len: Integer): string;
const
  CHARS: array[0..63] of Char =
    ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
     'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
     'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
     'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/');
var
  i: Integer;
  b1, b2, b3: Byte;
  P: PByte;
begin
  Result := '';
  P := Data;
  i := 0;
  while i < Len do
  begin
    b1 := P^; Inc(P);
    if i + 1 < Len then begin b2 := P^; Inc(P); end else b2 := 0;
    if i + 2 < Len then begin b3 := P^; Inc(P); end else b3 := 0;

    Result := Result + CHARS[b1 shr 2];
    Result := Result + CHARS[((b1 and $03) shl 4) or (b2 shr 4)];
    if i + 1 < Len then
      Result := Result + CHARS[((b2 and $0F) shl 2) or (b3 shr 6)]
    else
      Result := Result + '=';
    if i + 2 < Len then
      Result := Result + CHARS[b3 and $3F]
    else
      Result := Result + '=';
    Inc(i, 3);
  end;
end;

function C14NEscapeAttr(const S: string): string;
var i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    case S[i] of
      '&': Result := Result + '&amp;';
      '<': Result := Result + '&lt;';
      '"': Result := Result + '&quot;';
      #9:  Result := Result + '&#x9;';
      #10: Result := Result + '&#xA;';
      #13: Result := Result + '&#xD;';
    else
      Result := Result + S[i];
    end;
end;

function C14NEscapeText(const S: string): string;
var i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    case S[i] of
      '&': Result := Result + '&amp;';
      '<': Result := Result + '&lt;';
      '>': Result := Result + '&gt;';
      #13: Result := Result + '&#xD;';
    else
      Result := Result + S[i];
    end;
end;

type
  TC14NItem = class
    SortKey: string;
    Rendered: string;
  end;

procedure C14NSort(L: TList);
var
  i, j: Integer;
  Tmp: Pointer;
begin
  for i := 1 to L.Count - 1 do
  begin
    j := i;
    while (j > 0) and
          (TC14NItem(L[j]).SortKey < TC14NItem(L[j-1]).SortKey) do
    begin
      Tmp := L[j];
      L[j] := L[j-1];
      L[j-1] := Tmp;
      Dec(j);
    end;
  end;
end;

function CanonicalizeNode(Node: OleVariant; ParentNS: TStrings;
                          SkipSig: Boolean): string;
const
  XMLDSIG_NS = 'http://www.w3.org/2000/09/xmldsig#';
var
  NodeType, i: Integer;
  Attrs, Children, Attr, Child: OleVariant;
  AttrName, AttrValue, Prefix: string;
  NodeName, NodeBase, NodeNS, AttrNS: string;
  NSList, AttrList: TList;
  Item: TC14NItem;
  ChildNS: TStringList;
  Tmp: Variant;
  Cnt: Integer;
begin
  Result := '';
  NodeType := Node.nodeType;

  case NodeType of
    1: // ELEMENT
    begin
      NodeName := Node.nodeName;
      NodeBase := Node.baseName;
      NodeNS := '';
      try
        Tmp := Node.namespaceURI;
        if not VarIsNull(Tmp) then NodeNS := Tmp;
      except
      end;

      if SkipSig and (NodeBase = 'Signature') and (NodeNS = XMLDSIG_NS) then
        Exit;

      NSList := TList.Create;
      AttrList := TList.Create;
      ChildNS := TStringList.Create;
      try
        ChildNS.Assign(ParentNS);

        Attrs := Node.attributes;
        if (not VarIsNull(Attrs)) and (not VarIsClear(Attrs)) then
        begin
          Cnt := Attrs.length;
          for i := 0 to Cnt - 1 do
          begin
            Attr := Attrs.item[i];
            AttrName := Attr.name;
            AttrValue := Attr.value;

            if AttrName = 'xmlns' then
            begin
              if ChildNS.Values['_def_'] <> AttrValue then
              begin
                Item := TC14NItem.Create;
                Item.SortKey := '';
                Item.Rendered := ' xmlns="' + C14NEscapeAttr(AttrValue) + '"';
                NSList.Add(Item);
                ChildNS.Values['_def_'] := AttrValue;
              end;
            end
            else if Copy(AttrName, 1, 6) = 'xmlns:' then
            begin
              Prefix := Copy(AttrName, 7, Length(AttrName));
              if ChildNS.Values['_ns_' + Prefix] <> AttrValue then
              begin
                Item := TC14NItem.Create;
                Item.SortKey := Prefix;
                Item.Rendered := ' xmlns:' + Prefix + '="' +
                                 C14NEscapeAttr(AttrValue) + '"';
                NSList.Add(Item);
                ChildNS.Values['_ns_' + Prefix] := AttrValue;
              end;
            end
            else
            begin
              AttrNS := '';
              try
                Tmp := Attr.namespaceURI;
                if not VarIsNull(Tmp) then AttrNS := Tmp;
              except
              end;
              Item := TC14NItem.Create;
              Item.SortKey := AttrNS + #1 + string(Attr.baseName);
              Item.Rendered := ' ' + AttrName + '="' +
                               C14NEscapeAttr(AttrValue) + '"';
              AttrList.Add(Item);
            end;
          end;
        end;

        C14NSort(NSList);
        C14NSort(AttrList);

        Result := '<' + NodeName;
        for i := 0 to NSList.Count - 1 do
          Result := Result + TC14NItem(NSList[i]).Rendered;
        for i := 0 to AttrList.Count - 1 do
          Result := Result + TC14NItem(AttrList[i]).Rendered;
        Result := Result + '>';

        Children := Node.childNodes;
        if (not VarIsNull(Children)) and (not VarIsClear(Children)) then
        begin
          Cnt := Children.length;
          for i := 0 to Cnt - 1 do
          begin
            Child := Children.item[i];
            Result := Result + CanonicalizeNode(Child, ChildNS, SkipSig);
          end;
        end;

        Result := Result + '</' + NodeName + '>';
      finally
        for i := 0 to NSList.Count - 1 do TC14NItem(NSList[i]).Free;
        for i := 0 to AttrList.Count - 1 do TC14NItem(AttrList[i]).Free;
        NSList.Free;
        AttrList.Free;
        ChildNS.Free;
      end;
    end;

    3, 4: // TEXT / CDATA
    begin
      try Result := C14NEscapeText(string(Node.nodeValue)); except Result := ''; end;
    end;

    7: // PROCESSING_INSTRUCTION
    begin
      try
        Result := '<?' + string(Node.nodeName);
        if Length(string(Node.nodeValue)) > 0 then
          Result := Result + ' ' + string(Node.nodeValue);
        Result := Result + '?>';
      except
        Result := '';
      end;
    end;
  end;
end;

function CanonicalizeDoc(Doc: OleVariant; SkipSig: Boolean): string;
var
  Raiz: OleVariant;
  NS: TStringList;
begin
  Raiz := Doc.documentElement;
  NS := TStringList.Create;
  try
    Result := CanonicalizeNode(Raiz, NS, SkipSig);
  finally
    NS.Free;
  end;
end;

procedure ReverterBytes(var Bytes: array of Byte);
var
  i, j: Integer;
  Tmp: Byte;
begin
  i := 0;
  j := High(Bytes);
  while i < j do
  begin
    Tmp := Bytes[i];
    Bytes[i] := Bytes[j];
    Bytes[j] := Tmp;
    Inc(i);
    Dec(j);
  end;
end;

procedure TFrmAssinarXML.FormShow(Sender: TObject);
begin
  MemoLog.Clear;
  CarregarCertificados;
end;

procedure TFrmAssinarXML.Log(const S: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + S);
end;

procedure TFrmAssinarXML.CarregarCertificados;
var
  hStore: HCERTSTORE;
  pCert: PCERT_CONTEXT;
  Buf: array[0..255] of AnsiChar;
  Nome: string;
begin
  ComboCert.Items.Clear;

  hStore := CertOpenSystemStoreA(nil, 'MY');
  if hStore = nil then
  begin
    Log('Erro ao abrir store de certificados (MY)');
    Exit;
  end;
  try
    pCert := CertEnumCertificatesInStore(hStore, nil);
    while pCert <> nil do
    begin
      FillChar(Buf, SizeOf(Buf), 0);
      if CertGetNameStringA(pCert, CERT_NAME_FRIENDLY_DISPLAY_TYPE, 0, nil,
                            @Buf[0], SizeOf(Buf)) <= 1 then
        CertGetNameStringA(pCert, CERT_NAME_SIMPLE_DISPLAY_TYPE, 0, nil,
                           @Buf[0], SizeOf(Buf));
      Nome := string(PAnsiChar(@Buf[0]));
      if (Nome <> '') and (ComboCert.Items.IndexOf(Nome) < 0) then
        ComboCert.Items.Add(Nome);

      pCert := CertEnumCertificatesInStore(hStore, pCert);
    end;
  finally
    CertCloseStore(hStore, 0);
  end;

  Log('Certificados carregados: ' + IntToStr(ComboCert.Items.Count));
  if ComboCert.Items.Count > 0 then
    ComboCert.ItemIndex := 0;
end;

procedure TFrmAssinarXML.BtnRecarregarClick(Sender: TObject);
begin
  CarregarCertificados;
end;

procedure TFrmAssinarXML.BtnProcurarClick(Sender: TObject);
begin
  OpenDlg.Title  := 'Selecione o arquivo XML do eSocial';
  OpenDlg.Filter := 'Arquivos XML (*.xml)|*.xml|Todos (*.*)|*.*';
  OpenDlg.DefaultExt := 'xml';
  if OpenDlg.Execute then
    EditArquivo.Text := OpenDlg.FileName;
end;

procedure TFrmAssinarXML.BtnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmAssinarXML.BtnAssinarClick(Sender: TObject);
var
  hStore: HCERTSTORE;
  pCert, pAlvo: PCERT_CONTEXT;
  Buf: array[0..255] of AnsiChar;
  Nome: string;
  NomeAlvo: string;
  hProv: HCRYPTPROV;
  hHash: HCRYPTHASH;
  KeySpec: DWORD;
  fCallerFree: BOOL;
  Canonical: string;
  CanonicalUTF8: AnsiString;
  HashBytes: array[0..31] of Byte;
  HashLen: DWORD;
  SigBytes: array of Byte;
  SigLen: DWORD;
  HashB64, SigB64, CertB64, Sig, Saida: string;
  XmlDoc, SigDoc, NoSig, NoRaiz: OleVariant;
  CaminhoSaida: string;
  cbProvInfo: DWORD;
  pProvInfo: PCryptKeyProvInfo;
  hProvAES: HCRYPTPROV;
begin
  if ComboCert.ItemIndex < 0 then
  begin
    MessageDlg('Selecione um certificado.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if Trim(EditArquivo.Text) = '' then
  begin
    MessageDlg('Selecione o arquivo XML.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if not FileExists(EditArquivo.Text) then
  begin
    MessageDlg('Arquivo n'#227'o encontrado: ' + EditArquivo.Text, mtError, [mbOK], 0);
    Exit;
  end;

  MemoLog.Clear;
  NomeAlvo := ComboCert.Items[ComboCert.ItemIndex];
  Log('Iniciando assinatura...');
  Log('Certificado: ' + NomeAlvo);
  Log('Arquivo: ' + EditArquivo.Text);

  pAlvo := nil;
  hStore := CertOpenSystemStoreA(nil, 'MY');
  if hStore = nil then
  begin
    Log('ERRO: n'#227'o foi poss'#237'vel abrir store de certificados.');
    Exit;
  end;

  try
    pCert := CertEnumCertificatesInStore(hStore, nil);
    while pCert <> nil do
    begin
      FillChar(Buf, SizeOf(Buf), 0);
      if CertGetNameStringA(pCert, CERT_NAME_FRIENDLY_DISPLAY_TYPE, 0, nil,
                            @Buf[0], SizeOf(Buf)) <= 1 then
        CertGetNameStringA(pCert, CERT_NAME_SIMPLE_DISPLAY_TYPE, 0, nil,
                           @Buf[0], SizeOf(Buf));
      Nome := string(PAnsiChar(@Buf[0]));
      if Nome = NomeAlvo then
      begin
        pAlvo := pCert;
        Break;
      end;
      pCert := CertEnumCertificatesInStore(hStore, pCert);
    end;

    if pAlvo = nil then
    begin
      Log('ERRO: certificado n'#227'o localizado no store.');
      Exit;
    end;

    Screen.Cursor := crHourGlass;
    try
      hProv := 0;
      KeySpec := 0;
      fCallerFree := False;
      if not CryptAcquireCertificatePrivateKey(pAlvo, 0, nil, hProv, KeySpec,
                                               fCallerFree) then
      begin
        Log('ERRO ao obter chave privada (cert sem privkey?). C'#243'd: ' +
            IntToStr(GetLastError));
        Exit;
      end;
      Log('Chave privada obtida (KeySpec=' + IntToStr(KeySpec) + ')');

      // --- Upgrade do provider para PROV_RSA_AES (necessario p/ SHA-256) ---
      cbProvInfo := 0;
      CertGetCertificateContextProperty(pAlvo, CERT_KEY_PROV_INFO_PROP_ID,
                                        nil, cbProvInfo);
      if cbProvInfo > 0 then
      begin
        GetMem(pProvInfo, cbProvInfo);
        try
          if CertGetCertificateContextProperty(pAlvo, CERT_KEY_PROV_INFO_PROP_ID,
                                               pProvInfo, cbProvInfo) then
          begin
            hProvAES := 0;
            if CryptAcquireContextW(hProvAES, pProvInfo^.pwszContainerName,
                                    PWideChar(WideString(MS_ENH_RSA_AES_PROV_NAME)),
                                    PROV_RSA_AES, CRYPT_SILENT) then
            begin
              if fCallerFree then
                CryptReleaseContext(hProv, 0);
              hProv := hProvAES;
              KeySpec := pProvInfo^.dwKeySpec;
              fCallerFree := True;
              Log('Provider trocado para PROV_RSA_AES (SHA-256 OK)');
            end
            else
              Log('Aviso: nao foi possivel trocar provider (erro ' +
                  IntToStr(GetLastError) + '), seguindo com original');
          end;
        finally
          FreeMem(pProvInfo);
        end;
      end;

      try
        XmlDoc := CreateOleObject('Msxml2.DOMDocument.6.0');
        XmlDoc.async := False;
        XmlDoc.preserveWhiteSpace := True;
        if not XmlDoc.load(EditArquivo.Text) then
        begin
          Log('ERRO de parse XML: ' + string(XmlDoc.parseError.reason));
          Exit;
        end;
        Log('XML carregado e parseado');

        Canonical := CanonicalizeDoc(XmlDoc, True);
        CanonicalUTF8 := UTF8Encode(WideString(Canonical));
        Log('XML canonicalizado (c14n): ' + IntToStr(Length(CanonicalUTF8)) + ' bytes UTF-8');

        if not CryptCreateHash(hProv, CALG_SHA_256, 0, 0, hHash) then
        begin
          Log('ERRO CryptCreateHash (SHA-256): ' + IntToStr(GetLastError));
          Log('Aviso: certificado pode estar em provider sem suporte a SHA-256');
          Exit;
        end;

        try
          if not CryptHashData(hHash, @CanonicalUTF8[1], Length(CanonicalUTF8), 0) then
          begin
            Log('ERRO CryptHashData: ' + IntToStr(GetLastError));
            Exit;
          end;

          HashLen := SizeOf(HashBytes);
          if not CryptGetHashParam(hHash, HP_HASHVAL, @HashBytes[0], HashLen, 0) then
          begin
            Log('ERRO CryptGetHashParam: ' + IntToStr(GetLastError));
            Exit;
          end;
          Log('Hash SHA-256 calculado (' + IntToStr(HashLen) + ' bytes)');

          SigLen := 0;
          CryptSignHashA(hHash, KeySpec, nil, 0, nil, SigLen);
          if SigLen = 0 then
          begin
            Log('ERRO ao determinar tamanho da assinatura: ' + IntToStr(GetLastError));
            Exit;
          end;
          SetLength(SigBytes, SigLen);
          if not CryptSignHashA(hHash, KeySpec, nil, 0, @SigBytes[0], SigLen) then
          begin
            Log('ERRO CryptSignHash: ' + IntToStr(GetLastError));
            Exit;
          end;
          Log('Assinatura RSA gerada (' + IntToStr(SigLen) + ' bytes)');
        finally
          CryptDestroyHash(hHash);
        end;

        ReverterBytes(SigBytes);

        HashB64 := Base64Encode(@HashBytes[0], SizeOf(HashBytes));
        SigB64  := Base64Encode(@SigBytes[0], Length(SigBytes));
        CertB64 := Base64Encode(pAlvo^.pbCertEncoded, pAlvo^.cbCertEncoded);
        Log('Hash, assinatura e certificado em Base64');

        Sig :=
          '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">' +
          '<SignedInfo>' +
            '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />' +
            '<SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" />' +
            '<Reference URI="">' +
              '<Transforms>' +
                '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />' +
                '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />' +
              '</Transforms>' +
              '<DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256" />' +
              '<DigestValue>' + HashB64 + '</DigestValue>' +
            '</Reference>' +
          '</SignedInfo>' +
          '<SignatureValue>' + SigB64 + '</SignatureValue>' +
          '<KeyInfo>' +
            '<X509Data>' +
              '<X509Certificate>' + CertB64 + '</X509Certificate>' +
            '</X509Data>' +
          '</KeyInfo>' +
          '</Signature>';

        SigDoc := CreateOleObject('Msxml2.DOMDocument.6.0');
        SigDoc.async := False;
        if not SigDoc.loadXML(Sig) then
        begin
          Log('ERRO ao construir XML de assinatura: ' + string(SigDoc.parseError.reason));
          Exit;
        end;

        NoSig  := XmlDoc.importNode(SigDoc.documentElement, True);
        NoRaiz := XmlDoc.documentElement;
        NoRaiz.appendChild(NoSig);

        CaminhoSaida := ExtractFilePath(EditArquivo.Text) +
                        ChangeFileExt(ExtractFileName(EditArquivo.Text), '') +
                        '_assinado' + ExtractFileExt(EditArquivo.Text);

        Saida := XmlDoc.xml;
        with TFileStream.Create(CaminhoSaida, fmCreate) do
        try
          WriteBuffer(Saida[1], Length(Saida));
        finally
          Free;
        end;

        Log('Arquivo salvo: ' + CaminhoSaida);
        Log('Assinatura conclu'#237'da com sucesso!');
        MessageDlg('Assinatura conclu'#237'da:'#13#10 + CaminhoSaida,
                   mtInformation, [mbOK], 0);
      finally
        if fCallerFree and (hProv <> 0) then
          CryptReleaseContext(hProv, 0);
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  finally
    CertCloseStore(hStore, 0);
  end;
end;

end.
