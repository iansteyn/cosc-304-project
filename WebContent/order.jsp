<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>

<head>
    <title>Rowan & Ian's Grocery Order Processing</title>
</head>

<body>
    <%
        // Get session variables
        String customerIdString = request.getParameter("customerId");
        @SuppressWarnings({"unchecked"})
        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

        // VALIDATION
        // ----------
        // Create error messages
        String emptyCartMessage = "<h1>Shopping cart is empty!<h1>"
                                + "<h2><a href=\"listprod.jsp\">Return to shopping.</a></h2>";

        String invalidIdMessage = "<h1>Invalid customer id.<h1>"
                                + "<h2><a href=\"checkout.jsp\">Try again.</a></h2>";

        // Validate shopping cart
        if (productList.isEmpty()) { //TODO: this line causes an error when shop page is loaded on its on
            out.println(emptyCartMessage);
            return; //END jsp execution early
        }

        // Validate customer id (PT 1)
        boolean customerIdIsNumber = customerIdString.matches("^[0-9]+$");

        if (! customerIdIsNumber) {
            out.println(invalidIdMessage);
            return; //END jsp execution early
        }

        // Connect to DB and validate customer id (PT 2),
        PreparedStatement pstmt1 = con.prepareStatement(
            "SELECT firstName, lastName FROM customer WHERE customerId = ?"
        );
        
        int customerId = Integer.parseInt(customerIdString);
        pstmt1.setInt(1, customerId); 

        ResultSet customerResultSet = pstmt1.executeQuery();
        boolean customerIdIsInDB = customerResultSet.isBeforeFirst();

        if (!customerIdIsInDB) {
            out.println(invalidIdMessage);
            closeConnection();
            return; //end jsp execution early
        }

        // SAVE INFO TO ORDERSUMMARY
        // -------------------------
        // Save customerid and orderdate information to database
        String insertSQL = "INSERT INTO orderSummary(customerId, orderDate) VALUES(?, ?)";

        PreparedStatement pstmt = con.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);			
        pstmt.setInt(1, customerId);
        pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
        pstmt.executeUpdate();

        //PREPARE TO SAVE AND PRINT PRODUCTLIST INFO
        // Prep - Get orderId generated from previous INSERT
        ResultSet keys = pstmt.getGeneratedKeys();
        keys.next();
        int orderId = keys.getInt(1);
        pstmt.close();

        //Prep - prepare a new insert statement
        String insertSQL2 = "INSERT INTO OrderProduct(OrderId, ProductId, quantity, price) VALUES(?, ?, ?, ?)";
        PreparedStatement pstmt2 = con.prepareStatement(insertSQL2);
        pstmt2.setInt(1, orderId);

        //html prep - for some reason multiline strings are not a thing for JSP
        out.println(
            "<h1>Your Order Summary</h1>"
            +"<table style='text-align: center'>"
            +   "<tr>"
            +       "<th>Product Id</th>"
            +       "<th>Product Name</th>"
            +       "<th>Quantity</th>"
            +       "<th>Price</th>"
            +       "<th>Subtotal</th>"
            +   "</tr>"
        );

        //prep - initialize orderTotal variable, get currency formatter
        double orderTotal = 0;
        NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();
        
        //SAVE AND PRINT PRODUCT LIST INFO
        //For each item in productList:
            // - insert it into OrderProduct table, using the orderId
            // - calculate its subtotal to the order total
            // - print out its row in the table
            // Each entry in the HashMap is an ArrayList with item 0-id, 1-name, 2-price, 3-quantity
        Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
        while (iterator.hasNext()) {
        
            //Get item info from productList hashmap
            Map.Entry<String, ArrayList<Object>> entry = iterator.next();
            ArrayList<Object> product = (ArrayList<Object>) entry.getValue();

            String productIdString = (String) product.get(0); 
            String productName = (String) product.get(1);
            String priceString = (String) product.get(2);
            int quantity = ((Integer) product.get(3)).intValue(); 

            int productId = Integer.parseInt(productIdString);
            double price = Double.parseDouble(priceString);

            // Insert item record into OrderProduct table
            pstmt2.setInt(2, productId);
            pstmt2.setInt(3, quantity);
            pstmt2.setDouble(4, price);
            pstmt2.executeUpdate();

            //Calculate subtotal
            double subtotal = quantity * price;
            orderTotal += subtotal;

            //Print row
            String tableRow = String.format(
                "<tr> <td>%d</td> <td>%s</td> <td>%d</td> <td>%s</td> <td>%s</td> </tr>",
                productId,
                productName,
                quantity,
                currencyFormatter.format(price),
                currencyFormatter.format(subtotal)
            );

            out.println(tableRow);
        }

        pstmt2.close();

        // ORDER TOTAL STUFF
        //print orderTotal
        String finalRow = String.format(
            "<tr> <td></td> <td></td> <td></td> <th>Order Total</th> <td>%s</tr>",
            currencyFormatter.format(orderTotal)
        );
        out.println(finalRow);
        out.println("</table>");

        //Update total amount for order record
        String updateSQL = "UPDATE orderSummary SET totalAmount = ? WHERE orderId = ?";
        PreparedStatement pstmt3 = con.prepareStatement(updateSQL);
        pstmt3.setDouble(1, orderTotal);
        pstmt3.setInt(2, orderId);
        pstmt3.executeUpdate();
        pstmt3.close();

        // SUCCESS STUFF
        // get customer name
        customerResultSet.next();
        String customerName = customerResultSet.getString("firstName") + " " + customerResultSet.getString("lastName");

        // print success message
        String successMessage = String.format(
            "<h1>Order Completed. Will be shipped soon...</h1>"
            +"<h2>Your order reference number is: %d</h2>"
            +"<h2>Shipping to customer: %d. Name: %s",
            orderId,
            customerId,
            customerName
        );

        out.println(successMessage);
        out.println("<h2><a href=\"shop.html\">Return to home page.</a></h2>");

        // Clear cart if order placed successfully
        session.setAttribute("productList", null);
        //Is there a need to clear the relevant rows in the inCart table?? 
        //The info doesn't appear to have been put in it anywhere...

        //close db connection
        closeConnection(); // from jdbc.jsp

        //TODO - rename all pstmts more sensibly.
    %>

    <p>this shouldn't show on the error pages<p> <!--TODO remove-->
</body>
</html>

