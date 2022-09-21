package edu.umd.cmsc798a.iremumcp.server.servlets;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.Point;

import edu.umd.cmsc798a.iremumcp.server.dao.PMF;
import edu.umd.cmsc798a.iremumcp.server.dao.TestObjectToSave;

public class TestObjectToSaveServlet extends HttpServlet {

	private static final long serialVersionUID = -8868827162183253308L;

	public void doGet(HttpServletRequest req, HttpServletResponse res)
			throws IOException {
		Logger log = Logger.getLogger(TestObjectToSaveServlet.class.getName());
		log.info("TestObjectToSaveServlet.doGet()");

		double lat = Double.parseDouble(req.getParameter("lat"));
		double lon = Double.parseDouble(req.getParameter("lon"));

		Point p = null;
		List<String> cells = null;

		// Create bunch of test objects with random (lat,lng) pairs
		TestObjectToSave testObj1 = new TestObjectToSave();
		testObj1.setLatitude(lat);
		testObj1.setLongitude(lon);
		p = new Point(testObj1.getLatitude(), testObj1.getLongitude());
		cells = GeocellManager.generateGeoCell(p);
		testObj1.setGeocells(cells);
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		try {
			pm.makePersistent(testObj1);
		} finally {
			pm.close();
		}

	}
}
