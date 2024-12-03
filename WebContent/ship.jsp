<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>

<style>
table, th, td {
    text-align: center;
    border: 1px solid black;
    border-collapse: collapse;
    padding:5px
}
</style>

<html>
<head>
    <title>Puzzle Place Shipment Processing</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
<%@ include file="header.jsp" %>

    <%!
        String indexPageLink = "<h2><a href=\"index.jsp\">Back to Main Page</a></h2>";
    %>

    <%-- GET AND VALIDATE ORDER ID --%>
    <%------------------------------%>
    <%
        String orderIdString = request.getParameter("orderId");

        // validate that orderId is a number
        if (orderIdString == null || !orderIdString.matches("^[0-9]+$")) {
            out.println("<h2>Error: Order ID is missing from URL or is not an integer.</h2>");
            out.println(indexPageLink);
            return; //end JSP early
        }

        int orderId = Integer.parseInt(orderIdString);

        // Check if valid order id in database
        try {
            getConnection();
        
            /* Note: querying from orderProduct rather than orderSummary
             * verifies that there are actually items in the order. */
            PreparedStatement validation_pstmt = con.prepareStatement(
                "SELECT orderId\n"
              + "FROM OrderProduct\n"
              + "WHERE orderId = ?"
            );
            validation_pstmt.setInt(1, orderId);
            ResultSet validation_rst = validation_pstmt.executeQuery();

            boolean orderIdInDatabase = validation_rst.isBeforeFirst();

            if (! orderIdInDatabase) {
                out.println("<h2>Invalid order ID or no items in order.</h2>");
                out.println(indexPageLink);
                return; //end JSP early
            }
        }
        catch (SQLException ex) {
            out.println(ex);
        }
        finally {
            closeConnection();
        }
    %>

    <%-- PRINT START OF TABLE --%>
    <%--------------------------%>
    <h1>Ordered Products in Shipment</h1>

    <table>
        <tr>
            <th>Product ID</th>
            <th>Quantity</th>
            <th>Previous Inventory</th>
            <th>New Inventory</th>
        </tr>

    <%-- ATTEMPT SHIPMENT TRANSACTION --%>
    <%----------------------------------%>
    <%
        try {
            //--- START TRANSACTION ---//
            // Start a transaction (turn-off auto-commit)
            getConnection();
            con.setAutoCommit(false);

            // Retrieve all items in Order with given id
            PreparedStatement orderProduct_pstmt = con.prepareStatement(
                "SELECT productId, quantity\n"
              + "FROM OrderProduct\n"
              + "WHERE orderId = ?"
            );
            orderProduct_pstmt.setInt(1, orderId);

            ResultSet orderProduct_rst = orderProduct_pstmt.executeQuery();

            //prepare statements for product-by-product processing
            PreparedStatement getInventory_pstmt = con.prepareStatement(
                "SELECT quantity\n"
              + "FROM ProductInventory\n"
              + "WHERE warehouseId = 1 AND productId = ?"
            );

            PreparedStatement updateInventory_pstmt = con.prepareStatement(
                "UPDATE ProductInventory\n"
              + "SET quantity = ?\n"
              + "WHERE warehouseId = 1 AND productId = ?"
            );

            //--- PROCESS EACH PRODUCT IN ORDER ---//
            while(orderProduct_rst.next()) {

                //retrieve product info
                int productId = orderProduct_rst.getInt("productId");
                int orderedQuantity = orderProduct_rst.getInt("quantity");

                // Find quantity available in warehouse 1.
                getInventory_pstmt.setInt(1, productId);
                ResultSet getInventory_rst = getInventory_pstmt.executeQuery();

                boolean warehouseHasThisProduct = getInventory_rst.isBeforeFirst();
                int inventoryQuantity;

                if (warehouseHasThisProduct) {
                    getInventory_rst.next();
                    inventoryQuantity = getInventory_rst.getInt("quantity");
                }
                else {
                    inventoryQuantity = 0;
                }

                // verify sufficient quantity
                    /* If any item does not have sufficient inventory, cancel transaction and rollback.*/
                if (orderedQuantity > inventoryQuantity) {
                    out.println("</table>");

                    String errorMessage = String.format(
                        "<h2>Shipment not done. Insufficient inventory for product with ID (%d).</h2>",
                        productId
                    );
                    out.println(errorMessage);

                    con.rollback();
                    return; //end JSP early
                }

                // Update warehouse inventory quantity
                int newQuantity = inventoryQuantity - orderedQuantity;
                updateInventory_pstmt.setInt(1, newQuantity);
                updateInventory_pstmt.setInt(2, productId);
                updateInventory_pstmt.executeUpdate();

                // print product info
                String tableRow = String.format(
                    "<tr> <td><b><i>%d</i></b></td> <td>%d</td> <td>%d</td> <td>%d</td> </tr>",
                    productId,
                    orderedQuantity,
                    inventoryQuantity,
                    newQuantity
                );

                out.println(tableRow);
            }

            //--- END TRANSACTION ---//
            // Create a new shipment record.
                /* shipmentId gets autoincremeneted, so no need to specify it */
            PreparedStatement ship_pstmt = con.prepareStatement(
                "INSERT INTO Shipment(shipmentDate, shipmentDesc, warehouseId)\n"
                + "VALUES(?, ?, 1)"
            );
            ship_pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            ship_pstmt.setString(2, "This shipment contains various items"); //idk what shipmentDesc is supposed to be?
            ship_pstmt.executeUpdate();

            // at last, commit the transaction and print success!
            con.commit();

            out.println("</table>");
            out.println("<h2>Shipment succesfully processed.</h2>");
        }
        catch (SQLException ex) {
            con.rollback();
            out.println(ex);
        }
        finally {
            con.setAutoCommit(true);
            closeConnection();

            out.println(indexPageLink);
        }
    %>

</body>
</html>


