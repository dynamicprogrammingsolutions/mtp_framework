//
class CApplicationInterface : public CAppObject
{
public:
   virtual void Command(CObject* command) { AbstractFunctionWarning(__FUNCTION__); }
   virtual void Event(CObject* event) { AbstractFunctionWarning(__FUNCTION__); }
   virtual CObject* GetService(string name) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual CObject* GetService(ENUM_APPLICATION_SERVICE srv) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
};