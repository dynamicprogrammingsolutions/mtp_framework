//

enum ENUM_EVENT_TYPE {
   E_VERBOSE = 1,
   E_INFO = 2,
   E_NOTICE = 4,
   E_WARNING = 8, 
   E_ERROR = 16,
   E_DEBUG = 32,
};

class CEventLog : public CObject
{
public:
   virtual int Type() const { return classEventLog; }
   
   ENUM_EVENT_TYPE type;
   string message;
   string function;
};