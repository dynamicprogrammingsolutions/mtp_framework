//
#include "Loader.mqh"

#define APPLICATION_INTERFACE_H
class CApplicationInterface : public CObject
{
public:
   virtual CServiceProvider* GetService(string name) { return NULL; }
   virtual CServiceProvider* GetService(ENUM_APPLICATION_SERVICE srv) { return NULL; }
};