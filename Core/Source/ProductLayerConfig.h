
// this is the URL for the endpoint server
#define PLY_ENDPOINT_URL [NSURL URLWithString:@"http://api.productlayer.com"]


// this is a prefix added before REST methods, e.g. for a version of the API
#define PLY_PATH_PREFIX @"v1-alpha"

// this is the api key which is needed in every api call. If the key is not present in the Header of the request you will get an error message.
#define PLY_API_KEY @"07db921b-2a45-4191-ba6c-1392e9d3b44d"


// Openshift
//#define PLY_ENDPOINT_URL [NSURL URLWithString:@"http://api-productlayer.rhcloud.com"]
//#define PLY_API_KEY @"4ddcef6b-3b15-4867-b435-82cfe244ce9d"

// Acer Aspire
//#define PLY_ENDPOINT_URL [NSURL URLWithString:@"http://192.168.178.34:28080"]
//#define PLY_API_KEY @"52ceabd7-433c-4c2f-b139-1f32db1964c3"