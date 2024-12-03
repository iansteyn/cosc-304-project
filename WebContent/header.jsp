<div>
    <H1 align="center"><font face="cursive" color="#3399FF"><a href="index.jsp">Rowan & Ian's Grocery</a></font></H1>      
    <div class="centered-options">
        <p><a href="listprod.jsp">Begin Shopping</a></p>
        <p>test 2 </p>
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
    padding: 10;
    justify-content: space-evenly;
}

</style>
