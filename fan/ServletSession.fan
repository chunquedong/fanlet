
using web
using [java] javax.servlet.http

class ServletSession : WebSession
{
  private HttpSession? session
  
  new make(HttpSession? hs) : super(hs.getId()) {
    session = hs
  }
  
  override Void delete() {
    session.invalidate()
  }
}