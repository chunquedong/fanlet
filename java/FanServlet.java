
package fan.servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import fan.sys.*;
import fanx.interop.*;

public class FanServlet extends HttpServlet
{
  private FanObj webmod;

  public static FanObj loadAndCreateType(String fanTypeName, Object... values)
  {
    return (FanObj) Type.find(fanTypeName).make(new List(Sys.ObjType, values));
  }

  @Override
  public void init() throws ServletException
  {
    super.init();
    try
    {
      java.lang.reflect.Method m = Class.forName("fanjardist.Main").
          getDeclaredMethod("main", String[].class);
      m.invoke(null, new Object[]{new String[]{}});
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
      throw new RuntimeException(ex);
    }

    String n = getInitParameter("fan.servlet.webmod");
    if (n == null)
      throw ArgErr.make("FanServlet requires an init param specifying 'fan.servlet.webmod'");
    webmod = loadAndCreateType(n);
    if (!webmod.typeof().fits(Type.find("web::WebMod")))
      throw ArgErr.make(webmod.typeof().qname() + " does not fit webmod");
    webmod.typeof().method("onStart").call(webmod);
  }

  @Override
  public void destroy()
  {
    super.destroy();
    webmod.typeof().method("onStop").call(webmod);
  }

  @Override
  protected void service(HttpServletRequest req, HttpServletResponse res)
    throws ServletException, IOException
  {
    final FanObj webres = loadAndCreateType("servlet::ServletRes", res);
    final FanObj webreq = loadAndCreateType("servlet::ServletReq", req, webmod);

    Map locals = (Map) Type.find("concurrent::Actor").method("locals").call();
    locals.set("web.res", webres);
    locals.set("web.req", webreq);

    try
    {
      webmod.typeof().method("onService").call(webmod);
    }
    finally
    {
      // save the session, and cleanup thread locals
      FanObj session = (FanObj) webreq.typeof().method("session").call(webreq);
      session.typeof().method("save").call(session);

      locals.remove("web.req");
      locals.remove("web.res");
    }

    try { webres.typeof().method("close").call(webres); }
    catch(Exception ex) { ex.printStackTrace(); }
  }
}