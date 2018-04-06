<%-- 
    Document   : results
    Created on : Mar 24, 2018, 8:13:07 PM
    Author     : Sam
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ page language="java" import="java.util.*" errorPage="" %>
<html>
    <head>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

        <!-- Title -->
        <title>Jazz Concert | Query Results</title>

        <!-- Custom icons -->
        <link rel="stylesheet" href="css/font-awesome.css" />

        <!-- Custom CSS -->
        <link rel="stylesheet" href="css/styles.css" />
    </head>
    <body>
        <header class="background--dark">
            <!-- Navigation -->
            <nav class="wrapper--unpadded">
                <div class="navbar__content">
                    <a class="navbar__content__brand--dark" href="index.jsp"><img src="img/jazz_grasp_logo.png" alt="Jazz Grasp Logo"></a>
                    <ul class="navigation">
                        <li class="navigation__item">
                            <a class="navigation__item__link--dark" href="index.jsp">Home</a>
                        </li>
                        <li class="navigation__item">
                            <a class="navigation__item__link--dark" href="tickets.jsp">Order Tickets</a>
                        </li>
                        <li class="navigation__item">
                            <a class="navigation__item__link--dark" href="results.jsp">Results</a>
                        </li>
                    </ul>
                </div>
            </nav>
        </header>

        <%@page import="java.sql.*"%>

        <%
            Connection conn = null;
            ResultSet rsOne = null;
            ResultSet rsTwo = null;
            ResultSet rsThree = null;
            ResultSet rsFour = null;
            boolean isResultSetEmpty = true;
            PreparedStatement preparedStatementOne = null;
            PreparedStatement preparedStatementTwo = null;
            PreparedStatement preparedStatementThree = null;
            PreparedStatement preparedStatementFour = null;
            String driver = "org.apache.derby.jdbc.ClientDataSource";
            String url = "jdbc:derby://localhost:1527/Concert;user=app;password=password";

            try {

                Class.forName(driver).newInstance();
                conn = DriverManager.getConnection(url);

                // First query
                String queryOne = "SELECT S_CAT, S_SOLD FROM SEATS";
                preparedStatementOne = conn.prepareStatement(queryOne);
                rsOne = preparedStatementOne.executeQuery();

                // Second query
                String queryTwo = "SELECT S_CAT, SUM(75 - S_SOLD) AS S_SOLD FROM SEATS GROUP BY S_CAT";
                preparedStatementTwo = conn.prepareStatement(queryTwo);
                rsTwo = preparedStatementTwo.executeQuery();

                // Third query
                String queryThree = "SELECT S_CAT, S_TOTAL FROM SEATS";
                preparedStatementThree = conn.prepareStatement(queryThree);
                rsThree = preparedStatementThree.executeQuery();

                // Fourth and final query
                String queryFour = "SELECT SUM(S_TOTAL) AS S_TOTAL FROM SEATS";
                preparedStatementFour = conn.prepareStatement(queryFour);
                rsFour = preparedStatementFour.executeQuery();

        %>
        <main class="showcase--medium-screen-plus background background2">
            <div class="wrapper">
                <div class="box text--light">
                    <h1>Results of the query</h1>
                    <p class="text--emphasize">Tickets Sold Per Category</p>
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%     while (rsOne.next()) {
                                    //If we enter to the while, the ResultSet wasn't empty
                                    isResultSetEmpty = false;
                            %>
                            <tr>
                                <td><%=rsOne.getString("S_CAT")%></td>
                                <td><%=rsOne.getInt("S_SOLD")%></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <p class="text--emphasize">Tickets Available Per Category</p>
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                while (rsTwo.next()) {
                                    //If we enter to the while, the ResultSet wasn't empty
                                    isResultSetEmpty = false;
                            %>
                            <tr>
                                <td><%=rsTwo.getString("S_CAT")%></td>
                                <td><%=rsTwo.getInt("S_SOLD")%></td>
                            </tr>

                            <% } %>
                        </tbody>
                    </table>
                    <p class="text--emphasize">Sales Report</p>
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                while (rsThree.next()) {
                                    //If we enter to the while, the ResultSet wasn't empty
                                    isResultSetEmpty = false;

                            %>

                            <tr>
                                <td><%=rsThree.getString("S_CAT")%></td>
                                <td><%=String.format("$%,.2f", (rsThree.getDouble("S_TOTAL")))%></td>
                            </tr>
                            <%
                                }

                                while (rsFour.next()) {
                                    //If we enter to the while, the ResultSet wasn't empty
                                    isResultSetEmpty = false;

                            %>
                            <tr>
                                <td><strong>Category Total</strong></td>
                                <td><strong><%=String.format("$%,.2f", rsFour.getDouble("S_TOTAL"))%></strong></td>
                            </tr>		
                        </tbody>	
                    </table>
                    <%
                        }

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
        </main>

        <footer class="background--dark">
            <div class="wrapper--unpadded">
                <div class="grid--thirds">
                    <div class="grid--thirds__item">
                        <small>&copy; 2018 Jazz Grasp</small>
                    </div>
                    <div class="grid--thirds__item text--center">
                        <a href="http://validator.w3.org/check?uri=referer">HTML</a> | <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a>
                    </div>
                    <div class="grid--thirds__item text--right">
                        <ul class="social__icons">
                            <li class="social__icons__item"><a class="social__icons--dark" href="#"><i class="fa fa-facebook-official" aria-hidden="true"></i></a></li>
                            <li class="social__icons__item"><a class="social__icons--dark" href="#"><i class="fa fa-twitter" aria-hidden="true"></i></a></li>
                            <li class="social__icons__item"><a class="social__icons--dark" href="#"><i class="fa fa-instagram" aria-hidden="true"></i></a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </footer>  
    </body>
</html>
