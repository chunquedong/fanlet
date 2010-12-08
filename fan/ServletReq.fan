
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

  new make(HttpServletRequest? request, WebMod wm)
  {
    req = request
    mod = wm
    webIn = Interop.toFan(req.getInputStream)
  }

  override InStream in() { webIn }
  override IpAddr remoteAddr() { IpAddr(req.getRemoteAddr) }
  override Int remotePort() { req.getRemotePort }
  override Version version := Version("0")
  override Str method() { return req.getMethod }
  override Uri uri()
  {
    if (req.getQueryString() == null)
    {
      return Uri.fromStr(req.getRequestURI)
    }
    return Uri.fromStr(req.getRequestURI + "?" + req.getQueryString)
  }
  override once WebSession session() { ServletSession(req.getSession) }
  override SocketOptions socketOptions() { throw UnsupportedErr() }

  override once Str:Str headers()
  {
    hdrs := Str:Str[:]
    hdrs.caseInsensitive = true
    e := req.getHeaderNames
    while (e.hasMoreElements)
    {
      name := e.nextElement
      hdrs[name] = req.getHeader(name)
    }
    return hdrs.ro
  }
}

