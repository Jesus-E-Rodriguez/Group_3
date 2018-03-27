<jsp:include page="partials/header.jsp" />
<%@page import="java.sql.*"%>

<%
    Connection conn = null;
    ResultSet rsOne = null;
    ResultSet rsTwo = null;
    boolean isResultSetEmpty = true;
    PreparedStatement preparedStatementOne = null;
    PreparedStatement preparedStatementTwo = null;
    String driver = "org.apache.derby.jdbc.ClientDataSource";
    String url = "jdbc:derby://localhost:1527/Concert;user=app;password=password";
    int C_ID = Integer.parseInt(session.getAttribute("C_ID").toString());
    try {

        Class.forName(driver).newInstance();
        conn = DriverManager.getConnection(url);

        // First query
        String queryOne = "SELECT C_FNAME, C_LNAME, C_EMAIL, C_ADDRESS, C_ZIP, C_CITY, C_STATE FROM CLIENTS WHERE C_ID = " + C_ID;
        preparedStatementOne = conn.prepareStatement(queryOne);
        rsOne = preparedStatementOne.executeQuery();

        // Second query
        String queryTwo = "SELECT O.O_QUANTITY, O.O_SHIPPING, O.O_FEE, O.O_TOTAL, O.O_CATNAME, S.S_PRICE FROM ORDERS O, SEATS S WHERE O.O_CATNAME = S.S_CAT AND O.C_ID = " + C_ID;
        preparedStatementTwo = conn.prepareStatement(queryTwo);
        rsTwo = preparedStatementTwo.executeQuery();
%>

<div class="showcase--medium-screen-plus background background2 text--light">
    <div class="wrapper">
        <div class="box">
            <h1>This is your ticket to Jazz Grasp!</h1>
            <h2>See you at Theatre Charlotte on April 13th, 2018 at 7:30pm.</h2>
            <p class="text--emphasize">Print a copy of this page for your records. Tickets are non-refundable.</p>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th colspan="2">Personal Information</th>
                    </tr>
                </thead>
                <%     while (rsOne.next()) {
                        //If we enter to the while, the ResultSet wasn't empty
                        isResultSetEmpty = false;
                %>
                <tbody>
                    <tr>
                        <td>First Name: <strong><%=rsOne.getString("C_FNAME")%></strong></td>
                        <td>Last Name: <strong><%=rsOne.getString("C_LNAME")%></strong></td>

                    </tr>
                    <tr>
                        <td colspan="2">Address: <strong><%=rsOne.getString("C_ADDRESS")%></strong></td>
                    </tr>
                    <tr>
                        <td>City: <strong><%=rsOne.getString("C_CITY")%></strong></td>
                        <td>Zip Code: <strong><%=rsOne.getString("C_ZIP")%></strong></td>
                    </tr>
                    <tr>
                        <td>State: <strong><%=rsOne.getString("C_STATE")%></strong></td>
                        <td>Email: <strong><%=rsOne.getString("C_EMAIL")%></strong></td>
                    </tr>
                </tbody>
                <% }%>
            </table>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>Category</th>
                        <th>Quantity</th>
                        <th>Price</th>
                        <th>Service Fee</th>
                        <th>Shipping Fee</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <%     while (rsTwo.next()) {
                        //If we enter to the while, the ResultSet wasn't empty
                        isResultSetEmpty = false;
                %>
                <tbody>
                    <tr>
                        <td><%=rsTwo.getString("O_CATNAME")%></td>
                        <td><%=rsTwo.getString("O_QUANTITY")%>  X</td>
                        <td><%=String.format("$%,.2f", rsTwo.getDouble("S_PRICE"))%></td>
                        <td><%=String.format("$%,.2f", rsTwo.getDouble("O_FEE"))%></td>
                        <td><%=String.format("$%,.2f", rsTwo.getDouble("O_SHIPPING"))%></td>
                        <td><%=String.format("$%,.2f", rsTwo.getDouble("O_TOTAL"))%></td>
                    </tr>
                    <% } %>
            </table>
            <%

                if (isResultSetEmpty) {
            %>
            <h2>The database is empty</h2>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    try {
                        conn.rollback();
                    } catch (Exception re) {
                        re.printStackTrace();
                    }
                } finally {
                    // try to close the connection...
                    try {
                        // close the connection...
                        conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            %>
        </div>
    </div>
</div>

<jsp:include page="partials/footer.jsp" />
