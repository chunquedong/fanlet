

using web
using concurrent
using [java] javax.servlet
using [java] javax.servlet.http

class FanServlet : HttpServlet, Weblet
{
  // would ultimately like to just override service(), but JavaFFI can't do it
  
  private Void setThreadLocalReqRes(HttpServletRequest? req, HttpServletResponse? res)
  {
    Actor.locals["web.req"] = ServletReq(req)
    Actor.locals["web.res"] = ServletRes(res)
  }
  
  override Void doDelete(HttpServletRequest? req, HttpServletResponse? res)
  {
    setThreadLocalReqRes(req, res)
    onDelete()
  }
  
  override Void doGet(HttpServletRequest? req, HttpServletResponse? res)
  {
    setThreadLocalReqRes(req, res)
    onGet()
  }
  
  override Void doHead(HttpServletRequest? req, HttpServletResponse? res)
  {
    setThreadLocalReqRes(req, res)
    onHead()
  }
  
  override Void doOptions(HttpServletRequest? req, HttpServletResponse? res)
  {
    setThreadLocalReqRes(req, res)
    onOptions()
  }
  
  override Void doPost(HttpServletRequest? req, HttpServletResponse? res)
  {
    setThreadLocalReqRes(req, res)
    onPost()
  }
  
  override Void doPut(HttpServletRequest? req, HttpServletResponse? res)
  {
    setThreadLocalReqRes(req, res)
    onPut()
  }
  
  override Void doTrace(HttpServletRequest? req, HttpServletResponse? res)
  {
    setThreadLocalReqRes(req, res)
    onTrace()
  }
}

internal const class ServletDefaultMod : WebMod
{
  override Void onGet()
  {
    res.headers["Content-Type"] = "text/html; charset=utf-8"
    out := res.out
    out.html
      .head
        .title.w("Fanlet").titleEnd
      .headEnd
      .body
        .h1.w("Fanlet").h1End
        .p.w("Fantom is running in a servlet container!").pEnd
        .p.w("Currently there is no WebMod installed on this server.").pEnd
        .p.w("See <a href='http://fantom.org/doc/wisp/pod-doc.html'>wisp::pod-doc</a>
              to configure a WebMod for the server.").pEnd
      .bodyEnd
    .htmlEnd
  }
}


