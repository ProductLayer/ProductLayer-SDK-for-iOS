

#define PLYConfig [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ProductLayer"]

// this is the URL for the endpoint server
#define PLY_ENDPOINT_URL [NSURL URLWithString:[PLYConfig objectForKey:@"PLYAPIEndpoint"]]


// this is a prefix added before REST methods, e.g. for a version of the API
#define PLY_PATH_PREFIX [PLYConfig objectForKey:@"PLYAPIVersion"]

// this is the api key which is needed in every api call. If the key is not present in the Header of the request you will get an error message.
#define PLY_API_KEY [PLYConfig objectForKey:@"PLYAPIKey"]
