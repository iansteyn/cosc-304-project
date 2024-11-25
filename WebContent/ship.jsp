<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
    <title>Rowan and Ian's Grocery Shipment Processing</title>
</head>

<body>
<%@ include file="header.jsp" %>

    <%!
        String indexPageLink = "<h2><a href=\"index.jsp\">Back to Main Page</a></h2>";
    %>

    <%
        // Get order id
        String orderIdString = request.getParameter("orderId");

        if (orderIdString == null || !orderIdString.matches("^[0-9]+$")) {
            out.println("<h2>Error: Missing or non-integer order id.</h2>");
            out.println(indexPageLink);
            return; //end JSP early
        }

        int orderId = Integer.parseInt(orderIdString);

        try {
            // Check if valid order id in database
            getConnection();
            PreparedStatement pstmt = con.prepareStatement(
                "SELECT orderId FROM OrderSummary WHERE orderId = ?"
            );
            pstmt.setInt(1, orderId);
            
            ResultSet rst = pstmt.executeQuery();
            boolean orderIdInDatabase = rst.isBeforeFirst();

            if (! orderIdInDatabase) {
                out.println("<h2>Invalid order id.</h2>");
                return;
            }
        
            // TODO: Start a transaction (turn-off auto-commit)
            
            // TODO: Retrieve all items in order with given id
            // TODO: Create a new shipment record.
            // TODO: For each item verify sufficient quantity available in warehouse 1.
            // TODO: If any item does not have sufficient inventory, cancel transaction and rollback. Otherwise, update inventory for each item.
            
            // TODO: Auto-commit should be turned back on
        }
        catch (SQLException ex) {
            out.println(ex);
        }
        finally {
            closeConnection();
            out.println(indexPageLink);
        }
    %>

</body>
</html>
