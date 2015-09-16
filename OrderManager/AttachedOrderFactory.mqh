//
#include "..\Loader.mqh"
class CAttachedOrderFactory : public CFactoryInterface {
public:
   virtual int Type() const { return classAttachedOrderFactory; }
protected:
   virtual CAppObject* GetNewObject() { return new CAttachedOrder(); }
};