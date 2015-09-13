//
#include "Loader.mqh"

class COrderFactory : public COrderFactoryBase {
   virtual COrderBaseBase* NewOrderObject() { return new COrder(); }
   virtual COrderBaseBase* NewAttachedOrderObject() { return new CAttachedOrder(); }
};