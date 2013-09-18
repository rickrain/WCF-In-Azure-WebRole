WCF-In-Azure-WebRole
====================

Solution hosting a WCF Service in an Azure WebRole, with HTTP and TCP endpoints provisioned during startup.

To run:

1. Open with Visual Studio 2013.

2. Build the solution.

3. Publish to your Windows Azure Subscription.

4. Open the WCFTestClient and add a service using http://<yourservicename>cloudapp.net/calc.svc.


To secure the endpoints, run the New-CloudServiceSSLCert.ps1 script to generate a test certificate.  Full details on this and required application changes are here http://rickrainey.com/2013/09/18/securing-a-wcf-service-in-an-azure-web-role-with-http-tcp-endpoints-2/.
