
using web
using inet
using [java] javax.servlet.http
using [java] javax.servlet.http::Cookie as JCookie
using [java] fanx.interop

internal class ServletRes : WebRes
{
  private HttpServletResponse? res
  internal WebOutStream? webOut
  override Bool isCommitted := false { private set }

  new make(HttpServletResponse? response)
  {
    res = response
  }

  override Bool isDone := false { private set }
  override Void done() { isDone = true }

  override WebOutStream out()
  {
    // if we are grabbing a stream to write response content, then
    // ensure we are committed with content; it is an illegal state
    // if another code path committed with no-content
    commit(true)
    if (webOut == null) throw Err("Must set Content-Length or Content-Type to write content")
    return webOut
  }

  override Void redirect(Uri uri, Int statusCode := 303)
  {
    this.statusCode = statusCode
    commit(false)
    res.sendRedirect(uri.toStr)
  }

  override Void sendErr(Int statusCode, Str? msg := null)
  {
    commit(false)
    res.sendError(statusCode, msg)
  }

  override Int statusCode := 200
  {
    set
    {
      checkUncommitted
      &statusCode = it
      // this is applied in commit()
    }
  }

  internal Void checkUncommitted()
  {
    if (isCommitted) throw Err("WebRes already committed")
  }

  **
  ** If we haven't committed yet, then write the response header.
  ** The content flag specifies whether this response will have a
  ** content body in the response.
  **
  internal Void commit(Bool content)
  {
    // check if committed
    if (isCommitted) return
    isCommitted = true

    // if we have content then we need to ensure we have our
    // headers and response stream are setup correctly
    if (content)
      webOut = WebOutStream(Interop.toFan(res.getOutputStream))

    // write response line and headers
    res.setStatus(statusCode)
    headers.each |Str v, Str k| { res.addHeader(k, v) }
    cookies.each |c|
    {
      jc := JCookie(c.name, c.val)
      if (c.maxAge != null) jc.setMaxAge(c.maxAge.toSec)
      if (c.secure == true) jc.setSecure(true)
      if (c.domain != null) jc.setDomain(c.domain)
      jc.setPath(c.path)
      res.addCookie(jc)
    }
  }

  override Str:Str headers := Str:Str[:]
  {
    get { return (isCommitted ? &headers.ro : &headers) }
  }

  override web::Cookie[] cookies := Cookie[,]
  {
    get { return (isCommitted ? &cookies.ro : &cookies) }
  }

  ** I add this method
  internal Void close()
  {
    commit(false)
    if (webOut != null) webOut.close
  }
}

