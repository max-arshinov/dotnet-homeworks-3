spa = container "SPA" "" "React" Web 
web = container "Web Application" "Delivers the static content and SPA" "ASP.NET Core"
web -> spa "Delivers to the customer's web browser"