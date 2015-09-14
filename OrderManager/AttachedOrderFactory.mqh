//
#include "..\Loader.mqh"
class CAttachedOrderFactory : public CAttachedOrderFactoryBase {
public:
   virtual int Type() const { return classAttachedOrderFactory; }
protected:
   virtual CAppObject* GetNewObject() { return new CAttachedOrder(); }
};