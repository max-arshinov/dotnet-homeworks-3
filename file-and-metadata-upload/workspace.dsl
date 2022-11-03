workspace "File and metadata upload"{
    !identifiers hierarchical

    model {
        system = softwaresystem "File/Metadata Storage" {
            db = container "Schemaless Database" "" MongoDB 
            cache = container Cache "" "Redis"
            queue = container Queue "" "RabbitMQ"        
            s3 = container S3 {
                tempBucket = component "Temp Bucket"
                persistentBucket = component "Persistent Bucket"                
                tempBucket -> persistentBucket
            }
            background = container Background {
                consumer = component "Consumer"
            }      
            api = container API {
                uploadFile = component "Upload File"
                uploadFile -> cache
                uploadFile -> background.consumer
                
                saveMetadata = component "Save Metadata"
                saveMetadata -> cache
                saveMetadata -> background.consumer
                
                signalR = component SignalR                
                queue -> signalR
            }       
      
            spa = container SPA {
                uploadFileComponent = component "Upload File"
                uploadFileComponent -> api.uploadFile
                uploadFileComponent -> api.saveMetadata
                api.signalR -> spa.uploadFileComponent
            }
        }
    }
    
    views {
        theme default
        dynamic system.spa {
            autolayout
            {
                system.spa.uploadFileComponent -> system.api.uploadFile "Sends Upload File Request With Request ID (GUID/UUID)"
                system.api.uploadFile -> system.s3.tempBucket "Saves File To The Temp Bucket"
                system.api.uploadFile -> system.cache "Saves File Id To Cache"
                system.api.uploadFile -> system.queue "Sends \"File Uploaded\" Message To The  Queue"
                system.queue -> system.background.consumer "Receives \"File Uploaded\" Message From The  Queue"
                system.background.consumer -> system.cache "Increments Request ID Key"
                system.background.consumer -> system.queue "If Cache[Request ID] == 2 Sends \"File & MetaData Uploaded\" Event" 
            }
            {
                system.spa.uploadFileComponent -> system.api.saveMetadata "Sends Upload Metadata Request With Request ID (GUID/UUID)"
                system.api.saveMetadata -> system.cache "Saves Metadata To Cache"
                system.api.saveMetadata -> system.queue "Sends \"File MetaData Uploaded\" Message To The  Queue"
                system.queue -> system.background.consumer "Receives \"File MetaData Uploaded\" Message From The  Queue"
                system.background.consumer -> system.cache "Increments Request ID Key"
                system.background.consumer -> system.queue "If Cache[Request ID] == 2 Sends \"File & MetaData Uploaded\" Event" 
            }          
            {
                system.queue -> system.background.consumer "Receives \"File & MetaData Uploaded\" Event"
                system.background.consumer -> system.s3.tempBucket "Sends Move \"File From The Temp To Persistent Bucket\" Request"
                system.s3.tempBucket -> system.s3.persistentBucket "Moves Uploaded File From The Temp To Persistent Bucket"
                system.background.consumer -> system.db "Saves Metadata And File Id To DB"
                system.background.consumer -> system.queue "Sends \"File Uploaded\" Event"
                system.queue -> system.api.signalR "Receives \"File Uploaded\" Event"
                system.api.signalR -> system.spa.uploadFileComponent "Notifies Frontend That Upload Is Finished"
            }
        } 
    }
}