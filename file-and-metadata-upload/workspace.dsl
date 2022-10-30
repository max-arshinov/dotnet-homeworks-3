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
            api = container API {
                uploadFile = component "Upload File"
                uploadFile -> queue "File Uploaded" Message
                
                saveMetadata = component "Save Metadata"
                saveMetadata -> db "Saves Metadata"
                saveMetadata -> cache "Saves Metadata To Cache If File Is Not Available"                
            }       
            background = container Background {
                consumer = component "Consumer"
                queue -> consumer "File Uploaded" Messsage
                consumer -> db "Saves File Id"
                consumer -> s3.tempBucket "Moves Uploaded File From The Temp To Persistent Bucket"
                
                job = component "Job"
                job -> cache "Checks Uploaded File Id"                           
            }            
            spa = container SPA {
                uploadFileComponent = component "Upload File"
                uploadFileComponent -> api.uploadFile "Upload File"
                uploadFileComponent -> api.saveMetadata "Save File Metadata"
            }
        }
    }
    
    views {
        theme default
        dynamic system.spa {
            autolayout
            {
                system.spa.uploadFileComponent -> system.api.uploadFile "Sends Upload File Request"
                system.api.uploadFile -> system.s3.tempBucket "Saves File To The Temp Bucket"
                system.api.uploadFile -> system.cache "Saves Uploaded File Id"
                system.api.uploadFile -> system.queue "Sends \"File Uploaded\" Message To The  Queue"
                system.queue -> system.background.consumer "Receives \"File Uploaded\" Message From The  Queue"
                system.background.consumer -> system.db "Saves Metadata If Not Yet Saved"
            }
            {
                system.spa.uploadFileComponent -> system.api.saveMetadata "Sends Upload Metadata Request"
                system.api.saveMetadata -> system.cache "Checks File Id In Cache"
                system.api.saveMetadata -> system.db "Saves Metadata To DB If Uploaded File Id Is Available In Cache"
            }          
            {
                system.background.job -> system.s3.tempBucket "Moves Uploaded File From The Temp To Persistent Bucket If Metadata Is Already Saved"
                system.s3.tempBucket -> system.s3.persistentBucket "Moves Uploaded File From The Temp To Persistent Bucket If Metadata Is Already Saved"
            }
        }
        
        styles {
        }
    }
}