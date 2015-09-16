//
enum ENUM_APPLICATION_SERVICE {
   srvNone,
#include "Interfaces\ServiceProviders\__services.mqh"
#ifdef CUSTOM_SERVICES
   CUSTOM_SERVICES
#endif
   srvLast
};