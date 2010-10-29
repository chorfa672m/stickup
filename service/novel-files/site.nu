(load "NuMarkup:xhtml")
(load "NuJSON")

(set STICKUP_FILE "stickups.json")
(set USERS_FILE "users.json")

(function load-stickups ()
     (set s (NSString stringWithContentsOfFile:STICKUP_FILE))
     (or (s JSONValue) (array)))

(function save-stickups ()
     ((STICKUPS JSONRepresentation) writeToFile:STICKUP_FILE atomically:NO))

(function load-users ()
     (set s (NSString stringWithContentsOfFile:USERS_FILE))
     (or (s JSONValue) (dict)))

(function save-users ()
     ((USERS JSONRepresentation) writeToFile:USERS_FILE atomically:NO))

(set STICKUPS (load-stickups))
(set USERS (load-users))

(get "/"
     (&html (&head)
            (&body (&h1 "Hello")
                   (&p "This is stickup.")
                   (&table
                          (&tr (&th "user")
                               (&th "time")
                               (&th "latitude")
                               (&th "longitude")
                               (&th "message"))
                          (STICKUPS map:
                               (do (stickup)
                                   (&tr (&td (stickup user:))
                                        (&td (stickup time:))
                                        (&td (stickup latitude:))
                                        (&td (stickup longitude:))
                                        (&td (stickup message:)))))))))

(post "/stickup"
      (set stickup (REQUEST post))
      (if (and (set user (stickup user:))
               (set password (stickup password:))
               (eq password (USERS user)))
          (then
               (stickup removeObjectForKey:"password")
               (stickup time:((NSDate date) description))
               (STICKUPS << stickup)
               (save-stickups)
               ((dict status:200 message:"Thank you.")
                JSONRepresentation))
          (else
               ((dict status:403 message:"Unable to post stickup.")
                JSONRepresentation))))

(get "/stickups"
     (puts ((REQUEST query) description))
     ((dict status:200 stickups:STICKUPS) JSONRepresentation))

(post "/signup"
      (set info (REQUEST post))
      (set user (info user:))
      (set password (info password:))
      ((cond ((eq user nil)
              (dict status:403 message:"Please specify a user"))
             ((eq password nil)
              (dict status:403 message:"Please specify a password"))
             ((USERS user)
              (dict status:403 message:"This user already exists."))
             (else
                  (USERS setObject:password forKey:user)
                  (save-users)
                  (dict status:200 message:(+ "Successfully registered " user "."))))
       JSONRepresentation))


