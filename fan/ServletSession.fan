
using web
using [java] javax.servlet.http

class ServletSession : WebSession
{
  private HttpSession? session
  private Bool isValid := true
  
  new make(HttpSession? hs) : super(hs.getId)
  {
    session = hs
    e := session.getAttributeNames
    while (e.hasMoreElements)
    {
      name := e.nextElement
      this.map[name] = session.getAttribute(name)
    }
  }
  
  override Void delete()
  {
    session.invalidate()
    isValid = false
  }
  
  internal Void save()
  {
    if (isValid)
      this.map.each |Obj? v, Str k| { session.setAttribute(k, v) }
  }
}