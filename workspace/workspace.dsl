workspace {
    !identifiers hierarchical

    model {
        group "Out of scope" {
            softwareSystem "Event-Driven Architecture" "" OutOfScope 
            softwareSystem "Big Data" "" OutOfScope 
            softwareSystem "Big Compute" "" OutOfScope
        }

        group "Monolith" {
            softwareSystem "N-tier MVC" "" Done {
                mvc = container MVC "ASP.NET Core" "" Web {
                    view = component View Razor Web
                    !include n-tier.dsl
                    
                    view -> auth
                    view -> controller
                }
                !include db.dsl

                mvc.orm -> db
            }

            softwareSystem "N-tier SPA" "" Done {
                !include spa-web.dsl
                api = container API "ASP.NET Core" {
                    !include n-tier.dsl
                }
                !include db.dsl

                spa -> api.controller
                api.orm -> db
            }

            softwareSystem "Vertical Slices SPA" {
                perspectives {
                    Implementation "DDD Strategic Patterns: Ubiquitous Languge, Bounded Context"
                    Tests "Integration Tests with WebApplicationFactory"
                }
  
                !include spa-web.dsl
                api = container API "ASP.NET Core" {                    
                    controller = component Controller
                    queryHandler = component "Query Handler" {
                        perspectives {
                            Implementation "Can bypass domain model due to performance considerations. Try to reuse Specications and EF Core Global Query Filters if possible"
                        }

                    }
                    commandHandler = component "Command Handler" {
                        perspectives {
                            Implementation "DDD Tactical Patterns: Entity, Value Object, Aggregate, Domain Event, Specification; EF Core Global Query Filters"
                            Tests "Unit Tests"
                        }
                    } 


                    orm = component ORM
                    mapper = component "Data Mapper" "Mapster/AutoMapper"
                    rawSql = component "Raw SQL" "Execute Query / Dapper" {
                        perspectives {
                            Implementation "Try to avoid it unless it's absolutely necessary"
                        }
                    }

                    # Query
                    controller -> queryHandler
                    queryHandler -> mapper
                    mapper -> orm
                    queryHandler -> rawSql

                    # Command
                    controller -> commandHandler
                    commandHandler -> orm
                }
                !include db.dsl

                spa -> api.controller
                api.orm -> db
                api.rawSql -> db           
            }
        }

        group Distributed {
            softwareSystem "Web-Queue-Worker: Fire & Forget" {
                web = container "Web App" "N-tier MVC, N-tier SPA, or Vertical Slices" "" "Web" {
                    massTransit = component "Mass Transit"
                }
                broker = container "Message Broker" "" "RabbitMQ/Kafka" Broker {
                    topic1 = component "Topic #1"
                    topic2 = component "Topic #2"
                    topicN = component "Topic #..."
                }
                worker = container "Worker" "Background Service and/or Serverless" "" Background
                !include db.dsl

                web.massTransit -> broker.topic1 "Pub"
                web.massTransit -> broker.topic2 "Pub"
                web.massTransit -> broker.topicN "Pub"
                
                worker -> broker.topic1 "Sub"
                worker -> broker.topic2 "Sub"
                worker -> broker.topicN "Sub"
                worker -> db
            }

            softwareSystem "Web-Queue-Worker: OperationId" {
                !include spa-web.dsl
                api = container "API" "" "" "Web" {
                    massTransit = component "Mass Transit"
                    signalRHub = component "SignalR Hub"
                    controller = component Controller "Pub"  
                    controller -> massTransit             
                }
                broker = container "Message Broker" "" "RabbitMQ/Kafka" Broker {
                    topic1 = component "Topic #1"
                    topic2 = component "Topic #2"
                    topicN = component "Topic #..."
                }
                worker = container "Worker" "Background Service and/or Serverless" "" Background {
                    signalRClient = component "SignalR client"
                }
                !include db.dsl

                spa -> api.signalRHub "Sub"
                spa -> api.controller "Sub Fallback"

                api.massTransit -> broker.topic1 "Pub"
                api.massTransit -> broker.topic2 "Pub"
                api.massTransit -> broker.topicN "Pub"
                
                worker -> broker.topic1 "Sub"
                worker -> broker.topic2 "Sub"
                worker -> broker.topicN "Sub"
                worker.signalRClient -> api.signalRHub "Pub"
                worker -> db
            }            

            softwareSystem "Microservices" {
              
            }
        }
    }

    views {
        !include styles.dsl
    }
}