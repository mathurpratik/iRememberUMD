package edu.umd.cmsc798a.iremumcp.server.servlets;

import javax.servlet.http.HttpServlet;
import java.io.IOException;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import edu.umd.cmsc798a.iremumcp.server.dao.LocationDao;
import edu.umd.cmsc798a.iremumcp.server.dao.PMF;

public class GetAllBlobsServlet extends HttpServlet {

	private static final long serialVersionUID = -8592189289105741538L;

	public void doGet(HttpServletRequest req, HttpServletResponse res)
			throws IOException {
		List<LocationDao> allCells = getAllCells();
		StringBuffer buf = new StringBuffer();

		res.getWriter().write(buf.toString());
		for (LocationDao l : allCells) {
			buf.append(l.getData().getKeyString() + "\n");
		}

		res.getWriter().write(buf.toString());
	}

	@SuppressWarnings("unchecked")
	public static List<LocationDao> getAllCells() {

		String query = "select from " + LocationDao.class.getName() + "";
		PersistenceManager pm = PMF.get().getPersistenceManager();

		return (List<LocationDao>) pm.newQuery(query).execute();

	}

}
