# AURIN OpenAPI: Tomcat OpenLayers example

To build, first put your Open API username and password into the [proxy configuration file](./src/main/webapp/WEB-INF/cgi/openapi.cfg). Install maven and use it to build a war file, for example on Ubuntu:

    sudo apt-get install maven
    mvn clean package

Put the generated war file into your tomcat webapps directory:

    sudo mv target/aurin-openapi.war /var/lib/tomcat7/webapps

The code is in [index.jsp](src/main/webapp/index.jsp).

This build requires the ability to run cgi scripts to run a simple python proxy to circumvent browser same-origin restrictions.  For example, to do this on an Ubuntu system, edit `/etc/tomcat7/web.xml` and uncomment the CGI processing servelet entry, which should look something like the below:

    <servlet>
        <servlet-name>cgi</servlet-name>
        <servlet-class>org.apache.catalina.servlets.CGIServlet</servlet-class>
        <init-param>
          <param-name>debug</param-name>
          <param-value>0</param-value>
        </init-param>
        <init-param>
          <param-name>cgiPathPrefix</param-name>
          <param-value>WEB-INF/cgi</param-value>
        </init-param>
         <load-on-startup>5</load-on-startup>
    </servlet>

And its servlet mapping:

    <servlet-mapping>
        <servlet-name>cgi</servlet-name>
        <url-pattern>/cgi-bin/*</url-pattern>
    </servlet-mapping>

Next, in the `/etc/tomcat7/context.xml` file, modify the `<Context>` opening tag from:

    <Context>

To:

    <Context reloadable="true" privileged="true">

Restart Tomcat and test that CGI scripts are working: [http://localhost:8080/aurin-openapi/cgi-bin/test.cgi](http://localhost:8080/aurin-openapi/cgi-bin/test.cgi)

You should now be able to open the example in your browser: [http://localhost:8080/aurin-openapi/](http://localhost:8080/aurin-openapi/).
