//
class CApplicationInterface : public CAppObject
{
public:
   virtual CObject* GetService(string name) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
   virtual CObject* GetService(ENUM_APPLICATION_SERVICE srv) { AbstractFunctionWarning(__FUNCTION__); return NULL; }
};