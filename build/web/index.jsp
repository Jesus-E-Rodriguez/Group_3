<%-- 
    Document   : index
    Created on : Mar 22, 2018, 7:54:02 PM
    Author     : Katie
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
        <title>Jazz Concert | Home</title>

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
                    <a class="navbar__content__brand--dark" href="#"><img src="img/jazz_grasp_logo.png" alt="Jazz Grasp Logo"></a>
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


        <div class="showcase--medium-screen-plus background display-flex align-items-center" id="background1">
            <div class="wrapper--unpadded">
                <h1>The show is about to begin!</h1>
                <p class="text--emphasize">Get ready Charlotte, North Carolina! The word renowned jazz band, 
                    Jazz Grasp is coming to Theatre Charlotte on April 13, 2018 at 7:30pm for a one time limited 
                    seating jazz concert that will blow you away. This is one performance you truly don't 
                    want to miss.
                </p>
                <a class="button button--primary-color" href="tickets.jsp">Order Now!</a>
            </div>
        </div>

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

