
using web
using inet
using [java] javax.servlet.http
using [java] javax.servlet.http::Cookie as JCookie
using [java] fanx.interop

class ServletRes : WebRes
{
  HttpServletResponse? res
  override readonly Bool isCommitted := false
  internal WebOutStream? webOut

  new make(HttpServletResponse? response) {
      res = response
  }
  
  override readonly Bool isDone := false
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
    set {
      checkUncommitted
      &statusCode = it
      // this is applied in commit()
    }
  }
  
  **
  ** If the response has already been committed, then throw an Err.
  **
  internal Void checkUncommitted() {
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
    if (content) {
      webOut = WebOutStream(Interop.toFan(res.getOutputStream()))
    }

    // write response line and headers
    res.setStatus(this.statusCode)
    this.headers.each |Str v, Str k| {
      res.addHeader(v, k)
    }
    this.cookies.each |c| {
      jc := JCookie(c.name, c.val)
      if (c.maxAge != null) jc.setMaxAge(c.maxAge.toSec)
      if (c.secure == true) jc.setSecure(true)
      if (c.domain != null) jc.setDomain(c.domain)
      res.addCookie(jc)
    }
  }
  
  override Str:Str headers := Str:Str[:] {
    get { checkUncommitted; return &headers }
  }
  
  override web::Cookie[] cookies := web::Cookie[,] {
    get { checkUncommitted; return &cookies }
  }
}

