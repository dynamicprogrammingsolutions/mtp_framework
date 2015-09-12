//
#include "..\AppObject.mqh"

class CSymbolInfoBase : public CAppObject
{
   public:
      virtual string Name() const { return NULL; }
      virtual bool Name(string name) { return false; }
};
