<div>
    <H1 align="center"><font face="cursive" color="#3399FF"><a href="index.jsp">Rowan & Ian's Grocery</a></font></H1>      
    <div class="centered-options">
        <p><a href="listprod.jsp">Begin Shopping</a></p>
        <p><a href="listorder.jsp">List All Orders</a></p>
        <p>
        <%
        if ((String) session.getAttribute("authenticatedUser") != null) {
            out.println("Welcome, " + session.getAttribute("authenticatedUser") + ". <a href=\"logout.jsp\">Log out</a>");
        }
        else {
            out.println("<a href=\"login.jsp\">Login</a>");
        }
        %>
        </p>
    </div>
</div>

<style>
    div {
        background-color: #dddddd;
    }
    div.centered-options {
    display: flex;
    margin: auto;
    justify-content: space-evenly;
}

</style>
