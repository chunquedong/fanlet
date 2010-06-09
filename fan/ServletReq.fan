
using web
using inet
using [java] javax.servlet
using [java] javax.servlet.http
using [java] fanx.interop

internal class ServletReq : WebReq
{
  private HttpServletRequest? req
  private InStream webIn
  override WebMod mod
  
  new make(HttpServletRequest? request, WebMod wm) {
    req = request
    mod = wm
    webIn = Interop.toFan(req.getInputStream())
  }
  
  override InStream in() { return webIn }
  override IpAddr remoteAddr() { return IpAddr(req.getRemoteAddr()) }
  override Int remotePort() { return req.getRemotePort() }
  override Version version := Version("0")
  override Str method() { return req.getMethod() }
  override Uri uri() { return Uri.fromStr(req.getRequestURI()) }
  override once WebSession session() { return ServletSession(req.getSession()) }
  
  override once Str:Str headers() {
    hdrs := Str:Str[:]
    e := req.getHeaderNames()
    while (e.hasMoreElements()) {
      name := e.nextElement()
      hdrs[name] = req.getHeader(name)
    }
    return hdrs.ro
  }
}

