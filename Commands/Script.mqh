//
class CScript : public CAppObject
{
public:
   virtual int Type() const { return classScript; }
   
   TraitAppAccess

   static int Command;
   
   int id;
   long lparam;
   double dparam;
   string sparam;
   
   CScript()
   {
   }
   
   CScript(int _id, long _lparam, double _dparam, string _sparam)
   {
      id = _id;
      lparam = _lparam;
      dparam = _dparam;
      sparam = _sparam;
   }
};

int CScript::Command = 0;