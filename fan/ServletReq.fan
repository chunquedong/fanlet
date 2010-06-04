
using web
using inet
using [java] javax.servlet
using [java] javax.servlet.http
using [java] fanx.interop

class ServletReq : WebReq
{
  private HttpServletRequest? servletReq
  static const Version nullVersion := Version("0")
  
  new make(HttpServletRequest? request) {
    servletReq = request
  }
  
  override InStream in := Interop.toFan(servletReq.getInputStream())
  override IpAddr remoteAddr := IpAddr(servletReq.getRemoteAddr())
  override Int remotePort := servletReq.getRemotePort()
  override Version version := nullVersion
  override Str method := servletReq.getMethod()
  override Uri uri := Uri.fromStr(servletReq.getRequestURI())
  override WebMod mod := ServletDefaultMod()
  ** not sure how to deal with sessions yet...
  override WebSession session := ServletSession(servletReq.getSession())
  
  override once Str:Str headers() {
    hdrs := Str:Str[:]
    while (servletReq.getHeaderNames().hasMoreElements()) {
      name := servletReq.getHeaderNames().nextElement()
      hdrs[name] = servletReq.getHeader(name)
    }
    return hdrs
  }
}