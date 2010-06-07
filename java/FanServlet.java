
package fan.servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import fan.sys.*;
import fanx.interop.*;

public class FanServlet extends HttpServlet
{
  private FanObj webmod;
  private static final Logger log = Logger.getLogger(FanServlet.class.getName());
  
  public static FanObj loadAndCreateType(String fanTypeName, Object... values)
  {
    return (FanObj) Type.find(fanTypeName).make(new List(Sys.ObjType, values));
  }
  
  @Override
  public void init() throws ServletException
  {
    super.init();
    String n = getInitParameter("fan.servlet.webmod");
    if (n == null)
      throw ArgErr.make("FanServlet requires an init param specifying 'fan.servlet.webmod'").val;
    webmod = loadAndCreateType(n);
    if (!webmod.typeof().fits(Type.find("web::WebMod")))
      throw ArgErr.make(webmod.typeof().qname() + " does not fit webmod").val;
    webmod.typeof().method("onStart").call(webmod);
  }
  
  @Override
  public void destroy()
  {
    super.destroy();
    webmod.typeof().method("onStop").call(webmod);
  }
  
  private void dispatch(Method method, HttpServletRequest req, HttpServletResponse res)
  {
    final FanObj webres = loadAndCreateType("servlet::ServletRes", res);
    // final FanObj webreq = loadAndCreateType("servlet::ServletReq", req, webmod);
    // log.warning("made req: " + req);
    Map locals = (Map) Type.find("concurrent::Actor").method("locals").call();
    // locals.set("web.req", webreq);
    locals.set("web.res", webres);
    method.call(webmod); // first param is the object to call on
  }
  
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
      dispatch(webmod.typeof().method("onGet"), req, res);
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
      dispatch(webmod.typeof().method("onPost"), req, res);
  }

  @Override
  protected void doDelete(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
      dispatch(webmod.typeof().method("onDelete"), req, res);
  }

  @Override
  protected void doHead(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
      dispatch(webmod.typeof().method("onHead"), req, res);
  }

  @Override
  protected void doOptions(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
      dispatch(webmod.typeof().method("onOptions"), req, res);
  }

  @Override
  protected void doPut(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
      dispatch(webmod.typeof().method("onPut"), req, res);
  }

  @Override
  protected void doTrace(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
      dispatch(webmod.typeof().method("onTrace"), req, res);
  }
  
}