//
#include <Object.mqh>

class CSymbolInfoBase : public CObject
{
   public:
      virtual string Name() const { return NULL; }
      virtual bool Name(string name) { return false; }
};
