
using web
using [java] javax.servlet.http

class ServletSession : WebSession
{
  private HttpSession? session
  private Bool isValid := true

  new make(HttpSession? hs)
  {
    session = hs
    id = session.getId
    e := session.getAttributeNames
    while (e.hasMoreElements)
    {
      name := e.nextElement
      this.map[name] = session.getAttribute(name)
    }
  }

  override const Str id

  override Void delete()
  {
    session.invalidate()
    isValid = false
  }

  override Str:Obj? map := Str:Obj[:]

  internal Void save()
  {
    if (isValid)
      this.map.each |Obj? v, Str k| { session.setAttribute(k, v) }
  }
}