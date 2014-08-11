TMNetwork
=========

Simple networking 

TMNetwork is fairly similar to AFNetworking from a usage point of view.
It is neither as expansive or as tested as AFNetworking, and differs in a few significant ways.

1. The failure case decodes the response if it is decodable, and passes this into the failure block.
2. Installable general hooks for response codes using `[setHook:forStatusCode:]`.
3. Uses NSURLSessionTask convenience methods. This works for the scope of TMNetwork, and many "simple" projects, but it may not work for you

It is under heavy development at the moment.
