<!DOCTYPE html>
<html>

<head>
    <title>Administrator Page</title>
</head>

<body>

    <%@ include file="jdbc.jsp" %>
    <%@ include file="auth.jsp" %>

    <h1>Administrator Sales Report by Day<h1>

    <table>
        <tr>
            <th>Order Date<th>
            <th>Total Order Amount<th>
        <tr>

        <%

            // TODO: Write SQL query that prints out total order amount by day
            String sql = "SELECT orderDate, SUM(totalAmount) AS summedTotalAmount"
                    + "FROM OrderSummary"
                    + "GROUP BY orderDate";

            getConnection();
            Statement stmt = con.createStatement();
            ResultSet rst = stmt.executeQuery(sql);

            NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();

            while(rst.next()) {
                Timestamp orderDate = rst.getTimestamp(orderDate);
                double summedTotalAmount = rst.getDouble(summedTotalAmount);

                //TODO: turn date into string

                //TODO: format currency
                String formattedTotalAmount = 

                String tableRow = String.format(
                    "<tr> <td>%s</td> <td>%s</td> <tr>",
                    formattedDate,
                    currencyFormatter.format(summedTotalAmount);
                );

                out.println(tableRow);
            }

            closeConnection();

        %>

    </table>

</body>
</html>

