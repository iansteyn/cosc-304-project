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

        // Try to ship the order
        try {
            // Check if valid order id in database
                //TODO - do I need to check if there are products in the order??
            getConnection();
            PreparedStatement validation_pstmt = con.prepareStatement(
                "SELECT orderId\n"
              + "FROM OrderSummary\n"
              + "WHERE orderId = ?"
            );
            validation_pstmt.setInt(1, orderId);
            ResultSet validation_rst = validation_pstmt.executeQuery();

            boolean orderIdInDatabase = validation_rst.isBeforeFirst();

            if (! orderIdInDatabase) {
                out.println("<h2>Invalid order id.</h2>");
                return; //end JSP early (`finally` block will still execute)
            }

            //print table heading
            out.println(
                "<h1>Ordered Products in Shipment</h1>"
                +"<table>"
                + "<tr>"
                +   "<th>Product ID</th>"
                +   "<th>Quantity</th>"
                +   "<th>Previous Inventory</th>"
                +   "<th>New Inventory</th>"
                + "</tr>"
            );

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

            //prepare some more statements for retrieval
            PreparedStatement inventory_pstmt = con.prepareStatement(
                "SELECT quantity\n"
                + "FROM ProductInventory\n"
                + "WHERE warehouseId = 1 AND productId = ?"
            );

            //process each product in the order
            while(orderProduct_rst.next()) {

                //retrieve product info
                int productId = orderProduct_rst.getInt("productId");
                int orderedQuantity = orderProduct_rst.getInt("quantity");

                // TODO: For each item verify sufficient quantity available in warehouse 1.
                inventory_pstmt.setInt(1, productId);
                ResultSet inventory_rst = inventory_pstmt.executeQuery();
                inventory_rst.next();

                int inventoryQuantity = inventory_rst.getInt("quantity");

                // TODO: If any item does not have sufficient inventory, cancel transaction and rollback. Otherwise, update inventory for each item.
                if (orderedQuantity <= inventoryQuantity) {

                    String tableRow = String.format(
                        "<tr> <td>%d</td> <td>%d</td> <td>%d</td> <td>%d</td> </tr>",
                        productId,
                        orderedQuantity,
                        inventoryQuantity,
                        inventoryQuantity - orderedQuantity
                    );

                    out.println(tableRow);

                    //TODO: decrement inventory in db??
                }
                else {
                    //rollback
                    //print error message
                    //return
                }
            }

            // Create a new shipment record. - this needs to go either before or after while loop, i moved it here
                    // shipmentId gets autoicrmeneted, so no need to specify it
                PreparedStatement ship_pstmt = con.prepareStatement(
                    "INSERT INTO Shipment(shipmentDate, shipmentDesc, warehouseId)\n"
                  + "VALUES(?, ?, 1)"
                );
                ship_pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
                ship_pstmt.setString(2, "This shipment contains various items"); //idk what shipmentDesc is supposed to be?
                ship_pstmt.executeUpdate();

            // TODO: Auto-commit should be turned back on
        }
        catch (SQLException ex) {
            out.println(ex);
        }
        finally {
            out.println("</table>");
            closeConnection();
            out.println(indexPageLink);
        }
    %>

</body>
</html>
