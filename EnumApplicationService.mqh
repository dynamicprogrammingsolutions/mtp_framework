//
enum ENUM_APPLICATION_SERVICE {
   srvNone,
#include "ServiceProviderBase\__services.mqh"
#ifdef CUSTOM_SERVICES
   CUSTOM_SERVICES
#endif
   srvLast
};