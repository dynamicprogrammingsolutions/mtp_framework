//
class CScript : public CObject
{
public:
   int id;
   long lparam;
   double dparam;
   string sparam;
   
   static int Command;
  
   virtual int Type() const { return classScript; }
   
   CScript(int _id, long _lparam, double _dparam, string _sparam)
   {
      id = _id;
      lparam = _lparam;
      dparam = _dparam;
      sparam = _sparam;
   }
};

int CScript::Command = 0;