//
#include "..\Loader.mqh"

class COrderFactory : public CFactoryInterface {
public:
   virtual int Type() const { return classOrderFactory; }
protected:
   virtual CAppObject* GetNewObject() { return new COrder(); }
};