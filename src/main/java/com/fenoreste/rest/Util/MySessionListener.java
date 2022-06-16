/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Util;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

/**
 *
 * @author wilmer
 */
@WebListener
public class MySessionListener implements HttpSessionListener {

    public MySessionListener() {
    }

    public void sessionCreated(HttpSessionEvent sessionEvent) {

        // Get the session that was created
        HttpSession session = sessionEvent.getSession();

        // Store something in the session, and log a message
        try {
            System.out.println("[MySessionListener] Session created: " + session);
            session.setAttribute("foo", "bar");
        } catch (Exception e) {
            System.out.println("[MySessionListener] Error setting session attribute: " + e.getMessage());
        }
    }

    public void sessionDestroyed(HttpSessionEvent sessionEvent) {

        // Get the session that was invalidated
        HttpSession session = sessionEvent.getSession();

        // Log a message
        System.out.println("[MySessionListener] Session invalidated: " + session);
        System.out.println("[MySessionListener] Value of foo is: " + session.getAttribute("foo"));
    }
    /*
  @Override
  public void sessionCreated(HttpSessionEvent se) {
      System.out.println("-- HttpSessionListener#sessionCreated invoked --");
      HttpSession session = se.getSession();
      System.out.println("session id: " + session.getId());
      session.setMaxInactiveInterval(1);//in seconds
  }

  @Override
  public void sessionDestroyed(HttpSessionEvent se) {
      System.out.println("-- HttpSessionListener#sessionDestroyed invoked --");
  }*/
}
