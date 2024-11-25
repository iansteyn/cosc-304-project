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
            //TODO - do I need to check if there are products in the order??
            getConnection();
            PreparedStatement validation_pstmt = con.prepareStatement(
                "SELECT orderId FROM OrderSummary WHERE orderId = ?"
            );
            validation_pstmt.setInt(1, orderId);

            ResultSet validation_rst = validation_pstmt.executeQuery();
            boolean orderIdInDatabase = validation_rst.isBeforeFirst();

            if (! orderIdInDatabase) {
                out.println("<h2>Invalid order id.</h2>");
                return; //end JSP early (`finally` block will still execute)
            }

            // Start a transaction (turn-off auto-commit)
            con.setAutoCommit(false);

            // Retrieve all items in Order with given id
            PreparedStatement orderProduct_pstmt = con.prepareStatement(
                "SELECT productId, quantity\n"
              + "FROM OrderProduct\n"
              + "WHERE orderId = ?"
            );
            orderProduct_pstmt.setInt(1, orderId);

            ResultSet orderProduct_rst = orderProduct_pstmt.executeQuery();

            //TO DO retrieve in a loop

            // Create a new shipment record. - wait shouldn't this go after the check for inventory??
                // shipmentId gets autoicrmeneted, so no need to specify it
            PreparedStatment ship_pstmt = con.prepareStatement(
                "INSERT INTO Shipment(shipmentDate, shipmentDesc, warehouseId)\n"
              + "VALUES(?, ?, 1)"
            );
            ship_pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            ship_pstmt.setString(2, "This shipment contains various items"); //idk what shipmentDesc is supposed to be?
            ship_pstmt.executeUpdate;

            // TODO: For each item verify sufficient quantity available in warehouse 1.
            Statement inventory_pstmt = con.prepareStatement(
                "SELECT quantity\n"
              + "FROM ProductInventory\n"
              + "WHERE warehouseId = 1 && productId = ?"
            );
            inventory_pstmt.setInt(1, productId);

            ResultSet inventory_rst = inventory_stmt.executeQuery();
            inventory_rst.next();
            int inventoryQuantity = inventory_rst.getInt("quantity");

            // TODO: If any item does not have sufficient inventory, cancel transaction and rollback. Otherwise, update inventory for each item.
            if (orderedQuantity <= inventoryQuantity) {
                //print results
                //TODO: decrement inventory in db??
            }
            else {
                //rollback
                //print error message
                //return
            }

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
