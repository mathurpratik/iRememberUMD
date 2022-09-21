/**
 * PMF.java
 * 
 * Description: Copied and pasted from: http://code.google.com/appengine/docs/java/datastore/jdo/overview.html
 * 				The app uses the factory instance to create one PersistenceManager 
 * 				instance for each request that accesses the datastore.
 * 
 * File added: 12/19/2011	Pratik Mathur - Initial Import
 * 
 */

package edu.umd.cmsc798a.iremumcp.server.dao;

import javax.jdo.JDOHelper;
import javax.jdo.PersistenceManagerFactory;

public final class PMF {
    private static final PersistenceManagerFactory pmfInstance =
        JDOHelper.getPersistenceManagerFactory("transactions-optional");

    private PMF() {}

    public static PersistenceManagerFactory get() {
        return pmfInstance;
    }
}