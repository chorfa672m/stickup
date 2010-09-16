(load "NuMarkup:xhtml")
(load "NuMongoDB")
(load "NuHTTPHelpers")

(get "/"
     (set mongo (NuMongoDB new))
     (set connected (mongo connectWithOptions:nil))
     (mongo authenticateUser:"stickup"
            withPassword:"stickup"
            forDatabase:"stickup")
     (set stickups (mongo findArray:nil
                          inCollection:"stickup.stickups"))
     (mongo close)
     (&html (&head)
            (&body (&h1 "Hello")
                   (&p "This is stickup.")
                   (&table
                          (&tr (&th "user")
                               (&th "time")
                               (&th "latitude")
                               (&th "longitude")
                               (&th "message"))
                          (stickups map:
                               (do (stickup)
                                   (&tr (&td (stickup user:))
                                        (&td ((stickup time:) description))
                                        (&td ((stickup location:) latitude:))
                                        (&td ((stickup location:) longitude:))
                                        (&td (stickup message:)))))))))
