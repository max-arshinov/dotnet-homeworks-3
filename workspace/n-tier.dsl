auth = component Auth "" "ASP.NET Core Authentication"
controller = component Controller
service = component Service
orm = component ORM "" "EF Core"
identity = component Identity "" "Microsoft Identity"

auth -> identity
controller -> service
controller -> auth
service -> orm
orm -> identity